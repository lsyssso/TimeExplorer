"""
Reset message table and insert prepared historical messages.
This program is modified based on another assignment submission of mine
"""

import pg8000
import database

class SchemaCreator:
    conn = database.database_connect()
    def createSchema(self):
        try:
            curs = self.conn.cursor()
            curs.execute("DROP TABLE IF EXISTS message;")
            curs.execute("CREATE TABLE message\
                (fromDate timestamp not null, \
                 toDate timestamp not null, \
                 message VARCHAR(100) not null, \
                 selfie VARCHAR(100), \
                 cover VARCHAR(10), \
                 STAMP VARCHAR(8), \
                 msgtype int NOT NULL, \
                 messageId SERIAL primary key);")
            curs.execute("INSERT INTO MESSAGE (fromDate, toDate, message, cover, msgtype) values ('1940-05-30', current_timestamp, 'It is hard to believe the old milling building has turned into this beautiful Bank building\n\nBen', 'old', 1);")
            #curs.execute(
            #    "INSERT INTO MESSAGE (fromDate, toDate, message, cover, msgtype) values ('1923-12-21', current_timestamp, 'Did they literally move the entire facade from Commercial Banking Company to here?\n\nJason', 'old', 1);")
            #curs.execute(
            #    "INSERT INTO MESSAGE (fromDate, toDate, message, cover, msgtype) values ('1938-08-11', current_timestamp, 'Look at this new Commonwealth bank!\n\nJake', 'old', 1);")
            curs.execute(
                "INSERT INTO MESSAGE (fromDate, toDate, message, cover, msgtype) values ('1958-04-27', current_timestamp, 'Bank building now belongs to Pharmacy!\n\nJimmy', 'old', 1);")
            #curs.execute("INSERT INTO MESSAGE (fromDate, toDate, message, cover, msgtype) values ('1955-03-03', current_timestamp, 'A symbolic identical representation of the scientific precinct @Bank building\n\nHayden', 'old', 1);")
            #curs.execute(
            #    "INSERT INTO MESSAGE (fromDate, toDate, message, cover, msgtype) values ('1923-09-15', current_timestamp, 'So bad that the uni can''t afford new materials\n\nA hard working builder', 'old', 1);")

            self.conn.commit()
        except pg8000.DatabaseError as e:
            self.conn.rollback()
            print(e)
        finally:
            curs.close()
            self.conn.close()


creator = SchemaCreator()
creator.createSchema()
