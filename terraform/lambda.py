import os
import json
from datetime import datetime
from urllib.request import *

aggregator_url = "https://aggregator.bmltenabled.org/main_server/api/v1/rootservers"
slack_url = os.environ.get('SLACK_WEBHOOK')


def send_slack_alert(message_to_send, webhook_url):
    payload = {
        'channel': 'root-status',
        'username': 'aggregator-bot',
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
    if "STOPPED" not in task_state_detail["desiredStatus"]:
        return
    started_at = task_state_detail["startedAt"]
    started_at_dt = datetime.strptime(started_at, '%Y-%m-%dT%H:%M:%S.%fZ')
    started_at_ts = (started_at_dt - datetime(1970, 1, 1)).total_seconds()

    req = Request(url=aggregator_url, headers={}, method='GET')
    with urlopen(req) as res:
        body = res.read().decode()

    root_servers = json.loads(body)

    for root in root_servers:
        last_import_dt = datetime.strptime(root["lastSuccessfulImport"], '%Y-%m-%d %H:%M:%S')
        last_import_ts = (last_import_dt - datetime(1970, 1, 1)).total_seconds()
        last_import_formatted = last_import_dt.strftime("%d-%b-%Y (%H:%M:%S)")

        if last_import_ts < started_at_ts:
            print("Failed Import: ", root["name"])
            message = {"color": "#ff6600",
                       "fallback": "Aggregator Failed Import.",
                       "title": "Aggregator Failed Import",
                       "title_link": aggregator_url,
                       "footer": "BMLT-Enabled",
                       "footer_icon": "https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2018-12-26/512035188372_266e0f7e633d3b17af73_132.png",
                       "ts": datetime.utcnow().timestamp(),
                       "fields": [
                           {"title": "Root Server", "value": root["url"], "short": False},
                           {"title": "Last Import", "value": last_import_formatted, "short": True}
                       ]
                       }
            if slack_url:
                send_slack_alert(message, slack_url)
            else:
                print(message)
        else:
            print("Passed Import: ", root["name"])
