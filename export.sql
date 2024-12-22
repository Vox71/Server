\c online_store;


CREATE TABLE Categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT
);

CREATE TABLE Products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    category_id INTEGER REFERENCES Categories(id),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE Orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL
);

CREATE TABLE Order_Items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES Orders(id),
    product_id INTEGER REFERENCES Products(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0)
);

CREATE TABLE Cart (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL
);

CREATE TABLE Cart_Items (
    id SERIAL PRIMARY KEY,
    cart_id INTEGER REFERENCES Cart(id),
    product_id INTEGER REFERENCES Products(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0)
);


-- Функция на удаление из корзины
CREATE OR REPLACE FUNCTION cancel_cart(cart_id INTEGER)
RETURNS VOID AS $$
BEGIN
    DELETE FROM Cart_Items
    WHERE cart_id = cart_id;
END;
$$ LANGUAGE plpgsql;
-- SELECT cancel_cart(1); -- где 1 - id корзины

-- Получить свою корзину
-- CREATE FUNCTION get_user_cart(user_id INTEGER) RETURNS TABLE(cart_id INTEGER, product_id INTEGER, quantity INTEGER) AS $$
-- BEGIN
--     RETURN QUERY SELECT ci.cart_id, ci.product_id, ci.quantity
--     FROM Cart_Items ci
--     JOIN Carts c ON ci.cart_id = c.id
--     WHERE c.user_id = user_id;
-- END;
-- $$ LANGUAGE plpgsql;

----------------------------------------
CREATE ROLE customer WITH LOGIN PASSWORD 'customer_password';

GRANT EXECUTE ON FUNCTION cancel_cart(INTEGER) TO customer;

GRANT SELECT ON Products TO customer;
GRANT SELECT ON Categories TO customer;

REVOKE ALL ON Orders FROM customer;
REVOKE ALL ON Order_Items FROM customer;

ALTER TABLE Carts ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_cart_policy ON Carts
FOR SELECT USING (user_id = current_user_id()); -- user_id - это идентификатор, связанный с текущим пользователем

ALTER TABLE Cart_Items ENABLE ROW LEVEL SECURITY;

CREATE POLICY user_cart_items_policy ON Cart_Items
FOR SELECT USING (EXISTS (SELECT 1 FROM Carts WHERE Carts.id = cart_id AND Carts.user_id = current_user_id()));

-- Вставка тестовых категорий
INSERT INTO Categories (name, description) VALUES
('Electronics', 'Devices and gadgets'),
('Clothing', 'Apparel and accessories'),
('Books', 'Literature and textbooks'),
('Home & Kitchen', 'Household items and kitchen appliances');

-- Вставка тестовых продуктов
INSERT INTO Products (name, description, price, category_id, stock_quantity) VALUES
('Smartphone', 'Latest model smartphone with great features.', 699.99, 1, 50),
('Laptop', 'High-performance laptop for gaming and work.', 1099.99, 1, 30),
('T-shirt', 'Comfortable cotton t-shirt.', 19.99, 2, 100),
('Jeans', 'Stylish denim jeans.', 49.99, 2, 70),
('Fiction Book', 'An intriguing story of adventure and suspense.', 14.99, 3, 200),
('Cookbook', 'Delicious recipes from around the world.', 29.99, 3, 150),
('Blender', 'High-speed blender for smoothies and shakes.', 89.99, 4, 40),
('Coffee Maker', 'Brews the best coffee at home.', 49.99, 4, 60);

-- Вставка тестовых заказов
INSERT INTO Orders (user_id) VALUES
(1),
(2),
(3),
(1);

-- Вставка тестовых элементов заказов
INSERT INTO Order_Items (order_id, product_id, quantity) VALUES
(1, 1, 1), -- 1 Smartphone
(1, 2, 1),  -- 1 Jeans
(2, 3, 1),  -- 1 T-shirt
(3, 2, 1), -- 1 Laptop
(4, 6, 1);  -- 1 Cookbook

-- Вставка тестовых корзин
INSERT INTO Cart (user_id) VALUES
(1),
(2),
(3);

-- Вставка тестовых элементов корзины
INSERT INTO Cart_Items (cart_id, product_id, quantity) VALUES
(1, 1, 1), -- 1 Smartphone
(1, 5, 2), -- 2 Fiction Books
(2, 2, 1), -- 1 Laptop
(2, 3, 3), -- 3 T-shirts
(3, 4, 1), -- 1 Coffee Maker
(3, 7, 1); -- 1 Blender

INSERT INTO public.cart (user_id) VALUES
	 (1),
	 (2),
	 (3),
	 (0),
	 (4),
	 (5),
	 (6),
	 (7),
	 (8),
	 (9);
INSERT INTO public.cart (user_id) VALUES
	 (10),
	 (11),
	 (12),
	 (13),
	 (14),
	 (15),
	 (16),
	 (17),
	 (18),
	 (19);
INSERT INTO public.cart (user_id) VALUES
	 (20),
	 (21),
	 (22),
	 (23),
	 (24),
	 (25),
	 (26),
	 (27),
	 (28),
	 (29);
INSERT INTO public.cart (user_id) VALUES
	 (30),
	 (31),
	 (32),
	 (33),
	 (34),
	 (35),
	 (36),
	 (37),
	 (38),
	 (39);
INSERT INTO public.cart (user_id) VALUES
	 (40),
	 (41),
	 (42),
	 (43),
	 (44),
	 (45),
	 (46),
	 (47),
	 (48),
	 (49);
INSERT INTO public.cart (user_id) VALUES
	 (50),
	 (51),
	 (52),
	 (53),
	 (54),
	 (55),
	 (56),
	 (57),
	 (58),
	 (59);
INSERT INTO public.cart (user_id) VALUES
	 (60),
	 (61),
	 (62),
	 (63),
	 (64),
	 (65),
	 (66),
	 (67),
	 (68),
	 (69);
INSERT INTO public.cart (user_id) VALUES
	 (70),
	 (71),
	 (72),
	 (73),
	 (74),
	 (75),
	 (76),
	 (77),
	 (78),
	 (79);
INSERT INTO public.cart (user_id) VALUES
	 (80),
	 (81),
	 (82),
	 (83),
	 (84),
	 (85),
	 (86),
	 (87),
	 (88),
	 (89);
INSERT INTO public.cart (user_id) VALUES
	 (90),
	 (91),
	 (92),
	 (93),
	 (94),
	 (95),
	 (96),
	 (97),
	 (98),
	 (99);
INSERT INTO public.cart (user_id) VALUES
	 (100),
	 (101),
	 (102),
	 (103),
	 (104),
	 (105),
	 (106),
	 (107),
	 (108),
	 (109);
INSERT INTO public.cart (user_id) VALUES
	 (110),
	 (111),
	 (112),
	 (113),
	 (114),
	 (115),
	 (116),
	 (117),
	 (118),
	 (119);
INSERT INTO public.cart (user_id) VALUES
	 (120),
	 (121),
	 (122),
	 (123),
	 (124),
	 (125),
	 (126),
	 (127),
	 (128),
	 (129);
INSERT INTO public.cart (user_id) VALUES
	 (130),
	 (131),
	 (132),
	 (133),
	 (134),
	 (135),
	 (136),
	 (137),
	 (138),
	 (139);
INSERT INTO public.cart (user_id) VALUES
	 (140),
	 (141),
	 (142),
	 (143),
	 (144),
	 (145),
	 (146),
	 (147),
	 (148),
	 (149);
INSERT INTO public.cart (user_id) VALUES
	 (150),
	 (151),
	 (152),
	 (153),
	 (154),
	 (155),
	 (156),
	 (157),
	 (158),
	 (159);
INSERT INTO public.cart (user_id) VALUES
	 (160),
	 (161),
	 (162),
	 (163),
	 (164),
	 (165),
	 (166),
	 (167),
	 (168),
	 (169);
INSERT INTO public.cart (user_id) VALUES
	 (170),
	 (171),
	 (172),
	 (173),
	 (174),
	 (175),
	 (176),
	 (177),
	 (178),
	 (179);
INSERT INTO public.cart (user_id) VALUES
	 (180),
	 (181),
	 (182),
	 (183),
	 (184),
	 (185),
	 (186),
	 (187),
	 (188),
	 (189);
INSERT INTO public.cart (user_id) VALUES
	 (190),
	 (191),
	 (192),
	 (193),
	 (194),
	 (195),
	 (196),
	 (197),
	 (198),
	 (199);
INSERT INTO public.cart (user_id) VALUES
	 (200),
	 (201),
	 (202),
	 (203),
	 (204),
	 (205),
	 (206),
	 (207),
	 (208),
	 (209);
INSERT INTO public.cart (user_id) VALUES
	 (210),
	 (211),
	 (212),
	 (213),
	 (214),
	 (215),
	 (216),
	 (217),
	 (218),
	 (219);
INSERT INTO public.cart (user_id) VALUES
	 (220),
	 (221),
	 (222),
	 (223),
	 (224),
	 (278),
	 (306),
	 (438),
	 (459),
	 (526);
INSERT INTO public.cart (user_id) VALUES
	 (544),
	 (550),
	 (588),
	 (589),
	 (636),
	 (657),
	 (665),
	 (667),
	 (669),
	 (670);
INSERT INTO public.cart (user_id) VALUES
	 (688),
	 (689),
	 (692),
	 (693),
	 (715),
	 (742),
	 (225),
	 (226),
	 (227),
	 (228);
INSERT INTO public.cart (user_id) VALUES
	 (241),
	 (242),
	 (265),
	 (304),
	 (315),
	 (377),
	 (415),
	 (416),
	 (422),
	 (423);
INSERT INTO public.cart (user_id) VALUES
	 (484),
	 (511),
	 (619),
	 (620),
	 (635),
	 (731),
	 (732),
	 (853),
	 (861),
	 (885);
INSERT INTO public.cart (user_id) VALUES
	 (886),
	 (888),
	 (895),
	 (896),
	 (934),
	 (935),
	 (936),
	 (973),
	 (974),
	 (976);
INSERT INTO public.cart (user_id) VALUES
	 (229),
	 (277),
	 (286),
	 (290),
	 (312),
	 (313),
	 (364),
	 (397),
	 (421),
	 (490);
INSERT INTO public.cart (user_id) VALUES
	 (491),
	 (493),
	 (523),
	 (530),
	 (549),
	 (624),
	 (644),
	 (645),
	 (659),
	 (660);
INSERT INTO public.cart (user_id) VALUES
	 (685),
	 (785),
	 (786),
	 (796),
	 (801),
	 (802),
	 (806),
	 (817),
	 (851),
	 (956);
INSERT INTO public.cart (user_id) VALUES
	 (957),
	 (969),
	 (970),
	 (230),
	 (296),
	 (297),
	 (298),
	 (500),
	 (501),
	 (508);
INSERT INTO public.cart (user_id) VALUES
	 (541),
	 (542),
	 (628),
	 (634),
	 (646),
	 (718),
	 (752),
	 (797),
	 (798),
	 (814);
INSERT INTO public.cart (user_id) VALUES
	 (815),
	 (901),
	 (971),
	 (231),
	 (232),
	 (234),
	 (235),
	 (236),
	 (237),
	 (238);
INSERT INTO public.cart (user_id) VALUES
	 (339),
	 (342),
	 (343),
	 (455),
	 (475),
	 (514),
	 (519),
	 (546),
	 (548),
	 (552);
INSERT INTO public.cart (user_id) VALUES
	 (569),
	 (591),
	 (641),
	 (642),
	 (684),
	 (707),
	 (845),
	 (854),
	 (857),
	 (858);
INSERT INTO public.cart (user_id) VALUES
	 (862),
	 (913),
	 (914),
	 (915),
	 (952),
	 (953),
	 (954),
	 (233),
	 (314),
	 (327);
INSERT INTO public.cart (user_id) VALUES
	 (328),
	 (355),
	 (396),
	 (440),
	 (482),
	 (504),
	 (539),
	 (572),
	 (658),
	 (662);
INSERT INTO public.cart (user_id) VALUES
	 (664),
	 (711),
	 (753),
	 (771),
	 (800),
	 (809),
	 (874),
	 (875),
	 (876),
	 (987);
INSERT INTO public.cart (user_id) VALUES
	 (990),
	 (239),
	 (334),
	 (345),
	 (402),
	 (403),
	 (412),
	 (413),
	 (463),
	 (464);
INSERT INTO public.cart (user_id) VALUES
	 (469),
	 (470),
	 (479),
	 (524),
	 (527),
	 (529),
	 (578),
	 (580),
	 (585),
	 (592);
INSERT INTO public.cart (user_id) VALUES
	 (593),
	 (705),
	 (728),
	 (768),
	 (770),
	 (780),
	 (781),
	 (811),
	 (846),
	 (881);
INSERT INTO public.cart (user_id) VALUES
	 (882),
	 (883),
	 (991),
	 (1000),
	 (240),
	 (245),
	 (246),
	 (251),
	 (252),
	 (336);
INSERT INTO public.cart (user_id) VALUES
	 (337),
	 (366),
	 (367),
	 (433),
	 (565),
	 (579),
	 (586),
	 (587),
	 (614),
	 (615);
INSERT INTO public.cart (user_id) VALUES
	 (722),
	 (725),
	 (830),
	 (831),
	 (911),
	 (928),
	 (929),
	 (933),
	 (941),
	 (968);
INSERT INTO public.cart (user_id) VALUES
	 (243),
	 (271),
	 (350),
	 (365),
	 (430),
	 (431),
	 (434),
	 (435),
	 (477),
	 (494);
INSERT INTO public.cart (user_id) VALUES
	 (495),
	 (507),
	 (594),
	 (629),
	 (630),
	 (655),
	 (656),
	 (671),
	 (672),
	 (673);
INSERT INTO public.cart (user_id) VALUES
	 (681),
	 (682),
	 (699),
	 (820),
	 (821),
	 (828),
	 (904),
	 (905),
	 (906),
	 (948);
INSERT INTO public.cart (user_id) VALUES
	 (975),
	 (988),
	 (244),
	 (295),
	 (311),
	 (324),
	 (325),
	 (326),
	 (359),
	 (368);
INSERT INTO public.cart (user_id) VALUES
	 (369),
	 (370),
	 (371),
	 (395),
	 (409),
	 (410),
	 (411),
	 (424),
	 (432),
	 (515);
INSERT INTO public.cart (user_id) VALUES
	 (537),
	 (553),
	 (554),
	 (558),
	 (559),
	 (602),
	 (603),
	 (623),
	 (706),
	 (775);
INSERT INTO public.cart (user_id) VALUES
	 (835),
	 (909),
	 (910),
	 (944),
	 (247),
	 (248),
	 (309),
	 (310),
	 (354),
	 (401);
INSERT INTO public.cart (user_id) VALUES
	 (425),
	 (426),
	 (427),
	 (540),
	 (631),
	 (638),
	 (713),
	 (714),
	 (721),
	 (754);
INSERT INTO public.cart (user_id) VALUES
	 (767),
	 (788),
	 (826),
	 (827),
	 (829),
	 (834),
	 (871),
	 (872),
	 (873),
	 (986);
INSERT INTO public.cart (user_id) VALUES
	 (249),
	 (250),
	 (266),
	 (281),
	 (282),
	 (300),
	 (333),
	 (348),
	 (349),
	 (376);
INSERT INTO public.cart (user_id) VALUES
	 (389),
	 (390),
	 (391),
	 (392),
	 (460),
	 (461),
	 (465),
	 (466),
	 (595),
	 (625);
INSERT INTO public.cart (user_id) VALUES
	 (626),
	 (627),
	 (727),
	 (734),
	 (735),
	 (789),
	 (879),
	 (880),
	 (887),
	 (938);
INSERT INTO public.cart (user_id) VALUES
	 (253),
	 (254),
	 (267),
	 (316),
	 (318),
	 (319),
	 (428),
	 (467),
	 (468),
	 (487);
INSERT INTO public.cart (user_id) VALUES
	 (516),
	 (518),
	 (577),
	 (601),
	 (637),
	 (666),
	 (708),
	 (710),
	 (736),
	 (746);
INSERT INTO public.cart (user_id) VALUES
	 (747),
	 (764),
	 (765),
	 (766),
	 (777),
	 (778),
	 (799),
	 (807),
	 (855),
	 (856);
INSERT INTO public.cart (user_id) VALUES
	 (859),
	 (940),
	 (943),
	 (985),
	 (255),
	 (344),
	 (352),
	 (353),
	 (363),
	 (446);
INSERT INTO public.cart (user_id) VALUES
	 (447),
	 (448),
	 (485),
	 (531),
	 (532),
	 (557),
	 (560),
	 (561),
	 (566),
	 (567);
INSERT INTO public.cart (user_id) VALUES
	 (573),
	 (576),
	 (613),
	 (616),
	 (617),
	 (621),
	 (719),
	 (720),
	 (737),
	 (738);
INSERT INTO public.cart (user_id) VALUES
	 (744),
	 (772),
	 (805),
	 (863),
	 (864),
	 (917),
	 (939),
	 (256),
	 (264),
	 (284);
INSERT INTO public.cart (user_id) VALUES
	 (289),
	 (303),
	 (329),
	 (380),
	 (381),
	 (462),
	 (472),
	 (486),
	 (607),
	 (647);
INSERT INTO public.cart (user_id) VALUES
	 (648),
	 (686),
	 (687),
	 (709),
	 (790),
	 (803),
	 (816),
	 (840),
	 (955),
	 (257);
INSERT INTO public.cart (user_id) VALUES
	 (258),
	 (259),
	 (261),
	 (263),
	 (283),
	 (301),
	 (305),
	 (335),
	 (456),
	 (488);
INSERT INTO public.cart (user_id) VALUES
	 (489),
	 (538),
	 (547),
	 (555),
	 (556),
	 (581),
	 (622),
	 (632),
	 (633),
	 (643);
INSERT INTO public.cart (user_id) VALUES
	 (668),
	 (698),
	 (723),
	 (729),
	 (730),
	 (810),
	 (869),
	 (870),
	 (891),
	 (892);
INSERT INTO public.cart (user_id) VALUES
	 (949),
	 (992),
	 (995),
	 (996),
	 (260),
	 (262),
	 (439),
	 (441),
	 (492),
	 (509);
INSERT INTO public.cart (user_id) VALUES
	 (563),
	 (564),
	 (776),
	 (818),
	 (819),
	 (918),
	 (919),
	 (958),
	 (959),
	 (960);
INSERT INTO public.cart (user_id) VALUES
	 (964),
	 (965),
	 (979),
	 (980),
	 (997),
	 (268),
	 (276),
	 (279),
	 (280),
	 (299);
INSERT INTO public.cart (user_id) VALUES
	 (388),
	 (451),
	 (483),
	 (517),
	 (543),
	 (610),
	 (611),
	 (792),
	 (822),
	 (823);
INSERT INTO public.cart (user_id) VALUES
	 (916),
	 (924),
	 (925),
	 (926),
	 (927),
	 (932),
	 (269),
	 (285),
	 (506),
	 (520);
INSERT INTO public.cart (user_id) VALUES
	 (583),
	 (700),
	 (712),
	 (733),
	 (813),
	 (884),
	 (893),
	 (894),
	 (950),
	 (270);
INSERT INTO public.cart (user_id) VALUES
	 (275),
	 (340),
	 (341),
	 (347),
	 (382),
	 (393),
	 (394),
	 (417),
	 (418),
	 (419);
INSERT INTO public.cart (user_id) VALUES
	 (420),
	 (458),
	 (502),
	 (503),
	 (533),
	 (534),
	 (562),
	 (674),
	 (675),
	 (676);
INSERT INTO public.cart (user_id) VALUES
	 (791),
	 (832),
	 (833),
	 (842),
	 (843),
	 (844),
	 (889),
	 (989),
	 (993),
	 (994);
INSERT INTO public.cart (user_id) VALUES
	 (999),
	 (272),
	 (273),
	 (274),
	 (287),
	 (288),
	 (291),
	 (292),
	 (293),
	 (294);
INSERT INTO public.cart (user_id) VALUES
	 (330),
	 (331),
	 (332),
	 (372),
	 (414),
	 (436),
	 (437),
	 (444),
	 (445),
	 (450);
INSERT INTO public.cart (user_id) VALUES
	 (478),
	 (521),
	 (522),
	 (568),
	 (574),
	 (575),
	 (612),
	 (677),
	 (750),
	 (751);
INSERT INTO public.cart (user_id) VALUES
	 (793),
	 (865),
	 (866),
	 (867),
	 (868),
	 (899),
	 (903),
	 (937),
	 (302),
	 (358);
INSERT INTO public.cart (user_id) VALUES
	 (404),
	 (405),
	 (429),
	 (442),
	 (443),
	 (454),
	 (496),
	 (497),
	 (498),
	 (499);
INSERT INTO public.cart (user_id) VALUES
	 (608),
	 (609),
	 (743),
	 (748),
	 (749),
	 (769),
	 (824),
	 (825),
	 (877),
	 (897);
INSERT INTO public.cart (user_id) VALUES
	 (307),
	 (308),
	 (373),
	 (385),
	 (386),
	 (387),
	 (449),
	 (473),
	 (476),
	 (510);
INSERT INTO public.cart (user_id) VALUES
	 (525),
	 (545),
	 (551),
	 (596),
	 (597),
	 (598),
	 (599),
	 (600),
	 (604),
	 (605);
INSERT INTO public.cart (user_id) VALUES
	 (618),
	 (649),
	 (650),
	 (678),
	 (690),
	 (691),
	 (696),
	 (697),
	 (779),
	 (782);
INSERT INTO public.cart (user_id) VALUES
	 (794),
	 (795),
	 (852),
	 (878),
	 (890),
	 (984),
	 (317),
	 (356),
	 (357),
	 (398);
INSERT INTO public.cart (user_id) VALUES
	 (399),
	 (400),
	 (570),
	 (571),
	 (683),
	 (694),
	 (695),
	 (724),
	 (726),
	 (739);
INSERT INTO public.cart (user_id) VALUES
	 (740),
	 (741),
	 (745),
	 (755),
	 (756),
	 (757),
	 (758),
	 (759),
	 (760),
	 (761);
INSERT INTO public.cart (user_id) VALUES
	 (762),
	 (763),
	 (804),
	 (836),
	 (837),
	 (838),
	 (839),
	 (841),
	 (849),
	 (850);
INSERT INTO public.cart (user_id) VALUES
	 (907),
	 (908),
	 (912),
	 (951),
	 (320),
	 (321),
	 (322),
	 (323),
	 (338),
	 (351);
INSERT INTO public.cart (user_id) VALUES
	 (362),
	 (378),
	 (379),
	 (406),
	 (407),
	 (408),
	 (452),
	 (471),
	 (474),
	 (480);
INSERT INTO public.cart (user_id) VALUES
	 (512),
	 (513),
	 (582),
	 (584),
	 (606),
	 (898),
	 (900),
	 (902),
	 (962),
	 (963);
INSERT INTO public.cart (user_id) VALUES
	 (977),
	 (998),
	 (346),
	 (360),
	 (361),
	 (374),
	 (375),
	 (453),
	 (457),
	 (481);
INSERT INTO public.cart (user_id) VALUES
	 (535),
	 (536),
	 (590),
	 (651),
	 (652),
	 (653),
	 (654),
	 (661),
	 (663),
	 (679);
INSERT INTO public.cart (user_id) VALUES
	 (680),
	 (783),
	 (784),
	 (787),
	 (847),
	 (848),
	 (860),
	 (920),
	 (921),
	 (922);
INSERT INTO public.cart (user_id) VALUES
	 (923),
	 (930),
	 (931),
	 (942),
	 (972),
	 (978),
	 (383),
	 (384),
	 (505),
	 (528);
INSERT INTO public.cart (user_id) VALUES
	 (639),
	 (640),
	 (701),
	 (702),
	 (703),
	 (704),
	 (716),
	 (717),
	 (773),
	 (774);
INSERT INTO public.cart (user_id) VALUES
	 (808),
	 (812),
	 (945),
	 (946),
	 (947),
	 (961),
	 (966),
	 (967),
	 (981),
	 (982);
INSERT INTO public.cart (user_id) VALUES
	 (983);
