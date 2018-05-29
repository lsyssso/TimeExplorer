from http.server import BaseHTTPRequestHandler, HTTPServer
import pg8000
import database
import json

def all_messages():
    output = None
    try:
        conn = database.database_connect()
        cur = conn.cursor()
        print("FETCHING ALL MESSAGES...")
        cur.execute("SELECT * FROM MESSAGE ORDER BY TODATE DESC;")
        results = cur.fetchall()
        #print(results)

        messages = [{
            'messageId': str(row[7]),
            'fromDate': str(row[0]),
            'toDate': str(row[1]),
            'message': str(row[2]),
            'selfie': str(row[3]),
            'cover': str(row[4]),
            'stamp': str(row[5]),
            'msgtype': str(row[6])
        } for row in results]
        for i in range(len(messages)):
            messages[i] = json.dumps(messages[i])

        print("processing output")
        output = '\n'.join(messages)
        #print(output)
        cur.close()
    except pg8000.DatabaseError:
        print("FAILED TO FETCH MESSAGES")
    finally:
        conn.close()
        return output

def insert_message(message):
    conn = database.database_connect()
    cur = conn.cursor()
    result = ""
    try:
        fromDate = message["fromDate"]
        toDate = message["toDate"]
        content = message["message"]
        selfie = message["selfie"]
        cover = message["cover"]
        stamp = message["stamp"]
        msgType = message["type"]
        conn = database.database_connect()
        cur = conn.cursor()
        print("INSERTING MESSAGE...")
        cur.execute("INSERT INTO MESSAGE VALUES(%s, %s, %s, %s, %s, %s, %s);", (fromDate, toDate, content, selfie, cover, stamp, msgType))
        conn.commit()
        result = "Success"
    except Exception as e:
        print(str(e))
        conn.rollback()
        result = "Failed"
    finally:
        conn.close()
        return result

class S(BaseHTTPRequestHandler):
    def _set_headers(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()

    def do_GET(self):
        self._set_headers()
        self.wfile.write(bytes(all_messages(), "UTF-8"))

    def do_HEAD(self):
        self._set_headers()

    def do_POST(self):
        # Doesn't do anything with posted data
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        content_length = int(self.headers['Content-Length'])  # <--- Gets the size of data
        post_data = self.rfile.read(content_length)  # <--- Gets the data itself
        #print(post_data)
        post_message = json.loads(post_data.decode('utf-8'))
        self._set_headers()
        self.wfile.write(bytes(insert_message(post_message), "UTF-8"))

    def do_OPTIONS(self):
        self.send_response(200, "ok")
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()


def run(server_class=HTTPServer, handler_class=S, port=8082):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print('Starting httpd...')
    httpd.serve_forever()


if __name__ == "__main__":
    from sys import argv

    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()