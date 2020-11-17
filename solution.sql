CREATE TABLE users(
	userId INTEGER,
	age INTEGER,
	PRIMARY KEY(userId)
);

CREATE TABLE items(
	itemId INTEGER,
	price NUMERIC,
	PRIMARY KEY(itemId)
);

CREATE TABLE purchases(
	purchaseId INTEGER,
	userId INTEGER,
	itemId INTEGER,
	date DATE,
	PRIMARY KEY(purchaseId),
	FOREIGN KEY(userId) REFERENCES users(userId),
	FOREIGN KEY(itemId) REFERENCES items(itemId)
);


INSERT INTO users VALUES(0, 17);
INSERT INTO users VALUES(1, 18);
INSERT INTO users VALUES(2, 25);
INSERT INTO users VALUES(3, 26);
INSERT INTO users VALUES(4, 35);
INSERT INTO users VALUES(5, 36);
INSERT INTO users VALUES(6, 37);
INSERT INTO users VALUES(7, 14);
INSERT INTO users VALUES(8, 17);
INSERT INTO users VALUES(9, 23);
INSERT INTO users VALUES(10, 25);
INSERT INTO users VALUES(11, 39);
INSERT INTO users VALUES(12, 49);

INSERT INTO items VALUES(0, 100);
INSERT INTO items VALUES(1, 99999);
INSERT INTO items VALUES(2, 837);
INSERT INTO items VALUES(3, 45);
INSERT INTO items VALUES(4, 71);
INSERT INTO items VALUES(5, 229);
INSERT INTO items VALUES(6, 37);
INSERT INTO items VALUES(7, 39);
INSERT INTO items VALUES(8, 452);
INSERT INTO items VALUES(9, 641);
INSERT INTO items VALUES(10, 37);
INSERT INTO items VALUES(11, 4.99);
INSERT INTO items VALUES(12, 499);

INSERT INTO purchases VALUES(0, 11, 1, '01.05.2019');
INSERT INTO purchases VALUES(1, 11, 2, '26.06.2019');
INSERT INTO purchases VALUES(2, 11, 2, '11.06.2019');
INSERT INTO purchases VALUES(3, 11, 9, '29.12.2019');
INSERT INTO purchases VALUES(4, 11, 9, '12.01.2020');
INSERT INTO purchases VALUES(5, 11, 12, '26.01.2020');
INSERT INTO purchases VALUES(6, 4, 1, '01.01.2018');
INSERT INTO purchases VALUES(7, 4, 5, '16.02.2019');
INSERT INTO purchases VALUES(8, 4, 5, '05.05.2019');
INSERT INTO purchases VALUES(9, 4, 12, '11.11.2019');
INSERT INTO purchases VALUES(10, 9, 2, '01.04.2019');
INSERT INTO purchases VALUES(11, 9, 2, '01.05.2019');
INSERT INTO purchases VALUES(12, 9, 9, '01.06.2019');
INSERT INTO purchases VALUES(13, 9, 12, '17.08.2019');
INSERT INTO purchases VALUES(14, 0, 2, '14.07.2019');
INSERT INTO purchases VALUES(15, 0, 3, '22.11.2019');
INSERT INTO purchases VALUES(16, 0, 5, '05.11.2019');
INSERT INTO purchases VALUES(17, 2, 3, '06.11.2019');
INSERT INTO purchases VALUES(18, 2, 4, '05.01.2020');
INSERT INTO purchases VALUES(19, 2, 9, '29.01.2020');
INSERT INTO purchases VALUES(20, 5, 3, '27.02.2019');
INSERT INTO purchases VALUES(21, 5, 3, '07.04.2019');
INSERT INTO purchases VALUES(22, 5, 6, '07.04.2019');
INSERT INTO purchases VALUES(23, 5, 10, '11.09.2019');
INSERT INTO purchases VALUES(24, 6, 3, '11.03.2018');
INSERT INTO purchases VALUES(25, 6, 3, '17.01.2020');
INSERT INTO purchases VALUES(26, 6, 3, '03.05.2019');
INSERT INTO purchases VALUES(27, 6, 3, '03.05.2019');
INSERT INTO purchases VALUES(28, 6, 6, '03.05.2019');
INSERT INTO purchases VALUES(29, 6, 7, '03.05.2019');
INSERT INTO purchases VALUES(30, 6, 7, '07.09.2019');
INSERT INTO purchases VALUES(31, 6, 7, '02.03.2020');
INSERT INTO purchases VALUES(32, 3, 4, '21.12.2018');
INSERT INTO purchases VALUES(33, 3, 10, '21.12.2018');
INSERT INTO purchases VALUES(34, 3, 10, '19.07.2018');
INSERT INTO purchases VALUES(35, 3, 11, '25.10.2018');
INSERT INTO purchases VALUES(36, 10, 11, '19.11.2018');


-- 1.1
with avg_sum as(
	select date_trunc('month', purchases.date), sum(items.price) as val
	from purchases
	join users on(users.userId=purchases.userId)
	join items on(purchases.itemId=items.itemId)
	where users.age between 18 and 25
	group by date_trunc('month', purchases.date)
)
select avg(val) from avg_sum

-- 1.2
with avg_sum as(
	select date_trunc('month', purchases.date), sum(items.price) as val
	from purchases
	join users on(users.userId=purchases.userId)
	join items on(purchases.itemId=items.itemId)
	where users.age between 26 and 35
	group by date_trunc('month', purchases.date)
)
select avg(val) from avg_sum

-- 2
with proceeds as(
	select date_trunc('month', purchases.date) as trunc_month, sum(items.price) as val
	from purchases
	join users on(users.userId=purchases.userId)
	join items on(purchases.itemId=items.itemId)
	where users.age>=35
	group by date_trunc('month', purchases.date)
)
select trunc_month from proceeds where proceeds.val=(select max(val) from proceeds)

-- 3
with proceeds as(
	select purchases.itemId, sum(price) as val
	from purchases
	join items on (purchases.itemId=items.itemId)
	where extract('year' from date)=(select max(extract('year' from date)) from purchases)
	group by purchases.itemId
)
select itemId from proceeds where proceeds.val=(select max(val) from proceeds)

-- 4
with proceeds as(
	select purchases.itemId, sum(price) as val
	from purchases
	join items on (purchases.itemId=items.itemId)
	where extract('year' from date)=(select max(extract('year' from date)) from purchases)
	group by purchases.itemId
	order by val desc
)
select itemId, val/(select sum(val) from proceeds) from proceeds limit 3


