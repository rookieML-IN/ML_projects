import scrapy
from datetime import date
from ..items import AutoReportItem
import csv


class GenspiderSpider(scrapy.Spider):
    name = 'repo'
    allowed_domains = ['https://www.worldometers.info/coronavirus/country/india']
    start_urls = ['https://www.worldometers.info/coronavirus/country/india']
    output = 'daily_cov.csv'

    def parse(self, response):
        items = AutoReportItem()

        tot_cases = response.xpath('//*[@id="maincounter-wrap"]/div/span/text()')[0].extract()
        tot_deaths = response.xpath('//*[@id="maincounter-wrap"]/div/span/text()')[1].extract()
        tot_recov = response.xpath('//*[@id="maincounter-wrap"]/div/span/text()')[2].extract()
        scrp_date = str(date.today())

        items['scrp_date'] = scrp_date
        items['tot_cases'] = tot_cases
        items['tot_deaths'] = tot_deaths
        items['tot_recov'] = tot_recov

        with open(self.output, "a", newline="") as f:
            writer = csv.writer(f)
            Scrap_Date = scrp_date
            Tot_cases = tot_cases
            Tot_deaths = tot_deaths
            Tot_recov = tot_recov

            writer.writerow([Scrap_Date, Tot_cases, Tot_deaths, Tot_recov])
            yield {'Scrap_Date': scrp_date, 'Total Cases': tot_cases, 'Total Deaths':tot_deaths,
                   'Total Recoveries': tot_recov}

        yield items

