# Load required tilt extensions

load('ext://helm_resource', 'helm_resource')
load('ext://uibutton', 'cmd_button', 'location')

# ----- Load Configuration from config.yaml -----

configFile = read_yaml('./config.yaml')

# ----- Global Variables -----

# Set to True to enable clustering
# TODO add support for DBStore for DocLib and Elasticsearch
config.define_string("replicas")

cfg = config.parse()
liferay_replicas = cfg.get(
	"replicas", configFile.get('dxp').get('replicas'))

# ----- MySQL -----

helm_resource(
	name='mysql',
	chart='oci://registry-1.docker.io/bitnamicharts/mysql',
	flags=[
		'--set=auth.database=lportal',
		'--set=auth.username=lportal',
		'--set=auth.password=lportal',
		'--set=primary.persistentVolumeClaimRetentionPolicy.enabled=true',
		'--set=primary.persistentVolumeClaimRetentionPolicy.whenScaled=Delete',
		'--set=primary.persistentVolumeClaimRetentionPolicy.whenDeleted=Delete',
	],
	labels='mysql',
)

# ----- DXP -----

docker_build(
	ref='liferay-tilt/dxp',
	context='./dxp-docker-root',
	dockerfile_contents='''
FROM %s

COPY --chown=liferay:liferay deploy /opt/liferay/deploy
COPY portal-ext.properties /opt/liferay/portal-ext.properties
COPY osgi/configs /opt/liferay/osgi/configs
COPY osgi/log4j /opt/liferay/osgi/log4j
COPY unicast.xml /opt/liferay/unicast.xml
''' % (configFile.get('dxp').get('image')),
)

helm_resource(
	name='dxp',
	chart='./charts/dxp',
	deps=[
		'./charts/dxp',
	],
	flags=[
		'--set=image=liferay-tilt/dxp',
		'--set=replicas=%s' % configFile.get(
			'dxp').get('replicas'),
	],
	image_deps=['liferay-tilt/dxp'],
	image_keys=['image'],
	resource_deps=[
		'mysql',
	],
	labels='dxp',
)

# ----- Test Resources -----

test_resources_yaml = helm(
	'test-resources',
	name='test-resources',
)

k8s_yaml(test_resources_yaml)

k8s_resource(
	auto_init=False,
	labels='test-resources',
	objects=[
		'liferaysamplebatchserviceid-liferay.com-lxc-ext-provision-metadata:configmap',
		'liferaysampleiframe1-liferay.com-lxc-ext-provision-metadata:configmap',
	],
	new_name='test-resources',
	resource_deps=['dxp'],
)

# ----- Nuke Data -----

local_resource(
	name='drop-database',
	cmd='./drop-database.sh',
	cmd_bat='./drop-database.cmd',
	trigger_mode=TRIGGER_MODE_MANUAL,
	auto_init=False,
	resource_deps=[
		'mysql',
		'dxp',
	],
	labels='z-drop-database'
)
