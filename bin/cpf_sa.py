#!/usr/bin/env python
# coding=utf-8

'''计算每年应该 top up SA 多少钱，使得 SA 在 55 岁转成 RA 时，余额能达到 FRS
假设 SA 是在年底 top up，在次年1月1日时，根据本年底余额付息
ref: https://www.cpf.gov.sg/member/faq/retirement-income/general-information-on-retirement/what-are-the-retirement-sums-applicable-to-me-

My output:

55 age year = 2041, frs of the year = 351502.2
At the end of year 2022, balance is 12.0K
At the end of year 2023, after deposit 11700, balance comes to 24.3K
...
At the end of year 2040, after deposit 11700, balance comes to 337.6K
At the beginning of year 2041, balance comes to 351.7K
'''

curr_frs = [float(x) * 1000 for x in [166, 171, 176, 181, 186, 192, 198.8, 205.8, 213, 220.4, 228.2]]
start_year = 2017
rate = 1.04
extra_rate = 1.05
extra_quota = 60000


def main():
    curr_year = 2022
    curr_balance = 4000 + 8000
    years = 19 # 55 - 36
    deposit_everyyear = 11700

    end_year = curr_year + years
    end_year_frs = ((curr_frs[-1] / curr_frs[0])**2) * curr_frs[end_year - 20 - start_year]
    print('55 age year = %d, frs of the year = %.1f' % (end_year, end_year_frs))

    y = 0
    print('At the end of year %d, balance is %.1fK' % (curr_year + y, curr_balance / 1000.0))
    for y in range(1, years):
        if curr_balance > extra_quota:
            curr_balance = curr_balance * rate + extra_quota * (extra_rate - rate)
        else:
            curr_balance = curr_balance * extra_rate
        curr_balance += deposit_everyyear
        print('At the end of year %d, after deposit %d, balance comes to %.1fK' % (curr_year + y, deposit_everyyear, curr_balance / 1000.0))
    y += 1
    curr_balance = curr_balance * rate + extra_quota * (extra_rate - rate)
    print('At the beginning of year %d, balance comes to %.1fK' % (curr_year + y, curr_balance / 1000.0))


if __name__ == '__main__':
    main()
