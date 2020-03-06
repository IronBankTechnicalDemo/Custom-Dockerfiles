#!/usr/bin/python3

import os

from entrypoint_helpers import env, gen_cfg, gen_container_id, str2bool, start_app


RUN_USER = env['run_user']
RUN_GROUP = env['run_group']
JIRA_INSTALL_DIR = env['jira_install_dir']
JIRA_HOME = env['jira_home']
BASE_INSTALL_DIR = env['base_install_dir']

gen_container_id()
if os.stat('/etc/container_id').st_size == 0:
    gen_cfg('container_id.j2', '/etc/container_id', user=RUN_USER, group=RUN_GROUP, overwrite=True)
gen_cfg('server.xml.j2', f'{JIRA_INSTALL_DIR}/conf/server.xml', user=RUN_USER, group=RUN_GROUP, overwrite=True)
gen_cfg('dbconfig.xml.j2', f'{JIRA_HOME}/dbconfig.xml', user=RUN_USER, group=RUN_GROUP, overwrite=False)
if str2bool(env.get('clustered')):
    gen_cfg('cluster.properties.j2', f'{JIRA_HOME}/cluster.properties', user=RUN_USER, group=RUN_GROUP, overwrite=False)

os.system(f'/bin/sh {BASE_INSTALL_DIR}/entrypoint/entry.sh')
start_app(f'{JIRA_INSTALL_DIR}/bin/start-jira.sh -fg', JIRA_HOME, name='Jira')
