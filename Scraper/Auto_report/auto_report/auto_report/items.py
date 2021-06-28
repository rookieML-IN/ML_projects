# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


class AutoReportItem(scrapy.Item):
    scrp_date = scrapy.Field()
    tot_cases = scrapy.Field()
    tot_deaths = scrapy.Field()
    tot_recov = scrapy.Field()
