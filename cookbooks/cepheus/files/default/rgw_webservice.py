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
import flask
import json
import os
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

    def create_user(self, user, display_name):
        log.debug("User: %s, %s" % (user, display_name))
        return 'create_user'


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

        # result must be a dictionary or jsonify will likely explode
        # if not type(result) == dict:
        #     raise Exception('func passed to flaskify must return dict')
    except Exception, e:
        log.error(e.message)

    return result


@app.route('/')
def help():
    return flask.render_template('rgw_webservice_help.html')


@app.route('/v1/user/create/<user>/<display_name>', methods=['PUT'])
def rgw_create_user(user, display_name):
    api = RGWWebServiceAPI()

    # Getting parameters
    # user = request.args.get('user')
    # Json example
    # flask.jsonify(data_dict)

    return flaskify(api.create_user, user, display_name)


if __name__ == '__main__':
    app.run()
