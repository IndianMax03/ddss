insert into films values (nextval('films_id_seq'), 'человек паук', 'фильм про человека паука в скафандре');
insert into reviews values (nextval('reviews_id_seq'), currval('films_id_seq'), 'прекрасный фильм мне очень даже понравился скофандор', 5);
insert into reviews values (nextval('reviews_id_seq'), currval('films_id_seq'), 'блин мне очень не понравился скофандор', 3);

insert into films values (nextval('films_id_seq'), 'бедмен', 'фильм про бедмена в бидоне');
insert into reviews values (nextval('reviews_id_seq'), currval('films_id_seq'), 'бидоны улет!', 5);
insert into reviews values (nextval('reviews_id_seq'), currval('films_id_seq'), 'мама не разрешила сходить', 1);
