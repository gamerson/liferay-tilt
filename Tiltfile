# Load required tilt extensions

load('ext://helm_resource', 'helm_resource')
load('ext://uibutton', 'cmd_button', 'location')

# ----- Global Variables -----

# Set to True to enable clustering
# TODO add support for DBStore for DocLib and Elasticsearch

config.define_string('domainBase')
DOMAIN_BASE_DEFAULT='localtest.me'

config.define_string('dxpDockerTag')
DXP_DOCKER_TAG_DEFAULT='liferay/dxp:latest'

config.define_string('mysqlVolumePolicy')
MYSQL_VOLUME_POLICY_DEFAULT='Retain'

config.define_string('replicas')
REPLICAS_DEFAULT='1'

cfg = config.parse()

# ----- MySQL -----

helm_resource(
	name='mysql',
	chart='oci://registry-1.docker.io/bitnamicharts/mysql',
	flags=[
		'--set=primary.persistentVolumeClaimRetentionPolicy.whenDeleted=%s'
			% cfg.get('mysqlVolumePolicy', MYSQL_VOLUME_POLICY_DEFAULT),
		'-f',
		'%s/charts/mysql/values.yaml' % os.getcwd(),
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
COPY --chown=liferay:liferay osgi /opt/liferay/osgi
COPY --chown=liferay:liferay portal-ext.properties /opt/liferay/portal-ext.properties
COPY --chown=liferay:liferay tomcat /opt/liferay/tomcat
COPY --chown=liferay:liferay unicast.xml /opt/liferay/unicast.xml
''' % (cfg.get('dxpDockerTag', DXP_DOCKER_TAG_DEFAULT)),
)

helm_resource(
	name='dxp',
	chart='./charts/dxp',
	deps=[
		'./charts/dxp',
	],
	flags=[
		'--set=image=liferay-tilt/dxp',
		'--set=replicas=%s' % cfg.get('replicas', REPLICAS_DEFAULT),
		'--set=domainBase=%s' % cfg.get('domainBase', DOMAIN_BASE_DEFAULT),
	],
	image_deps=['liferay-tilt/dxp'],
	image_keys=['image'],
	resource_deps=[
		'mysql',
	],
	labels='dxp',
)

# ----- Test Resources -----

helm_resource(
	name='test-resources',
	chart='./test-resources',
	deps=[
		'./test-resources',
	],
	flags=[
		'--set=domainBase=%s' % cfg.get('domainBase', DOMAIN_BASE_DEFAULT),
	],
	resource_deps=[
		'dxp',
	],
	labels='test-resources',
)