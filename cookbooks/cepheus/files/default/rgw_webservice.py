#!/usr/bin/env python
#
# Author: Chris Jones <chris.jones@lambdastack.io>
# Copyright 2017, LambdaStack
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import logging
import logging.handlers
import subprocess
import json
import os
import flask
from flask import request

# NB: Setup Logging
log = logging.getLogger(__name__)
log.setLevel(logging.DEBUG)
# handler = logging.handlers.SysLogHandler(address = '/dev/log')
handler = logging.handlers.TimedRotatingFileHandler('/var/log/rgw_webservice/rgw_webservice.log', when='midnight', backupCount=5)
formatter = logging.Formatter('%(module)s.%(funcName)s: %(message)s')
handler.setFormatter(formatter)
log.addHandler(handler)

app = flask.Flask(__name__)

# NB: Use flask.jsonify in the methods/functions that return json and not globally

class RGWWebServiceAPI(object):
    def __init__(self):
        # Setup admin user info here
        pass

    def user_create(self, user, display_name, region=None, zone=None, access_key=None, secret_key=None, zone_region_prefix="client.radosgw"):
        log.debug("User: %s, %s" % (user, display_name))

        cmd = ["/usr/bin/radosgw-admin", "user", "create", "--conf", "/etc/ceph/ceph.conf", "--uid", "%s" % user, "--display-name", "%s" % display_name]
        if region is not None and zone is not None:
            cmd.append("-n")
            # NB: This should match '[client.radosgw...]' or something similar found in ceph.conf for the RGW section
            cmd.append("%s.%s-%s" % (zone_region_prefix, region, zone))

        if access_key is not None:
            cmd.append("--access-key")
            cmd.append("%s" % access_key)

        if secret_key is not None:
            # Newer versions of radosgw-admin support --secret-key too
            cmd.append("--secret")
            cmd.append("%s" % secret_key)

        return call(cmd)

# NB: Expects JSON returned
def call(cmd):
    # log.debug(' '.join([str(x) for x in cmd]))
    process = subprocess.Popen(cmd, env=os.environ.copy(), stdout=subprocess.PIPE)
    json_output, err = process.communicate()
    if err:
        log.error(err)
        return None

    # log.debug(json_output)

    return json_output


def flaskify(func, *args, **kwargs):
    result = ''
    """
    Wraps Flask response generation so that the underlying worker
    functions can be invoked without a Flask application context.

    :param func: function to invoke
    :param *args: any arguments to pass to the func
    :param **kwargs: any keyword arguments to pass to func

    :returns: Flask response object
    """
    try:
        result = func(*args, **kwargs)
    except Exception, e:
        log.error(e)

    return result


@app.route('/')
def help():
    return flask.render_template('rgw_webservice_help.html')


@app.route('/v1/users/create/<user>/<display_name>', methods=['PUT'])
def rgw_users_create(user, display_name):
    api = RGWWebServiceAPI()

    # Getting parameters
    # user = request.args.get('user')
    # Json example
    # flask.jsonify(data_dict)

    return flaskify(api.user_create, user, display_name)


@app.route('/v1/users/get/<user>', methods=['GET'])
def rgw_users_get(user):
    api = RGWWebServiceAPI()
    return flaskify(api.user_get, user)


if __name__ == '__main__':
    app.run()
