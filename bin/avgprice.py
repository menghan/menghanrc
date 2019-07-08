#!/usr/bin/env python
# coding=utf-8

import sys
lines = map(str.strip, sys.stdin)
records = []
for line in lines:
    date, price, amount = line.split('\t')[:3]
    records.append({
        'date': date,
        'price': float(price.split('/')[1]),
        'index': int(price.split('/')[0]),
        'amount': float(amount) * 10000,
    })

shares = 0
current_amount = 0.0
for record in records:
    current_amount += record['amount']
    shares += int(record['amount'] / record['price'])
    avgprice = current_amount / shares
    avgindex = avgprice * record['index'] / record['price']
    print 'until %s\n\tYou have %d shares (%.2f) on average price %.4f est index %d\n\tYou earn %.2f' % (record['date'], shares, shares * record['price'], avgprice, avgindex, shares * (record['price'] - avgprice))
