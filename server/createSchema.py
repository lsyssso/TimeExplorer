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
            #curs.execute("INSERT INTO MESSAGE (fromDate, toDate, message, cover, msgtype) values ('2018-05-25', current_timestamp, 'Greeting from yesterday!\n\nSiyang', 'Pink', 0);")
            #curs.execute("INSERT INTO MESSAGE (fromDate, toDate, message, cover, msgtype) values ('2018-03-03', current_timestamp, 'an envelope with selfie sticker...\n', 'selfie', 0);")
            #curs.execute("INSERT INTO MESSAGE (fromDate, toDate, message, cover, msgtype) values ('2017-05-22', current_timestamp, 'Greeting from 2017!\n\nUnknown', 'cbc001', 2);")
            #curs.execute("INSERT INTO MESSAGE (fromDate, toDate, message, cover, msgtype) values ('1924-02-03', current_timestamp, 'Isn''t this commercial banking company?\n\nJack', 'old', 1);")
            self.conn.commit()
        except pg8000.DatabaseError as e:
            self.conn.rollback()
            print(e)
        finally:
            curs.close()
            self.conn.close()


creator = SchemaCreator()
creator.createSchema()
