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

import flask
import json
import os
from flask import request

app = flask.Flask(__name__)

class RGWWebServiceAPI(object):
    def __init__(self):
        # Setup admin user info here
        pass

    def create_user(self, user, display_name):
        print "User: %s, %s" % (user, display_name)
        # Return dict


def flaskify(func, *args, **kwargs):
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
        if not type(result) == dict:
            raise Exception('func passed to flaskify must return dict')
    except Exception, e:
        print e.message

    return flask.jsonify(result)


@app.route('/')
def help():
    return flask.render_template('rgw_webservice_help.html')


@app.route('/v1/user/create/<user>/<display_name>', methods=['GET'])
def rgw_create_user(user, display_name):
    api = RGWWebServiceAPI()

    # Remove after debug
    print 'API Created...'

    # Getting parameters
    # user = request.args.get('user')
    # flask.jsonify(api.create_user(user, display_name))
    return flaskify(api.create_user, user, display_name)


if __name__ == '__main__':
    app.run()
