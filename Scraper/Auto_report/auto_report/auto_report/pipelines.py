# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://docs.scrapy.org/en/latest/topics/item-pipeline.html


# useful for handling different item types with a single interface
from itemadapter import ItemAdapter

import sqlite3 as sq

class AutoReportPipeline:

    def __init__(self):
        self.create_connection()
        #self.create_table()

    def create_connection(self):
        self.conn = sq.connect('cov.db')
        self.curr = self.conn.cursor()

    # def create_table(self):
    #     self.curr.execute(""" DROP TABLE IF EXISTS  cov_daily_fig""")
    #     self.curr.execute(""" create table cov_daily_fig(scrp_date text,tot_cases int,tot_deaths int,tot_recov int)""")

    def process_item(self, item, spider):
        self.store_db(item)
        return item

    def store_db(self, item):
        self.curr.execute("""
                    insert into cov_daily_fig values(
                    ?,?,?,?) """, (
            item['scrp_date'],
            item['tot_cases'],
            item['tot_deaths'],
            item['tot_recov']
        ))
        self.conn.commit()


