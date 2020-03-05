import os
import json
from datetime import datetime
from urllib.request import *

tomato_url = "https://tomato.bmltenabled.org/rest/v1/rootservers/"
slack_url = os.environ.get('SLACK_WEBHOOK')


def send_slack_alert(message_to_send, webhook_url):
    payload = {
        'channel': 'test-hook',
        'username': 'tomato-bot',
        'text': '',
        'icon_emoji': ':tomato:',
        "attachments": [message_to_send]
    }

    req = Request(url=webhook_url,
                  data=json.dumps(payload).encode(),
                  headers={'Content-Type': 'application/json'},
                  method='POST')
    with urlopen(req) as res:
        body = res.read().decode()
        print(body)


def lambda_handler(event, context):
    task_state_detail = event["detail"]
    if "STOPPED" in task_state_detail["desiredStatus"]:
        started_at = task_state_detail["startedAt"]
        started_at_dt = datetime.strptime(started_at, '%Y-%m-%dT%H:%M:%S.%fZ')
        started_at_ts = (started_at_dt - datetime(1970, 1, 1)).total_seconds()

        req = Request(url=tomato_url, headers={}, method='GET')
        with urlopen(req) as res:
            body = res.read().decode()

        root_servers = json.loads(body)

        for i in root_servers:
            last_import_dt = datetime.strptime(i["last_successful_import"], '%Y-%m-%dT%H:%M:%S.%fZ')
            last_import_ts = (last_import_dt - datetime(1970, 1, 1)).total_seconds()
            last_import_formatted = last_import_dt.strftime("%d-%b-%Y (%H:%M:%S)")

            if last_import_ts < started_at_ts:
                print("Failed Import: ", i["name"])
                message = {"color": "#ff6600",
                           "fallback": "Tomato Failed Import.",
                           "title": "Tomato Failed Import",
                           "title_link": "https://tomato.na-bmlt.org/rest/v1/rootservers/",
                           "footer": "BMLT-Enabled",
                           "footer_icon": "https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2018-12-26/512035188372_266e0f7e633d3b17af73_132.png",
                           "ts": datetime.utcnow().timestamp(),
                           "fields": [
                               {"title": "Root Server", "value": i["root_server_url"], "short": False},
                               {"title": "Last Import", "value": last_import_formatted, "short": True}
                           ]
                           }
                if slack_url is not None and slack_url != "":
                    send_slack_alert(message, slack_url)
                else:
                    print(message)
    else:
        return
