-- kill other connections
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'fishing_stories' AND pid <> pg_backend_pid();
-- (re)create the database
DROP DATABASE IF EXISTS fishing_stories;
CREATE DATABASE fishing_stories;
-- connect via psql
\c fishing_stories

--
-- PostgreSQL database dump
--

-- Dumped from database version 14.1
-- Dumped by pg_dump version 14.1

-- Started on 2022-06-28 05:25:01 UTC

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 244 (class 1255 OID 27794)
-- Name: curr_min_distance(numeric, numeric); Type: FUNCTION; Schema: public; Owner: fishing_stories
--

CREATE FUNCTION public.curr_min_distance(lat numeric, lon numeric) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE url_id INTEGER;
BEGIN
	WITH distances AS (
	SELECT u.id as u_id, 3963 * ACOS(SIN(gp.latitude) * SIN($1) + COS(gp.latitude) * COS($1) * COS($2 - gp.longitude)) AS dist FROM data_urls u
	INNER JOIN global_positions gp
	ON u.global_position_id = gp.id WHERE u.data_type = 'current'
	) SELECT u_id FROM distances WHERE dist = (SELECT MIN(dist) FROM distances) INTO url_id;
	RETURN url_id;
END;
$_$;


ALTER FUNCTION public.curr_min_distance(lat numeric, lon numeric) OWNER TO fishing_stories;

--
-- TOC entry 243 (class 1255 OID 27617)
-- Name: find_nearest_curr(); Type: FUNCTION; Schema: public; Owner: fishing_stories
--

CREATE FUNCTION public.find_nearest_curr() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE url_id INTEGER;
DECLARE lat NUMERIC;
DECLARE lon NUMERIC;
BEGIN
	 
 	SELECT gp.latitude, gp.longitude FROM global_positions gp
 	WHERE NEW.global_position_id = gp.id INTO lat, lon;
 	SELECT * FROM curr_min_distance(lat, lon) INTO url_id;
 	NEW.current_url_id = url_id;
 	RETURN NEW;
END;
$$;


ALTER FUNCTION public.find_nearest_curr() OWNER TO fishing_stories;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 221 (class 1259 OID 26541)
-- Name: account_privileges; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.account_privileges (
    account_type_id integer NOT NULL,
    privilege_id integer NOT NULL
);


ALTER TABLE public.account_privileges OWNER TO fishing_stories;

--
-- TOC entry 210 (class 1259 OID 26467)
-- Name: account_types; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.account_types (
    id integer NOT NULL,
    name character varying NOT NULL,
    price numeric NOT NULL
);


ALTER TABLE public.account_types OWNER TO fishing_stories;

--
-- TOC entry 209 (class 1259 OID 26466)
-- Name: account_types_id_seq; Type: SEQUENCE; Schema: public; Owner: fishing_stories
--

CREATE SEQUENCE public.account_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_types_id_seq OWNER TO fishing_stories;

--
-- TOC entry 3529 (class 0 OID 0)
-- Dependencies: 209
-- Name: account_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fishing_stories
--

ALTER SEQUENCE public.account_types_id_seq OWNED BY public.account_types.id;


--
-- TOC entry 230 (class 1259 OID 26673)
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO fishing_stories;

--
-- TOC entry 239 (class 1259 OID 27491)
-- Name: angler_baits; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.angler_baits (
    angler_id integer NOT NULL,
    bait_id integer NOT NULL
);


ALTER TABLE public.angler_baits OWNER TO fishing_stories;

--
-- TOC entry 240 (class 1259 OID 27506)
-- Name: angler_fishing_spots; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.angler_fishing_spots (
    angler_id integer NOT NULL,
    fishing_spot_id integer NOT NULL
);


ALTER TABLE public.angler_fishing_spots OWNER TO fishing_stories;

--
-- TOC entry 241 (class 1259 OID 27521)
-- Name: angler_gear; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.angler_gear (
    angler_id integer NOT NULL,
    fishing_gear_id integer NOT NULL
);


ALTER TABLE public.angler_gear OWNER TO fishing_stories;

--
-- TOC entry 242 (class 1259 OID 27568)
-- Name: angler_outings; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.angler_outings (
    angler_id integer NOT NULL,
    fishing_outing_id integer NOT NULL
);


ALTER TABLE public.angler_outings OWNER TO fishing_stories;

--
-- TOC entry 223 (class 1259 OID 26557)
-- Name: anglers; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.anglers (
    id integer NOT NULL,
    name character varying(30) NOT NULL,
    rank_id integer NOT NULL
);


ALTER TABLE public.anglers OWNER TO fishing_stories;

--
-- TOC entry 222 (class 1259 OID 26556)
-- Name: anglers_id_seq; Type: SEQUENCE; Schema: public; Owner: fishing_stories
--

CREATE SEQUENCE public.anglers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.anglers_id_seq OWNER TO fishing_stories;

--
-- TOC entry 3530 (class 0 OID 0)
-- Dependencies: 222
-- Name: anglers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fishing_stories
--

ALTER SEQUENCE public.anglers_id_seq OWNED BY public.anglers.id;


--
-- TOC entry 212 (class 1259 OID 26478)
-- Name: baits; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.baits (
    id integer NOT NULL,
    name character varying NOT NULL,
    artificial boolean NOT NULL,
    size numeric,
    color character varying,
    description character varying
);


ALTER TABLE public.baits OWNER TO fishing_stories;

--
-- TOC entry 211 (class 1259 OID 26477)
-- Name: baits_id_seq; Type: SEQUENCE; Schema: public; Owner: fishing_stories
--

CREATE SEQUENCE public.baits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.baits_id_seq OWNER TO fishing_stories;

--
-- TOC entry 3531 (class 0 OID 0)
-- Dependencies: 211
-- Name: baits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fishing_stories
--

ALTER SEQUENCE public.baits_id_seq OWNED BY public.baits.id;


--
-- TOC entry 236 (class 1259 OID 26909)
-- Name: current_stations; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.current_stations (
    id integer NOT NULL,
    name character varying(280) NOT NULL,
    global_position_id integer NOT NULL
);


ALTER TABLE public.current_stations OWNER TO fishing_stories;

--
-- TOC entry 235 (class 1259 OID 26908)
-- Name: current_stations_id_seq; Type: SEQUENCE; Schema: public; Owner: fishing_stories
--

CREATE SEQUENCE public.current_stations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.current_stations_id_seq OWNER TO fishing_stories;

--
-- TOC entry 3532 (class 0 OID 0)
-- Dependencies: 235
-- Name: current_stations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fishing_stories
--

ALTER SEQUENCE public.current_stations_id_seq OWNED BY public.current_stations.id;


--
-- TOC entry 234 (class 1259 OID 26836)
-- Name: data_urls; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.data_urls (
    id integer NOT NULL,
    url character varying NOT NULL,
    global_position_id integer NOT NULL,
    data_type character varying(8) NOT NULL
);


ALTER TABLE public.data_urls OWNER TO fishing_stories;

--
-- TOC entry 233 (class 1259 OID 26835)
-- Name: data_urls_id_seq; Type: SEQUENCE; Schema: public; Owner: fishing_stories
--

CREATE SEQUENCE public.data_urls_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.data_urls_id_seq OWNER TO fishing_stories;

--
-- TOC entry 3533 (class 0 OID 0)
-- Dependencies: 233
-- Name: data_urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fishing_stories
--

ALTER SEQUENCE public.data_urls_id_seq OWNED BY public.data_urls.id;


--
-- TOC entry 225 (class 1259 OID 26586)
-- Name: fishes; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.fishes (
    id integer NOT NULL,
    species character varying NOT NULL,
    weight numeric,
    length numeric,
    description character varying,
    image bytea,
    date_time_caught timestamp without time zone NOT NULL,
    angler_id integer NOT NULL,
    fishing_spot_id integer NOT NULL,
    bait_id integer NOT NULL,
    gear_id integer
);


ALTER TABLE public.fishes OWNER TO fishing_stories;

--
-- TOC entry 224 (class 1259 OID 26585)
-- Name: fishes_id_seq; Type: SEQUENCE; Schema: public; Owner: fishing_stories
--

CREATE SEQUENCE public.fishes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fishes_id_seq OWNER TO fishing_stories;

--
-- TOC entry 3534 (class 0 OID 0)
-- Dependencies: 224
-- Name: fishes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fishing_stories
--

ALTER SEQUENCE public.fishes_id_seq OWNED BY public.fishes.id;


--
-- TOC entry 227 (class 1259 OID 26610)
-- Name: fishing_conditions; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.fishing_conditions (
    id integer NOT NULL,
    weather character varying NOT NULL,
    tide_phase character varying NOT NULL,
    time_stamp timestamp without time zone NOT NULL,
    current_flow character varying,
    current_speed numeric,
    moon_phase character varying(20),
    wind_direction character varying(3),
    wind_speed integer,
    pressure_yesterday numeric,
    pressure_today numeric
);


ALTER TABLE public.fishing_conditions OWNER TO fishing_stories;

--
-- TOC entry 226 (class 1259 OID 26609)
-- Name: fishing_conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: fishing_stories
--

CREATE SEQUENCE public.fishing_conditions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fishing_conditions_id_seq OWNER TO fishing_stories;

--
-- TOC entry 3535 (class 0 OID 0)
-- Dependencies: 226
-- Name: fishing_conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fishing_stories
--

ALTER SEQUENCE public.fishing_conditions_id_seq OWNED BY public.fishing_conditions.id;


--
-- TOC entry 214 (class 1259 OID 26489)
-- Name: fishing_gear; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.fishing_gear (
    id integer NOT NULL,
    rod character varying NOT NULL,
    reel character varying,
    line character varying,
    hook character varying,
    leader character varying
);


ALTER TABLE public.fishing_gear OWNER TO fishing_stories;

--
-- TOC entry 213 (class 1259 OID 26488)
-- Name: fishing_gear_id_seq; Type: SEQUENCE; Schema: public; Owner: fishing_stories
--

CREATE SEQUENCE public.fishing_gear_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fishing_gear_id_seq OWNER TO fishing_stories;

--
-- TOC entry 3536 (class 0 OID 0)
-- Dependencies: 213
-- Name: fishing_gear_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fishing_stories
--

ALTER SEQUENCE public.fishing_gear_id_seq OWNED BY public.fishing_gear.id;


--
-- TOC entry 216 (class 1259 OID 26498)
-- Name: fishing_outings; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.fishing_outings (
    id integer NOT NULL,
    name character varying(280) NOT NULL,
    outing_date date NOT NULL,
    fishing_spot_id integer NOT NULL,
    fishing_conditions_id integer NOT NULL
);


ALTER TABLE public.fishing_outings OWNER TO fishing_stories;

--
-- TOC entry 215 (class 1259 OID 26497)
-- Name: fishing_outings_id_seq; Type: SEQUENCE; Schema: public; Owner: fishing_stories
--

CREATE SEQUENCE public.fishing_outings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fishing_outings_id_seq OWNER TO fishing_stories;

--
-- TOC entry 3537 (class 0 OID 0)
-- Dependencies: 215
-- Name: fishing_outings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fishing_stories
--

ALTER SEQUENCE public.fishing_outings_id_seq OWNED BY public.fishing_outings.id;


--
-- TOC entry 232 (class 1259 OID 26824)
-- Name: fishing_spots; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.fishing_spots (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    nickname character varying,
    is_public boolean NOT NULL,
    global_position_id integer NOT NULL,
    current_url_id integer
);


ALTER TABLE public.fishing_spots OWNER TO fishing_stories;

--
-- TOC entry 231 (class 1259 OID 26823)
-- Name: fishing_spots_id_seq; Type: SEQUENCE; Schema: public; Owner: fishing_stories
--

CREATE SEQUENCE public.fishing_spots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fishing_spots_id_seq OWNER TO fishing_stories;

--
-- TOC entry 3538 (class 0 OID 0)
-- Dependencies: 231
-- Name: fishing_spots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fishing_stories
--

ALTER SEQUENCE public.fishing_spots_id_seq OWNED BY public.fishing_spots.id;


--
-- TOC entry 238 (class 1259 OID 26970)
-- Name: global_positions; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.global_positions (
    id integer NOT NULL,
    latitude numeric NOT NULL,
    longitude numeric NOT NULL
);


ALTER TABLE public.global_positions OWNER TO fishing_stories;

--
-- TOC entry 237 (class 1259 OID 26969)
-- Name: global_positions_id_seq; Type: SEQUENCE; Schema: public; Owner: fishing_stories
--

CREATE SEQUENCE public.global_positions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.global_positions_id_seq OWNER TO fishing_stories;

--
-- TOC entry 3539 (class 0 OID 0)
-- Dependencies: 237
-- Name: global_positions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fishing_stories
--

ALTER SEQUENCE public.global_positions_id_seq OWNED BY public.global_positions.id;


--
-- TOC entry 218 (class 1259 OID 26518)
-- Name: privileges; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.privileges (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.privileges OWNER TO fishing_stories;

--
-- TOC entry 217 (class 1259 OID 26517)
-- Name: privileges_id_seq; Type: SEQUENCE; Schema: public; Owner: fishing_stories
--

CREATE SEQUENCE public.privileges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.privileges_id_seq OWNER TO fishing_stories;

--
-- TOC entry 3540 (class 0 OID 0)
-- Dependencies: 217
-- Name: privileges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fishing_stories
--

ALTER SEQUENCE public.privileges_id_seq OWNED BY public.privileges.id;


--
-- TOC entry 220 (class 1259 OID 26529)
-- Name: ranks; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.ranks (
    id integer NOT NULL,
    name character varying NOT NULL,
    rank_number integer NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE public.ranks OWNER TO fishing_stories;

--
-- TOC entry 219 (class 1259 OID 26528)
-- Name: ranks_id_seq; Type: SEQUENCE; Schema: public; Owner: fishing_stories
--

CREATE SEQUENCE public.ranks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ranks_id_seq OWNER TO fishing_stories;

--
-- TOC entry 3541 (class 0 OID 0)
-- Dependencies: 219
-- Name: ranks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fishing_stories
--

ALTER SEQUENCE public.ranks_id_seq OWNED BY public.ranks.id;


--
-- TOC entry 229 (class 1259 OID 26654)
-- Name: user_accounts; Type: TABLE; Schema: public; Owner: fishing_stories
--

CREATE TABLE public.user_accounts (
    id integer NOT NULL,
    username character varying(30) NOT NULL,
    password character varying(256) NOT NULL,
    account_type_id integer NOT NULL,
    angler_id integer,
    email character varying(280)
);


ALTER TABLE public.user_accounts OWNER TO fishing_stories;

--
-- TOC entry 228 (class 1259 OID 26653)
-- Name: user_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: fishing_stories
--

CREATE SEQUENCE public.user_accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_accounts_id_seq OWNER TO fishing_stories;

--
-- TOC entry 3542 (class 0 OID 0)
-- Dependencies: 228
-- Name: user_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fishing_stories
--

ALTER SEQUENCE public.user_accounts_id_seq OWNED BY public.user_accounts.id;


--
-- TOC entry 3257 (class 2604 OID 27870)
-- Name: account_types id; Type: DEFAULT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.account_types ALTER COLUMN id SET DEFAULT nextval('public.account_types_id_seq'::regclass);


--
-- TOC entry 3263 (class 2604 OID 27871)
-- Name: anglers id; Type: DEFAULT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.anglers ALTER COLUMN id SET DEFAULT nextval('public.anglers_id_seq'::regclass);


--
-- TOC entry 3258 (class 2604 OID 27872)
-- Name: baits id; Type: DEFAULT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.baits ALTER COLUMN id SET DEFAULT nextval('public.baits_id_seq'::regclass);


--
-- TOC entry 3269 (class 2604 OID 27873)
-- Name: current_stations id; Type: DEFAULT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.current_stations ALTER COLUMN id SET DEFAULT nextval('public.current_stations_id_seq'::regclass);


--
-- TOC entry 3268 (class 2604 OID 27874)
-- Name: data_urls id; Type: DEFAULT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.data_urls ALTER COLUMN id SET DEFAULT nextval('public.data_urls_id_seq'::regclass);


--
-- TOC entry 3264 (class 2604 OID 27875)
-- Name: fishes id; Type: DEFAULT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.fishes ALTER COLUMN id SET DEFAULT nextval('public.fishes_id_seq'::regclass);


--
-- TOC entry 3265 (class 2604 OID 27876)
-- Name: fishing_conditions id; Type: DEFAULT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.fishing_conditions ALTER COLUMN id SET DEFAULT nextval('public.fishing_conditions_id_seq'::regclass);


--
-- TOC entry 3259 (class 2604 OID 27877)
-- Name: fishing_gear id; Type: DEFAULT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.fishing_gear ALTER COLUMN id SET DEFAULT nextval('public.fishing_gear_id_seq'::regclass);


--
-- TOC entry 3260 (class 2604 OID 27878)
-- Name: fishing_outings id; Type: DEFAULT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.fishing_outings ALTER COLUMN id SET DEFAULT nextval('public.fishing_outings_id_seq'::regclass);


--
-- TOC entry 3267 (class 2604 OID 27879)
-- Name: fishing_spots id; Type: DEFAULT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.fishing_spots ALTER COLUMN id SET DEFAULT nextval('public.fishing_spots_id_seq'::regclass);


--
-- TOC entry 3270 (class 2604 OID 27880)
-- Name: global_positions id; Type: DEFAULT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.global_positions ALTER COLUMN id SET DEFAULT nextval('public.global_positions_id_seq'::regclass);


--
-- TOC entry 3261 (class 2604 OID 27881)
-- Name: privileges id; Type: DEFAULT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.privileges ALTER COLUMN id SET DEFAULT nextval('public.privileges_id_seq'::regclass);


--
-- TOC entry 3262 (class 2604 OID 27882)
-- Name: ranks id; Type: DEFAULT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.ranks ALTER COLUMN id SET DEFAULT nextval('public.ranks_id_seq'::regclass);


--
-- TOC entry 3266 (class 2604 OID 27883)
-- Name: user_accounts id; Type: DEFAULT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.user_accounts ALTER COLUMN id SET DEFAULT nextval('public.user_accounts_id_seq'::regclass);


--
-- TOC entry 3502 (class 0 OID 26541)
-- Dependencies: 221
-- Data for Name: account_privileges; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.account_privileges (account_type_id, privilege_id) FROM stdin;
1	1
2	2
2	4
3	2
3	4
3	6
3	11
3	12
5	2
5	4
5	6
5	7
5	8
5	9
5	10
5	11
5	12
\.


--
-- TOC entry 3491 (class 0 OID 26467)
-- Dependencies: 210
-- Data for Name: account_types; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.account_types (id, name, price) FROM stdin;
1	Admin	0.0
2	Friend of an Angler	7.99
3	Casual Angler	19.99
5	Advanced	199.99
\.


--
-- TOC entry 3511 (class 0 OID 26673)
-- Dependencies: 230
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.alembic_version (version_num) FROM stdin;
8fe8c0101ec3
\.


--
-- TOC entry 3520 (class 0 OID 27491)
-- Dependencies: 239
-- Data for Name: angler_baits; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.angler_baits (angler_id, bait_id) FROM stdin;
\.


--
-- TOC entry 3521 (class 0 OID 27506)
-- Dependencies: 240
-- Data for Name: angler_fishing_spots; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.angler_fishing_spots (angler_id, fishing_spot_id) FROM stdin;
\.


--
-- TOC entry 3522 (class 0 OID 27521)
-- Dependencies: 241
-- Data for Name: angler_gear; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.angler_gear (angler_id, fishing_gear_id) FROM stdin;
\.


--
-- TOC entry 3523 (class 0 OID 27568)
-- Dependencies: 242
-- Data for Name: angler_outings; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.angler_outings (angler_id, fishing_outing_id) FROM stdin;
\.


--
-- TOC entry 3504 (class 0 OID 26557)
-- Dependencies: 223
-- Data for Name: anglers; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.anglers (id, name, rank_id) FROM stdin;
\.


--
-- TOC entry 3493 (class 0 OID 26478)
-- Dependencies: 212
-- Data for Name: baits; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.baits (id, name, artificial, size, color, description) FROM stdin;
1	Tsunami Swimshad	t	7	black back	soft plastic
2	Cotton Coredell Pencil Popper	t	7	silver/black	plastic pencil popper
3	Skinner V2 Bucktail	t	1.25	pearl	Hefty, full bucktail
\.


--
-- TOC entry 3517 (class 0 OID 26909)
-- Dependencies: 236
-- Data for Name: current_stations; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.current_stations (id, name, global_position_id) FROM stdin;
10901	0.1 mile east of Point Evans, The Narrows, Washington Current	12492
10902	0.1 mile SW of Devils Foot Island, Woods Hole, Massachusetts Current	12493
10903	0.3 mile northeast of, Marrowstone Point, Washington Current	12494
10904	0.4 mile north of, Brunswick River, North Carolina Current (16d)	12495
10905	0.4 mile north of, Brunswick River, North Carolina Current (6d)	12496
10906	0.4 mile northeast of, Marrowstone Point, Washington Current	12497
10907	0.5 mile NE of Little Gull Island, The Race, New York Current	12498
10908	0.5 mile southeast of, Pinellas Point, Florida Current	12499
10909	1.1 miles northwest of, Marrowstone Point, Washington Current	12500
10910	1.6 miles northeast of, Marrowstone Point, Washington Current	12501
10911	1.8 miles north of mouth, Brunswick River, North Carolina Current (6d)	12502
10912	1.9 miles SE of, Pinellas Point, Florida Current	12503
10913	2.4 miles southwest of, Point Judith, Rhode Island Current	12504
10914	2.6 miles south of, Pinellas Point, Florida Current	12505
10915	28th St. Pier (San Diego), 0.35 nmi. SW, California Current (14d)	12506
10916	28th St. Pier (San Diego), 0.35 nmi. SW, California Current (28d)	12507
10917	28th St. Pier (San Diego), 0.92 nmi. SW, California Current (7d)	12508
10918	3 miles southeast of, Pinellas Point, Florida Current	12509
10919	610 Statute Mile Mark, Bear River, Georgia Current (6d)	12510
10920	Abiels Ledge, 0.4 mile south of, Massachusetts Current	12511
10921	Acabonack Hbr. ent., 0.6 mile ESE of, New York Current	12512
10922	Active Pass, British Columbia Current	12513
10923	Adak Strait, 4 miles ENE of Naga Point, Alaska Current	12514
10924	Adak Strait, off Argonne Point, Alaska Current	12515
10925	Admiralty Head, 0.5 mile west of, Washington Current	12516
10926	Admiralty Inlet (off Bush Point), Washington Current	12517
10927	Admiralty Inlet, Washington Current	12518
10928	Agate Pass, North End of, Washington Current	12519
10929	Agate Pass, South End of, Washington Current	12520
10930	Agate Passage, north end, Washington Current	12521
10931	Agate Passage, south end, Washington Current	12522
10932	Akutan Pass, Aleutian Islands, Alaska Current	12523
10933	Alameda Radar Tower, .9 SSW of, South San Francisco Bay, California Current	12524
10934	Alcatraz (North Point), San Francisco Bay, California Current	12525
10935	Alcatraz Island .8 mi E, San Francisco Bay, California Current	12526
10936	Alcatraz Island S, San Francisco Bay, California Current	12527
10937	Alcatraz Island W, San Francisco Bay, California Current	12528
10938	Alcatraz Island, 5 mi N, San Francisco Bay, California Current	12529
10939	Alden Point, Patos Is, 2 miles S of, Washington Current	12530
10940	Alden Point, Patos Island, 2 miles S of, Washington Current	12531
10941	Alki Point, 0.3 mile west of, Washington Current	12532
10942	Alki Point, 0.3 miles W of, Washington Current	12533
10943	Almy Point Bridge, south of, Sakonnet River, Rhode Island Current (15d)	12534
10944	Amak Island, 5 miles north of, Alaska Current	12535
10945	Amak Island, 5 miles southeast of, Alaska Current	12536
10946	Amoco Pier, off, Cooper River, South Carolina Current	12537
10947	Angel Island .8 mi E, San Francisco Bay, California Current	12538
10948	Angel Island off Quarry Point, San Francisco Bay, California Current	12539
10949	Antioch Pt .3 mi E, San Joaquin River, California Current	12540
10950	Apavawook Cape, 1 mile south of, St. Lawrence Island, Alaska Current	12541
10951	Apokak Creek entrance, Alaska Current	12542
10952	Apple Cove Point, 0.5 mile E of, Washington Current	12543
10953	Approach, Beaufort Inlet, North Carolina Current	12544
10954	Aransas Pass, Texas Current	12545
10955	Aransas Pass, Texas Current (15d)	12546
10956	Aransas Pass, Texas Current (35d)	12547
10957	Aransas Pass, Texas Current (50d)	12548
10958	Arnold Point, 0.4 mile west of, Maryland Current	12549
10959	Ashe Island Cut, St. Helena Sound, South Carolina Current (6d)	12550
10960	Ashe Island Cut, SW of, Coosaw River, South Carolina Current (15d)	12551
10961	Ashepoo Coosaw Cutoff, South Carolina Current (6d)	12552
10962	Ashepoo River, off Jefford Creek entrance, South Carolina Current	12553
10963	Avatanak Strait, Alaska Current	12554
10964	Avondale, Pawcatuck River, Rhode Island Current (6d)	12555
10965	Baby Pass, Alaska Current	12556
10966	Back River entrance, Cooper River, South Carolina Current	12557
10967	Back River entrance, Georgia Current (10d)	12558
10968	Back River entrance, Georgia Current (18d)	12559
10969	Bahia Honda Harbor, bridge, Florida Current	12560
10970	Bah�a Honda Harbor (Bridge) Florida Current	12561
10971	Baker Bay entrance, E of Sand Island Tower, Washington Current (23d)	12562
10972	Baker Beach (South Bay), 0.3 nmi. NW of, California Current (31d)	12563
10973	Baker Beach (South Bay), 0.3 nmi. NW of, California Current (50d)	12564
10974	Balch Passage, Washington Current	12565
10975	Bald Eagle Pt., east of, Harris Creek, Maryland Current	12566
10976	Bald Head, North Carolina Current	12567
10977	Ballast Point, 0.55 nmi. north of, California Current (14d)	12568
10978	Ballast Point, 0.55 nmi. north of, California Current (34d)	12569
10979	Ballast Point, 100 yards north of, California Current	12570
10980	Ballast Point, south of, California Current (5d)	12571
10981	Baltimore Harbor Approach (off Sandy Point), Maryland Current	12572
10982	Baltimore Harbor Approach, Maryland Current	12573
10983	Bar Channel, Georgia Current (12d)	12574
10984	Bar, Georgia Current	12575
10985	Barataria Bay, 1.1 mi. NE of Manilla, Louisiana Current	12576
10986	Barataria Pass, Barataria Bay, Louisiana Current	12577
10987	Barnegat Inlet, Barnegat Bay, New Jersey Current	12578
10988	Barnes Island, 0.8 mile southwest of, Washington Current	12579
10989	Barnes Island, 0.8 mile SW of, Washington Current	12580
10990	Bartlett Reef, 0.2 mile south of, New York Current	12581
10991	Battery Point, Chilkoot Inlet, Alaska Current	12582
10992	Battery, southwest of, Ashley River, South Carolina Current	12583
10993	Bay Point Island, S of, Broad River entrance, South Carolina Current (15d)	12584
10994	Bayonne Bridge, Kill van Kull, New York Current	12585
10995	Bayonne Bridge, Kill van Kull, New York Current (2)	12586
10996	Beardslee Island, West of, Glacier Bay, Alaska Current	12587
10997	Beaufort Airport, Beaufort River, South Carolina Current (15d)	12588
10998	Beaufort River Entrance, South Carolina Current (15d)	12589
10999	Beaufort River, South Carolina Current (15d)	12590
11000	Beaufort, Beaufort River, South Carolina Current (12d)	12591
11001	Beavertail Point, 0.8 mile northwest of, Rhode Island Current	12592
11002	Bechevin Bay, off Rocky Point, Alaska Current	12593
11003	Bees Ferry Bridge, Ashley River, South Carolina Current	12594
11004	Bellingham Channel, off Cypress I. Light, Washington Current	12595
11005	Bellingham Channel, off Cypress Island, Light of, Washington Current	12596
11006	Benedict, highway bridge, Maryland Current	12597
11007	Bergen Point Reach (Bayonne Bridge), Kill van Kull, New York Current (16d)	12598
11008	Bergen Point Reach (Bayonne Bridge), New York Current (29d)	12599
11009	Berkeley Yacht Harbor .9 mi S, San Francisco Bay, California Current	12600
11010	Berkeley Yacht Harbor, California Current	12601
11011	Big Sarasota Pass, Florida Current	12602
11012	Bird Shoal, SE of, Beaufort Inlet, North Carolina Current (6d)	12603
11013	Black Point and Plum Island, between, New York Current (15d)	12604
11014	Black Point, 0.8 mile south of, Connecticut Current (15d)	12605
11015	Black Point, SW of, Sakonnet River, Rhode Island Current (15d)	12606
11016	Blackburn Bay, south end, bridge, Florida Current	12607
11017	Blair Channel, Ocracoke Inlet, North Carolina Current (10d)	12608
11018	Blake Island, southwest of, Washington Current	12609
11019	Blake Island, SW of, Washington Current	12610
11020	Blind Pass (north end), Florida Current	12611
11021	Bloody Point Bar Light, 0.6 mi. NW of, Maryland Current (19d)	12612
11022	Bloody Pt., 0.5 mile north of, New River, South Carolina Current	12613
11023	Bloody Pt., 0.5 mile west of, New River, South Carolina Current	12614
11024	Blount Island, East of, Florida Current (16d)	12615
11025	Blount Island, East of, Florida Current (30d)	12616
11026	Blount Island, East of, Florida Current (7d)	12617
11027	Bluff Point .1 mi E, San Francisco Bay, California Current	12618
11028	Boat Passage, British Columbia Current	12619
11029	Boca Grande Channel, Florida Current	12620
11030	Boca Grande Pass, Charlotte Harbor, Florida Current	12621
11031	Bodie Island-Pea Island, between, Oregon Inlet, North Carolina Current (12d)	12622
11032	Bodie Island-Pea Island, between, Oregon Inlet, North Carolina Current (6d)	12623
11033	Bolivar Roads, Texas Current	12624
11034	Bolivar Roads, Texas Current (14d)	12625
11035	Bolivar Roads, Texas Current (31d)	12626
11036	Bolivar Roads, Texas Current (8d)	12627
11037	Bonneau Ferry, east of, Cooper River, South Carolina Current	12628
11038	Boston Harbor, Massachusetts Current	12629
11039	Boundary Pass, 2 miles NNE of Skipjack Island, Washington Current	12630
11040	Bourne Highway bridge, Massachusetts Current	12631
11041	Bournedale, Massachusetts Current	12632
11042	Braddock Point, SW of, Calibogue Sound, South Carolina Current (10d)	12633
11043	Bradley Point, NNE of, Georgia Current (10d)	12634
11044	Brandt Bridge, San Joaquin River, California Current	12635
11045	Branford Reef, 1.5 miles southwest of, Connecticut Current (15d)	12636
11046	Branford Reef, 5.0 miles south of, Connecticut Current (15d)	12637
11047	Brenton Point, 1.4 n.mi. southwest of, Rhode Island Current (7d)	12638
11048	Brewerton Channel Eastern Ext., Buoy '7', Maryland Current (14d)	12639
11049	Brickyard Creek, South Carolina Current (10d)	12640
11050	Bridge, 0.8 mi. south of Maximo Pt., Florida Current	12641
11051	Bridgeport Hbr. ent., btn. jetties, Connecticut Current (4d)	12642
11052	Broad River Bridge, S of, Broad River, South Carolina Current (15d)	12643
11053	Broad River Entrance, Point Royal Sound, South Carolina Current (15d)	12644
11054	Broadway Bridge, New York Current	12645
11055	Broken Ground-Horseshoe Shoal, between, Massachusetts Current	12646
11056	Bronx-Whitestone Bridge, East of, New York Current (14d)	12647
11057	Brooklyn Bridge, 0.1 mile southwest of, New York Current	12648
11058	Brooklyn Bridge, New York Current (15d)	12649
11059	Broomes Island, 0.4 mile south of, Maryland Current	12650
11060	Broughton Island (south), Buttermilk Sound, Georgia Current (9d)	12651
11061	Brunswick River Bridge, southeast of, Georgia Current (13d)	12652
11062	Brunswick River Bridge, southeast of, Georgia Current (21d)	12653
11063	Brunswick River, off Quarantine Dock, Georgia Current	12654
11064	Brunswick, off Prince Street Dock, Georgia Current	12655
11065	Bull Point, east of, Rhode Island Current (10d)	12656
11066	Bull River, 2 miles below hwy. bridge, Georgia Current	12657
11067	Bunces Pass (West of Bayway bridge), Florida Current	12658
11068	Buoy '19', off Nowell Creek, Wando River, South Carolina Current	12659
11069	Burnside Island, SE of, Burnside River, Georgia Current (10d)	12660
11070	Burntpot Island, west of, Skidaway River, Georgia Current (6d)	12661
11071	Burrows Bay, 0.5 E of Allan Island, Washington Current	12662
11072	Burrows Bay, 0.5 mile east of Allan I, Washington Current	12663
11073	Burrows I.-Allan I., Passage between, Washington Current	12664
11074	Burrows Is - Allan Is channel, Washington Current	12665
11075	Burrows Island Light, 0.8 miles WNW of, Washington Current	12666
11076	Burrows Island Light, Washington Current	12667
11077	Bush Point Light, 0.5 mile NW of, Washington Current	12668
11078	Bush River, 0.4 mi. SW of Bush Point, Maryland Current	12669
11079	Butler Island, 0.3 mile south of, South Carolina Current	12670
11080	Buttermilk Channel (SEE CAUTION NOTE), New York Current (15d)	12671
11081	Buttermilk Channel, New York Current	12672
11082	Buzzard Roost Creek, Georgia Current (13d)	12673
11083	Byrd Creek Entrance, SE of, Broad River, South Carolina Current (12d)	12674
11084	Cabin Bluff, Cumberland River, Georgia Current	12675
11085	Caesar Creek, Biscayne Bay, Florida Current	12676
11086	Cambridge hwy. bridge, W. of Swing Span, Maryland Current (18d)	12677
11087	Caminada Pass, Barataria Bay, Louisiana Current	12678
11088	Camp Key, 1.9 miles northwest of, Florida Current	12679
11089	Campbell Island, east side, North Carolina Current (16d)	12680
11090	Campbell Island, east side, North Carolina Current (26d)	12681
11091	Campbell Island, east side, North Carolina Current (6d)	12682
11092	Canapitsit Channel, Massachusetts Current	12683
11093	Cape Blanco, Oregon Current	12684
11094	Cape Cod Canal (railroad bridge), Massachusetts Current	12685
11095	Cape Cod Canal, east end, Massachusetts Current (15d)	12686
11096	Cape Cod Canal, Massachusetts Current	12687
11097	Cape Constantine, 4 miles Southeast of, Alaska Current	12688
11098	Cape Haze, 2.3 mi. S of, Charlotte Hbr, Florida Current	12689
11099	Cape Lieskof, 3 miles west of, Alaska Current	12690
11100	Cape Poge Light, 1.4 miles west of, Massachusetts Current	12691
11101	Cape Poge Lt., 1.7 miles SSE of, Massachusetts Current	12692
11102	Cape Poge Lt., 3.2 miles northeast of, Massachusetts Current	12693
11103	Cape Sebastian, Oregon Current	12694
11104	Cape Spencer, 3 miles south of, Alaska Current	12695
11105	Cape Vizcaino, California Current	12696
11106	Captain Hbr. Ent., 0.6 mile southwest of, Connecticut Current (15d)	12697
11107	Captain Hbr. Ent., 0.6 mile southwest of, Connecticut Current (30d)	12698
11108	Captiva Pass, Florida Current	12699
11109	Carquinez Strait, California Current	12700
11110	Carrot Island, Beaufort Inlet, North Carolina Current (6d)	12701
11111	Carson Creek Entrance, 1.4 nmi. ESE of, Alaska Current (15d) - IGNORE HEIGHTS	12702
11112	Carson Creek Entrance, 2.4 nmi. ESE of, Alaska Current (50d)	12703
11113	Carson Creek Entrance, 3.3 nmi. SE of, Alaska Current (78d)	12704
11114	Carter Bay, west of, Alaska Current	12705
11115	Castle Hill, west of, East Passage, Rhode Island Current (15d)	12706
11116	Castle Pinckney, 0.4 mile south of, South Carolina Current	12707
11117	Castle Pinckney, 0.6 mile southwest of, South Carolina Current	12708
11118	Cathlamet Channel, SE of Nassa Point, Washington Current (19d)	12709
11119	Cats Point (bridge west of), Florida Current	12710
11120	Cattle Point, 1.2 mile SE of, Washington Current	12711
11121	Cattle Point, 1.2 miles southeast of, Washington Current	12712
11122	Cattle Point, 2.8 miles SSW of, Washington Current	12713
11123	Cattle Point, 5 miles SSW of, Washington Current	12714
11124	Cedar Hammock, south of, Georgia Current (12d)	12715
11125	Cedar Point, 0.2 mile west of, New York Current	12716
11126	Cedar Point, 1.1 miles ENE of, Maryland Current	12717
11127	Cedar Point, 2.9 n.mi. ENE of, Maryland Current (16d)	12718
11128	Cedar Point, 2.9 n.mi. ENE of, Maryland Current (50d)	12719
11129	Cedar Point, 4.7 n.mi. east of, Maryland Current (15d)	12720
11130	Cedar Point, 4.7 n.mi. east of, Maryland Current (5d)	12721
11131	Cerberus Shoal and Fishers I., between, Connecticut Current (7d)	12722
11132	Cerberus Shoal, 1.5 miles east of, Connecticut Current (15d)	12723
11133	Chain Island .7 mi SW, Sacramento River, California Current	12724
11134	channel entrance, Ocracoke Inlet, North Carolina Current	12725
11135	Channel, 1.5 miles north of Westport, Washington Current	12726
11136	Channel, 2.1 miles NNE of Westport, Washington Current	12727
11137	Channel, 6 miles N of Mobile Point, Alabama Current	12728
11138	Charles Island, 0.8 mile SSE of, Connecticut Current	12729
11139	Charleston Harbor (off Fort Sumter), South Carolina Current	12730
11140	Charleston Harbor Entrance, South Carolina Current	12731
11141	Charleston Harbor, off Fort Sumter, South Carolina Current (expired 1996-12-31)	12732
11142	Charleston Hbr. ent. (between jetties), South Carolina Current	12733
11143	Chaseville Turn, Florida Current (14d)	12734
11144	Chaseville Turn, Florida Current (30d)	12735
11145	Chaseville Turn, Florida Current (4d)	12736
11146	Chesapeake and Delaware Canal, Maryland/Delaware Current	12737
11147	Chesapeake Bay Bridge, main channel, Maryland Current	12738
11148	Chesapeake Bay Entrance, Virginia Current (1) (expired 1987-12-31)	12739
11149	Chesapeake Bay Entrance, Virginia Current (2)	12740
11150	Chestertown, Maryland Current	12741
11151	Childsbury, S.A.L. RR. bridge, Cooper River, South Carolina Current	12742
11152	Chinook Point, WSW of, Washington Current (14d)	12743
11153	Chlora Point, 0.5 n.mi. SSW of, Maryland Current (17d)	12744
11154	Chlora Point, 0.5 n.mi. SSW of, Maryland Current (24d)	12745
11155	Chowan Creek, South Carolina Current (15d)	12746
11156	Chugul Pass, 0.5 mile NE of Cape Ruin, Alaska Current	12747
11157	Chugul Pass, 0.8 mile SW of Tanager Pt, Alaska Current	12748
11158	Chugul Pass, 2 miles NE of Cape Ruin, Alaska Current	12749
11159	City Island Bridge, New York Current (10d)	12750
11160	City Island, 0.6 mile southeast of, New York Current (15d)	12751
11161	City Point, 1.3 miles northeast of, Connecticut Current	12752
11162	Clark Island, 1.6 mile North of, Washington Current	12753
11163	Clark Island, 1.6 miles north of, Washington Current	12754
11164	Clarks Point, 1 mile west of, Alaska Current	12755
11165	Clason Point, 0.3 n.mi. S of, New York Current (15d)	12756
11166	Clatsop Spit, NNE of, Washington Current (15d)	12757
11167	Clay Head, 1.2 miles ENE of, Block Island, Rhode Island Current (15d)	12758
11168	Clay Point, 1.3 miles NNE of, New York Current (15d)	12759
11169	Claybluff Point Light, 2.3 nmi. SE of, Alaska Current (6d)	12760
11170	Claybluff Point Light, 3.5 nmi. south of, Alaska Current (75d)	12761
11171	Clearwater Pass, 0.2 mi. NE of Sand Key, Florida Current	12762
11172	Clifton Channel, Washington Current (10d)	12763
11173	Coast Guard Tower, southwest of, Oregon Inlet, North Carolina Current (12d)	12764
11174	Coast Guard Tower, southwest of, Oregon Inlet, North Carolina Current (6d)	12765
11175	Cold Spring Pt., Seekonk River, Rhode Island Current	12766
11176	College Point Reef, 0.25 n.mi. NW of, New York Current (15d)	12767
11177	Colville Island, 1 mile SSE of, Washington Current	12768
11178	Colville Island, 1 miles SSE of, Washington Current	12769
11179	Colville Island, 1.4 miles E of, Washington Current	12770
11180	Colville Island, 1.4 miles east of, Washington Current	12771
11181	Combahee River, South Carolina Current (15d)	12772
11182	Combahee River, South Carolina Current (8d)	12773
11183	Commodore Point, terminal channel, Florida Current (17d)	12774
11184	Commodore Point, terminal channel, Florida Current (27d)	12775
11185	Commodore Point, terminal channel, Florida Current (7d)	12776
11186	Common Fence Point, northeast of, Rhode Island Current (10d)	12777
11187	Common Fence Point, west of, Rhode Island Current (10d)	12778
11188	Conanicut Point, ENE of, Rhode Island Current (15d)	12779
11189	Cook Point, 1.4 n.mi. NNW of, Maryland Current (15d)	12780
11190	Cook Point, 1.4 n.mi. NNW of, Maryland Current (45d)	12781
11191	Coos Bay entrance, Oregon Current	12782
11192	Coosaw Island, South of, Morgan River, South Carolina Current (10d)	12783
11193	Coquille River entrance, Oregon Current	12784
11194	Cornfield Point, 1.1 miles south of, Connecticut Current (15d)	12785
11195	Cornfield Point, 1.9 n.mi. SW of, Connecticut Current (15d)	12786
11196	Cornfield Point, 2.8 n.mi. SE of, Connecticut Current (15d)	12787
11197	Cornfield Point, 3 miles south of, Connecticut Current (7d)	12788
11198	Coronado, off northeast end, California Current (14d)	12789
11199	Coronado, off northeast end, California Current (38d)	12790
11200	Cortez, north of bridge, Florida Current	12791
11201	Cos Cob Harbor, off Goose Island, Connecticut Current	12792
11202	Cotuit Bay entrance (Bluff Point), Massachusetts Current	12793
11203	Courtney Campbell Parkway, Florida Current	12794
11204	Cove Point (1.1 mi. NE of), Maryland Current	12795
11205	Cove Point, 1.1 n.mi. east of, Maryland Current (17d)	12796
11206	Cove Point, 1.1 n.mi. east of, Maryland Current (40d)	12797
11207	Cove Point, 2.7 n.mi. east of, Maryland Current (15d)	12798
11208	Cove Point, 2.7 n.mi. east of, Maryland Current (40d)	12799
11209	Cove Point, 2.7 n.mi. east of, Maryland Current (98d)	12800
11210	Cove Point, 3.9 n.mi. east of, Maryland Current (11d)	12801
11211	Cove Point, 4.9 n.mi. NNE of, Maryland Current (15d)	12802
11212	Cove Point, 4.9 n.mi. NNE of, Maryland Current (40d)	12803
11213	Cove Point, 4.9 n.mi. NNE of, Maryland Current (67d)	12804
11214	Craighill Angle, right outside quarter, Maryland Current	12805
11215	Craighill Channel entrance, Buoy '2C', Maryland Current (15d)	12806
11216	Craighill Channel entrance, Buoy '2C', Maryland Current (38d)	12807
11217	Craighill Channel, Belvidere Shoal, Maryland Current (18d)	12808
11218	Craighill Channel, NE of Mountain Pt, Maryland Current	12809
11219	Crane Island, south of, Wasp Passage, Washington Current	12810
11220	Crane Island, Wasp Passage, South of, Washington Current	12811
11221	Crane Neck Point, 0.5 mile northwest of, New York Current	12812
11222	Crane Neck Point, 3.4 miles WNW of, New York Current (15d)	12813
11223	Crane Neck Point, 3.7 miles WSW of, New York Current (15d)	12814
11224	Crescent River, Georgia Current (11d)	12815
11225	Cross Rip Channel, Massachusetts Current	12816
11226	Cryders Point, 0.4 mile NNW of, New York Current	12817
11227	Cumberland River, north entrance, Georgia Current	12818
11228	Customhouse Reach, off Customhouse, South Carolina Current	12819
11229	Customhouse Reach, South Carolina Current	12820
11230	Cut A & B, Channel Junction, Florida Current	12821
11231	Cut A Channel, marker '10', Hillsborough Bay, Florida Current (15d)	12822
11232	Cut C Channel, marker '21', Hillsborough Bay, Florida Current (15d)	12823
11233	Cut E Channel, marker '2E', Florida Current (15d)	12824
11234	Dames Point, 0.23 n.mi. ESE of, Florida Current (14d)	12825
11235	Dames Point, 0.23 n.mi. ESE of, Florida Current (31d)	12826
11236	Dames Point, 0.23 n.mi. ESE of, Florida Current (5d)	12827
11237	Dames Point, 0.25 n.mi. SE of, Florida Current (14d)	12828
11238	Dames Point, 0.25 n.mi. SE of, Florida Current (28d)	12829
11239	Dames Point, 0.25 n.mi. SE of, Florida Current (5d)	12830
11240	Dana Passage, Washington Current	12831
11241	Daniel Island Bend, Cooper River, South Carolina Current	12832
11242	Daniel Island Reach, Buoy '48', Cooper River, South Carolina Current	12833
11243	Daniel Island Reach, Cooper River, South Carolina Current	12834
11244	Daufuskie Landing Light, south of, South Carolina Current (10d)	12835
11245	Davis Point, California Current	12836
11246	Davis Point, midchannel, San Pablo Bay, California Current	12837
11247	Daws Island, SE of, Broad River, South Carolina Current (15d)	12838
11248	Daws Island, south of, Chechessee River, South Carolina Current (15d)	12839
11249	Deception Island, 1.3 miles NW of, Washington Current	12840
11250	Deception Island, 1.O miles W of, Washington Current	12841
11251	Deception Island, 2.7 mile West of, Washington Current	12842
11252	Deception Island, 2.7 miles west of, Washington Current	12843
11253	Deception Pass (narrows), Washington Current	12844
11254	Deception Pass, Washington Current	12845
11255	Deep Point, Maryland Current	12846
11256	Deepwater Point, Miles River, Maryland Current	12847
11257	Delancey Point, 1 mile southeast of, New York Current (15d)	12848
11258	Delaware Bay Entrance, Delaware Current (1) (expired 1986-12-31)	12849
11259	Delaware Bay Entrance, Delaware Current (2)	12850
11260	Dennis Port, 2.2 miles south of, Massachusetts Current	12851
11261	Derbin Strait, Alaska Current	12852
11262	Deveaux Banks, off North Edisto River entrance, South Carolina Current (12d)	12853
11263	Discovery Island, 3 miles SSE of, Washington Current	12854
11264	Discovery Island, 3.3 miles NE of, Washington Current	12855
11265	Discovery Island, 3.3 miles northeast of, Washington Current	12856
11266	Discovery Island, 7.6 miles SSE of, Washington Current	12857
11267	Doboy Island (North River), Georgia Current (12d)	12858
11268	Doboy Island (North River), Georgia Current (20d)	12859
11269	Doctor Point, 0.6 mile NNW of, North Carolina Current (16d)	12860
11270	Doctor Point, 0.6 mile NNW of, North Carolina Current (26d)	12861
11271	Doctor Point, 0.6 mile NNW of, North Carolina Current (6d)	12862
11272	Dodd Narrows, British Columbia Current	12863
11273	Dover Bridge, Maryland Current	12864
11274	Dram Tree Point, 0.5 mile SSE of, North Carolina Current	12865
11275	Drayton Harbor Entrance, Washington Current	12866
11276	Drum Island Reach, off Drum I., Buoy '45', South Carolina Current	12867
11277	Drum Island, 0.2 mile above, Cooper River, South Carolina Current	12868
11278	Drum Island, 0.4 mile SSE of, South Carolina Current	12869
11279	Drum Island, east of (bridge), South Carolina Current	12870
11280	Drum Point, 0.3 mile SSE of, Maryland Current	12871
11281	Drummond Point, channel south of, Florida Current (17d)	12872
11282	Drummond Point, channel south of, Florida Current (27d)	12873
11283	Drummond Point, channel south of, Florida Current (7d)	12874
11284	Duck Pond Point, 3.2 n.mi. NW of, New York Current (15d)	12875
11285	Dumbarton Bridge, San Francisco Bay, California Current	12876
11286	Dumbarton Hwy Bridge, South San Francisco Bay, California Current	12877
11287	Dumbarton Point 2.3 mi NE, South San Francisco Bay, California Current	12878
11288	Dumpling Rocks, 0.2 mile southeast of, Massachusetts Current	12879
11289	Dutch Island and Beaver Head, between, Rhode Island Current	12880
11290	Dutch Island, east of, West Passage, Rhode Island Current (15d)	12881
11291	Dutch Island, SE of, Skidaway River, Georgia Current (10d)	12882
11292	Dutch Island, west of, Rhode Island Current (7d)	12883
11293	Dyer Island, west of, Rhode Island Current (7d)	12884
11294	Dyer Island-Carrs Point (between), Rhode Island Current	12885
11295	East 107th Street, New York Current (15d)	12886
11296	East Branch, 0.2 mile above entrance, Cooper River, South Carolina Current	12887
11297	East Chop, 1 mile north of, Massachusetts Current	12888
11298	East Chop-Squash Meadow, between, Massachusetts Current	12889
11299	east of, off 36th Avenue, Roosevelt Island, New York Current	12890
11300	east of, Roosevelt Island, New York Current	12891
11301	East Pt., Fishers I., 4.1 miles S of, New York Current (15d)	12892
11302	Eastchester Bay, near Big Tom, New York Current (5d)	12893
11303	Eastern Plain Point, 1.2 miles N of, New York Current	12894
11304	Eastern Plain Pt., 3.9 miles ENE of, New York Current	12895
11305	Eastern Point, 1.5 miles south of, New York Current	12896
11306	Eatons Neck Point, 2.5 n.mi. NNW of, New York Current (15d)	12897
11307	Eatons Neck Pt., 1.3 miles north of, New York Current (15d)	12898
11308	Eatons Neck Pt., 1.8 miles west of, New York Current	12899
11309	Eatons Neck Pt., 3 miles north of, New York Current (15d)	12900
11310	Eatons Neck Pt., 3 miles north of, New York Current (40d)	12901
11311	Eatons Neck Pt., 3 miles north of, New York Current (70d)	12902
11312	Eddy Rock Shoal, west of, Connecticut River, Connecticut Current (15d)	12903
11313	Edgartown, Inner Harbor, Massachusetts Current	12904
11314	Ediz Hook Light, 1.2 miles N of, Washington Current	12905
11315	Ediz Hook Light, 1.2 miles north of, Washington Current	12906
11316	Ediz Hook Light, 5.3 miles ENE of, Washington Current	12907
11317	Edmonds, 2.7 miles WSW of, Washington Current	12908
11318	Edmonds, 2.7 wsW of, Washington Current	12909
11319	Edwards Pt. and Sandy Pt., between, Rhode Island Current (4d)	12910
11320	Eel Pt., Nantucket I. 2.5 miles NE of, Massachusetts Current	12911
11321	Egg Bank, St. Helena Sound, South Carolina Current (10d)	12912
11322	Egmont Channel (3 mi. W of Egmont Key Lt.), Florida Current	12913
11323	Egmont Channel, marker '10', Florida Current (15d)	12914
11324	Elba Island Cut, NE of, Savannah River, South Carolina Current (10d)	12915
11325	Elba Island, NE of, Savannah River, Georgia Current (10d)	12916
11326	Elba Island, west of, Savannah River, Georgia Current (10d)	12917
11327	Eld Inlet entrance, Washington Current	12918
11328	Eld Inlet Entrance, Washington Current	12919
11329	Eldred Rock, Alaska Current	12920
11330	Eldred Rock, Alaska Current (70d)	12921
11331	Elliott Cut, west end, South Carolina Current	12922
11332	Elm Point, 0.2 mile west of, New York Current (15d)	12923
11333	Entrance Point, 3 miles west of, Alaska Current	12924
11334	Entrance Point, Alaska Current	12925
11335	Entrance to Mississippi Sound, Pass Aux Herons, Alabama Current	12926
11336	Entrance, 0.2 mile south of north jetty, Washington Current	12927
11337	Entrance, 0.6 mile WNW of Westport, Washington Current	12928
11338	Entrance, 1.1 miles NW of Westport, Washington Current	12929
11339	Entrance, Georgia Current	12930
11340	Entrance, Georgia Current (14d)	12931
11341	Entrance, Georgia Current (19d)	12932
11342	Entrance, Georgia Current (22d)	12933
11343	Entrance, Georgia Current (29d)	12934
11344	Entrance, north of channel, Georgia Current (13d)	12935
11345	Entrance, off Beach Hammock, Georgia Current	12936
11346	Entrance, off Wassaw Island, Georgia Current	12937
11347	Entrance, Point Chehalis Range, Washington Current	12938
11348	Entrance, south of channel, Georgia Current (11d)	12939
11349	Entrance, south of channel, Georgia Current (29d)	12940
11350	Etolin Point, 8.5 miles west of, Alaska Current	12941
11351	Eustasia Island, 0.6 mile ESE of, Connecticut River, Connecticut Current	12942
11352	Execution Rocks, 0.4 mile southwest of, New York Current (15d)	12943
11353	Fajardo Harbor (channel), Puerto Rico Current	12944
11354	Fauntleroy Point Light, 0.8 mile ESE of, Washington Current	12945
11355	Fauntleroy Point Light, 0.89 mile ESE of, Washington Current	12946
11356	Fenimore Rock, 1.2 miles southwest of, Alaska Current	12947
11357	Fenwick Island Cut, South Edisto River, South Carolina Current (15d)	12948
11358	Fig Island, north of, Back River, Georgia Current	12949
11359	Filbin Creek Reach, 0.2 mile east of, Cooper River, South Carolina Current	12950
11360	Filbin Creek Reach, Buoy '58', Cooper River, South Carolina Current	12951
11361	Filbin Creek Reach, Cooper River, South Carolina Current	12952
11362	First Narrows, British Columbia Current	12953
11363	Fleming Point 1.7 mi SW, San Francisco Bay, California Current	12954
11364	Florida Passage (south), Georgia Current (6d)	12955
11365	Florida Passage, N of, Ogeechee River, Georgia Current (10d)	12956
11366	Folly I. Channel, N of Ft. Johnson, South Carolina Current	12957
11367	Folly Reach, Buoy '5', South Carolina Current	12958
11368	Folly River and Cardigan River, between, Georgia Current (10d)	12959
11369	Fort Macon, 0.2 mile NE of, Beaufort Inlet, North Carolina Current (10d)	12960
11370	Fort Macon, 0.2 mile NE of, Beaufort Inlet, North Carolina Current (20d)	12961
11371	Fort Macon, 0.6 mile SE of, Beaufort Inlet, North Carolina Current	12962
11372	Fort Point, 0.3 nmi. west of, California Current (75d)	12963
11373	Fort Pulaski, 1.8 miles above, Georgia Current	12964
11374	Fort Pulaski, 4.8 miles above, Georgia Current	12965
11375	Fort Pulaski, Georgia Current	12966
11376	Fort Sumter Range, Buoy '14', South Carolina Current	12967
11377	Fort Sumter Range, Buoy '2', South Carolina Current	12968
11378	Fort Sumter Range, Buoy '20', South Carolina Current	12969
11379	Fort Sumter Range, Buoy '4', South Carolina Current	12970
11380	Fort Sumter Range, Buoy '8', South Carolina Current	12971
11381	Foulweather Bluff, Washington Current	12972
11382	Foulweather Bluff, Washington Current (2)	12973
11383	Four Mile Point, St. Marks River, Florida Current	12974
11384	four miles north of, Block Island, Rhode Island Current	12975
11385	Fowler Island, 0.1 mile NNW of, Housatonic River, Connecticut Current (5d)	12976
11386	Fox Point, south of, Providence River, Rhode Island Current (10d)	12977
11387	Frazier Point, south of, South Carolina Current	12978
11388	Frazier Point, west of, South Carolina Current	12979
11389	Freestone Point, 2.3 miles east of, Maryland Current	12980
11390	Fripps Inlet, Fripps Island, South Carolina Current (15d)	12981
11391	Front River, Georgia Current (13d)	12982
11392	Frost-Willow Island, between, Washington Current	12983
11393	Ft. Sumter, 0.6 n.mi. NW of, South Carolina Current	12984
11394	Ft. Taylor, 0.6 mile N of, Key West, Florida Current	12985
11395	G St. Pier (San Diego), 0.22 nmi. SW of, California Current (14d)	12986
11396	G St. Pier (San Diego), 0.22 nmi. SW of, California Current (37d)	12987
11397	Gabriola Passage, British Columbia Current	12988
11398	Galveston Bay Entrance, Texas Current	12989
11399	Galveston Channel, west end, Texas Current	12990
11400	Gandy Bridge, east channel, Florida Current (6d)	12991
11401	Gandy Bridge, west channel, Florida Current	12992
11402	Gardiners Island, 3 miles northeast of, Connecticut Current (10d)	12993
11403	Gardiners Point & Plum Island, between, New York Current (15d)	12994
11404	Gardiners Pt. Ruins, 1.1 miles N of, New York Current	12995
11405	Gasparilla Pass, Florida Current	12996
11406	Gay Head, 1.5 miles northwest of, Massachusetts Current	12997
11407	Gay Head, 3 miles north of, Massachusetts Current	12998
11408	Gay Head, 3 miles northeast of, Massachusetts Current	12999
11409	George Washington Bridge (Hudson River), New York Current	13000
11410	Georgetown, Maryland Current	13001
11411	Georgetown, Sampit River, South Carolina Current	13002
11412	Gibson Point, 0.8 mile east of, Washington Current	13003
11413	Gibson Point, 0.8 miles E of, Washington Current	13004
11414	Gig Harbor Entrance, Washington Current	13005
11415	Gig Harbor entrance, Washington Current	13006
11416	Gillard Pass, British Columbia Current	13007
11417	Goff Point, 0.4 mile northwest of, New York Current	13008
11418	Golden Gate Bridge .8 mi E ., San Francisco Bay, California Current	13009
11419	Golden Gate Point, off, Florida Current	13010
11420	Goodnews Bay entrance, Alaska Current	13011
11421	Gorge-Tillicum Bridge, British Columbia Current	13012
11422	Goshen Point, 1.9 miles SSE of, New York Current (15d)	13013
11423	Goshen Point, SE of, Wadmalaw River, South Carolina Current (12d)	13014
11424	Goshen Point, south of, Wadmalaw River, South Carolina Current (12d)	13015
11425	Gould Island, southeast of, Rhode Island Current (7d)	13016
11426	Gould Island, west of, Rhode Island Current (15d)	13017
11427	Grand Manan Channel (Bay of Fundy Entrance), New Brunswick Current	13018
11428	Grays Harbor Entrance, Washington Current	13019
11429	Great Gull Island, 0.7 mile WSW of, New York Current	13020
11430	Great Point, 0.5 mile west of, Massachusetts Current	13021
11431	Great Point, 3 miles west of, Massachusetts Current	13022
11432	Great Salt Pond ent., 1 mile NW of, Block Island, Rhode Island Current (7d)	13023
11433	Great Salt Pond entrance, Block Island, Rhode Island Current	13024
11434	Green Hill Point, 1.1 miles south of, Rhode Island Current	13025
11435	Green Point, 0.8 mile northwest of, Washington Current	13026
11436	Green Point, 0.8 mile NW of, Washington Current	13027
11437	Greenbury Point, 1.8 miles east of, Maryland Current (8d)	13028
11438	Greenwich Point, 1.1 miles south of, Connecticut Current (15d)	13029
11439	Greenwich Point, 1.1 miles south of, Connecticut Current (55d)	13030
11440	Greenwich Point, 2.5 miles south of, New York Current (15d)	13031
11441	Greenwich Point, 2.5 miles south of, New York Current (55d)	13032
11442	Grove Point, 0.7 n.mi.NW of, Maryland Current (14d)	13033
11443	Grove Point, Maryland Current	13034
11444	Guemes Channel, West entrance of, Washington Current	13035
11445	Guemes Channel, west entrance, Washington Current	13036
11446	Gull I. and Nashawena I., between, Massachusetts Current	13037
11447	Gunpowder River entrance, Maryland Current	13038
11448	Hagan Island, 1 n.mi. below, Cooper River, South Carolina Current	13039
11449	Hague Channel, east of Doe Point, Alaska Current	13040
11450	Haig Point Light, NW of, Cooper River, South Carolina Current (10d)	13041
11451	Hail Point, 0.7 n.mi.east of, Maryland Current (16d)	13042
11452	Hains Point, D.C. Current	13043
11453	Hale Passage, 0.5 mile SE of Lummi Point, Washington Current	13044
11454	Hale Passage, 0.5 miles SE of Lummi Pt, Washington Current	13045
11455	Hale Passage, West end, Washington Current	13046
11456	Hale Passage, west end, Washington Current	13047
11457	Halfmoon Shoal, 1.9 miles northeast of, Massachusetts Current	13048
11458	Halfmoon Shoal, 3.5 miles east of, Massachusetts Current	13049
11459	Hallowing Point, Maryland Current	13050
11460	Hammersley Inlet, 0.8 mile east of Libby Point, Washington Current	13051
11461	Hammersley Inlet, 0.8 miles E of Libby Pt, Washington Current	13052
11462	Hammersley Inlet, W of Skookum Pt, Washington Current	13053
11463	Hammersley Inlet, west of Skookum Point, Washington Current	13054
11464	Hammonasset Point, 1.2 miles SW of, Connecticut Current (15d)	13055
11465	Hammonasset Point, 5 miles south of, Connecticut Current (15d)	13056
11466	Hammond, northeast of ship channel, Oregon Current (15d)	13057
11467	Handkerchief Lighted Whistle Buoy 'H', Massachusetts Current	13058
11468	Harbor ent., south of Plum Point, Oyster Bay, New York Current	13059
11469	Harbor Island (east end), SSW of, California Current (15d)	13060
11470	Harbor Key, 1.3 miles west of, Florida Current	13061
11471	Harbor of Refuge, south entrance, Point Judith, Rhode Island Current	13062
11472	Harbor Point, Alaska Current	13063
11473	Harbor, west of Soper Point, Oyster Bay, New York Current	13064
11474	Harney Channel, Washington Current	13065
11475	Hart Island and City Island, between, New York Current (15d)	13066
11476	Hart Island, 0.2 mile north of, New York Current (15d)	13067
11477	Hart Island, 0.3 n.mi. SSE of, New York Current (15d)	13068
11478	Hart Island, southeast of, New York Current (15d)	13069
11479	Hartford Jetty, Connecticut River, Connecticut Current (9d) - IGNORE HEIGHTS	13070
11480	Hatchett Point, 1.1 miles WSW of, Connecticut Current	13071
11481	Hatchett Point, 1.6 n.mi. S of, Connecticut Current (15d)	13072
11482	Hatteras Inlet, North Carolina Current	13073
11483	Haverstraw (Hudson River), New York Current	13074
11484	Hay Beach Point, 0.3 mile NW of, New York Current	13075
11485	Hazel Point, Washington Current	13076
11486	Heceta Head, Oregon Current	13077
11487	Hedge Fence Lighted Gong Buoy 22, Massachusetts Current	13078
11488	Hedge Fence-L'Hommedieu Shoal, between, Massachusetts Current	13079
11489	Heikish Narrows, British Columbia Current	13080
11490	Hell Gate (East River), New York Current	13081
11491	Hell Gate (off Mill Rock), New York Current	13082
11492	Hempstead Harbor, off Glenwood Landing, New York Current (10d)	13083
11493	Hendersons Point, Maryland Current	13084
11494	Henry Hudson Bridge, 0.7 nmi. SE of, New York Current (16d)	13085
11495	Herbert C. Bonner Bridge, WSW of, Oregon Inlet, North Carolina Current (6d)	13086
11496	Herod Point, 2.8 miles north of, New York Current (15d)	13087
11497	Herod Point, 5.0 n.mi. NW of, New York Current (15d)	13088
11498	Herod Point, 6.5 miles north of, New York Current (15d)	13089
11499	Higganum Creek, 0.5 mile ESE of, Connecticut River, Connecticut Current	13090
11500	High Bridge, New York Current	13091
11501	Highway Bridge, Ashley River, South Carolina Current	13092
11502	Hilton Head, South Carolina Current	13093
11503	Hog Creek Point, north of, New York Current	13094
11504	Hog Island Channel, South Carolina Current	13095
11505	Hog Island Reach, Buoy '12', South Carolina Current	13096
11506	Hog Island Reach, SW of Remley Point, South Carolina Current	13097
11507	Hog Island, northwest of, Rhode Island Current (10d)	13098
11508	Hog Point, 0.6 n.mi. north of, Maryland Current (13d)	13099
11509	Hog Point, 0.6 n.mi. north of, Maryland Current (41d)	13100
11510	Holland Point, 2.0 n.mi east of, Maryland Current (15d)	13101
11511	Holland Point, 2.0 n.mi. SSW of, Maryland Current (14d)	13102
11512	Hooper Bay entrance, Alaska Current	13103
11513	Horlbeck Creek, 0.2 mile above entrance, Wando River, South Carolina Current	13104
11514	Horlbeck Creek, 2.5 miles north of, Wando River, South Carolina Current	13105
11515	Horse Reach, South Carolina Current	13106
11516	Horseshoe Point, 1.7 miles east of, Maryland Current	13107
11517	Horseshoe Shoal, North Carolina Current (16d)	13108
11518	Horseshoe Shoal, North Carolina Current (26d)	13109
11519	Horseshoe Shoal, North Carolina Current (6d)	13110
11520	Horton Point, 1.4 miles NNW of, New York Current	13111
11521	Houston Channel, W of Port Bolivar, Texas Current (14d)	13112
11522	Houston Channel, W of Port Bolivar, Texas Current (26d)	13113
11523	Houston Channel, W of Port Bolivar, Texas Current (3d)	13114
11524	Houston Ship Channel (Red Fish Bar), Texas Current (14d)	13115
11525	Houston Ship Channel (Red Fish Bar), Texas Current (24d)	13116
11526	Houston Ship Channel (Red Fish Bar), Texas Current (7d)	13117
11527	Howell Point, 0.4 mile NNW of, Maryland Current	13118
11528	Howell Point, 0.5 n.mi. south of, Maryland Current (7d)	13119
11529	Howell Point, 0.8 n.mi. west of, Maryland Current (15d)	13120
11530	Huckleberry Island, 0.2 mile NW of, New York Current (15d)	13121
11531	Huckleberry Island, 0.5 mile north of, Washington Current	13122
11532	Huckleberry Island, 0.5 miles N of, Washington Current	13123
11533	Huckleberry Island, 0.6 mile SE of, New York Current (15d)	13124
11534	Hunting Island, south of, Washington Current (20d)	13125
11535	Huntington Bay, off East Fort Point, New York Current (15d)	13126
11536	Huntington Bay, off East Fort Point, New York Current (30d)	13127
11537	Hunts Point, southwest of, New York Current	13128
11538	Hutchinson Island, Ashepoo River, South Carolina Current (10d)	13129
11539	Hutchinson R., Pelham Highway Bridge, New York Current (5d)	13130
11540	Iceberg Point, 2.1 mile SSW of, Washington Current	13131
11541	Iceberg Point, 2.1 miles SSW of, Washington Current	13132
11542	ICW Intersection, Florida Current (10d)	13133
11543	ICW Intersection, Florida Current (16d)	13134
11544	ICW Intersection, Florida Current (29d)	13135
11545	Igitkin Pass, 0.8 mile N of Tanager Pt, Alaska Current	13136
11546	India Point RR. bridge, Seekonk River, Rhode Island Current	13137
11547	Intracoastal Waterway, Southport, North Carolina Current (6d)	13138
11548	Isaac Shoal, Florida Current	13139
11549	Isanotski Strait (False Pass cannery), Alaska Current	13140
11550	Isanotski Strait (False Pass Cannery), Alaska Current	13141
11551	Isle of Hope City, SE of, Skidaway River, Georgia Current (10d)	13142
11552	Isle of Hope City, Skidaway River, Georgia Current (10d)	13143
11553	Jacksonville, F.E.C. RR. bridge, Florida Current	13144
11554	Jacksonville, off Washington St, Florida Current	13145
11555	James Island, 1.6 n.mi. SW of, Maryland Current (15d)	13146
11556	James Island, 1.6 n.mi. SW of, Maryland Current (5d)	13147
11557	James Island, 2.5 miles WNW of, Maryland Current	13148
11558	James Island, 3.4 miles west of, Maryland Current	13149
11559	Jamestown-North Kingstown Bridge, Rhode Island Current (15d)	13150
11560	Jehossee Island, S tip, South Edisto River, South Carolina Current (15d)	13151
11561	Jekyll Creek, south entrance, Georgia Current	13152
11562	Jennings Point, 0.2 mile NNW of, New York Current (13d)	13153
11563	Joe Island, 1.8 miles northwest of, Florida Current	13154
11564	Joe's Cut, Wilmington River, Georgia Current (10d)	13155
11565	Johns Island Airport, south of, South Carolina Current (12d)	13156
11566	Johns Island Bridge, South Carolina Current (14d)	13157
11567	Johns Island, 0.8 mile north of, Washington Current	13158
11568	Johns Island, 0.8 mile North of, Washington Current	13159
11569	Johns Island, South Carolina Current (12d)	13160
11570	Johnson Creek, midway between ends, Georgia Current	13161
11571	Johnston Channel, off Halftide Rock, Alaska Current	13162
11572	Johnstone Strait Central, British Columbia Current	13163
11573	Jones Point, Alexandria, Virginia Current	13164
11574	Juan De Fuca Strait (East), British Columbia Current	13165
11575	Kagalaska Strait, off Galas Point, Alaska Current	13166
11576	Kalohi Channel, Hawaii Current	13167
11577	Kamen Point, 1.3 miles southwest of, Washington Current	13168
11578	Kamen Point, 1.3 miles SW of, Washington Current	13169
11579	Kanaga Pass, 0.3 mile NW of Annoy Rock, Alaska Current	13170
11580	Kanaga Pass, 2.2 miles NE of Annoy Rock, Alaska Current	13171
11581	Katama Pt., 0.6 mi. NNW of, Katama Bay, Massachusetts Current	13172
11582	Kellett Bluff, west of, Washington Current	13173
11583	Kellett Bluff, West of, Washington Current	13174
11584	Kelsey Point, 1 mile south of, Connecticut Current	13175
11585	Kelsey Point, 2.1 miles southeast of, Connecticut Current	13176
11586	Kent Island Narrows (highway bridge), Maryland Current (4d)	13177
11587	Kent Point, 1.3 miles south of, Maryland Current	13178
11588	Kent Point, 1.4 n.mi. east of, Maryland Current (15d)	13179
11589	Kent Point, 4 miles southwest of, Maryland Current	13180
11590	Kenwood Beach, 1.5 miles northeast of, Maryland Current	13181
11591	Key West, 0.3 mi. W of Ft. Taylor, Florida Current	13182
11592	Key West, Florida Current	13183
11593	Kickamuit R. (Narrows), Mt. Hope Bay, Rhode Island Current	13184
11594	King Island, west of, Georgia Current	13185
11595	Kings Island Channel, Savannah River, Georgia Current (10d)	13186
11596	Kings Point, Lopez Island, 1 mile NNW of, Washington Current	13187
11597	Kings Point, Lopez Island, 1 nnw of, Washington Current	13188
11598	Krysi Pass, Rat Islands, Alaska Current	13189
11599	Kvichak Bay (off Naknek River entrance), Alaska Current	13190
11600	L'Hommedieu Shoal, north of west end, Massachusetts Current	13191
11601	Lafayette swing bridge, Waccamaw River, South Carolina Current	13192
11602	Largo Shoals, west of, Puerto Rico Current	13193
11603	Lawrence Point, Orcas I., 1.3 mi. NE of, Washington Current	13194
11604	Lawrence Point, Orcas Island, 1.3 mile East of, Washington Current	13195
11605	Lazaretto Creek Entrance, N of, Bull River, Georgia Current (10d)	13196
11606	Lemon Island South, Chechessee River, South Carolina Current (10d)	13197
11607	Lewis Bay entrance channel, Massachusetts Current	13198
11608	Lewis Island, 0.9 mile east of, Florida Current	13199
11609	Lewis Point, 6.0 miles WNW of, Rhode Island Current (15d)	13200
11610	Lewis Pt., 1.0 mile southwest of, Block Island, Rhode Island Current	13201
11611	Lewis Pt., 1.5 miles west of, Block Island, Rhode Island Current	13202
11612	Liberty Bay, Port Orchard, Washington Current	13203
11613	Limestone Point, Spieden Channel, Washington Current	13204
11614	Little Barnwell I., E of, Whale Branch River, South Carolina Current (6d)	13205
11615	Little Coyote Pt 3.1 mi ENE, South San Francisco Bay, California Current	13206
11616	Little Coyote Pt 3.4 mi NNE, South San Francisco Bay, California Current	13207
11617	Little Don Island, east of, Vernon River, Georgia Current (10d)	13208
11618	Little Egg Island, northwest of, Georgia Current (12d)	13209
11619	Little Gull Island, 0.8 mile NNW of, The Race, New York Current (15d)	13210
11620	Little Gull Island, 0.8 mile SSE of, New York Current	13211
11621	Little Gull Island, 1.1 miles ENE of, The Race, New York Current	13212
11622	Little Gull Island, 1.4 n.mi. NNE of, The Race, New York Current (45d)	13213
11623	Little Mud River Range, Georgia Current (9d)	13214
11624	Little Narragansett Bay entrance, Rhode Island Current	13215
11625	Little Ogeechee River Entrance, Georgia Current (10d)	13216
11626	Little Ogeechee River Entrance, Georgia Current (20d)	13217
11627	Little Ogeechee River Entrance, north of, Georgia Current (6d)	13218
11628	Little Peconic Bay entrance, New York Current (19d)	13219
11629	Little Sarasota Bay, south end, bridge, Florida Current	13220
11630	Little St. Simon Island (north), Georgia Current (11d)	13221
11631	Little Tanaga Strait, off Tana Pt, Alaska Current	13222
11632	Little Wassaw Island, SW of, Georgia Current (10d)	13223
11633	Lloyd Point, 1.3 miles NNW of, New York Current (15d)	13224
11634	Lloyd Point, 1.3 miles NNW of, New York Current (40d)	13225
11635	Long Beach Pt., 0.7 mile southwest of, New York Current (15d)	13226
11636	Long Island, NNE of, Skidaway River, Georgia Current (6d)	13227
11637	Long Island, south of, Skidaway River, Georgia Current (10d)	13228
11638	Long Key Viaduct, Florida Current	13229
11639	Long Key, drawbridge east of, Florida Current	13230
11640	Long Key, east of drawbridge, Florida Current	13231
11641	Long Neck Point, 0.6 mile south of, Connecticut Current (15d)	13232
11642	Long Neck Point, 0.6 mile south of, Connecticut Current (27d)	13233
11643	Long Point, 1 mile southeast of, Maryland Current	13234
11644	Long Shoal-Norton Shoal, between, Massachusetts Current	13235
11645	Longboat Pass, Florida Current	13236
11646	Lopez Pass, Washington Current	13237
11647	Love Point, 1.6 n.mi. east of, Maryland Current (16d)	13238
11648	Love Point, 2.0 nmi north of, Maryland Current (15d)	13239
11649	Love Point, 2.0 nmi north of, Maryland Current (5d)	13240
11650	Love Point, 2.5 miles north of, Maryland Current	13241
11651	Low Point, entrance to Taiya Inlet, Alaska Current	13242
11652	Lowe Point (northeast of), Sasanoa River, Maine Current	13243
11653	Lower Hell Gate (Knubble Bay, Maine) Current	13244
11654	Lynch Point, Back River, Maryland Current	13245
11655	Lynde Point, channel east of, Connecticut River, Connecticut Current	13246
11656	Lyons Creek Wharf, Maryland Current	13247
11657	MacKay Creek, south entrance, South Carolina Current (10d)	13248
11658	Mackay R., 0.5 mi. N of Troup Creek entrance, Georgia Current	13249
11659	Macombs Dam Bridge, New York Current	13250
11660	Madison Ave. Bridge, New York Current	13251
11661	Main Ship Channel entrance, Key West, Florida Current	13252
11662	Mandarin Point, Florida Current (15d)	13253
11663	Mandarin Point, Florida Current (24d)	13254
11664	Mandarin Point, Florida Current (6d)	13255
11665	Manhasset Bay entrance, New York Current (15d)	13256
11666	Manhattan Bridge, East of, New York Current (15d)	13257
11667	Manhattan, off 31st Street, New York Current	13258
11668	Marblehead Channel, Massachusetts Current	13259
11669	Mare Island Strait Entrance, San Pablo Bay, California Current	13260
11670	Mare Island Strait, So Vallejo, San Pablo Bay, California Current	13261
11671	Marrowstone Point, 0.3 miles NE of, Washington Current	13262
11672	Marrowstone Point, 0.4 miles NE of, Washington Current	13263
11673	Marrowstone Point, 1.1 miles NW of, Washington Current	13264
11674	Marrowstone Point, 1.6 miles NE of, Washington Current	13265
11675	Martin Point, 0.6 n.mi. west of, Maryland Current (18d)	13266
11676	Maryland Point, Maryland Current	13267
11677	Matia Island, 0.8 mile West of, Washington Current	13268
11678	Matia Island, 0.8 mile west of, Washington Current	13269
11679	Matia Island, 1.4 mile North of, Washington Current	13270
11680	Matia Island, 1.4 miles north of, Washington Current	13271
11681	Matinecock Point, 0.7 mile NNW of, New York Current (15d)	13272
11682	Matinecock Point, 0.7 mile NNW of, New York Current (40d)	13273
11683	Matinecock Point, 1.7 miles northwest of, New York Current (15d)	13274
11684	Mattituck Inlet, 1 mile northwest of, New York Current (15d)	13275
11685	Mayport Basin Entrance, Florida Current (15d)	13276
11686	Mayport Basin Entrance, Florida Current (32d)	13277
11687	Mayport Basin Entrance, Florida Current (9d)	13278
11688	Mayport, Florida Current (17d)	13279
11689	Mayport, Florida Current (27d)	13280
11690	Mayport, Florida Current (7d)	13281
11691	McGowan, SSW of, Washington Current (14d)	13282
11692	McQueen Island Cut, Georgia Current (10d)	13283
11693	Medway River at Marsh Island, Georgia Current (10d)	13284
11694	Medway River, northwest of Cedar Point, Georgia Current (10d)	13285
11695	Miacomet Pond, 3.0 miles SSE of, Massachusetts Current	13286
11696	Miami Harbor Entrance, Florida Current (1) (expired 1986-12-31)	13287
11697	Miami Harbor Entrance, Florida Current (2)	13288
11698	Miami Harbor Entrance, Florida Current (3)	13289
11699	Middle Marshes, S of, Beaufort Inlet, North Carolina Current (6d)	13290
11700	Middle, Quicks Hole, Massachusetts Current	13291
11701	Middle, Robinsons Hole, Massachusetts Current	13292
11702	Midnight Pass entrance, Florida Current	13293
11703	Mile Point, southeast of, Florida Current (18d)	13294
11704	Mile Point, southeast of, Florida Current (29d)	13295
11705	Mile Point, southeast of, Florida Current (7d)	13296
11706	Mile Rock Lt., 0.2 nmi. NW of, California Current (15d)	13297
11707	Mile Rock Lt., 0.2 nmi. NW of, California Current (35d)	13298
11708	Milford Point, 0.2 mile west of, Housatonic River, Connecticut Current (10d)	13299
11709	Mill Rock, northeast of, New York Current	13300
11710	Mill Rock, west of, New York Current	13301
11711	Miller Island, 1.5 miles ENE of, Maryland Current (7d)	13302
11712	Mobile Bay Entrance (off Mobile Point), Alabama Current	13303
11713	Mobile Bay Entrance, Alabama Current	13304
11714	Mobile River entrance, Alabama Current	13305
11715	Monomoy Point, 6 miles west of, Massachusetts Current	13306
11716	Monomoy Pt., channel 0.2 mile west of, Massachusetts Current	13307
11717	Montauk Harbor entrance, New York Current (6d)	13308
11718	Montauk Point, 1 mile northeast of, New York Current	13309
11719	Montauk Point, 1.2 miles east of, New York Current	13310
11720	Montauk Point, 5.4 miles NNE of, New York Current (15d)	13311
11721	Montezuma Slough 1 mi in W Entrance, Suisun Bay, California Current	13312
11722	Montezuma Slough E end nr Brg, Suisun Bay, California Current	13313
11723	Montezuma Slough West Entrance, Suisun Bay, California Current	13314
11724	Montgomery, Vernon River, Georgia Current (6d)	13315
11725	Morakas Point, Naknek River, Alaska Current	13316
11726	Morehead City, RR. bridge, N of, Beaufort Inlet, North Carolina Current (6d)	13317
11727	Morehead City, S of, Beaufort Inlet, North Carolina Current (6d)	13318
11728	Moreland, 0.5 n.mi. below, Cooper River, South Carolina Current	13319
11729	Morgan Island, NE of, Coosaw River, South Carolina Current (15d)	13320
11730	Morgan Island, North end, Coosaw River, South Carolina Current (15d)	13321
11731	Morgans Point, Texas Current (15d)	13322
11732	Morgans Point, Texas Current (25d)	13323
11733	Morgans Point, Texas Current (6d)	13324
11734	Moser Channel (swingbridge), Florida Current	13325
11735	Moser Channel, swingbridge, Florida Current	13326
11736	Mount Hope Bridge, Rhode Island Current (7d)	13327
11737	Mount Hope Point, northeast of, Rhode Island Current (10d)	13328
11738	Mountain Point, Magothy River entrance, Maryland Current	13329
11739	Mt. Prospect, 0.6 mile SSE of, New York Current (15d)	13330
11740	Mulford Gardens Channel #2 SSW, South San Francisco Bay, California Current	13331
11741	Mulford Point, 3.1 miles northwest of, Connecticut Current (15d)	13332
11742	Mullet Key Channel entrance, Florida Current	13333
11743	Mullet Key Channel, marker '24', Florida Current (15d)	13334
11744	Muskeget Channel, Massachusetts Current	13335
11745	Muskeget I., channel 1 mile northeast of, Massachusetts Current	13336
11746	Muskeget Rock, 1.3 miles southwest of, Massachusetts Current	13337
11747	Mutiny Bay, 3.3 miles SE of, Washington Current	13338
11748	Myrtle Sound, Intracoastal Waterway, North Carolina Current (6d)	13339
11749	Mystic, Highway Bridge, Mystic River, Connecticut Current (6d)	13340
11750	N. Newport River, above Walburg Creek, Georgia Current (6d)	13341
11751	N. Newport River, ESE of S. Newport Cut, Georgia Current (6d)	13342
11752	N. Newport River, NE of Vandyke Creek, Georgia Current (10d)	13343
11753	N. Newport River, NW of Johnson Creek, Georgia Current (10d)	13344
11754	Nakwakto Rapids, British Columbia Current	13345
11755	Nantucket Harbor entrance channel, Massachusetts Current	13346
11756	Nantucket Harbor Entrance Channel, Massachusetts Current	13347
11757	Napatree Point, 0.7 mile southwest of, Rhode Island Current	13348
11758	National City, California Current	13349
11759	National City, WSW of Pier 12, California Current (32d)	13350
11760	Nayatt Point, WNW of, Rhode Island Current (10d)	13351
11761	New Dungeness Light, 2.8 miles NNW of, Washington Current	13352
11762	New Dungeness Light, 6 miles NNE of, Washington Current	13353
11763	New Ground, Florida Current	13354
11764	New Haven Harbor entrance, Connecticut Current	13355
11765	New London Harbor entrance, Connecticut Current	13356
11766	New Pass, Florida Current	13357
11767	New Teakettle Cr., 0.8 mi. N of, Mud River, Georgia Current	13358
11768	Newburyport (Merrimack River), Massachusetts Current	13359
11769	Newport Marshes, E of, Beaufort Inlet, North Carolina Current (6d)	13360
11770	Newport Marshes, SE of, Beaufort Inlet, North Carolina Current (15d)	13361
11771	Newport Marshes, SE of, Beaufort Inlet, North Carolina Current (6d)	13362
11772	Niantic (Railroad Bridge), Connecticut Current (5d)	13363
11773	Nisqually Reach, Washington Current	13364
11774	No Name Key (northeast of), Florida Current	13365
11775	No Name Key, northeast of, Florida Current	13366
11776	Noank, New York Current (4d)	13367
11777	Nobska Point, 1 mile southeast of, Massachusetts Current	13368
11778	Nobska Point, 1.8 miles east of, Massachusetts Current	13369
11779	Nodule Point, 0.5 mile southeast of, Washington Current	13370
11780	Nodule Pt, 0.5 mile SE of, Washington Current	13371
11781	North Charleston, Cooper River, South Carolina Current	13372
11782	North Edisto River entrance, South Carolina Current	13373
11783	North end, Quicks Hole, Massachusetts Current	13374
11784	North end, Robinsons Hole, Massachusetts Current	13375
11785	North end, Woods Hole, Massachusetts Current	13376
11786	North Haven Peninsula, north of, New York Current	13377
11787	North Hill Point, 1.1 miles NNW of, New York Current	13378
11788	North Inian Pass, Cross Sound, Alaska Current	13379
11789	North Island, California Current (14d)	13380
11790	North Island, California Current (34d)	13381
11791	North Jetty, 0.8 mile southeast of, South Carolina Current	13382
11792	North of Big Tom Creek Entrance, Bear River, Georgia Current (10d)	13383
11793	North Passage, Alaska Current	13384
11794	North Point, 2.5 miles northeast of, Maryland Current (7d)	13385
11795	North River at Darien River, Georgia Current (9d)	13386
11796	North Santee River entrance, South Carolina Current (6d)	13387
11797	Northport Bay entrance (in channel), New York Current (15d)	13388
11798	Northport Bay, south of Duck I. Bluff, New York Current	13389
11799	Northwest Channel, Key West, Florida Current	13390
11800	Northwest Channel, Key West, Florida Current (2)	13391
11801	Northwest of Newell Creek Entrance, Bear River, Georgia Current (10d)	13392
11802	Norton Point, 0.5 mile north of, Massachusetts Current	13393
11803	Norwalk River, off Gregory Point, Connecticut Current (15d)	13394
11804	Nowell Creek entrance, Wando River, South Carolina Current	13395
11805	Nushagak Bay entrance, Alaska Current	13396
11806	Oak Neck Point, 0.6 mile north of, New York Current (15d)	13397
11807	Oak Neck Point, 0.6 mile north of, New York Current (30d)	13398
11808	Oakland Airport SW, South San Francisco Bay, California Current	13399
11809	Oakland Harbor High Street Bridge, San Francisco Bay, California Current	13400
11810	Oakland Harbor WebStreeter Street, San Francisco Bay, California Current	13401
11811	Oakland Inner Harbor Entrance, San Francisco Bay, California Current	13402
11812	Oakland Inner Harbor Reach, 33 ft. below datum Current	13403
11813	Oakland Outer Harbor Entrance, San Francisco Bay, California Current	13404
11814	Oatland Island, north tip, Georgia Current (10d)	13405
11815	Obstruction Pass Light, 0.4 mile NW of, Washington Current	13406
11816	Odingsell River Entrance, Georgia Current (10d)	13407
11817	Odingsell River Entrance, Georgia Current (20d)	13408
11818	Off Jamaica Point, Maryland Current	13409
11819	Off Northeast Cape, St. Lawrence Island, Alaska Current	13410
11820	Off Pleasant Beach, Rich Passage, Washington Current	13411
11821	Off Smith Cove, Thames River, Connecticut Current (5d)	13412
11822	Off Stoddard Hill, Thames River, Connecticut Current (15d)	13413
11823	Off Winthrop Ave., Astoria, New York Current	13414
11824	Ogliuga Island, pass East of, Delarof Is, Alaska Current	13415
11825	Old Field Point, 1 mile east of, New York Current (15d)	13416
11826	Old Field Point, 1 mile east of, New York Current (22d)	13417
11827	Old Field Point, 2 miles northeast of, New York Current (15d)	13418
11828	Old Field Point, 2 miles northeast of, New York Current (40d)	13419
11829	Old Field Point, 2.9 n.mi. NNW of, New York Current (15d)	13420
11830	Old Harbor Pt., 0.5 mile southeast of, Block Island, Rhode Island Current	13421
11831	Old Man Shoal, Nantucket Shoals, Massachusetts Current	13422
11832	Old Tampa Bay Entrance (Port Tampa), Florida Current	13423
11833	Old Tampa Bay Entrance (Port Tampa), Florida Current (15d)	13424
11834	Old Teakettle Creek (north), Georgia Current (13d)	13425
11835	Old Teakettle Creek (south), Georgia Current (13d)	13426
11836	Old Teakettle Creek Entrance, south of, Georgia Current (15d)	13427
11837	Old Town Point Wharf, northwest of, Maryland Current (17d)	13428
11838	Old Town Point Wharf, northwest of, Maryland Current (29d)	13429
11839	Olele Point, 1.8 mile ENE of, Washington Current	13430
11840	Olele Point, 1.8 miles ENE of, Washington Current	13431
11841	Onemile Cut, 1 mile southeast of, Georgia Current	13432
11842	Ordinary Point, 0.4 mile west of, Maryland Current	13433
11843	Ordnance Reach, Cooper River, South Carolina Current	13434
11844	Orient Point, 1 mile WNW of, New York Current	13435
11845	Orient Point, 2.4 miles SSE of, New York Current	13436
11846	Otter Point, off of, north side, Alaska Current	13437
11847	Oyster Point 2.8 mi E, South San Francisco Bay, California Current	13438
11848	Oyster Point, California Current	13439
11849	Pablo Creek bascule bridge, Florida Current (3d)	13440
11850	Paradise Point, 0.4 mile east of, New York Current (13d)	13441
11851	Parker Reef Light, 0.5 mile north of, Washington Current	13442
11852	Parker Reef Light, 1 mile North of, Washington Current	13443
11853	Parris Island Lookout Tower, Broad River, South Carolina Current (15d)	13444
11854	Parris Island, Beaufort River, South Carolina Current (10d)	13445
11855	Parris Island, Beaufort River, South Carolina Current (15d)	13446
11856	Parrot Creek, Coosaw Island, South Carolina Current (15d)	13447
11857	Parsonage Point, 1.3 n.mi. ESE of, New York Current (15d)	13448
11858	Pass Abel, Barataria Bay, Louisiana Current	13449
11859	Pass-a-Grille Channel, Florida Current	13450
11860	Passage Key Inlet (off Bean Pt.), Florida Current (15d)	13451
11861	Patience I. and Warwick Neck, between, Rhode Island Current	13452
11862	Patience Island, narrows east of, Rhode Island Current	13453
11863	Patos Island Light, 1.4 miles W of, Washington Current	13454
11864	Patos Island Light, 1.4 miles west of, Washington Current	13455
11865	Peale Passage, north end, Washington Current	13456
11866	Peale Passage, North end, Washington Current	13457
11867	Peapod Rocks Light, 1.2 mile South of, Washington Current	13458
11868	Peapod Rocks Light, 1.2 miles south of, Washington Current	13459
11869	Pear Point, 1.1 miles east of, Washington Current	13460
11870	Pear Point, San Juan Island, 1.1 mile East of, Washington Current	13461
11871	Peavine Pass, West Entrance of, Washington Current	13462
11872	Peavine Pass, west entrance, Washington Current	13463
11873	Pee Dee River, swing bridge, South Carolina Current	13464
11874	Pelican Bank, St. Helena Sound, South Carolina Current (15d)	13465
11875	Penikese Island, 0.2 mile south of, Massachusetts Current	13466
11876	Penikese Island, 0.8 mile northwest of, Massachusetts Current	13467
11877	Peningo Neck, 0.6 mi. off Parsonage Pt, New York Current (15d)	13468
11878	Pensacola Bay entrance, midchannel, Florida Current	13469
11879	Persimmon Point, Maryland Current	13470
11880	Petaluma River Approach #3/#4, San Pablo Bay, California Current	13471
11881	Petaluma River Approach, San Pablo Bay, California Current	13472
11882	Philadelphia, Pennsylvania Current	13473
11883	Pickering Passage, north end, Washington Current	13474
11884	Pickering Passage, North, Washington Current	13475
11885	Pickering Passage, off Graham Point, Washington Current	13476
11886	Pickering Passage, off Graham Pt, Washington Current	13477
11887	Pickering Passage, south end, Washington Current	13478
11888	Pickering Passage, South, Washington Current	13479
11889	Pier 67, off 19th Street, New York Current	13480
11890	Pigeon Island, SSE of, Skidaway River, Georgia Current (10d)	13481
11891	Pillar Point, Washington Current	13482
11892	Pine Creek Point, 2.3 miles SSE of, Connecticut Current (15d)	13483
11893	Pine Island, South Edisto River, South Carolina Current (15d)	13484
11894	Pine Key (Pinellas Bayway bridge), Florida Current	13485
11895	Piney Point, 0.6 mile NNW of, Florida Current	13486
11896	Pinole Point 1.2 mi W, San Pablo Bay, California Current	13487
11897	Pitt Passage, E of Pitt Island, Washington Current	13488
11898	Pitt Passage, east of Pitt Island, Washington Current	13489
11899	Pleasant Island, 3 miles south of, Alaska Current	13490
11900	Pleasant Point, South Carolina Current (12d)	13491
11901	Plum Gut, New York Current (30d)	13492
11902	Plum Island, 0.8 mile NNW of, New York Current	13493
11903	Plum Point, 1.4 miles ESE of, Maryland Current	13494
11904	Plum Point, 2.1 n.mi. NNE of, Maryland Current (15d)	13495
11905	Point Adams, NNE OF, Oregon Current (14d)	13496
11906	Point Arena, California Current	13497
11907	Point Arguello, California Current	13498
11908	Point Avisadero .3 mi E, South San Francisco Bay, California Current	13499
11909	Point Avisadero 1 mi E, South San Francisco Bay, California Current	13500
11910	Point Avisadero 2 mi E, South San Francisco Bay, California Current	13501
11911	Point Blunt .3 mi S, San Francisco Bay, California Current	13502
11912	Point Blunt .8 mi SE, San Francisco Bay, California Current	13503
11913	Point Bonita Lt., 0.4 nmi. SSE of, California Current (43d)	13504
11914	Point Bonita Lt., 5.27 nmi. WSW of, California Current (39d)	13505
11915	Point Bonita, 0.8 nmi. NE of, California Current (22d)	13506
11916	Point Bonita, 0.8 nmi. NE of, California Current (41d)	13507
11917	Point Bonita, 0.95 nmi. SSE of, California Current (22d)	13508
11918	Point Bonita, 0.95 nmi. SSE of, California Current (42d)	13509
11919	Point Cabrillo, California Current	13510
11920	Point Cavallo 1.3 mi E, San Francisco Bay, California Current	13511
11921	Point Delgada, California Current	13512
11922	Point Diablo, 0.2 mile SE of, California Current	13513
11923	Point Disney, 1.6 mile East of, Washington Current	13514
11924	Point Disney, 1.6 miles east of, Washington Current	13515
11925	Point Ellice, east of, Washington Current (17d)	13516
11926	Point Gammon, 1.2 miles south of, Massachusetts Current	13517
11927	Point Hammond, 1.1 miles northwest of, Washington Current	13518
11928	Point Hammond, 1.1 miles NW of, Washington Current	13519
11929	Point Hudson, 0.5 mile E of, Washington Current	13520
11930	Point Hudson, 0.5 mile east of, Washington Current	13521
11931	Point Lobos, 1.3 nmi. SW of, California Current (46d)	13522
11932	Point Lobos, 3.73 nmi. W of, California Current (46d)	13523
11933	Point Loma Light, 0.8 nmi. east of, California Current (15d)	13524
11934	Point Loma Light, 0.8 nmi. east of, California Current (33d)	13525
11935	Point No Point, 2.1 miles south of, Connecticut Current (15d)	13526
11936	Point Partridge, 3.7 miles W of, Washington Current	13527
11937	Point Partridge, 3.7 miles west of, Washington Current	13528
11938	Point Patience, 0.1 mile southwest of, Maryland Current (15d)	13529
11939	Point Peter, North Carolina Current (6d)	13530
11940	Point Piedras Blancas, California Current	13531
11941	Point Pinos, California Current	13532
11942	Point Retreat, 1 mile west of, Alaska Current	13533
11943	Point Reyes, California Current	13534
11944	Point Richmond .5 mi W, San Francisco Bay, California Current	13535
11945	Point Sacramento .3 mi NE, Sacramento River, California Current	13536
11946	Point San Luis, California Current	13537
11947	Point San Pablo Midchannel, San Pablo Bay, California Current	13538
11948	Point San Quentin 1.9 mi E, San Francisco Bay, California Current	13539
11949	Point Sur, California Current	13540
11950	Point Wilson, 0.5 mi., northeast of, Washington Current	13541
11951	Point Wilson, 0.5 miles NE of, Washington Current	13542
11952	Point Wilson, 0.8 mile east of, Washington Current	13543
11953	Point Wilson, 0.8 miles east of, Washington Current	13544
11954	Point Wilson, 1.1 miles NW of, Washington Current	13545
11955	Point Wilson, 1.4 miles NE of, Washington Current	13546
11956	Point Wilson, 1.4 miles northeast of, Washington Current	13547
11957	Point Wilson, 2.3 miles NE of, Washington Current	13548
11958	Point Ybel (0.4 Mi. NW of), Florida Current	13549
11959	Point Ybel, 0.4 mile northwest of, Florida Current	13550
11960	Pollock Rip Channel (Butler Hole), Massachusetts Current	13551
11961	Pollock Rip Channel, east end, Massachusetts Current	13552
11962	Pollock Rip Channel, Massachusetts Current	13553
11963	Pond entrance, Point Judith, Rhode Island Current	13554
11964	Pond Point, 4.2 miles SSE of, Connecticut Current	13555
11965	Pooles Island 2.0 n.mi. SSW of, Maryland Current (15d)	13556
11966	Pooles Island, 0.8 mile south of, Maryland Current	13557
11967	Pooles Island, 1.6 n.mi. east of, Maryland Current (16d)	13558
11968	Pooles Island, 4 miles southwest of, Maryland Current	13559
11969	Poplar Island, 2.2 n.mi. WSW of, Maryland Current (14d)	13560
11970	Poplar Island, 3.0 n.mi. WSW of, Maryland Current (15d)	13561
11971	Poplar Island, 3.0 n.mi. WSW of, Maryland Current (48d)	13562
11972	Poplar Island, east of south end, Maryland Current	13563
11973	Poplar Point, south of, Maryland Current	13564
11974	Popof Strait, Alaska Current	13565
11975	Porlier Pass, British Columbia Current	13566
11976	Port Gamble Bay entrance, Washington Current	13567
11977	Port Gamble Bay, Washington Current	13568
11978	Port Heiden, Alaska Current	13569
11979	Port Ingleside, Texas Current (5d)	13570
11980	Port Jefferson Harbor entrance, New York Current	13571
11981	Port Manatee Channel entrance, Florida Current (15d)	13572
11982	Port Manatee Channel, marker '4', Florida Current (15d)	13573
11983	Port Manatee, Tampa Bay, Florida Current	13574
11984	Port Royal Plantation Tower, east of, South Carolina Current (15d)	13575
11985	Port Townsend Canal, Washington Current	13576
11986	Port Townsend, 0.5 miles S of Point Hudson, Washington Current	13577
11987	Port Washington Narrows, north ent, Washington Current	13578
11988	Port Washington Narrows, North Entrance of, Washington Current	13579
11989	Port Washington Narrows, south ent, Washington Current	13580
11990	Port Washington Narrows, South Entrance of, Washington Current	13581
11991	Port Wentworth, 0.2 mile above, Georgia Current	13582
11992	Portsmouth Harbor Entrance, New Hampshire Current	13583
11993	Potomac River Bridge, 0.4 mile south of, Maryland Current	13584
11994	Potrero Point 1.1 mi E, South San Francisco Bay, California Current	13585
11995	President Point, 1.5 mile E of, Washington Current	13586
11996	Princess Louisa Inlet, British Columbia Current	13587
11997	Protection Point, 2.5 miles east of, Alaska Current	13588
11998	Puffin Island light, 4.8 miles N of, Washington Current	13589
11999	Puffin Island Light, 4.8 miles north of, Washington Current	13590
12000	Punta Gorda, California Current	13591
12001	Punta Ostiones, 1.5 miles west of, Puerto Rico Current	13592
12002	Quantico Creek entrance, Virginia Current	13593
12003	Quantico, Virginia Current	13594
12004	Quarantine Station, La Playa, California Current	13595
12005	Quatre Bayoux Pass, Barataria Bay, Louisiana Current	13596
12006	Quatsino Narrows, British Columbia Current	13597
12007	Quicks Hole (middle), Massachusetts Current	13598
12008	Quillayute River entrance, Washington Current	13599
12009	Quinn Island, Prairie Channel, Washington Current (8d)	13600
12010	Quonochontaug Beach, 1.1 miles S of, Rhode Island Current	13601
12011	Quonochontaug Beach, 3.8 miles S of, Rhode Island Current (15d)	13602
12012	Rabbit Island, northwest of, South Carolina Current	13603
12013	Raccoon Key & Egg Island Shoal, between, Georgia Current (10d)	13604
12014	Raccoon Key, Georgia Current (10d)	13605
12015	Raccoon Point, 0.6 mile NNE of, Washington Current	13606
12016	Raccoon Strait off Hospital Cove, San Francisco Bay, California Current	13607
12017	Raccoon Strait off Point Stuart, San Francisco Bay, California Current	13608
12018	Race Passage, British Columbia Current	13609
12019	Race Point, 0.4 mile southwest of, The Race, New York Current	13610
12020	Racoon Point, 0.6  mile NNE of, Washington Current	13611
12021	Radio Island, E of, Beaufort Inlet, North Carolina Current (6d)	13612
12022	Ragged Point, 1.5 miles east of, Maryland Current	13613
12023	Railroad drawbridge, above, Housatonic River, Connecticut Current (5d)	13614
12024	Railroad drawbridge, Connecticut River, Connecticut Current (15d)	13615
12025	Ram Island Reef, south of, New York Current (7d)	13616
12026	Ram Island, 1.4 miles NNE of, New York Current	13617
12027	Ram Island, 2.2 miles east of, New York Current	13618
12028	Ramshorn Creek Light, E of, Cooper River, South Carolina Current (6d)	13619
12029	Range D, off Mosquito Creek, South Carolina Current	13620
12030	Rathall Creek entrance, Wando River, South Carolina Current	13621
12031	Rattlesnake Key, 1.1 miles northwest of, Florida Current	13622
12032	Rattlesnake Key, 3.1 miles west of, Florida Current	13623
12033	Reaves Point Channel, North Carolina Current (16d)	13624
12034	Reaves Point Channel, North Carolina Current (26d)	13625
12035	Reaves Point Channel, North Carolina Current (6d)	13626
12036	Reaves Point, 0.3 mile east of, North Carolina Current (16d)	13627
12037	Reaves Point, 0.3 mile east of, North Carolina Current (26d)	13628
12038	Reaves Point, 0.3 mile east of, North Carolina Current (6d)	13629
12039	Reaves Point, 0.4 mile north of, North Carolina Current (16d)	13630
12040	Reaves Point, 0.4 mile north of, North Carolina Current (26d)	13631
12041	Reaves Point, 0.4 mile north of, North Carolina Current (6d)	13632
12042	Reaves Point, 0.8 mile northeast of, North Carolina Current (16d)	13633
12043	Reaves Point, 0.8 mile northeast of, North Carolina Current (26d)	13634
12044	Reaves Point, 0.8 mile northeast of, North Carolina Current (6d)	13635
12045	Rebellion Reach, 0.8 n.mi. N. of Ft. Sumter, South Carolina Current	13636
12046	Red Bay Point, draw bridge, Florida Current (14d)	13637
12047	Red Bay Point, draw bridge, Florida Current (4d)	13638
12048	Red Bay Point, draw bridge, Florida Current (6d)	13639
12049	Red Point, 0.2 mile W of, Northeast River, Maryland Current (7d)	13640
12050	Red Rock .1 E, San Francisco Bay, California Current	13641
12051	Redding Rock Light, California Current	13642
12052	Remley Point, 0.2 mile northwest of, Wando River, South Carolina Current	13643
12053	Restoration Point, 0.6 miles ESE of, Washington Current	13644
12054	Ribbon Reef-Sow & Pigs Reef, between, Massachusetts Current	13645
12055	Rich Passage, East End, Washington Current	13646
12056	Rich Passage, North of Blake Island, Washington Current	13647
12057	Rich Passage, off Pleasant Beach, Washington Current	13648
12058	Rich Passage, West end, Washington Current	13649
12059	Richardson Bay Entrance, San Francisco Bay, California Current	13650
12060	Rikers I. chan., off La Guardia Field, New York Current	13651
12061	Rincon Point midbay, South San Francisco Bay, California Current	13652
12062	Roanoke Point, 2.3 miles NNW of, New York Current	13653
12063	Roanoke Point, 5.6 miles north of, New York Current (15d)	13654
12064	Robins Island, 0.5 mile south of, New York Current	13655
12065	Robins Point, 0.7 mile ESE of, Maryland Current (5d)	13656
12066	Robinsons Hole, 1.2 miles southeast of, Massachusetts Current	13657
12067	Rocky Hill, Connecticut River, Connecticut Current (9d)	13658
12068	Rocky Point, 0.3 mile north of, New York Current (15d)	13659
12069	Rocky Point, 1 mile east of, Oyster Bay, New York Current (15d)	13660
12070	Rocky Point, 2 miles WNW of, New York Current (15d)	13661
12071	Rocky Pt. (Elk Neck), 0.25 n.mi. SW of, Maryland Current (9d)	13662
12072	Roe Island S, Suisun Bay, California Current	13663
12073	Rosario Strait, Washington Current	13664
12074	Rose Island, northeast of, Rhode Island Current (15d)	13665
12075	Rose Island, northwest of, Rhode Island Current (15d)	13666
12076	Rose Island, west of, Rhode Island Current	13667
12077	Ross Island, 1 mile east of, marker '4', Florida Current (15d)	13668
12078	S. Newport River, above Swain River Ent, Georgia Current (10d)	13669
12079	S. Newport River, below S. Newport Cut, Georgia Current (10d)	13670
12080	S.C.L. RR. bridge, 0.1 mile below, Ashley River, South Carolina Current	13671
12081	S.C.L. RR. bridge, 1.5 miles above, Ashley River, South Carolina Current	13672
12082	Sachem Head 6.2 miles south of, Connecticut Current (15d)	13673
12083	Sachem Head, 1 mile SSE of, Connecticut Current	13674
12084	Sagamore Bridge, Massachusetts Current	13675
12085	Saginaw Channel, 2 mi. E of Pt.Retreat, Alaska Current (25d)	13676
12086	Saginaw Channel, 2 mi. E of Pt.Retreat, Alaska Current (70d)	13677
12087	Salisbury, Maryland (2 miles below) Current	13678
12088	Salt Point, California Current	13679
12089	Sampit River entrance, South Carolina Current	13680
12090	Sampson Island, NE end, South Edisto River, South Carolina Current (15d)	13681
12091	Sampson Island, S end, South Edisto River, South Carolina Current (15d)	13682
12092	Sams Point, Northwest of, Coosaw River, South Carolina Current (10d)	13683
12093	San Diego Bay Entrance, California Current	13684
12094	San Diego, 0.5 mile west of, California Current	13685
12095	San Francisco Bay Entrance (Golden Gate), California Current	13686
12096	San Francisco Bay Entrance (outside), California Current	13687
12097	San Juan Channel (south entrance), Washington Current	13688
12098	San Juan Channel (South Entrance), Washington Current	13689
12099	San Mateo Bridge, South San Francisco Bay, California Current	13690
12100	Sand Island Tower, 0.9nm SE of (north channel), Washington Current (15d)	13691
12101	Sand Island Tower, 1nm SE of (midchannel), Washington Current (15d)	13692
12102	Sand Island, SSE of, Washington Current (12d)	13693
12103	Sandy Point, 0.5 mile south of, Maryland Current	13694
12104	Sandy Point, 0.8 n.mi. ESE of, Maryland Current (15d)	13695
12105	Sandy Point, 0.8 n.mi. ESE of, Maryland Current (43d)	13696
12106	Sandy Point, 2.1 miles NNE of, Block Island, Rhode Island Current (15d)	13697
12107	Sandy Point, 2.3 n.mi. east of, Maryland Current (15d)	13698
12108	Sandy Point, 2.3 n.mi. east of, Maryland Current (41d)	13699
12109	Sandy Point, 4.1 miles northwest of, Rhode Island Current (15d)	13700
12110	Sandy Pt., 1.5 miles north of, Block Island, Rhode Island Current (7d)	13701
12111	Sansum Narrows, British Columbia Current	13702
12112	Sapelo River Entrance, Georgia Current (11d)	13703
12113	Sarasota Bay, south end, bridge, Florida Current	13704
12114	Saugatuck River, 0.3 mi. NW of Bluff Pt, Connecticut Current (15d)	13705
12115	Savannah River Entrance (between jetties), Georgia Current (11d)	13706
12116	Savannah River Entrance, Georgia Current	13707
12117	Savannah River Entrance, Georgia Current (2) (expired 1999-12-31)	13708
12118	Savannah, Georgia Current	13709
12119	Savannah, southeast of highway bridge, Georgia Current (10d)	13710
12120	Saybrook Breakwater, 1.5 miles SE of, Connecticut Current	13711
12121	Saybrook Point, 0.2 mile northeast of, Connecticut River, Connecticut Current	13712
12122	Sea Lion Pass, Rat Islands, Alaska Current	13713
12123	Seaboard Coast Line Railroad, Georgia Current	13714
12124	Sechelt Rapids, British Columbia Current (use with caution)	13715
12125	Second Narrows, British Columbia Current	13716
12126	Sergius Narrows, Peril Strait, Alaska Current	13717
12127	Seymour Narrows, British Columbia Current	13718
12128	Shackleford Banks, 0.8 mile S of, Beaufort Inlet, North Carolina Current (6d)	13719
12129	Shackleford Point, NE of, Beaufort Inlet, North Carolina Current (6d)	13720
12130	Shagwong Reef & Cerberus Shoal, between, New York Current	13721
12131	Shannon Point, 2 mile W of, Washington Current	13722
12132	Shannon Point, 2.0 miles west of, Washington Current	13723
12133	Sharp Island Lt., 2.1 n.mi. west of, Maryland Current (18d)	13724
12134	Sharp Island Lt., 2.3 n.mi. SE of, Maryland Current (20d)	13725
12135	Sharp Island Lt., 3.4 n.mi. west of, Maryland Current (18d)	13726
12136	Sharp Island Lt., 3.4 n.mi. west of, Maryland Current (35d)	13727
12137	Sheep Island Slue, North Carolina Current	13728
12138	Sheepscot River (off Barter Island), Maine Current	13729
12139	Sheffield I. Hbr., 0.5 mile southeast of, Connecticut Current (12d)	13730
12140	Sheffield I. Tower, 1.1 miles SE of, Connecticut Current (15d)	13731
12141	Sheffield I. Tower, 1.1 miles SE of, Connecticut Current (60d)	13732
12142	Sheridan Point, 0.1 mile southwest of, Maryland Current	13733
12143	Sherman Island (East), California Current	13734
12144	Shinnecock Canal, Railroad Bridge, New York Current	13735
12145	Shippan Point, 1.3 miles SSE of, Connecticut Current (15d)	13736
12146	Shippan Point, 1.3 miles SSE of, Connecticut Current (40d)	13737
12147	Shipyard Creek entrance, Cooper River, South Carolina Current	13738
12148	Shoal Point, 6 miles south of, New York Current (15d)	13739
12149	Shutes Folly Island, 0.4 mile west of, South Carolina Current	13740
12150	Shutes Reach, Buoy '8', South Carolina Current	13741
12151	Sierra Point 1.3 mi ENE, South San Francisco Bay, California Current	13742
12152	Sierra Point 4.4 mi E, South San Francisco Bay, California Current	13743
12153	Sinclair Island Light, 0.6 mile SE of, Washington Current	13744
12154	Sinclair Island, 1 mile NE of, Washington Current	13745
12155	Sisters Creek entrance (bridge), Florida Current (10d)	13746
12156	Sisters Creek entrance (bridge), Florida Current (4d)	13747
12157	Sitkinak Strait, Alaska Current	13748
12158	Six Mile Reef, 1.5 miles north of, Connecticut Current	13749
12159	Six Mile Reef, 2 miles east of, New York Current	13750
12160	Skagit Bay, 1 mi. S of Goat Island, Washington Current	13751
12161	Skagit Bay, 1 mile N of Rocky Point, Washington Current	13752
12162	Skagit Bay, 1 mile S of Goat Island, Washington Current	13753
12163	Skagit Bay, channel SW of Hope Island, Washington Current	13754
12164	Skagway, Taiya Inlet, Alaska Current	13755
12165	Skidaway Island, N End, Wilmington River, Georgia Current (10d)	13756
12166	Skidaway Narrows, Georgia Current	13757
12167	Skidaway River, north entrance, Georgia Current	13758
12168	Skipjack Island, 1.5 miles northwest of, Washington Current	13759
12169	Skipjack Island, 2 mile nne of, Washington Current	13760
12170	Skipjack Island, 2 miles NNE of, Washington Current	13761
12171	Skull Creek, north entrance, South Carolina Current	13762
12172	Skull Creek, south entrance, South Carolina Current (10d)	13763
12173	Smith Island, 1.4 miles SSW of, Washington Current	13764
12174	Smith Island, 2 miles east of, Washington Current	13765
12175	Smith Island, 3.7 miles ESE of, Washington Current	13766
12176	Smuggedy Swamp, South Edisto River, South Carolina Current (6d)	13767
12177	Snake Island, South Carolina Current (12d)	13768
12178	Snell Isle, 1.8 miles east of, Florida Current	13769
12179	Snow Point, 0.5 mile north of, Cooper River, South Carolina Current	13770
12180	Snows Cut, Intracoastal Waterway, North Carolina Current (6d)	13771
12181	Sound Beach, 2.2 miles north of, New York Current	13772
12182	South Bend, Willapa River, Washington Current	13773
12183	South Brother Island, NW of, New York Current (15d)	13774
12184	South Chan., 0.4 mi. NW of Ft. Johnson, South Carolina Current	13775
12185	South Chan., 0.8 mi. ENE of Ft. Johnson, South Carolina Current	13776
12186	South Channel, Buoy '32', South Carolina Current	13777
12187	South Channel, California Current	13778
12188	South Channel, San Francisco Bay Approach, California Current	13779
12189	South Channel, western end, Georgia Current	13780
12190	South Edisto River entrance, South Carolina Current	13781
12191	South end (midstream), The Narrows, Washington Current	13782
12192	South end, Quicks Hole, Massachusetts Current	13783
12193	South end, Robinsons Hole, Massachusetts Current	13784
12194	South end, Woods Hole, Massachusetts Current	13785
12195	South Inian Pass, Alaska Current	13786
12196	South Jetty, break in, South Carolina Current	13787
12197	South of Kilkenny Creek Entrance, Bear River, Georgia Current	13788
12198	South Passage, Alaska Current	13789
12199	South Point, Washington Current	13790
12200	South River, Georgia Current (13d)	13791
12201	South River, Georgia Current (21d)	13792
12202	South Santee River entrance, South Carolina Current (5d)	13793
12203	Southampton Shoal Light .2 mi E, San Francisco Bay, California Current	13794
12204	Southeast Channel entrance, South Carolina Current	13795
12205	Southeast Channel, Florida Current	13796
12206	Southport, North Carolina Current (16d)	13797
12207	Southport, North Carolina Current (26d)	13798
12208	Southport, North Carolina Current (6d)	13799
12209	Southwest Channel (S of Egmont Key), Florida Current (15d)	13800
12210	Southwest Channel, Florida Current	13801
12211	Southwest Ledge, 2.0 miles west of, Rhode Island Current (15d)	13802
12212	Southwest Ledge, Rhode Island Current	13803
12213	Spanish Wells, Calibogue Sound, South Carolina Current (30d)	13804
12214	Spesutie Island, channel north of, Maryland Current (7d)	13805
12215	Spoonbill Creek near Bridge, Suisun Bay, California Current	13806
12216	Spring Passage, South entrance of, Washington Current	13807
12217	Spring Passage, south entrance, Washington Current	13808
12218	Squaxin Passage, N of Hunter Point, Washington Current	13809
12219	Squaxin Passage, north of Hunter Point, Washington Current	13810
12220	St. Catherines Sound Entrance, Georgia Current (10d)	13811
12221	St. George Reef, California Current	13812
12222	St. Johns Bar Cut 0.13 n.mi. ENE of south jetty, Florida Current (14d)	13813
12223	St. Johns Bar Cut 0.13 n.mi. ENE of south jetty, Florida Current (33d)	13814
12224	St. Johns Bar Cut 0.13 n.mi. ENE of south jetty, Florida Current (46d)	13815
12225	St. Johns Bar Cut, 0.7 n.mi. east of jetties, Florida Current (14d)	13816
12226	St. Johns Bar Cut, 0.7 n.mi. east of jetties, Florida Current (31d)	13817
12227	St. Johns Bar Cut, 0.7 n.mi. east of jetties, Florida Current (5d)	13818
12228	St. Johns Bluff, Florida Current (17d)	13819
12229	St. Johns Bluff, Florida Current (26d)	13820
12230	St. Johns Bluff, Florida Current (7d)	13821
12231	St. Johns River Ent. (between jetties), Florida Current (10d)	13822
12232	St. Johns River Ent. (between jetties), Florida Current (30d)	13823
12233	St. Johns River Entrance (between jetties), Florida Current (16d)	13824
12234	St. Johns River Entrance, Florida Current	13825
12235	St. Johns River Entrance, Florida Current (2) (expired 1999-12-31)	13826
12236	St. Johns River Entrance, Florida Current (3)	13827
12237	St. Marks River approach, Florida Current	13828
12238	St. Marks, St. Marks River, Florida Current	13829
12239	St. Mathew I., southwest coast, Alaska Current	13830
12240	Stage Harbor, west of Morris Island, Massachusetts Current	13831
12241	Stake Point .9 Mi NNW, Suisun Bay, California Current	13832
12242	Stamford Harbor entrance, Connecticut Current (12d)	13833
12243	State Hwy. 7 bridge, Ashley River, South Carolina Current	13834
12244	Stono Inlet, South Carolina Current	13835
12245	Strait of Juan de Fuca Entrance, Washington Current	13836
12246	Stratford Point, 4.3 miles south of, Connecticut Current (15d)	13837
12247	Stratford Point, 4.3 miles south of, Connecticut Current (60d)	13838
12248	Stratford Point, 6.1 miles south of, New York Current (15d)	13839
12249	Stratford Point, 6.1 miles south of, New York Current (51d)	13840
12250	Stratford Shoal, 6 miles east of, New York Current	13841
12251	Strawberry Island, 0.8 mile W of, Washington Current	13842
12252	Strawberry Island, 0.8 mile west of, Washington Current	13843
12253	Sugarloaf Island, 0.2 mile S of, Beaufort Inlet, North Carolina Current (6d)	13844
12254	Suisun Slough Entrance, Suisun Bay, California Current	13845
12255	Sullivans I., 0.7 mi. NE of Ft. Sumter, South Carolina Current	13846
12256	Sunny Point, North Carolina Current (16d)	13847
12257	Sunny Point, North Carolina Current (26d)	13848
12258	Sunny Point, North Carolina Current (6d)	13849
12259	Surge Narrows, British Columbia Current	13850
12260	Sutherland Bluff, Sapelo River, Georgia Current	13851
12261	SW Point, St. Paul Island, 1 mile off, Pribilof Islands, Alaska Current	13852
12262	Swan Point, 1.6 miles northwest of, Maryland Current	13853
12263	Swan Point, 2.15 n.mi. west of, Maryland Current (18d)	13854
12264	Swan Point, 2.7 n.mi. SW of, Maryland Current (14d)	13855
12265	Swan Point, 2.7 n.mi. SW of, Maryland Current (27d)	13856
12266	Swan Point, Virginia Current	13857
12267	Sweetwater Channel, southwest of, California Current (14d)	13858
12268	Table Bluff Light, California Current	13859
12269	Tampa Bay (Sunshine Skyway Bridge), Florida Current	13860
12270	Tampa Bay (Sunshine Skyway Bridge), Florida Current (15d)	13861
12271	Tampa Bay Entrance (Egmont Channel), Florida Current	13862
12272	Tampa Bay Entrance (Egmont Channel), Florida Current (15d)	13863
12273	Tampa Bay Entrance, Florida Current	13864
12274	Tanaga Pass, 4 mi. off C. Amagalik, Alaska Current	13865
12275	Tarpaulin Cove, 1.5 miles east of, Massachusetts Current	13866
12276	Teaches Hole Channel, Ocracoke Inlet, North Carolina Current (10d)	13867
12277	Tensaw River entrance (bridge), Alabama Current	13868
12278	Terminal Channel (north end), Florida Current (17d)	13869
12279	Terminal Channel (north end), Florida Current (27d)	13870
12280	Terminal Channel (north end), Florida Current (7d)	13871
12281	Thatcher Pass, Washington Current	13872
12282	The Cove, entrance on the Cove Range, South Carolina Current	13873
12283	The Great Bend, Washington Current	13874
12284	The Narrows (Indian Rocks Beach Bridge), Florida Current	13875
12285	The Narrows (North End), Puget Sound, Washington Current	13876
12286	The Narrows, 0.1 miles E of Pt. Evans, Washington Current	13877
12287	The Narrows, Midchannel, New York Harbor, New York Current	13878
12288	The Narrows, Midchannel, New York Harbor, New York Current (2)	13879
12289	The Narrows, north end (midstream), Washington Current	13880
12290	The Narrows, North end E side, Washington Current	13881
12291	The Narrows, North End, W side, Washington Current	13882
12292	The Narrows, S end midstream, Washington Current	13883
12293	The Race, 0.6 n.mi. NW of Valiant Rock, New York Current (38d)	13884
12294	The Race, Long Island Sound, New York Current	13885
12295	The Race, Long Island Sound, New York Current (2) (expired 1993-12-31)	13886
12296	The Tee, 0.4 mile southwest of, Cooper River, South Carolina Current	13887
12297	The Tee, Cooper River, South Carolina Current	13888
12298	Thomas Pt. Shoal Lt., 0.5 n.mi. SE of, Maryland Current (16d)	13889
12299	Thomas Pt. Shoal Lt., 0.5 n.mi. SE of, Maryland Current (33d)	13890
12300	Thomas Pt. Shoal Lt., 1.8 mi. SW of, Maryland Current	13891
12301	Thomas Pt. Shoal Lt., 2.0 n.mi. east of, Maryland Current (22d)	13892
12302	Throg's Neck, Long Island Sound, New York Current	13893
12303	Throgs Neck Bridge, New York Current (15d)	13894
12304	Throgs Neck, 0.2 mile S of (Willets Point), New York Current (15d)	13895
12305	Throgs Neck, 0.3 n.mi. NE of, Long Island Sound, New York Current (15d)	13896
12306	Throgs Neck, 0.4 mile south of, New York Current (15d)	13897
12307	Thunderbolt, SE of, Wilmington River, Georgia Current (10d)	13898
12308	Tillamook Bay entrance, Oregon Current	13899
12309	Tiverton, RR. bridge, Sakonnet R., Rhode Island Current	13900
12310	Tiverton, Stone bridge, Sakonnet R., Rhode Island Current	13901
12311	Toe Point, Patos Island, 0.5 mile S of, Washington Current	13902
12312	Toe Point, Patos Island, 0.5 mile South of, Washington Current	13903
12313	Tolchester Beach, 0.33 n.mi. west of, Maryland Current (15d)	13904
12314	Tolchester Channel, Buoy '22', Maryland Current (15d)	13905
12315	Tolchester Channel, south of Buoy '38B', Maryland Current (15d)	13906
12316	Tolchester Channel, SW of Bouy '58B', Maryland Current (17d)	13907
12317	Tolchester Channel, SW of Bouy '58B', Maryland Current (25d)	13908
12318	Tolly Point, 1.6 miles east of, Maryland Current	13909
12319	Tombstone Point, 0.1 mile E of, Beaufort Inlet, North Carolina Current (15d)	13910
12320	Tongue Point, northwest of, Oregon Current (15d)	13911
12321	Totten Inlet entrance, Washington Current	13912
12322	Towhead Island, 0.4 mile East of, Washington Current	13913
12323	Towhead Island, 0.4 mile east of, Washington Current	13914
12324	Town Creek Lower Reach, South Carolina Current	13915
12325	Town Creek, 0.2 mile above bridge, South Carolina Current	13916
12326	Treasure Island .3 mi E, San Francisco Bay, California Current	13917
12327	Treasure Island .5 mi N, San Francisco Bay, California Current	13918
12328	Trial Island, 5.2 miles SSW of, Washington Current	13919
12329	Trinidad Head, California Current	13920
12330	Trout River Cut, Florida Current (15d)	13921
12331	Trout River Cut, Florida Current (32d)	13922
12332	Trout River Cut, Florida Current (6d)	13923
12333	Tuckernuck Island, 4.2 miles SSW of, Massachusetts Current	13924
12334	Tuckernuck Shoal, off east end, Massachusetts Current	13925
12335	Turkey Point, 1.2 n.mi. SW of, Maryland Current (9d)	13926
12336	Turn Point, Boundary Pass, Washington Current	13927
12337	Turn Rock Light, 1.9 miles northwest of, Washington Current	13928
12338	Turn Rock, 1.9 mile NW of, Washington Current	13929
12339	Turning Basin, Beaufort Inlet, North Carolina Current (15d)	13930
12340	Turning Basin, Beaufort Inlet, North Carolina Current (6d)	13931
12341	Turning Basin, Key West, Florida Current	13932
12342	Turning Basin, Northeast River, North Carolina Current (20d)	13933
12343	Turning Basin, Northeast River, North Carolina Current (6d)	13934
12344	Turtle River, off Allied Chemical Corp, Georgia Current	13935
12345	Turtle River, off Andrews Island, Georgia Current (20d)	13936
12346	Twotree Island Channel, Connecticut Current (11d)	13937
12347	Udagak Strait (narrows), Alaska Current	13938
12348	Ugamak Strait (North end), Alaska Current	13939
12349	Ugamak Strait, off Kaligagan Island, Alaska Current	13940
12350	Ulak Pass, Delarof Islands, Alaska Current	13941
12351	Umak Pass, off Narrows Point, Alaska Current	13942
12352	Umnak Pass, northwest of Ship Rock, Alaska Current	13943
12353	Umnak Pass, south approach, Alaska Current	13944
12354	Umnak Pass, southeast of Ship Rock, Alaska Current	13945
12355	Umpqua River entrance, Oregon Current	13946
12356	Unalga Pass, Alaska Current	13947
12357	Unga Strait (1.4 miles N of Unga Spit), Alaska Current	13948
12358	Unimak Pass (off Scotch Cap), Alaska Current	13949
12359	Unimak Pass, 11 miles WSW of Sennett Pt, Alaska Current	13950
12360	Unimak Pass, 2.4 miles N of Tanginak I, Alaska Current	13951
12361	Upper Hell Gate (Sasanoa River, Maine) Current	13952
12362	Upper Midnight channel, North Carolina Current	13953
12363	Vanderbilt Reef, 2 miles west of, Alaska Current	13954
12364	Venice Inlet, Florida Current	13955
12365	Vernon R., 1.2 miles S of Possum Point, Georgia Current	13956
12366	Vieques Passage, Puerto Rico Current	13957
12367	Vieques Passage, Puerto Rico Current (2)	13958
12368	Vieques Sound, Puerto Rico Current	13959
12369	Violet Point, 3.2 miles northwest of, Washington Current	13960
12370	Violet Point, 3.2 miles NW of, Washington Current	13961
12371	Violet Point, 3.7 miles N of, Washington Current	13962
12372	Vulcan Island .5 mi E, San Joaquin River, California Current	13963
12373	W Howard Frankland Bridge, Florida Current	13964
12374	Wadmalaw Island, Wadmalaw River entrance, South Carolina Current (12d)	13965
12375	Waldron Island, 1.7 miles West of, Washington Current	13966
12376	Waldron Island, 1.7 miles west of, Washington Current	13967
12377	Walker Island, south of, Washington Current (12d)	13968
12378	Wallace Channel, Ocracoke Inlet, North Carolina Current (9d)	13969
12379	Walls Cut, Turtle Island, South Carolina Current (6d)	13970
12380	Walrus Island, 0.5 mile west of, Pribilof Islands, Alaska Current	13971
12381	Wando River Upper Reach, Turning Basin, Wando River, South Carolina Current	13972
12382	Wappoo Creek, off of, Ashley River, South Carolina Current	13973
12383	Waquoit Bay entrance, Massachusetts Current	13974
12384	Wareham River, off Barneys Point, Massachusetts Current	13975
12385	Wareham River, off Long Beach Point, Massachusetts Current	13976
12386	Warehouse Bluff, southwest of, Alaska Current	13977
12387	Warren, Warren River, Rhode Island Current	13978
12388	Wasp Passage Light, 0.5 mile WSW of, Washington Current	13979
12389	Wasque Point, 2.0 miles southwest of, Massachusetts Current	13980
12390	Wassaw Island, N of E end, Wassaw Sound, Georgia Current (10d)	13981
12391	Wassaw Island, SSW of, Georgia Current (10d)	13982
12392	Wassaw Island, SSW of, Georgia Current (20d)	13983
12393	Watch Hill Point, 2.2 miles east of, Rhode Island Current	13984
12394	Watch Hill Point, 5.2 miles SSE of, Rhode Island Current (15d)	13985
12395	Watch Hill Point, 5.3 n.mi. SE of, Rhode Island Current (15d)	13986
12396	Weedon I. powerplant channel, marker '10', Florida Current (23d)	13987
12397	Weepecket Island, south of, Massachusetts Current	13988
12398	West 207th Street Bridge, New York Current	13989
12399	West Chop, 0.2 mile west of, Massachusetts Current	13990
12400	West Chop, 0.8 mile north of, Massachusetts Current	13991
12401	West end, Rich Passage, Washington Current	13992
12402	West Island Lt .5 mi SE, San Joaquin River, California Current	13993
12403	West Island, 1 mile southeast of, Massachusetts Current (6d)	13994
12404	West Marsh Island, 0.1 mile east of, Ashley River, South Carolina Current	13995
12405	west of, off 63rd Street, Roosevelt Island, New York Current	13996
12406	west of, off 67th Street, Roosevelt Island, New York Current	13997
12407	west of, off 75th Street, Roosevelt Island, New York Current	13998
12408	West Point, 0.3 mile west of, Washington Current	13999
12409	West Point, Seattle, 0.3 miles W of, Washington Current	14000
12410	West Point, Whidbey Island, 1.8 miles SW of, Washington Current	14001
12411	Westport River entrance, Massachusetts Current	14002
12412	Westport River Entrance, Massachusetts Current	14003
12413	Westport, channel 0.4 mile NE of, Washington Current	14004
12414	Weynton Passage, British Columbia Current	14005
12415	Whale Branch River, South Carolina Current (10d)	14006
12416	White Point, south of, Dawho River, South Carolina Current (12d)	14007
12417	Whooping Island, Dawho River, South Carolina Current (12d)	14008
12418	Wicopesset Island, 1.1 miles SSE of, Rhode Island Current	14009
12419	Wilcox Island Park, east of, Connecticut River, Connecticut Current	14010
12420	William Point Light, 0.8 miles W of, Washington Current	14011
12421	Williamsburg Bridge, 0.3 mile north of, New York Current	14012
12422	Williman Creek, South Carolina Current (10d)	14013
12423	Willis Ave. Bridge, 0.1 mile NW of, New York Current	14014
12424	Wilmington Island, SSE of, Bull River, Georgia Current (10d)	14015
12425	Wilmington R. ent., south channel, Georgia Current	14016
12426	Wilmington R., 0.5 mi. S of Turners Creek, Georgia Current	14017
12427	Wilmington River ent. off Cabbage Island, Georgia Current	14018
12428	Wilmington, North Carolina Current (20d)	14019
12429	Wilmington, North Carolina Current (6d)	14020
12430	Wilson Point 3.9 mi NNW, San Pablo Bay, California Current	14021
12431	Winter Point, Florida Current	14022
12432	Winthrop Point, Thames River, Connecticut Current	14023
12433	Winyah Bay entrance, South Carolina Current	14024
12434	Woods Hole, Massachusetts Current (use with caution)	14025
12435	Woods Point, Cooper River, South Carolina Current	14026
12436	Woods Point, SE of, Cooper River, South Carolina Current	14027
12437	Woody Island Channel (off Seal Island), Oregon Current (12d)	14028
12438	Woody Island Channel, Washington Current (15d)	14029
12439	Wooster Island, 0.1 mile southwest of, Housatonic River, Connecticut Current (5d)	14030
12440	Worton Point, 1.1 miles northwest of, Maryland Current	14031
12441	Worton Point, 1.5 n.mi. WSW of, Maryland Current (17d)	14032
12442	Wrangell Narrows (off Petersburg), Alaska Current	14033
12443	Wreck Shoal-Eldridge Shoal, between, Massachusetts Current	14034
12444	Wright R., 0.2 mile above Walls Cut, South Carolina Current	14035
12445	Wye River, west of Bruffs Island, Maryland Current (9d)	14036
12446	Yakobi Rock, 1 mile west of, Alaska Current	14037
12447	Yaquina Bay entrance, Oregon Current	14038
12448	Yaquina Bay, Highway Bridge, Oregon Current	14039
12449	Yaquina River, 1 mile below Toledo, Oregon Current	14040
12450	Yaquina, Yaquina River, Oregon Current	14041
12451	Yellow Bluff .8 mi E, San Francisco Bay, California Current	14042
12452	Yellow House Creek, Cooper River, South Carolina Current	14043
12453	Yellow House Landing, 1 mile NW of, Cooper River, South Carolina Current	14044
12454	Yerba Buena Island W of, San Francisco Bay, California Current	14045
12455	Yokeko Point, Deception Pass, Washington Current	14046
12456	Youngs Bay Bridge, Oregon Current (9d)	14047
12457	Youngs Bay Entrance, Oregon Current (17d)	14048
\.


--
-- TOC entry 3515 (class 0 OID 26836)
-- Dependencies: 234
-- Data for Name: data_urls; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.data_urls (id, url, global_position_id, data_type) FROM stdin;
12491	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=0%2E1+mile+east+of+Point+Evans%2C+The+Narrows%2C+Washington+Current	12492	current
12492	https://www.google.com/maps/place/47°17'8.0"N+122°32'40.0"W/@47.2858,-122.5445	12492	map
12493	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=0%2E1+mile+SW+of+Devils+Foot+Island%2C+Woods+Hole%2C+Massachusetts+Current	12493	current
12494	https://www.google.com/maps/place/41°31'12.0"N+70°41'6.0"W/@41.52,-70.685	12493	map
12495	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=0%2E3+mile+northeast+of%2C+Marrowstone+Point%2C+Washington+Current	12494	current
12496	https://www.google.com/maps/place/48°6'0.0"N+122°40'59.0"W/@48.1,-122.6833	12494	map
12497	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=0%2E4+mile+north+of%2C+Brunswick+River%2C+North+Carolina+Current+%2816d%29	12495	current
12498	https://www.google.com/maps/place/34°10'52.0"N+77°57'56.0"W/@34.1812,-77.9658	12495	map
12499	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=0%2E4+mile+north+of%2C+Brunswick+River%2C+North+Carolina+Current+%286d%29	12496	current
12500	https://www.google.com/maps/place/34°10'52.0"N+77°57'56.0"W/@34.1812,-77.9658	12496	map
12501	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=0%2E4+mile+northeast+of%2C+Marrowstone+Point%2C+Washington+Current	12497	current
12502	https://www.google.com/maps/place/48°6'0.0"N+122°40'59.0"W/@48.1,-122.6833	12497	map
12503	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=0%2E5+mile+NE+of+Little+Gull+Island%2C+The+Race%2C+New+York+Current	12498	current
12504	https://www.google.com/maps/place/41°13'0.0"N+72°5'59.0"W/@41.2167,-72.1	12498	map
12505	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=0%2E5+mile+southeast+of%2C+Pinellas+Point%2C+Florida+Current	12499	current
12506	https://www.google.com/maps/place/27°41'49.0"N+82°37'56.0"W/@27.697,-82.6325	12499	map
12507	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=1%2E1+miles+northwest+of%2C+Marrowstone+Point%2C+Washington+Current	12500	current
12508	https://www.google.com/maps/place/48°7'0.0"N+122°42'0.0"W/@48.1167,-122.7	12500	map
12509	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=1%2E6+miles+northeast+of%2C+Marrowstone+Point%2C+Washington+Current	12501	current
12510	https://www.google.com/maps/place/48°7'0.0"N+122°40'0.0"W/@48.1167,-122.6667	12501	map
12511	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=1%2E8+miles+north+of+mouth%2C+Brunswick+River%2C+North+Carolina+Current+%286d%29	12502	current
12512	https://www.google.com/maps/place/34°12'19.0"N+77°58'28.0"W/@34.2055,-77.9745	12502	map
12513	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=1%2E9+miles+SE+of%2C+Pinellas+Point%2C+Florida+Current	12503	current
12514	https://www.google.com/maps/place/27°41'4.0"N+82°36'34.0"W/@27.6847,-82.6097	12503	map
12515	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=2%2E4+miles+southwest+of%2C+Point+Judith%2C+Rhode+Island+Current	12504	current
12516	https://www.google.com/maps/place/41°19'52.0"N+71°30'38.0"W/@41.3312,-71.5108	12504	map
12517	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=2%2E6+miles+south+of%2C+Pinellas+Point%2C+Florida+Current	12505	current
12518	https://www.google.com/maps/place/27°39'37.0"N+82°38'30.0"W/@27.6605,-82.6417	12505	map
12519	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=28th+St%2E+Pier+%28San+Diego%29%2C+0%2E35+nmi%2E+SW%2C+California+Current+%2814d%29	12506	current
12520	https://www.google.com/maps/place/32°40'58.0"N+117°8'34.0"W/@32.6828,-117.1428	12506	map
12521	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=28th+St%2E+Pier+%28San+Diego%29%2C+0%2E35+nmi%2E+SW%2C+California+Current+%2828d%29	12507	current
12522	https://www.google.com/maps/place/32°40'58.0"N+117°8'34.0"W/@32.6828,-117.1428	12507	map
12523	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=28th+St%2E+Pier+%28San+Diego%29%2C+0%2E92+nmi%2E+SW%2C+California+Current+%287d%29	12508	current
12524	https://www.google.com/maps/place/32°40'28.0"N+117°8'58.0"W/@32.6747,-117.1495	12508	map
12525	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=3+miles+southeast+of%2C+Pinellas+Point%2C+Florida+Current	12509	current
12526	https://www.google.com/maps/place/27°40'22.0"N+82°35'34.0"W/@27.673,-82.593	12509	map
12527	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=610+Statute+Mile+Mark%2C+Bear+River%2C+Georgia+Current+%286d%29	12510	current
12528	https://www.google.com/maps/place/31°48'37.0"N+81°10'36.0"W/@31.8105,-81.1767	12510	map
12529	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Abiels+Ledge%2C+0%2E4+mile+south+of%2C+Massachusetts+Current	12511	current
12530	https://www.google.com/maps/place/41°41'6.0"N+70°40'23.0"W/@41.685,-70.6733	12511	map
12531	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Acabonack+Hbr%2E+ent%2E%2C+0%2E6+mile+ESE+of%2C+New+York+Current	12512	current
12532	https://www.google.com/maps/place/41°1'18.0"N+72°7'23.0"W/@41.0217,-72.1233	12512	map
12533	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Active+Pass%2C+British+Columbia+Current	12513	current
12534	https://www.google.com/maps/place/48°52'0.0"N+123°17'59.0"W/@48.8667,-123.3	12513	map
12535	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Adak+Strait%2C+4+miles+ENE+of+Naga+Point%2C+Alaska+Current	12514	current
12536	https://www.google.com/maps/place/51°46'59.0"N+177°0'0.0"W/@51.7833,-177.0	12514	map
12537	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Adak+Strait%2C+off+Argonne+Point%2C+Alaska+Current	12515	current
12538	https://www.google.com/maps/place/51°47'59.0"N+176°56'59.0"W/@51.8,-176.95	12515	map
12539	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Admiralty+Head%2C+0%2E5+mile+west+of%2C+Washington+Current	12516	current
12540	https://www.google.com/maps/place/48°8'59.0"N+122°42'0.0"W/@48.15,-122.7	12516	map
12541	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Admiralty+Inlet+%28off+Bush+Point%29%2C+Washington+Current	12517	current
12542	https://www.google.com/maps/place/48°1'59.0"N+122°37'59.0"W/@48.0333,-122.6333	12517	map
12543	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Admiralty+Inlet%2C+Washington+Current	12518	current
12544	https://www.google.com/maps/place/48°1'48.0"N+122°38'12.0"W/@48.03,-122.6367	12518	map
12545	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Agate+Pass%2C+North+End+of%2C+Washington+Current	12519	current
12546	https://www.google.com/maps/place/47°43'0.0"N+122°32'59.0"W/@47.7167,-122.55	12519	map
12547	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Agate+Pass%2C+South+End+of%2C+Washington+Current	12520	current
12548	https://www.google.com/maps/place/47°42'0.0"N+122°34'0.0"W/@47.7,-122.5667	12520	map
12549	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Agate+Passage%2C+north+end%2C+Washington+Current	12521	current
12550	https://www.google.com/maps/place/47°43'19.0"N+122°33'18.0"W/@47.722,-122.555	12521	map
12551	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Agate+Passage%2C+south+end%2C+Washington+Current	12522	current
12552	https://www.google.com/maps/place/47°42'46.0"N+122°33'55.0"W/@47.7128,-122.5655	12522	map
12553	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Akutan+Pass%2C+Aleutian+Islands%2C+Alaska+Current	12523	current
12554	https://www.google.com/maps/place/54°1'18.0"N+166°3'6.0"W/@54.0217,-166.0517	12523	map
12555	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Alameda+Radar+Tower%2C+%2E9+SSW+of%2C+South+San+Francisco+Bay%2C+California+Current	12524	current
12556	https://www.google.com/maps/place/37°43'59.0"N+122°15'59.0"W/@37.733333,-122.2666	12524	map
12557	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Alcatraz+%28North+Point%29%2C+San+Francisco+Bay%2C+California+Current	12525	current
12558	https://www.google.com/maps/place/37°49'36.0"N+122°25'0.0"W/@37.8267,-122.4167	12525	map
12559	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Alcatraz+Island+%2E8+mi+E%2C+San+Francisco+Bay%2C+California+Current	12526	current
12560	https://www.google.com/maps/place/37°48'59.0"N+122°24'0.0"W/@37.816666,-122.4	12526	map
12561	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Alcatraz+Island+S%2C+San+Francisco+Bay%2C+California+Current	12527	current
12562	https://www.google.com/maps/place/37°48'59.0"N+122°24'59.0"W/@37.816666,-122.4166	12527	map
12563	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Alcatraz+Island+W%2C+San+Francisco+Bay%2C+California+Current	12528	current
12564	https://www.google.com/maps/place/37°49'59.0"N+122°25'59.0"W/@37.833333,-122.4333	12528	map
12565	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Alcatraz+Island%2C+5+mi+N%2C+San+Francisco+Bay%2C+California+Current	12529	current
12566	https://www.google.com/maps/place/37°49'59.0"N+122°24'59.0"W/@37.833333,-122.4166	12529	map
12567	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Alden+Point%2C+Patos+Is%2C+2+miles+S+of%2C+Washington+Current	12530	current
12568	https://www.google.com/maps/place/47°45'0.0"N+122°58'59.0"W/@47.75,-122.9833	12530	map
12569	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Alden+Point%2C+Patos+Island%2C+2+miles+S+of%2C+Washington+Current	12531	current
12570	https://www.google.com/maps/place/48°45'28.0"N+122°58'49.0"W/@48.7578,-122.9803	12531	map
12571	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Alki+Point%2C+0%2E3+mile+west+of%2C+Washington+Current	12532	current
12572	https://www.google.com/maps/place/47°34'31.0"N+122°25'40.0"W/@47.5755,-122.428	12532	map
12573	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Alki+Point%2C+0%2E3+miles+W+of%2C+Washington+Current	12533	current
12574	https://www.google.com/maps/place/47°40'0.0"N+122°25'59.0"W/@47.6667,-122.4333	12533	map
12575	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Almy+Point+Bridge%2C+south+of%2C+Sakonnet+River%2C+Rhode+Island+Current+%2815d%29	12534	current
12576	https://www.google.com/maps/place/41°37'18.0"N+71°13'11.0"W/@41.6217,-71.22	12534	map
12577	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Amak+Island%2C+5+miles+north+of%2C+Alaska+Current	12535	current
12578	https://www.google.com/maps/place/55°30'0.0"N+163°10'0.0"W/@55.5,-163.1667	12535	map
12579	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Amak+Island%2C+5+miles+southeast+of%2C+Alaska+Current	12536	current
12580	https://www.google.com/maps/place/55°21'0.0"N+163°1'0.0"W/@55.35,-163.0167	12536	map
12581	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Amoco+Pier%2C+off%2C+Cooper+River%2C+South+Carolina+Current	12537	current
12582	https://www.google.com/maps/place/32°57'33.0"N+79°55'4.0"W/@32.9592,-79.918	12537	map
12583	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Angel+Island+%2E8+mi+E%2C+San+Francisco+Bay%2C+California+Current	12538	current
12584	https://www.google.com/maps/place/37°51'0.0"N+122°24'0.0"W/@37.85,-122.4	12538	map
12585	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Angel+Island+off+Quarry+Point%2C+San+Francisco+Bay%2C+California+Current	12539	current
12586	https://www.google.com/maps/place/37°51'0.0"N+122°24'0.0"W/@37.85,-122.4	12539	map
12587	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Antioch+Pt+%2E3+mi+E%2C+San+Joaquin+River%2C+California+Current	12540	current
12588	https://www.google.com/maps/place/38°1'59.0"N+121°48'59.0"W/@38.033333,-121.8166	12540	map
12589	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Apavawook+Cape%2C+1+mile+south+of%2C+St%2E+Lawrence+Island%2C+Alaska+Current	12541	current
12590	https://www.google.com/maps/place/63°7'0.0"N+168°55'59.0"W/@63.1167,-168.9333	12541	map
12591	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Apokak+Creek+entrance%2C+Alaska+Current	12542	current
12592	https://www.google.com/maps/place/60°7'59.0"N+162°10'0.0"W/@60.1333,-162.1667	12542	map
12593	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Apple+Cove+Point%2C+0%2E5+mile+E+of%2C+Washington+Current	12543	current
12594	https://www.google.com/maps/place/47°49'0.0"N+122°28'0.0"W/@47.8167,-122.4667	12543	map
12595	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Approach%2C+Beaufort+Inlet%2C+North+Carolina+Current	12544	current
12596	https://www.google.com/maps/place/34°40'18.0"N+76°40'12.0"W/@34.6717,-76.67	12544	map
12597	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Aransas+Pass%2C+Texas+Current	12545	current
12598	https://www.google.com/maps/place/27°49'59.0"N+97°2'42.0"W/@27.8333,-97.045	12545	map
12599	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Aransas+Pass%2C+Texas+Current+%2815d%29	12546	current
12600	https://www.google.com/maps/place/27°50'1.0"N+97°2'39.0"W/@27.8338,-97.0442	12546	map
12601	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Aransas+Pass%2C+Texas+Current+%2835d%29	12547	current
12602	https://www.google.com/maps/place/27°50'1.0"N+97°2'39.0"W/@27.8338,-97.0442	12547	map
12603	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Aransas+Pass%2C+Texas+Current+%2850d%29	12548	current
12604	https://www.google.com/maps/place/27°50'1.0"N+97°2'39.0"W/@27.8338,-97.0442	12548	map
12605	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Arnold+Point%2C+0%2E4+mile+west+of%2C+Maryland+Current	12549	current
12606	https://www.google.com/maps/place/39°27'49.0"N+75°58'27.0"W/@39.4638,-75.9742	12549	map
12607	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ashe+Island+Cut%2C+St%2E+Helena+Sound%2C+South+Carolina+Current+%286d%29	12550	current
12608	https://www.google.com/maps/place/32°31'12.0"N+80°29'17.0"W/@32.52,-80.4883	12550	map
12609	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ashe+Island+Cut%2C+SW+of%2C+Coosaw+River%2C+South+Carolina+Current+%2815d%29	12551	current
12610	https://www.google.com/maps/place/32°30'35.0"N+80°30'17.0"W/@32.51,-80.505	12551	map
12611	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ashepoo+Coosaw+Cutoff%2C+South+Carolina+Current+%286d%29	12552	current
12612	https://www.google.com/maps/place/32°31'29.0"N+80°27'11.0"W/@32.525,-80.4533	12552	map
12613	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ashepoo+River%2C+off+Jefford+Creek+entrance%2C+South+Carolina+Current	12553	current
12614	https://www.google.com/maps/place/32°30'24.0"N+80°24'35.0"W/@32.5067,-80.41	12553	map
12615	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Avatanak+Strait%2C+Alaska+Current	12554	current
12616	https://www.google.com/maps/place/54°7'0.0"N+165°28'0.0"W/@54.1167,-165.4667	12554	map
12617	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Avondale%2C+Pawcatuck+River%2C+Rhode+Island+Current+%286d%29	12555	current
12618	https://www.google.com/maps/place/41°19'54.0"N+71°50'43.0"W/@41.3317,-71.8455	12555	map
12619	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Baby+Pass%2C+Alaska+Current	12556	current
12620	https://www.google.com/maps/place/53°58'59.0"N+166°4'0.0"W/@53.9833,-166.0667	12556	map
12621	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Back+River+entrance%2C+Cooper+River%2C+South+Carolina+Current	12557	current
12622	https://www.google.com/maps/place/32°58'5.0"N+79°55'59.0"W/@32.9683,-79.9333	12557	map
12623	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Back+River+entrance%2C+Georgia+Current+%2810d%29	12558	current
12624	https://www.google.com/maps/place/31°8'53.0"N+81°26'30.0"W/@31.1483,-81.4417	12558	map
12625	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Back+River+entrance%2C+Georgia+Current+%2818d%29	12559	current
12626	https://www.google.com/maps/place/31°8'53.0"N+81°26'30.0"W/@31.1483,-81.4417	12559	map
12627	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bahia+Honda+Harbor%2C+bridge%2C+Florida+Current	12560	current
12628	https://www.google.com/maps/place/24°39'24.0"N+81°17'17.0"W/@24.6567,-81.2883	12560	map
12629	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bah%EDa+Honda+Harbor+%28Bridge%29+Florida+Current	12561	current
12630	https://www.google.com/maps/place/24°39'24.0"N+81°17'17.0"W/@24.6567,-81.2883	12561	map
12631	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Baker+Bay+entrance%2C+E+of+Sand+Island+Tower%2C+Washington+Current+%2823d%29	12562	current
12632	https://www.google.com/maps/place/46°15'43.0"N+123°59'52.0"W/@46.262,-123.998	12562	map
12633	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Baker+Beach+%28South+Bay%29%2C+0%2E3+nmi%2E+NW+of%2C+California+Current+%2831d%29	12563	current
12634	https://www.google.com/maps/place/37°47'52.0"N+122°29'18.0"W/@37.7978,-122.4885	12563	map
12635	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Baker+Beach+%28South+Bay%29%2C+0%2E3+nmi%2E+NW+of%2C+California+Current+%2850d%29	12564	current
12636	https://www.google.com/maps/place/37°47'52.0"N+122°29'18.0"W/@37.7978,-122.4885	12564	map
12637	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Balch+Passage%2C+Washington+Current	12565	current
12638	https://www.google.com/maps/place/47°11'15.0"N+122°41'49.0"W/@47.1875,-122.6972	12565	map
12639	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bald+Eagle+Pt%2E%2C+east+of%2C+Harris+Creek%2C+Maryland+Current	12566	current
12640	https://www.google.com/maps/place/38°43'45.0"N+76°18'18.0"W/@38.7292,-76.305	12566	map
12641	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bald+Head%2C+North+Carolina+Current	12567	current
12642	https://www.google.com/maps/place/33°52'25.0"N+78°0'26.0"W/@33.8738,-78.0075	12567	map
12643	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ballast+Point%2C+0%2E55+nmi%2E+north+of%2C+California+Current+%2814d%29	12568	current
12644	https://www.google.com/maps/place/32°41'44.0"N+117°13'57.0"W/@32.6958,-117.2325	12568	map
12645	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ballast+Point%2C+0%2E55+nmi%2E+north+of%2C+California+Current+%2834d%29	12569	current
12646	https://www.google.com/maps/place/32°41'44.0"N+117°13'57.0"W/@32.6958,-117.2325	12569	map
12647	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ballast+Point%2C+100+yards+north+of%2C+California+Current	12570	current
12648	https://www.google.com/maps/place/32°40'59.0"N+117°13'59.0"W/@32.6833,-117.2333	12570	map
12649	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ballast+Point%2C+south+of%2C+California+Current+%285d%29	12571	current
12650	https://www.google.com/maps/place/32°41'4.0"N+117°13'55.0"W/@32.6845,-117.2322	12571	map
12651	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Baltimore+Harbor+Approach+%28off+Sandy+Point%29%2C+Maryland+Current	12572	current
12652	https://www.google.com/maps/place/39°0'46.0"N+76°22'5.0"W/@39.013,-76.3683	12572	map
12653	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Baltimore+Harbor+Approach%2C+Maryland+Current	12573	current
12654	https://www.google.com/maps/place/39°0'47.0"N+76°22'5.0"W/@39.0133,-76.3683	12573	map
12710	https://www.google.com/maps/place/37°51'7.0"N+122°18'40.0"W/@37.8522,-122.3112	12601	map
12655	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bar+Channel%2C+Georgia+Current+%2812d%29	12574	current
12656	https://www.google.com/maps/place/31°6'18.0"N+81°20'17.0"W/@31.105,-81.3383	12574	map
12657	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bar%2C+Georgia+Current	12575	current
12658	https://www.google.com/maps/place/31°20'41.0"N+81°14'5.0"W/@31.345,-81.235	12575	map
12659	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Barataria+Bay%2C+1%2E1+mi%2E+NE+of+Manilla%2C+Louisiana+Current	12576	current
12660	https://www.google.com/maps/place/29°26'12.0"N+89°57'35.0"W/@29.4367,-89.96	12576	map
12661	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Barataria+Pass%2C+Barataria+Bay%2C+Louisiana+Current	12577	current
12662	https://www.google.com/maps/place/29°16'18.0"N+89°56'53.0"W/@29.2717,-89.9483	12577	map
12663	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Barnegat+Inlet%2C+Barnegat+Bay%2C+New+Jersey+Current	12578	current
12664	https://www.google.com/maps/place/39°46'0.0"N+74°7'0.0"W/@39.7667,-74.1167	12578	map
12665	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Barnes+Island%2C+0%2E8+mile+southwest+of%2C+Washington+Current	12579	current
12666	https://www.google.com/maps/place/48°41'8.0"N+122°47'19.0"W/@48.6858,-122.7888	12579	map
12667	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Barnes+Island%2C+0%2E8+mile+SW+of%2C+Washington+Current	12580	current
12668	https://www.google.com/maps/place/48°40'59.0"N+122°46'0.0"W/@48.6833,-122.7667	12580	map
12669	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bartlett+Reef%2C+0%2E2+mile+south+of%2C+New+York+Current	12581	current
12670	https://www.google.com/maps/place/41°16'12.0"N+72°7'41.0"W/@41.27,-72.1283	12581	map
12671	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Battery+Point%2C+Chilkoot+Inlet%2C+Alaska+Current	12582	current
12672	https://www.google.com/maps/place/59°13'0.0"N+135°20'59.0"W/@59.2167,-135.35	12582	map
12673	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Battery%2C+southwest+of%2C+Ashley+River%2C+South+Carolina+Current	12583	current
12674	https://www.google.com/maps/place/32°46'1.0"N+79°56'1.0"W/@32.7672,-79.9338	12583	map
12675	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bay+Point+Island%2C+S+of%2C+Broad+River+entrance%2C+South+Carolina+Current+%2815d%29	12584	current
12676	https://www.google.com/maps/place/32°13'59.0"N+80°37'47.0"W/@32.2333,-80.63	12584	map
12677	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bayonne+Bridge%2C+Kill+van+Kull%2C+New+York+Current	12585	current
12678	https://www.google.com/maps/place/40°38'30.0"N+74°8'35.0"W/@40.6417,-74.1433	12585	map
12679	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bayonne+Bridge%2C+Kill+van+Kull%2C+New+York+Current+%282%29	12586	current
12680	https://www.google.com/maps/place/40°38'30.0"N+74°8'35.0"W/@40.6417,-74.1433	12586	map
12681	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Beardslee+Island%2C+West+of%2C+Glacier+Bay%2C+Alaska+Current	12587	current
12682	https://www.google.com/maps/place/58°28'0.0"N+136°1'59.0"W/@58.4667,-136.0333	12587	map
12683	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Beaufort+Airport%2C+Beaufort+River%2C+South+Carolina+Current+%2815d%29	12588	current
12684	https://www.google.com/maps/place/32°27'0.0"N+80°39'47.0"W/@32.45,-80.6633	12588	map
12685	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Beaufort+River+Entrance%2C+South+Carolina+Current+%2815d%29	12589	current
12686	https://www.google.com/maps/place/32°17'17.0"N+80°39'6.0"W/@32.2883,-80.6517	12589	map
12687	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Beaufort+River%2C+South+Carolina+Current+%2815d%29	12590	current
12688	https://www.google.com/maps/place/32°24'11.0"N+80°40'18.0"W/@32.4033,-80.6717	12590	map
12689	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Beaufort%2C+Beaufort+River%2C+South+Carolina+Current+%2812d%29	12591	current
12690	https://www.google.com/maps/place/32°25'47.0"N+80°40'36.0"W/@32.43,-80.6767	12591	map
12691	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Beavertail+Point%2C+0%2E8+mile+northwest+of%2C+Rhode+Island+Current	12592	current
12692	https://www.google.com/maps/place/41°27'29.0"N+71°24'42.0"W/@41.4583,-71.4117	12592	map
12693	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bechevin+Bay%2C+off+Rocky+Point%2C+Alaska+Current	12593	current
12694	https://www.google.com/maps/place/54°58'59.0"N+163°25'59.0"W/@54.9833,-163.4333	12593	map
12695	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bees+Ferry+Bridge%2C+Ashley+River%2C+South+Carolina+Current	12594	current
12696	https://www.google.com/maps/place/32°50'48.0"N+80°2'59.0"W/@32.8467,-80.05	12594	map
12697	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bellingham+Channel%2C+off+Cypress+I%2E+Light%2C+Washington+Current	12595	current
12698	https://www.google.com/maps/place/48°33'37.0"N+122°39'49.0"W/@48.5603,-122.6637	12595	map
12699	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bellingham+Channel%2C+off+Cypress+Island%2C+Light+of%2C+Washington+Current	12596	current
12700	https://www.google.com/maps/place/48°32'59.0"N+122°39'0.0"W/@48.55,-122.65	12596	map
12701	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Benedict%2C+highway+bridge%2C+Maryland+Current	12597	current
12702	https://www.google.com/maps/place/38°30'42.0"N+76°40'19.0"W/@38.5117,-76.6722	12597	map
12703	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bergen+Point+Reach+%28Bayonne+Bridge%29%2C+Kill+van+Kull%2C+New+York+Current+%2816d%29	12598	current
12704	https://www.google.com/maps/place/40°38'30.0"N+74°8'35.0"W/@40.6417,-74.1433	12598	map
12705	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bergen+Point+Reach+%28Bayonne+Bridge%29%2C+New+York+Current+%2829d%29	12599	current
12706	https://www.google.com/maps/place/40°38'30.0"N+74°8'35.0"W/@40.6417,-74.1433	12599	map
12707	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Berkeley+Yacht+Harbor+%2E9+mi+S%2C+San+Francisco+Bay%2C+California+Current	12600	current
12708	https://www.google.com/maps/place/37°51'0.0"N+122°17'59.0"W/@37.85,-122.3	12600	map
12709	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Berkeley+Yacht+Harbor%2C+California+Current	12601	current
12711	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Big+Sarasota+Pass%2C+Florida+Current	12602	current
12712	https://www.google.com/maps/place/27°18'0.0"N+82°33'47.0"W/@27.3,-82.5633	12602	map
12713	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bird+Shoal%2C+SE+of%2C+Beaufort+Inlet%2C+North+Carolina+Current+%286d%29	12603	current
12714	https://www.google.com/maps/place/34°42'1.0"N+76°39'13.0"W/@34.7005,-76.6538	12603	map
12715	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Black+Point+and+Plum+Island%2C+between%2C+New+York+Current+%2815d%29	12604	current
12716	https://www.google.com/maps/place/41°13'59.0"N+72°12'17.0"W/@41.2333,-72.205	12604	map
12717	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Black+Point%2C+0%2E8+mile+south+of%2C+Connecticut+Current+%2815d%29	12605	current
12718	https://www.google.com/maps/place/41°16'23.0"N+72°12'29.0"W/@41.2733,-72.2083	12605	map
12719	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Black+Point%2C+SW+of%2C+Sakonnet+River%2C+Rhode+Island+Current+%2815d%29	12606	current
12720	https://www.google.com/maps/place/41°30'24.0"N+71°13'11.0"W/@41.5067,-71.22	12606	map
12721	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Blackburn+Bay%2C+south+end%2C+bridge%2C+Florida+Current	12607	current
12722	https://www.google.com/maps/place/27°7'23.0"N+82°28'11.0"W/@27.1233,-82.47	12607	map
12723	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Blair+Channel%2C+Ocracoke+Inlet%2C+North+Carolina+Current+%2810d%29	12608	current
12724	https://www.google.com/maps/place/35°4'52.0"N+76°2'1.0"W/@35.0813,-76.0338	12608	map
12725	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Blake+Island%2C+southwest+of%2C+Washington+Current	12609	current
12726	https://www.google.com/maps/place/47°31'29.0"N+122°29'58.0"W/@47.525,-122.4995	12609	map
12727	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Blake+Island%2C+SW+of%2C+Washington+Current	12610	current
12728	https://www.google.com/maps/place/47°36'0.0"N+122°40'0.0"W/@47.6,-122.6667	12610	map
12729	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Blind+Pass+%28north+end%29%2C+Florida+Current	12611	current
12730	https://www.google.com/maps/place/27°45'24.0"N+82°45'42.0"W/@27.7567,-82.7617	12611	map
12731	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bloody+Point+Bar+Light%2C+0%2E6+mi%2E+NW+of%2C+Maryland+Current+%2819d%29	12612	current
12732	https://www.google.com/maps/place/38°50'22.0"N+76°24'10.0"W/@38.8395,-76.4028	12612	map
12733	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bloody+Pt%2E%2C+0%2E5+mile+north+of%2C+New+River%2C+South+Carolina+Current	12613	current
12734	https://www.google.com/maps/place/32°5'17.0"N+80°52'47.0"W/@32.0883,-80.88	12613	map
12735	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bloody+Pt%2E%2C+0%2E5+mile+west+of%2C+New+River%2C+South+Carolina+Current	12614	current
12736	https://www.google.com/maps/place/32°4'54.0"N+80°52'59.0"W/@32.0817,-80.8833	12614	map
12737	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Blount+Island%2C+East+of%2C+Florida+Current+%2816d%29	12615	current
12738	https://www.google.com/maps/place/30°23'31.0"N+81°30'30.0"W/@30.392,-81.5085	12615	map
12739	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Blount+Island%2C+East+of%2C+Florida+Current+%2830d%29	12616	current
12740	https://www.google.com/maps/place/30°23'31.0"N+81°30'30.0"W/@30.392,-81.5085	12616	map
12741	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Blount+Island%2C+East+of%2C+Florida+Current+%287d%29	12617	current
12742	https://www.google.com/maps/place/30°23'31.0"N+81°30'30.0"W/@30.392,-81.5085	12617	map
12743	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bluff+Point+%2E1+mi+E%2C+San+Francisco+Bay%2C+California+Current	12618	current
12744	https://www.google.com/maps/place/37°52'59.0"N+122°25'59.0"W/@37.883333,-122.4333	12618	map
12745	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Boat+Passage%2C+British+Columbia+Current	12619	current
12746	https://www.google.com/maps/place/48°49'0.0"N+123°10'59.0"W/@48.8167,-123.1833	12619	map
12747	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Boca+Grande+Channel%2C+Florida+Current	12620	current
12748	https://www.google.com/maps/place/24°34'0.0"N+82°4'0.0"W/@24.5667,-82.0667	12620	map
12749	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Boca+Grande+Pass%2C+Charlotte+Harbor%2C+Florida+Current	12621	current
12750	https://www.google.com/maps/place/26°42'53.0"N+82°15'24.0"W/@26.715,-82.2567	12621	map
12751	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bodie+Island%2DPea+Island%2C+between%2C+Oregon+Inlet%2C+North+Carolina+Current+%2812d%29	12622	current
12752	https://www.google.com/maps/place/35°46'36.0"N+75°32'5.0"W/@35.7767,-75.535	12622	map
12753	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bodie+Island%2DPea+Island%2C+between%2C+Oregon+Inlet%2C+North+Carolina+Current+%286d%29	12623	current
12754	https://www.google.com/maps/place/35°46'36.0"N+75°32'5.0"W/@35.7767,-75.535	12623	map
12755	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bolivar+Roads%2C+Texas+Current	12624	current
12756	https://www.google.com/maps/place/29°20'35.0"N+94°46'54.0"W/@29.3433,-94.7817	12624	map
12757	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bolivar+Roads%2C+Texas+Current+%2814d%29	12625	current
12758	https://www.google.com/maps/place/29°20'35.0"N+94°46'52.0"W/@29.3433,-94.7813	12625	map
12759	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bolivar+Roads%2C+Texas+Current+%2831d%29	12626	current
12760	https://www.google.com/maps/place/29°20'35.0"N+94°46'52.0"W/@29.3433,-94.7813	12626	map
12761	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bolivar+Roads%2C+Texas+Current+%288d%29	12627	current
12762	https://www.google.com/maps/place/29°20'35.0"N+94°46'52.0"W/@29.3433,-94.7813	12627	map
12763	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bonneau+Ferry%2C+east+of%2C+Cooper+River%2C+South+Carolina+Current	12628	current
12764	https://www.google.com/maps/place/33°4'18.0"N+79°52'59.0"W/@33.0717,-79.8833	12628	map
12765	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Boston+Harbor%2C+Massachusetts+Current	12629	current
12766	https://www.google.com/maps/place/42°20'17.0"N+70°57'24.0"W/@42.3383,-70.9567	12629	map
12767	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Boundary+Pass%2C+2+miles+NNE+of+Skipjack+Island%2C+Washington+Current	12630	current
12768	https://www.google.com/maps/place/47°46'0.0"N+123°1'0.0"W/@47.7667,-123.0167	12630	map
12769	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bourne+Highway+bridge%2C+Massachusetts+Current	12631	current
12770	https://www.google.com/maps/place/41°45'0.0"N+70°34'59.0"W/@41.75,-70.5833	12631	map
12771	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bournedale%2C+Massachusetts+Current	12632	current
12772	https://www.google.com/maps/place/41°46'0.0"N+70°34'0.0"W/@41.7667,-70.5667	12632	map
12773	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Braddock+Point%2C+SW+of%2C+Calibogue+Sound%2C+South+Carolina+Current+%2810d%29	12633	current
12774	https://www.google.com/maps/place/32°6'17.0"N+80°50'12.0"W/@32.105,-80.8367	12633	map
12775	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bradley+Point%2C+NNE+of%2C+Georgia+Current+%2810d%29	12634	current
12776	https://www.google.com/maps/place/31°49'54.0"N+81°2'17.0"W/@31.8317,-81.0383	12634	map
12777	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Brandt+Bridge%2C+San+Joaquin+River%2C+California+Current	12635	current
12778	https://www.google.com/maps/place/37°51'59.0"N+121°18'59.0"W/@37.866666,-121.3166	12635	map
12779	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Branford+Reef%2C+1%2E5+miles+southwest+of%2C+Connecticut+Current+%2815d%29	12636	current
12780	https://www.google.com/maps/place/41°12'34.0"N+72°49'49.0"W/@41.2095,-72.8305	12636	map
12781	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Branford+Reef%2C+5%2E0+miles+south+of%2C+Connecticut+Current+%2815d%29	12637	current
12782	https://www.google.com/maps/place/41°8'39.0"N+72°49'40.0"W/@41.1442,-72.8278	12637	map
12783	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Brenton+Point%2C+1%2E4+n%2Emi%2E+southwest+of%2C+Rhode+Island+Current+%287d%29	12638	current
12784	https://www.google.com/maps/place/41°25'54.0"N+71°22'36.0"W/@41.4317,-71.3767	12638	map
12785	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Brewerton+Channel+Eastern+Ext%2E%2C+Buoy+%277%27%2C+Maryland+Current+%2814d%29	12639	current
12786	https://www.google.com/maps/place/39°9'46.0"N+76°23'22.0"W/@39.163,-76.3897	12639	map
12787	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Brickyard+Creek%2C+South+Carolina+Current+%2810d%29	12640	current
12788	https://www.google.com/maps/place/32°28'23.0"N+80°41'30.0"W/@32.4733,-80.6917	12640	map
12789	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bridge%2C+0%2E8+mi%2E+south+of+Maximo+Pt%2E%2C+Florida+Current	12641	current
12790	https://www.google.com/maps/place/27°41'35.0"N+82°40'48.0"W/@27.6933,-82.68	12641	map
12791	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bridgeport+Hbr%2E+ent%2E%2C+btn%2E+jetties%2C+Connecticut+Current+%284d%29	12642	current
12792	https://www.google.com/maps/place/41°8'59.0"N+73°10'59.0"W/@41.15,-73.1833	12642	map
12793	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Broad+River+Bridge%2C+S+of%2C+Broad+River%2C+South+Carolina+Current+%2815d%29	12643	current
12794	https://www.google.com/maps/place/32°22'54.0"N+80°46'36.0"W/@32.3817,-80.7767	12643	map
12795	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Broad+River+Entrance%2C+Point+Royal+Sound%2C+South+Carolina+Current+%2815d%29	12644	current
12796	https://www.google.com/maps/place/32°13'54.0"N+80°38'24.0"W/@32.2317,-80.64	12644	map
12797	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Broadway+Bridge%2C+New+York+Current	12645	current
12798	https://www.google.com/maps/place/40°52'23.0"N+73°54'42.0"W/@40.8733,-73.9117	12645	map
12799	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Broken+Ground%2DHorseshoe+Shoal%2C+between%2C+Massachusetts+Current	12646	current
12800	https://www.google.com/maps/place/41°32'59.0"N+70°17'5.0"W/@41.55,-70.285	12646	map
12801	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bronx%2DWhitestone+Bridge%2C+East+of%2C+New+York+Current+%2814d%29	12647	current
12802	https://www.google.com/maps/place/40°48'6.0"N+73°49'36.0"W/@40.8017,-73.8267	12647	map
12803	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Brooklyn+Bridge%2C+0%2E1+mile+southwest+of%2C+New+York+Current	12648	current
12804	https://www.google.com/maps/place/40°42'11.0"N+74°0'0.0"W/@40.7033,-74.0	12648	map
12805	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Brooklyn+Bridge%2C+New+York+Current+%2815d%29	12649	current
12806	https://www.google.com/maps/place/40°42'21.0"N+73°59'51.0"W/@40.706,-73.9975	12649	map
12807	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Broomes+Island%2C+0%2E4+mile+south+of%2C+Maryland+Current	12650	current
12808	https://www.google.com/maps/place/38°23'42.0"N+76°33'15.0"W/@38.395,-76.5542	12650	map
12809	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Broughton+Island+%28south%29%2C+Buttermilk+Sound%2C+Georgia+Current+%289d%29	12651	current
12810	https://www.google.com/maps/place/31°18'35.0"N+81°24'47.0"W/@31.31,-81.4133	12651	map
12811	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Brunswick+River+Bridge%2C+southeast+of%2C+Georgia+Current+%2813d%29	12652	current
12812	https://www.google.com/maps/place/31°6'53.0"N+81°28'36.0"W/@31.115,-81.4767	12652	map
12813	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Brunswick+River+Bridge%2C+southeast+of%2C+Georgia+Current+%2821d%29	12653	current
12814	https://www.google.com/maps/place/31°6'53.0"N+81°28'36.0"W/@31.115,-81.4767	12653	map
12815	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Brunswick+River%2C+off+Quarantine+Dock%2C+Georgia+Current	12654	current
12816	https://www.google.com/maps/place/31°6'42.0"N+81°28'23.0"W/@31.1117,-81.4733	12654	map
12817	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Brunswick%2C+off+Prince+Street+Dock%2C+Georgia+Current	12655	current
12818	https://www.google.com/maps/place/31°8'17.0"N+81°29'48.0"W/@31.1383,-81.4967	12655	map
12819	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bull+Point%2C+east+of%2C+Rhode+Island+Current+%2810d%29	12656	current
12820	https://www.google.com/maps/place/41°28'47.0"N+71°20'59.0"W/@41.48,-71.35	12656	map
12821	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bull+River%2C+2+miles+below+hwy%2E+bridge%2C+Georgia+Current	12657	current
12822	https://www.google.com/maps/place/32°1'5.0"N+80°56'23.0"W/@32.0183,-80.94	12657	map
12823	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bunces+Pass+%28West+of+Bayway+bridge%29%2C+Florida+Current	12658	current
12824	https://www.google.com/maps/place/27°38'49.0"N+82°44'22.0"W/@27.647,-82.7395	12658	map
12825	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Buoy+%2719%27%2C+off+Nowell+Creek%2C+Wando+River%2C+South+Carolina+Current	12659	current
12826	https://www.google.com/maps/place/32°52'19.0"N+79°51'55.0"W/@32.872,-79.8655	12659	map
12827	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Burnside+Island%2C+SE+of%2C+Burnside+River%2C+Georgia+Current+%2810d%29	12660	current
12828	https://www.google.com/maps/place/31°55'18.0"N+81°4'47.0"W/@31.9217,-81.08	12660	map
12829	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Burntpot+Island%2C+west+of%2C+Skidaway+River%2C+Georgia+Current+%286d%29	12661	current
12830	https://www.google.com/maps/place/31°58'5.0"N+81°3'11.0"W/@31.9683,-81.0533	12661	map
12831	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Burrows+Bay%2C+0%2E5+E+of+Allan+Island%2C+Washington+Current	12662	current
12832	https://www.google.com/maps/place/47°28'0.0"N+122°40'59.0"W/@47.4667,-122.6833	12662	map
12833	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Burrows+Bay%2C+0%2E5+mile+east+of+Allan+I%2C+Washington+Current	12663	current
12834	https://www.google.com/maps/place/48°27'46.0"N+122°40'58.0"W/@48.4628,-122.6828	12663	map
12835	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Burrows+I%2E%2DAllan+I%2E%2C+Passage+between%2C+Washington+Current	12664	current
12836	https://www.google.com/maps/place/48°28'18.0"N+122°41'58.0"W/@48.4717,-122.6997	12664	map
12837	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Burrows+Is+%2D+Allan+Is+channel%2C+Washington+Current	12665	current
12838	https://www.google.com/maps/place/47°28'0.0"N+122°42'0.0"W/@47.4667,-122.7	12665	map
12839	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Burrows+Island+Light%2C+0%2E8+miles+WNW+of%2C+Washington+Current	12666	current
12840	https://www.google.com/maps/place/48°28'59.0"N+122°43'59.0"W/@48.4833,-122.7333	12666	map
12841	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Burrows+Island+Light%2C+Washington+Current	12667	current
12842	https://www.google.com/maps/place/47°28'59.0"N+122°43'59.0"W/@47.4833,-122.7333	12667	map
12843	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bush+Point+Light%2C+0%2E5+mile+NW+of%2C+Washington+Current	12668	current
12844	https://www.google.com/maps/place/48°1'59.0"N+122°37'0.0"W/@48.0333,-122.6167	12668	map
12845	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Bush+River%2C+0%2E4+mi%2E+SW+of+Bush+Point%2C+Maryland+Current	12669	current
12846	https://www.google.com/maps/place/39°21'24.0"N+76°15'24.0"W/@39.3567,-76.2567	12669	map
12847	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Butler+Island%2C+0%2E3+mile+south+of%2C+South+Carolina+Current	12670	current
12848	https://www.google.com/maps/place/33°25'0.0"N+79°12'43.0"W/@33.4167,-79.212	12670	map
12849	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Buttermilk+Channel+%28SEE+CAUTION+NOTE%29%2C+New+York+Current+%2815d%29	12671	current
12850	https://www.google.com/maps/place/40°41'17.0"N+74°0'47.0"W/@40.6883,-74.0133	12671	map
12851	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Buttermilk+Channel%2C+New+York+Current	12672	current
12852	https://www.google.com/maps/place/40°41'8.0"N+74°0'48.0"W/@40.6858,-74.0135	12672	map
12853	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Buzzard+Roost+Creek%2C+Georgia+Current+%2813d%29	12673	current
12854	https://www.google.com/maps/place/31°24'53.0"N+81°22'30.0"W/@31.415,-81.375	12673	map
12855	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Byrd+Creek+Entrance%2C+SE+of%2C+Broad+River%2C+South+Carolina+Current+%2812d%29	12674	current
12856	https://www.google.com/maps/place/32°27'24.0"N+80°49'5.0"W/@32.4567,-80.8183	12674	map
12857	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cabin+Bluff%2C+Cumberland+River%2C+Georgia+Current	12675	current
12858	https://www.google.com/maps/place/30°52'54.0"N+81°30'47.0"W/@30.8817,-81.5133	12675	map
12859	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Caesar+Creek%2C+Biscayne+Bay%2C+Florida+Current	12676	current
12860	https://www.google.com/maps/place/25°23'12.0"N+80°13'36.0"W/@25.3867,-80.2267	12676	map
12861	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cambridge+hwy%2E+bridge%2C+W%2E+of+Swing+Span%2C+Maryland+Current+%2818d%29	12677	current
12862	https://www.google.com/maps/place/38°34'46.0"N+76°3'40.0"W/@38.5797,-76.0612	12677	map
12863	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Caminada+Pass%2C+Barataria+Bay%2C+Louisiana+Current	12678	current
12864	https://www.google.com/maps/place/29°11'53.0"N+90°2'48.0"W/@29.1983,-90.0467	12678	map
12865	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Camp+Key%2C+1%2E9+miles+northwest+of%2C+Florida+Current	12679	current
12866	https://www.google.com/maps/place/27°42'28.0"N+82°32'59.0"W/@27.7078,-82.55	12679	map
12867	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Campbell+Island%2C+east+side%2C+North+Carolina+Current+%2816d%29	12680	current
12868	https://www.google.com/maps/place/34°7'13.0"N+77°56'10.0"W/@34.1203,-77.9363	12680	map
12869	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Campbell+Island%2C+east+side%2C+North+Carolina+Current+%2826d%29	12681	current
12870	https://www.google.com/maps/place/34°7'13.0"N+77°56'10.0"W/@34.1203,-77.9363	12681	map
12871	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Campbell+Island%2C+east+side%2C+North+Carolina+Current+%286d%29	12682	current
12872	https://www.google.com/maps/place/34°7'13.0"N+77°56'10.0"W/@34.1203,-77.9363	12682	map
12873	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Canapitsit+Channel%2C+Massachusetts+Current	12683	current
12874	https://www.google.com/maps/place/41°25'23.0"N+70°54'29.0"W/@41.4233,-70.9083	12683	map
12875	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cape+Blanco%2C+Oregon+Current	12684	current
12876	https://www.google.com/maps/place/42°49'59.0"N+124°34'59.0"W/@42.8333,-124.5833	12684	map
12877	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cape+Cod+Canal+%28railroad+bridge%29%2C+Massachusetts+Current	12685	current
12878	https://www.google.com/maps/place/41°44'30.0"N+70°36'47.0"W/@41.7417,-70.6133	12685	map
12879	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cape+Cod+Canal%2C+east+end%2C+Massachusetts+Current+%2815d%29	12686	current
12880	https://www.google.com/maps/place/41°46'29.0"N+70°30'0.0"W/@41.775,-70.5	12686	map
12881	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cape+Cod+Canal%2C+Massachusetts+Current	12687	current
12882	https://www.google.com/maps/place/41°44'30.0"N+70°36'47.0"W/@41.7417,-70.6133	12687	map
12883	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cape+Constantine%2C+4+miles+Southeast+of%2C+Alaska+Current	12688	current
12884	https://www.google.com/maps/place/58°19'59.0"N+158°46'0.0"W/@58.3333,-158.7667	12688	map
12885	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cape+Haze%2C+2%2E3+mi%2E+S+of%2C+Charlotte+Hbr%2C+Florida+Current	12689	current
12886	https://www.google.com/maps/place/26°44'42.0"N+82°9'6.0"W/@26.745,-82.1517	12689	map
12887	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cape+Lieskof%2C+3+miles+west+of%2C+Alaska+Current	12690	current
12888	https://www.google.com/maps/place/55°45'0.0"N+162°11'59.0"W/@55.75,-162.2	12690	map
12889	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cape+Poge+Light%2C+1%2E4+miles+west+of%2C+Massachusetts+Current	12691	current
12890	https://www.google.com/maps/place/41°25'27.0"N+70°28'59.0"W/@41.4242,-70.4833	12691	map
12891	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cape+Poge+Lt%2E%2C+1%2E7+miles+SSE+of%2C+Massachusetts+Current	12692	current
12892	https://www.google.com/maps/place/41°23'59.0"N+70°25'36.0"W/@41.4,-70.4267	12692	map
12893	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cape+Poge+Lt%2E%2C+3%2E2+miles+northeast+of%2C+Massachusetts+Current	12693	current
12894	https://www.google.com/maps/place/41°27'29.0"N+70°24'0.0"W/@41.4583,-70.4	12693	map
12895	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cape+Sebastian%2C+Oregon+Current	12694	current
12896	https://www.google.com/maps/place/42°19'59.0"N+124°25'59.0"W/@42.3333,-124.4333	12694	map
12897	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cape+Spencer%2C+3+miles+south+of%2C+Alaska+Current	12695	current
12898	https://www.google.com/maps/place/58°8'59.0"N+136°37'59.0"W/@58.15,-136.6333	12695	map
12899	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cape+Vizcaino%2C+California+Current	12696	current
12900	https://www.google.com/maps/place/39°43'59.0"N+123°49'59.0"W/@39.7333,-123.8333	12696	map
12901	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Captain+Hbr%2E+Ent%2E%2C+0%2E6+mile+southwest+of%2C+Connecticut+Current+%2815d%29	12697	current
12902	https://www.google.com/maps/place/40°59'39.0"N+73°35'40.0"W/@40.9942,-73.5945	12697	map
12903	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Captain+Hbr%2E+Ent%2E%2C+0%2E6+mile+southwest+of%2C+Connecticut+Current+%2830d%29	12698	current
12904	https://www.google.com/maps/place/40°59'39.0"N+73°35'40.0"W/@40.9942,-73.5945	12698	map
12905	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Captiva+Pass%2C+Florida+Current	12699	current
12906	https://www.google.com/maps/place/26°36'33.0"N+82°13'20.0"W/@26.6093,-82.2223	12699	map
12907	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Carquinez+Strait%2C+California+Current	12700	current
12908	https://www.google.com/maps/place/38°3'42.0"N+122°13'5.0"W/@38.0617,-122.2183	12700	map
12909	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Carrot+Island%2C+Beaufort+Inlet%2C+North+Carolina+Current+%286d%29	12701	current
12910	https://www.google.com/maps/place/34°42'7.0"N+76°37'3.0"W/@34.7022,-76.6175	12701	map
12911	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Carson+Creek+Entrance%2C+1%2E4+nmi%2E+ESE+of%2C+Alaska+Current+%2815d%29+%2D+IGNORE+HEIGHTS	12702	current
12912	https://www.google.com/maps/place/59°58'59.0"N+141°28'11.0"W/@59.9833,-141.47	12702	map
12913	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Carson+Creek+Entrance%2C+2%2E4+nmi%2E+ESE+of%2C+Alaska+Current+%2850d%29	12703	current
12914	https://www.google.com/maps/place/59°59'12.0"N+141°26'12.0"W/@59.9867,-141.4367	12703	map
12915	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Carson+Creek+Entrance%2C+3%2E3+nmi%2E+SE+of%2C+Alaska+Current+%2878d%29	12704	current
12916	https://www.google.com/maps/place/59°58'11.0"N+141°24'47.0"W/@59.97,-141.4133	12704	map
12917	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Carter+Bay%2C+west+of%2C+Alaska+Current	12705	current
12918	https://www.google.com/maps/place/59°16'59.0"N+162°22'0.0"W/@59.2833,-162.3667	12705	map
12919	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Castle+Hill%2C+west+of%2C+East+Passage%2C+Rhode+Island+Current+%2815d%29	12706	current
12920	https://www.google.com/maps/place/41°27'24.0"N+71°22'41.0"W/@41.4567,-71.3783	12706	map
12921	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Castle+Pinckney%2C+0%2E4+mile+south+of%2C+South+Carolina+Current	12707	current
12922	https://www.google.com/maps/place/32°46'1.0"N+79°54'42.0"W/@32.767,-79.9117	12707	map
12923	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Castle+Pinckney%2C+0%2E6+mile+southwest+of%2C+South+Carolina+Current	12708	current
12924	https://www.google.com/maps/place/32°45'58.0"N+79°55'10.0"W/@32.7663,-79.9195	12708	map
12925	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cathlamet+Channel%2C+SE+of+Nassa+Point%2C+Washington+Current+%2819d%29	12709	current
12926	https://www.google.com/maps/place/46°9'22.0"N+123°18'53.0"W/@46.1562,-123.315	12709	map
12927	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cats+Point+%28bridge+west+of%29%2C+Florida+Current	12710	current
12928	https://www.google.com/maps/place/27°42'29.0"N+82°43'28.0"W/@27.7083,-82.7247	12710	map
12929	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cattle+Point%2C+1%2E2+mile+SE+of%2C+Washington+Current	12711	current
12930	https://www.google.com/maps/place/48°25'0.0"N+122°57'0.0"W/@48.4167,-122.95	12711	map
12931	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cattle+Point%2C+1%2E2+miles+southeast+of%2C+Washington+Current	12712	current
12932	https://www.google.com/maps/place/48°26'1.0"N+122°56'49.0"W/@48.4338,-122.947	12712	map
12933	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cattle+Point%2C+2%2E8+miles+SSW+of%2C+Washington+Current	12713	current
12934	https://www.google.com/maps/place/48°23'59.0"N+123°0'0.0"W/@48.4,-123.0	12713	map
12935	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cattle+Point%2C+5+miles+SSW+of%2C+Washington+Current	12714	current
12936	https://www.google.com/maps/place/48°22'59.0"N+123°1'0.0"W/@48.3833,-123.0167	12714	map
12937	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cedar+Hammock%2C+south+of%2C+Georgia+Current+%2812d%29	12715	current
12938	https://www.google.com/maps/place/31°32'42.0"N+81°14'48.0"W/@31.545,-81.2467	12715	map
12939	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cedar+Point%2C+0%2E2+mile+west+of%2C+New+York+Current	12716	current
12940	https://www.google.com/maps/place/41°2'22.0"N+72°16'4.0"W/@41.0397,-72.2678	12716	map
12941	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cedar+Point%2C+1%2E1+miles+ENE+of%2C+Maryland+Current	12717	current
12942	https://www.google.com/maps/place/38°18'16.0"N+76°21'6.0"W/@38.3045,-76.3517	12717	map
12943	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cedar+Point%2C+2%2E9+n%2Emi%2E+ENE+of%2C+Maryland+Current+%2816d%29	12718	current
12944	https://www.google.com/maps/place/38°18'38.0"N+76°18'47.0"W/@38.3108,-76.3133	12718	map
12945	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cedar+Point%2C+2%2E9+n%2Emi%2E+ENE+of%2C+Maryland+Current+%2850d%29	12719	current
12946	https://www.google.com/maps/place/38°18'38.0"N+76°18'47.0"W/@38.3108,-76.3133	12719	map
12947	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cedar+Point%2C+4%2E7+n%2Emi%2E+east+of%2C+Maryland+Current+%2815d%29	12720	current
12948	https://www.google.com/maps/place/38°17'55.0"N+76°16'22.0"W/@38.2987,-76.273	12720	map
12949	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cedar+Point%2C+4%2E7+n%2Emi%2E+east+of%2C+Maryland+Current+%285d%29	12721	current
12950	https://www.google.com/maps/place/38°17'55.0"N+76°16'22.0"W/@38.2987,-76.273	12721	map
12951	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cerberus+Shoal+and+Fishers+I%2E%2C+between%2C+Connecticut+Current+%287d%29	12722	current
12952	https://www.google.com/maps/place/41°13'0.0"N+71°58'0.0"W/@41.2167,-71.9667	12722	map
12953	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cerberus+Shoal%2C+1%2E5+miles+east+of%2C+Connecticut+Current+%2815d%29	12723	current
12954	https://www.google.com/maps/place/41°10'27.0"N+71°55'10.0"W/@41.1742,-71.9195	12723	map
12955	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Chain+Island+%2E7+mi+SW%2C+Sacramento+River%2C+California+Current	12724	current
12956	https://www.google.com/maps/place/38°2'59.0"N+121°51'59.0"W/@38.05,-121.8666	12724	map
12957	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=channel+entrance%2C+Ocracoke+Inlet%2C+North+Carolina+Current	12725	current
12958	https://www.google.com/maps/place/35°3'55.0"N+76°1'7.0"W/@35.0653,-76.0188	12725	map
12959	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Channel%2C+1%2E5+miles+north+of+Westport%2C+Washington+Current	12726	current
12960	https://www.google.com/maps/place/46°55'59.0"N+124°5'59.0"W/@46.9333,-124.1	12726	map
12961	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Channel%2C+2%2E1+miles+NNE+of+Westport%2C+Washington+Current	12727	current
12962	https://www.google.com/maps/place/46°55'59.0"N+124°4'59.0"W/@46.9333,-124.0833	12727	map
12963	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Channel%2C+6+miles+N+of+Mobile+Point%2C+Alabama+Current	12728	current
12964	https://www.google.com/maps/place/30°19'47.0"N+88°1'41.0"W/@30.33,-88.0283	12728	map
12965	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Charles+Island%2C+0%2E8+mile+SSE+of%2C+Connecticut+Current	12729	current
12966	https://www.google.com/maps/place/41°10'46.0"N+73°2'37.0"W/@41.1795,-73.0438	12729	map
12967	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Charleston+Harbor+%28off+Fort+Sumter%29%2C+South+Carolina+Current	12730	current
12968	https://www.google.com/maps/place/32°45'21.0"N+79°52'13.0"W/@32.756,-79.8703	12730	map
12969	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Charleston+Harbor+Entrance%2C+South+Carolina+Current	12731	current
12970	https://www.google.com/maps/place/32°45'24.0"N+79°52'12.0"W/@32.7567,-79.87	12731	map
12971	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Charleston+Harbor%2C+off+Fort+Sumter%2C+South+Carolina+Current+%28expired+1996%2D12%2D31%29	12732	current
12972	https://www.google.com/maps/place/32°45'29.0"N+79°52'5.0"W/@32.7583,-79.8683	12732	map
12973	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Charleston+Hbr%2E+ent%2E+%28between+jetties%29%2C+South+Carolina+Current	12733	current
12974	https://www.google.com/maps/place/32°43'59.0"N+79°49'59.0"W/@32.7333,-79.8333	12733	map
12975	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Chaseville+Turn%2C+Florida+Current+%2814d%29	12734	current
12976	https://www.google.com/maps/place/30°22'42.0"N+81°37'46.0"W/@30.3785,-81.6295	12734	map
12977	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Chaseville+Turn%2C+Florida+Current+%2830d%29	12735	current
12978	https://www.google.com/maps/place/30°22'42.0"N+81°37'46.0"W/@30.3785,-81.6295	12735	map
12979	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Chaseville+Turn%2C+Florida+Current+%284d%29	12736	current
12980	https://www.google.com/maps/place/30°22'42.0"N+81°37'46.0"W/@30.3785,-81.6295	12736	map
12981	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Chesapeake+and+Delaware+Canal%2C+Maryland%2FDelaware+Current	12737	current
12982	https://www.google.com/maps/place/39°31'59.0"N+75°49'0.0"W/@39.5333,-75.8167	12737	map
12983	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Chesapeake+Bay+Bridge%2C+main+channel%2C+Maryland+Current	12738	current
12984	https://www.google.com/maps/place/38°59'30.0"N+76°23'6.0"W/@38.9917,-76.385	12738	map
13202	https://www.google.com/maps/place/38°48'19.0"N+76°12'33.0"W/@38.8055,-76.2092	12847	map
12985	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Chesapeake+Bay+Entrance%2C+Virginia+Current+%281%29+%28expired+1987%2D12%2D31%29	12739	current
12986	https://www.google.com/maps/place/36°58'47.0"N+76°0'24.0"W/@36.98,-76.0067	12739	map
12987	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Chesapeake+Bay+Entrance%2C+Virginia+Current+%282%29	12740	current
12988	https://www.google.com/maps/place/36°58'47.0"N+75°59'53.0"W/@36.98,-75.9983	12740	map
12989	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Chestertown%2C+Maryland+Current	12741	current
12990	https://www.google.com/maps/place/39°12'25.0"N+76°3'40.0"W/@39.2072,-76.0612	12741	map
12991	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Childsbury%2C+S%2EA%2EL%2E+RR%2E+bridge%2C+Cooper+River%2C+South+Carolina+Current	12742	current
12992	https://www.google.com/maps/place/33°5'37.0"N+79°56'32.0"W/@33.0938,-79.9425	12742	map
12993	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Chinook+Point%2C+WSW+of%2C+Washington+Current+%2814d%29	12743	current
12994	https://www.google.com/maps/place/46°14'31.0"N+123°57'51.0"W/@46.2422,-123.9642	12743	map
12995	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Chlora+Point%2C+0%2E5+n%2Emi%2E+SSW+of%2C+Maryland+Current+%2817d%29	12744	current
12996	https://www.google.com/maps/place/38°37'41.0"N+76°9'6.0"W/@38.6283,-76.1517	12744	map
12997	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Chlora+Point%2C+0%2E5+n%2Emi%2E+SSW+of%2C+Maryland+Current+%2824d%29	12745	current
12998	https://www.google.com/maps/place/38°37'41.0"N+76°9'6.0"W/@38.6283,-76.1517	12745	map
12999	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Chowan+Creek%2C+South+Carolina+Current+%2815d%29	12746	current
13000	https://www.google.com/maps/place/32°22'11.0"N+80°38'17.0"W/@32.37,-80.6383	12746	map
13001	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Chugul+Pass%2C+0%2E5+mile+NE+of+Cape+Ruin%2C+Alaska+Current	12747	current
13002	https://www.google.com/maps/place/51°55'0.0"N+175°58'0.0"W/@51.9167,-175.9667	12747	map
13003	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Chugul+Pass%2C+0%2E8+mile+SW+of+Tanager+Pt%2C+Alaska+Current	12748	current
13004	https://www.google.com/maps/place/51°55'59.0"N+175°52'59.0"W/@51.9333,-175.8833	12748	map
13005	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Chugul+Pass%2C+2+miles+NE+of+Cape+Ruin%2C+Alaska+Current	12749	current
13006	https://www.google.com/maps/place/51°55'59.0"N+175°55'59.0"W/@51.9333,-175.9333	12749	map
13007	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=City+Island+Bridge%2C+New+York+Current+%2810d%29	12750	current
13008	https://www.google.com/maps/place/40°51'28.0"N+73°47'35.0"W/@40.8578,-73.7933	12750	map
13009	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=City+Island%2C+0%2E6+mile+southeast+of%2C+New+York+Current+%2815d%29	12751	current
13010	https://www.google.com/maps/place/40°49'43.0"N+73°46'28.0"W/@40.8287,-73.7745	12751	map
13011	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=City+Point%2C+1%2E3+miles+northeast+of%2C+Connecticut+Current	12752	current
13012	https://www.google.com/maps/place/41°17'49.0"N+72°54'25.0"W/@41.2972,-72.907	12752	map
13013	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Clark+Island%2C+1%2E6+mile+North+of%2C+Washington+Current	12753	current
13014	https://www.google.com/maps/place/48°43'59.0"N+122°46'0.0"W/@48.7333,-122.7667	12753	map
13015	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Clark+Island%2C+1%2E6+miles+north+of%2C+Washington+Current	12754	current
13016	https://www.google.com/maps/place/48°43'52.0"N+122°46'23.0"W/@48.7313,-122.7733	12754	map
13017	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Clarks+Point%2C+1+mile+west+of%2C+Alaska+Current	12755	current
13018	https://www.google.com/maps/place/58°49'59.0"N+158°34'59.0"W/@58.8333,-158.5833	12755	map
13019	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Clason+Point%2C+0%2E3+n%2Emi%2E+S+of%2C+New+York+Current+%2815d%29	12756	current
13020	https://www.google.com/maps/place/40°47'58.0"N+73°50'48.0"W/@40.7997,-73.8468	12756	map
13021	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Clatsop+Spit%2C+NNE+of%2C+Washington+Current+%2815d%29	12757	current
13022	https://www.google.com/maps/place/46°14'46.0"N+123°59'39.0"W/@46.2462,-123.9942	12757	map
13023	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Clay+Head%2C+1%2E2+miles+ENE+of%2C+Block+Island%2C+Rhode+Island+Current+%2815d%29	12758	current
13024	https://www.google.com/maps/place/41°13'20.0"N+71°31'50.0"W/@41.2225,-71.5308	12758	map
13025	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Clay+Point%2C+1%2E3+miles+NNE+of%2C+New+York+Current+%2815d%29	12759	current
13026	https://www.google.com/maps/place/41°17'52.0"N+71°58'31.0"W/@41.298,-71.9755	12759	map
13027	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Claybluff+Point+Light%2C+2%2E3+nmi%2E+SE+of%2C+Alaska+Current+%286d%29	12760	current
13028	https://www.google.com/maps/place/59°56'48.0"N+141°31'12.0"W/@59.9467,-141.52	12760	map
13029	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Claybluff+Point+Light%2C+3%2E5+nmi%2E+south+of%2C+Alaska+Current+%2875d%29	12761	current
13030	https://www.google.com/maps/place/59°54'35.0"N+141°35'41.0"W/@59.91,-141.595	12761	map
13031	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Clearwater+Pass%2C+0%2E2+mi%2E+NE+of+Sand+Key%2C+Florida+Current	12762	current
13032	https://www.google.com/maps/place/27°57'24.0"N+82°49'23.0"W/@27.9567,-82.8233	12762	map
13033	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Clifton+Channel%2C+Washington+Current+%2810d%29	12763	current
13034	https://www.google.com/maps/place/46°13'4.0"N+123°27'55.0"W/@46.2178,-123.4653	12763	map
13035	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Coast+Guard+Tower%2C+southwest+of%2C+Oregon+Inlet%2C+North+Carolina+Current+%2812d%29	12764	current
13036	https://www.google.com/maps/place/35°45'42.0"N+75°31'54.0"W/@35.7617,-75.5317	12764	map
13037	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Coast+Guard+Tower%2C+southwest+of%2C+Oregon+Inlet%2C+North+Carolina+Current+%286d%29	12765	current
13038	https://www.google.com/maps/place/35°45'42.0"N+75°31'54.0"W/@35.7617,-75.5317	12765	map
13039	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cold+Spring+Pt%2E%2C+Seekonk+River%2C+Rhode+Island+Current	12766	current
13040	https://www.google.com/maps/place/41°49'36.0"N+71°22'47.0"W/@41.8267,-71.38	12766	map
13041	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=College+Point+Reef%2C+0%2E25+n%2Emi%2E+NW+of%2C+New+York+Current+%2815d%29	12767	current
13042	https://www.google.com/maps/place/40°48'3.0"N+73°51'16.0"W/@40.801,-73.8547	12767	map
13043	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Colville+Island%2C+1+mile+SSE+of%2C+Washington+Current	12768	current
13044	https://www.google.com/maps/place/48°23'59.0"N+122°49'0.0"W/@48.4,-122.8167	12768	map
13045	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Colville+Island%2C+1+miles+SSE+of%2C+Washington+Current	12769	current
13046	https://www.google.com/maps/place/47°23'59.0"N+122°49'0.0"W/@47.4,-122.8167	12769	map
13047	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Colville+Island%2C+1%2E4+miles+E+of%2C+Washington+Current	12770	current
13048	https://www.google.com/maps/place/47°25'0.0"N+122°46'59.0"W/@47.4167,-122.7833	12770	map
13049	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Colville+Island%2C+1%2E4+miles+east+of%2C+Washington+Current	12771	current
13050	https://www.google.com/maps/place/48°25'0.0"N+122°46'59.0"W/@48.4167,-122.7833	12771	map
13051	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Combahee+River%2C+South+Carolina+Current+%2815d%29	12772	current
13052	https://www.google.com/maps/place/32°32'59.0"N+80°33'47.0"W/@32.55,-80.5633	12772	map
13053	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Combahee+River%2C+South+Carolina+Current+%288d%29	12773	current
13054	https://www.google.com/maps/place/32°31'36.0"N+80°32'12.0"W/@32.5267,-80.5367	12773	map
13055	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Commodore+Point%2C+terminal+channel%2C+Florida+Current+%2817d%29	12774	current
13056	https://www.google.com/maps/place/30°19'2.0"N+81°37'34.0"W/@30.3175,-81.6263	12774	map
13057	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Commodore+Point%2C+terminal+channel%2C+Florida+Current+%2827d%29	12775	current
13058	https://www.google.com/maps/place/30°19'2.0"N+81°37'34.0"W/@30.3175,-81.6263	12775	map
13059	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Commodore+Point%2C+terminal+channel%2C+Florida+Current+%287d%29	12776	current
13060	https://www.google.com/maps/place/30°19'2.0"N+81°37'34.0"W/@30.3175,-81.6263	12776	map
13061	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Common+Fence+Point%2C+northeast+of%2C+Rhode+Island+Current+%2810d%29	12777	current
13062	https://www.google.com/maps/place/41°39'29.0"N+71°12'29.0"W/@41.6583,-71.2083	12777	map
13063	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Common+Fence+Point%2C+west+of%2C+Rhode+Island+Current+%2810d%29	12778	current
13064	https://www.google.com/maps/place/41°38'59.0"N+71°14'42.0"W/@41.65,-71.245	12778	map
13065	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Conanicut+Point%2C+ENE+of%2C+Rhode+Island+Current+%2815d%29	12779	current
13066	https://www.google.com/maps/place/41°34'30.0"N+71°20'30.0"W/@41.575,-71.3417	12779	map
13067	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cook+Point%2C+1%2E4+n%2Emi%2E+NNW+of%2C+Maryland+Current+%2815d%29	12780	current
13068	https://www.google.com/maps/place/38°38'49.0"N+76°18'24.0"W/@38.6472,-76.3067	12780	map
13069	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cook+Point%2C+1%2E4+n%2Emi%2E+NNW+of%2C+Maryland+Current+%2845d%29	12781	current
13070	https://www.google.com/maps/place/38°38'49.0"N+76°18'24.0"W/@38.6472,-76.3067	12781	map
13071	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Coos+Bay+entrance%2C+Oregon+Current	12782	current
13072	https://www.google.com/maps/place/43°21'17.0"N+124°20'28.0"W/@43.355,-124.341166666667	12782	map
13073	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Coosaw+Island%2C+South+of%2C+Morgan+River%2C+South+Carolina+Current+%2810d%29	12783	current
13074	https://www.google.com/maps/place/32°27'6.0"N+80°34'59.0"W/@32.4517,-80.5833	12783	map
13075	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Coquille+River+entrance%2C+Oregon+Current	12784	current
13076	https://www.google.com/maps/place/43°7'18.0"N+124°25'10.0"W/@43.1216666666667,-124.419666666667	12784	map
13077	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cornfield+Point%2C+1%2E1+miles+south+of%2C+Connecticut+Current+%2815d%29	12785	current
13078	https://www.google.com/maps/place/41°14'39.0"N+72°23'24.0"W/@41.2442,-72.39	12785	map
13079	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cornfield+Point%2C+1%2E9+n%2Emi%2E+SW+of%2C+Connecticut+Current+%2815d%29	12786	current
13080	https://www.google.com/maps/place/41°14'28.0"N+72°25'18.0"W/@41.2413,-72.4217	12786	map
13081	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cornfield+Point%2C+2%2E8+n%2Emi%2E+SE+of%2C+Connecticut+Current+%2815d%29	12787	current
13082	https://www.google.com/maps/place/41°13'57.0"N+72°20'19.0"W/@41.2325,-72.3388	12787	map
13083	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cornfield+Point%2C+3+miles+south+of%2C+Connecticut+Current+%287d%29	12788	current
13084	https://www.google.com/maps/place/41°12'54.0"N+72°22'23.0"W/@41.215,-72.3733	12788	map
13085	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Coronado%2C+off+northeast+end%2C+California+Current+%2814d%29	12789	current
13086	https://www.google.com/maps/place/32°41'52.0"N+117°9'49.0"W/@32.698,-117.1638	12789	map
13087	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Coronado%2C+off+northeast+end%2C+California+Current+%2838d%29	12790	current
13088	https://www.google.com/maps/place/32°41'52.0"N+117°9'49.0"W/@32.698,-117.1638	12790	map
13089	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cortez%2C+north+of+bridge%2C+Florida+Current	12791	current
13090	https://www.google.com/maps/place/27°28'11.0"N+82°41'35.0"W/@27.47,-82.6933	12791	map
13091	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cos+Cob+Harbor%2C+off+Goose+Island%2C+Connecticut+Current	12792	current
13092	https://www.google.com/maps/place/41°1'0.0"N+73°35'59.0"W/@41.0167,-73.6	12792	map
13093	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cotuit+Bay+entrance+%28Bluff+Point%29%2C+Massachusetts+Current	12793	current
13094	https://www.google.com/maps/place/41°36'35.0"N+70°25'48.0"W/@41.61,-70.43	12793	map
13095	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Courtney+Campbell+Parkway%2C+Florida+Current	12794	current
13096	https://www.google.com/maps/place/27°58'4.0"N+82°37'27.0"W/@27.968,-82.6242	12794	map
13097	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cove+Point+%281%2E1+mi%2E+NE+of%29%2C+Maryland+Current	12795	current
13098	https://www.google.com/maps/place/38°22'54.0"N+76°21'35.0"W/@38.3817,-76.36	12795	map
13099	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cove+Point%2C+1%2E1+n%2Emi%2E+east+of%2C+Maryland+Current+%2817d%29	12796	current
13100	https://www.google.com/maps/place/38°22'52.0"N+76°21'37.0"W/@38.3813,-76.3603	12796	map
13101	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cove+Point%2C+1%2E1+n%2Emi%2E+east+of%2C+Maryland+Current+%2840d%29	12797	current
13102	https://www.google.com/maps/place/38°22'52.0"N+76°21'37.0"W/@38.3813,-76.3603	12797	map
13103	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cove+Point%2C+2%2E7+n%2Emi%2E+east+of%2C+Maryland+Current+%2815d%29	12798	current
13104	https://www.google.com/maps/place/38°22'48.0"N+76°19'31.0"W/@38.38,-76.3253	12798	map
13105	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cove+Point%2C+2%2E7+n%2Emi%2E+east+of%2C+Maryland+Current+%2840d%29	12799	current
13106	https://www.google.com/maps/place/38°22'48.0"N+76°19'31.0"W/@38.38,-76.3253	12799	map
13107	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cove+Point%2C+2%2E7+n%2Emi%2E+east+of%2C+Maryland+Current+%2898d%29	12800	current
13108	https://www.google.com/maps/place/38°22'48.0"N+76°19'31.0"W/@38.38,-76.3253	12800	map
13109	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cove+Point%2C+3%2E9+n%2Emi%2E+east+of%2C+Maryland+Current+%2811d%29	12801	current
13110	https://www.google.com/maps/place/38°22'31.0"N+76°17'55.0"W/@38.3753,-76.2987	12801	map
13111	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cove+Point%2C+4%2E9+n%2Emi%2E+NNE+of%2C+Maryland+Current+%2815d%29	12802	current
13112	https://www.google.com/maps/place/38°28'1.0"N+76°22'36.0"W/@38.4672,-76.3767	12802	map
13113	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cove+Point%2C+4%2E9+n%2Emi%2E+NNE+of%2C+Maryland+Current+%2840d%29	12803	current
13114	https://www.google.com/maps/place/38°28'1.0"N+76°22'36.0"W/@38.4672,-76.3767	12803	map
13115	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cove+Point%2C+4%2E9+n%2Emi%2E+NNE+of%2C+Maryland+Current+%2867d%29	12804	current
13116	https://www.google.com/maps/place/38°28'1.0"N+76°22'36.0"W/@38.4672,-76.3767	12804	map
13117	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Craighill+Angle%2C+right+outside+quarter%2C+Maryland+Current	12805	current
13118	https://www.google.com/maps/place/39°7'41.0"N+76°23'16.0"W/@39.1283,-76.3878	12805	map
13119	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Craighill+Channel+entrance%2C+Buoy+%272C%27%2C+Maryland+Current+%2815d%29	12806	current
13120	https://www.google.com/maps/place/39°2'25.0"N+76°22'40.0"W/@39.0403,-76.3778	12806	map
13121	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Craighill+Channel+entrance%2C+Buoy+%272C%27%2C+Maryland+Current+%2838d%29	12807	current
13122	https://www.google.com/maps/place/39°2'25.0"N+76°22'40.0"W/@39.0403,-76.3778	12807	map
13123	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Craighill+Channel%2C+Belvidere+Shoal%2C+Maryland+Current+%2818d%29	12808	current
13124	https://www.google.com/maps/place/39°5'40.0"N+76°23'34.0"W/@39.0947,-76.393	12808	map
13125	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Craighill+Channel%2C+NE+of+Mountain+Pt%2C+Maryland+Current	12809	current
13126	https://www.google.com/maps/place/39°4'52.0"N+76°23'40.0"W/@39.0813,-76.3945	12809	map
13127	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Crane+Island%2C+south+of%2C+Wasp+Passage%2C+Washington+Current	12810	current
13128	https://www.google.com/maps/place/48°35'22.0"N+122°59'55.0"W/@48.5895,-122.9987	12810	map
13129	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Crane+Island%2C+Wasp+Passage%2C+South+of%2C+Washington+Current	12811	current
13130	https://www.google.com/maps/place/48°34'59.0"N+123°0'0.0"W/@48.5833,-123.0	12811	map
13131	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Crane+Neck+Point%2C+0%2E5+mile+northwest+of%2C+New+York+Current	12812	current
13132	https://www.google.com/maps/place/40°58'0.0"N+73°10'0.0"W/@40.9667,-73.1667	12812	map
13133	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Crane+Neck+Point%2C+3%2E4+miles+WNW+of%2C+New+York+Current+%2815d%29	12813	current
13134	https://www.google.com/maps/place/40°58'59.0"N+73°13'52.0"W/@40.9833,-73.2312	12813	map
13135	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Crane+Neck+Point%2C+3%2E7+miles+WSW+of%2C+New+York+Current+%2815d%29	12814	current
13136	https://www.google.com/maps/place/40°56'17.0"N+73°13'52.0"W/@40.9383,-73.2312	12814	map
13137	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Crescent+River%2C+Georgia+Current+%2811d%29	12815	current
13138	https://www.google.com/maps/place/31°29'12.0"N+81°18'24.0"W/@31.4867,-81.3067	12815	map
13139	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cross+Rip+Channel%2C+Massachusetts+Current	12816	current
13140	https://www.google.com/maps/place/41°26'53.0"N+70°17'30.0"W/@41.4483,-70.2917	12816	map
13141	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cryders+Point%2C+0%2E4+mile+NNW+of%2C+New+York+Current	12817	current
13142	https://www.google.com/maps/place/40°48'1.0"N+73°47'55.0"W/@40.8003,-73.7987	12817	map
13143	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cumberland+River%2C+north+entrance%2C+Georgia+Current	12818	current
13144	https://www.google.com/maps/place/30°57'29.0"N+81°25'54.0"W/@30.9583,-81.4317	12818	map
13145	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Customhouse+Reach%2C+off+Customhouse%2C+South+Carolina+Current	12819	current
13146	https://www.google.com/maps/place/32°46'46.0"N+79°55'20.0"W/@32.7795,-79.9225	12819	map
13147	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Customhouse+Reach%2C+South+Carolina+Current	12820	current
13148	https://www.google.com/maps/place/32°46'56.0"N+79°55'12.0"W/@32.7825,-79.92	12820	map
13149	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cut+A+%26+B%2C+Channel+Junction%2C+Florida+Current	12821	current
13150	https://www.google.com/maps/place/27°38'19.0"N+82°37'31.0"W/@27.6388,-82.6255	12821	map
13151	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cut+A+Channel%2C+marker+%2710%27%2C+Hillsborough+Bay%2C+Florida+Current+%2815d%29	12822	current
13152	https://www.google.com/maps/place/27°48'42.0"N+82°26'50.0"W/@27.8118,-82.4473	12822	map
13153	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cut+C+Channel%2C+marker+%2721%27%2C+Hillsborough+Bay%2C+Florida+Current+%2815d%29	12823	current
13154	https://www.google.com/maps/place/27°50'45.0"N+82°26'37.0"W/@27.846,-82.4437	12823	map
13155	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Cut+E+Channel%2C+marker+%272E%27%2C+Florida+Current+%2815d%29	12824	current
13156	https://www.google.com/maps/place/27°43'31.0"N+82°32'8.0"W/@27.7253,-82.5357	12824	map
13157	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dames+Point%2C+0%2E23+n%2Emi%2E+ESE+of%2C+Florida+Current+%2814d%29	12825	current
13158	https://www.google.com/maps/place/30°23'11.0"N+81°33'13.0"W/@30.3865,-81.5538	12825	map
13159	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dames+Point%2C+0%2E23+n%2Emi%2E+ESE+of%2C+Florida+Current+%2831d%29	12826	current
13160	https://www.google.com/maps/place/30°23'11.0"N+81°33'13.0"W/@30.3865,-81.5538	12826	map
13161	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dames+Point%2C+0%2E23+n%2Emi%2E+ESE+of%2C+Florida+Current+%285d%29	12827	current
13162	https://www.google.com/maps/place/30°23'11.0"N+81°33'13.0"W/@30.3865,-81.5538	12827	map
13163	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dames+Point%2C+0%2E25+n%2Emi%2E+SE+of%2C+Florida+Current+%2814d%29	12828	current
13164	https://www.google.com/maps/place/30°23'4.0"N+81°33'16.0"W/@30.3847,-81.5547	12828	map
13165	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dames+Point%2C+0%2E25+n%2Emi%2E+SE+of%2C+Florida+Current+%2828d%29	12829	current
13166	https://www.google.com/maps/place/30°23'4.0"N+81°33'16.0"W/@30.3847,-81.5547	12829	map
13167	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dames+Point%2C+0%2E25+n%2Emi%2E+SE+of%2C+Florida+Current+%285d%29	12830	current
13168	https://www.google.com/maps/place/30°23'4.0"N+81°33'16.0"W/@30.3847,-81.5547	12830	map
13169	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dana+Passage%2C+Washington+Current	12831	current
13170	https://www.google.com/maps/place/47°9'47.0"N+122°52'4.0"W/@47.1633,-122.8678	12831	map
13171	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Daniel+Island+Bend%2C+Cooper+River%2C+South+Carolina+Current	12832	current
13172	https://www.google.com/maps/place/32°50'53.0"N+79°55'45.0"W/@32.8483,-79.9292	12832	map
13173	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Daniel+Island+Reach%2C+Buoy+%2748%27%2C+Cooper+River%2C+South+Carolina+Current	12833	current
13174	https://www.google.com/maps/place/32°49'37.0"N+79°55'43.0"W/@32.8272,-79.9288	12833	map
13175	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Daniel+Island+Reach%2C+Cooper+River%2C+South+Carolina+Current	12834	current
13176	https://www.google.com/maps/place/32°49'58.0"N+79°55'48.0"W/@32.8328,-79.93	12834	map
13177	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Daufuskie+Landing+Light%2C+south+of%2C+South+Carolina+Current+%2810d%29	12835	current
13178	https://www.google.com/maps/place/32°6'6.0"N+80°53'53.0"W/@32.1017,-80.8983	12835	map
13179	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Davis+Point%2C+California+Current	12836	current
13180	https://www.google.com/maps/place/38°3'43.0"N+122°16'36.0"W/@38.062,-122.2767	12836	map
13181	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Davis+Point%2C+midchannel%2C+San+Pablo+Bay%2C+California+Current	12837	current
13182	https://www.google.com/maps/place/38°2'59.0"N+122°15'0.0"W/@38.05,-122.25	12837	map
13183	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Daws+Island%2C+SE+of%2C+Broad+River%2C+South+Carolina+Current+%2815d%29	12838	current
13184	https://www.google.com/maps/place/32°18'6.0"N+80°43'29.0"W/@32.3017,-80.725	12838	map
13185	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Daws+Island%2C+south+of%2C+Chechessee+River%2C+South+Carolina+Current+%2815d%29	12839	current
13186	https://www.google.com/maps/place/32°17'12.0"N+80°44'35.0"W/@32.2867,-80.7433	12839	map
13187	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Deception+Island%2C+1%2E3+miles+NW+of%2C+Washington+Current	12840	current
13188	https://www.google.com/maps/place/47°25'0.0"N+122°42'0.0"W/@47.4167,-122.7	12840	map
13189	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Deception+Island%2C+1%2EO+miles+W+of%2C+Washington+Current	12841	current
13190	https://www.google.com/maps/place/47°23'59.0"N+122°42'0.0"W/@47.4,-122.7	12841	map
13191	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Deception+Island%2C+2%2E7+mile+West+of%2C+Washington+Current	12842	current
13192	https://www.google.com/maps/place/48°25'0.0"N+122°43'59.0"W/@48.4167,-122.7333	12842	map
13193	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Deception+Island%2C+2%2E7+miles+west+of%2C+Washington+Current	12843	current
13194	https://www.google.com/maps/place/48°24'45.0"N+122°44'22.0"W/@48.4125,-122.7395	12843	map
13195	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Deception+Pass+%28narrows%29%2C+Washington+Current	12844	current
13196	https://www.google.com/maps/place/48°24'22.0"N+122°38'34.0"W/@48.4062,-122.643	12844	map
13197	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Deception+Pass%2C+Washington+Current	12845	current
13198	https://www.google.com/maps/place/48°23'59.0"N+122°37'59.0"W/@48.4,-122.6333	12845	map
13199	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Deep+Point%2C+Maryland+Current	12846	current
13200	https://www.google.com/maps/place/39°6'22.0"N+76°7'13.0"W/@39.1063,-76.1205	12846	map
13201	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Deepwater+Point%2C+Miles+River%2C+Maryland+Current	12847	current
13203	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Delancey+Point%2C+1+mile+southeast+of%2C+New+York+Current+%2815d%29	12848	current
13204	https://www.google.com/maps/place/40°55'0.0"N+73°42'43.0"W/@40.9167,-73.7122	12848	map
13205	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Delaware+Bay+Entrance%2C+Delaware+Current+%281%29+%28expired+1986%2D12%2D31%29	12849	current
13206	https://www.google.com/maps/place/38°46'54.0"N+75°2'35.0"W/@38.7817,-75.0433	12849	map
13207	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Delaware+Bay+Entrance%2C+Delaware+Current+%282%29	12850	current
13208	https://www.google.com/maps/place/38°46'54.0"N+75°2'35.0"W/@38.7817,-75.0433	12850	map
13209	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dennis+Port%2C+2%2E2+miles+south+of%2C+Massachusetts+Current	12851	current
13210	https://www.google.com/maps/place/41°37'0.0"N+70°6'53.0"W/@41.6167,-70.115	12851	map
13211	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Derbin+Strait%2C+Alaska+Current	12852	current
13212	https://www.google.com/maps/place/54°6'0.0"N+165°13'59.0"W/@54.1,-165.2333	12852	map
13213	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Deveaux+Banks%2C+off+North+Edisto+River+entrance%2C+South+Carolina+Current+%2812d%29	12853	current
13214	https://www.google.com/maps/place/32°32'42.0"N+80°9'24.0"W/@32.545,-80.1567	12853	map
13215	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Discovery+Island%2C+3+miles+SSE+of%2C+Washington+Current	12854	current
13216	https://www.google.com/maps/place/48°22'59.0"N+123°12'0.0"W/@48.3833,-123.2	12854	map
13217	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Discovery+Island%2C+3%2E3+miles+NE+of%2C+Washington+Current	12855	current
13218	https://www.google.com/maps/place/47°16'0.0"N+122°31'59.0"W/@47.2667,-122.5333	12855	map
13219	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Discovery+Island%2C+3%2E3+miles+northeast+of%2C+Washington+Current	12856	current
13220	https://www.google.com/maps/place/48°27'0.0"N+123°9'0.0"W/@48.45,-123.15	12856	map
13221	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Discovery+Island%2C+7%2E6+miles+SSE+of%2C+Washington+Current	12857	current
13222	https://www.google.com/maps/place/48°17'59.0"N+123°10'0.0"W/@48.3,-123.1667	12857	map
13223	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Doboy+Island+%28North+River%29%2C+Georgia+Current+%2812d%29	12858	current
13224	https://www.google.com/maps/place/31°24'11.0"N+81°19'41.0"W/@31.4033,-81.3283	12858	map
13225	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Doboy+Island+%28North+River%29%2C+Georgia+Current+%2820d%29	12859	current
13226	https://www.google.com/maps/place/31°24'11.0"N+81°19'41.0"W/@31.4033,-81.3283	12859	map
13227	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Doctor+Point%2C+0%2E6+mile+NNW+of%2C+North+Carolina+Current+%2816d%29	12860	current
13228	https://www.google.com/maps/place/34°4'43.0"N+77°55'57.0"W/@34.0787,-77.9325	12860	map
13229	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Doctor+Point%2C+0%2E6+mile+NNW+of%2C+North+Carolina+Current+%2826d%29	12861	current
13230	https://www.google.com/maps/place/34°4'43.0"N+77°55'57.0"W/@34.0787,-77.9325	12861	map
13231	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Doctor+Point%2C+0%2E6+mile+NNW+of%2C+North+Carolina+Current+%286d%29	12862	current
13232	https://www.google.com/maps/place/34°4'43.0"N+77°55'57.0"W/@34.0787,-77.9325	12862	map
13233	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dodd+Narrows%2C+British+Columbia+Current	12863	current
13234	https://www.google.com/maps/place/49°8'12.0"N+123°49'0.0"W/@49.1367,-123.8167	12863	map
13235	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dover+Bridge%2C+Maryland+Current	12864	current
13236	https://www.google.com/maps/place/38°45'24.0"N+75°59'55.0"W/@38.7567,-75.9987	12864	map
13237	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dram+Tree+Point%2C+0%2E5+mile+SSE+of%2C+North+Carolina+Current	12865	current
13238	https://www.google.com/maps/place/34°11'31.0"N+77°57'26.0"W/@34.1922,-77.9575	12865	map
13239	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Drayton+Harbor+Entrance%2C+Washington+Current	12866	current
13240	https://www.google.com/maps/place/48°59'26.0"N+122°46'4.0"W/@48.9908,-122.7678	12866	map
13241	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Drum+Island+Reach%2C+off+Drum+I%2E%2C+Buoy+%2745%27%2C+South+Carolina+Current	12867	current
13242	https://www.google.com/maps/place/32°48'58.0"N+79°55'22.0"W/@32.8162,-79.9228	12867	map
13243	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Drum+Island%2C+0%2E2+mile+above%2C+Cooper+River%2C+South+Carolina+Current	12868	current
13244	https://www.google.com/maps/place/32°49'10.0"N+79°55'45.0"W/@32.8197,-79.9292	12868	map
13245	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Drum+Island%2C+0%2E4+mile+SSE+of%2C+South+Carolina+Current	12869	current
13246	https://www.google.com/maps/place/32°47'40.0"N+79°55'14.0"W/@32.7945,-79.9208	12869	map
13247	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Drum+Island%2C+east+of+%28bridge%29%2C+South+Carolina+Current	12870	current
13248	https://www.google.com/maps/place/32°48'16.0"N+79°54'55.0"W/@32.8045,-79.9153	12870	map
13249	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Drum+Point%2C+0%2E3+mile+SSE+of%2C+Maryland+Current	12871	current
13250	https://www.google.com/maps/place/38°18'55.0"N+76°25'9.0"W/@38.3155,-76.4192	12871	map
13251	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Drummond+Point%2C+channel+south+of%2C+Florida+Current+%2817d%29	12872	current
13252	https://www.google.com/maps/place/30°24'33.0"N+81°36'10.0"W/@30.4092,-81.6028	12872	map
13253	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Drummond+Point%2C+channel+south+of%2C+Florida+Current+%2827d%29	12873	current
13254	https://www.google.com/maps/place/30°24'33.0"N+81°36'10.0"W/@30.4092,-81.6028	12873	map
13255	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Drummond+Point%2C+channel+south+of%2C+Florida+Current+%287d%29	12874	current
13256	https://www.google.com/maps/place/30°24'33.0"N+81°36'10.0"W/@30.4092,-81.6028	12874	map
13257	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Duck+Pond+Point%2C+3%2E2+n%2Emi%2E+NW+of%2C+New+York+Current+%2815d%29	12875	current
13258	https://www.google.com/maps/place/41°4'43.0"N+72°33'54.0"W/@41.0788,-72.5652	12875	map
13259	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dumbarton+Bridge%2C+San+Francisco+Bay%2C+California+Current	12876	current
13260	https://www.google.com/maps/place/37°30'35.0"N+122°7'12.0"W/@37.51,-122.12	12876	map
13261	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dumbarton+Hwy+Bridge%2C+South+San+Francisco+Bay%2C+California+Current	12877	current
13262	https://www.google.com/maps/place/37°30'0.0"N+122°6'59.0"W/@37.5,-122.1166	12877	map
13263	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dumbarton+Point+2%2E3+mi+NE%2C+South+San+Francisco+Bay%2C+California+Current	12878	current
13264	https://www.google.com/maps/place/37°27'59.0"N+122°3'59.0"W/@37.466666,-122.0666	12878	map
13265	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dumpling+Rocks%2C+0%2E2+mile+southeast+of%2C+Massachusetts+Current	12879	current
13266	https://www.google.com/maps/place/41°31'59.0"N+70°55'5.0"W/@41.5333,-70.9183	12879	map
13267	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dutch+Island+and+Beaver+Head%2C+between%2C+Rhode+Island+Current	12880	current
13268	https://www.google.com/maps/place/41°29'48.0"N+71°24'11.0"W/@41.4967,-71.4033	12880	map
13269	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dutch+Island%2C+east+of%2C+West+Passage%2C+Rhode+Island+Current+%2815d%29	12881	current
13270	https://www.google.com/maps/place/41°30'11.0"N+71°23'41.0"W/@41.5033,-71.395	12881	map
13271	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dutch+Island%2C+SE+of%2C+Skidaway+River%2C+Georgia+Current+%2810d%29	12882	current
13272	https://www.google.com/maps/place/31°59'30.0"N+81°1'11.0"W/@31.9917,-81.02	12882	map
13273	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dutch+Island%2C+west+of%2C+Rhode+Island+Current+%287d%29	12883	current
13274	https://www.google.com/maps/place/41°30'18.0"N+71°24'35.0"W/@41.505,-71.41	12883	map
13275	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dyer+Island%2C+west+of%2C+Rhode+Island+Current+%287d%29	12884	current
13276	https://www.google.com/maps/place/41°35'12.0"N+71°18'29.0"W/@41.5867,-71.3083	12884	map
13277	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Dyer+Island%2DCarrs+Point+%28between%29%2C+Rhode+Island+Current	12885	current
13278	https://www.google.com/maps/place/41°34'30.0"N+71°17'48.0"W/@41.575,-71.2967	12885	map
13279	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=East+107th+Street%2C+New+York+Current+%2815d%29	12886	current
13280	https://www.google.com/maps/place/40°47'23.0"N+73°56'6.0"W/@40.79,-73.935	12886	map
13281	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=East+Branch%2C+0%2E2+mile+above+entrance%2C+Cooper+River%2C+South+Carolina+Current	12887	current
13282	https://www.google.com/maps/place/33°4'5.0"N+79°55'12.0"W/@33.0683,-79.92	12887	map
13283	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=East+Chop%2C+1+mile+north+of%2C+Massachusetts+Current	12888	current
13284	https://www.google.com/maps/place/41°29'5.0"N+70°33'29.0"W/@41.485,-70.5583	12888	map
13285	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=East+Chop%2DSquash+Meadow%2C+between%2C+Massachusetts+Current	12889	current
13286	https://www.google.com/maps/place/41°27'54.0"N+70°32'12.0"W/@41.465,-70.5367	12889	map
13287	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=east+of%2C+off+36th+Avenue%2C+Roosevelt+Island%2C+New+York+Current	12890	current
13288	https://www.google.com/maps/place/40°46'0.0"N+73°57'0.0"W/@40.7667,-73.95	12890	map
13289	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=east+of%2C+Roosevelt+Island%2C+New+York+Current	12891	current
13290	https://www.google.com/maps/place/40°45'29.0"N+73°57'4.0"W/@40.7582,-73.9513	12891	map
13291	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=East+Pt%2E%2C+Fishers+I%2E%2C+4%2E1+miles+S+of%2C+New+York+Current+%2815d%29	12892	current
13292	https://www.google.com/maps/place/41°13'23.0"N+71°55'29.0"W/@41.2233,-71.925	12892	map
13293	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Eastchester+Bay%2C+near+Big+Tom%2C+New+York+Current+%285d%29	12893	current
13294	https://www.google.com/maps/place/40°50'12.0"N+73°47'43.0"W/@40.8367,-73.7953	12893	map
13295	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Eastern+Plain+Point%2C+1%2E2+miles+N+of%2C+New+York+Current	12894	current
13296	https://www.google.com/maps/place/41°7'7.0"N+72°4'50.0"W/@41.1187,-72.0808	12894	map
13297	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Eastern+Plain+Pt%2E%2C+3%2E9+miles+ENE+of%2C+New+York+Current	12895	current
13298	https://www.google.com/maps/place/41°7'2.0"N+71°59'48.0"W/@41.1175,-71.9967	12895	map
13299	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Eastern+Point%2C+1%2E5+miles+south+of%2C+New+York+Current	12896	current
13300	https://www.google.com/maps/place/41°17'48.0"N+72°4'23.0"W/@41.2967,-72.0733	12896	map
13301	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Eatons+Neck+Point%2C+2%2E5+n%2Emi%2E+NNW+of%2C+New+York+Current+%2815d%29	12897	current
13302	https://www.google.com/maps/place/40°59'43.0"N+73°24'35.0"W/@40.9955,-73.41	12897	map
13303	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Eatons+Neck+Pt%2E%2C+1%2E3+miles+north+of%2C+New+York+Current+%2815d%29	12898	current
13304	https://www.google.com/maps/place/40°58'36.0"N+73°23'46.0"W/@40.9767,-73.3962	12898	map
13305	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Eatons+Neck+Pt%2E%2C+1%2E8+miles+west+of%2C+New+York+Current	12899	current
13306	https://www.google.com/maps/place/40°57'0.0"N+73°25'59.0"W/@40.95,-73.4333	12899	map
13307	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Eatons+Neck+Pt%2E%2C+3+miles+north+of%2C+New+York+Current+%2815d%29	12900	current
13308	https://www.google.com/maps/place/41°0'22.0"N+73°23'48.0"W/@41.0063,-73.3967	12900	map
13309	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Eatons+Neck+Pt%2E%2C+3+miles+north+of%2C+New+York+Current+%2840d%29	12901	current
13310	https://www.google.com/maps/place/41°0'22.0"N+73°23'48.0"W/@41.0063,-73.3967	12901	map
13311	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Eatons+Neck+Pt%2E%2C+3+miles+north+of%2C+New+York+Current+%2870d%29	12902	current
13312	https://www.google.com/maps/place/41°0'22.0"N+73°23'48.0"W/@41.0063,-73.3967	12902	map
13313	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Eddy+Rock+Shoal%2C+west+of%2C+Connecticut+River%2C+Connecticut+Current+%2815d%29	12903	current
13314	https://www.google.com/maps/place/41°26'34.0"N+72°27'46.0"W/@41.4428,-72.463	12903	map
13315	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Edgartown%2C+Inner+Harbor%2C+Massachusetts+Current	12904	current
13316	https://www.google.com/maps/place/41°23'24.0"N+70°30'29.0"W/@41.39,-70.5083	12904	map
13317	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ediz+Hook+Light%2C+1%2E2+miles+N+of%2C+Washington+Current	12905	current
13318	https://www.google.com/maps/place/48°10'0.0"N+123°25'0.0"W/@48.1667,-123.4167	12905	map
13319	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ediz+Hook+Light%2C+1%2E2+miles+north+of%2C+Washington+Current	12906	current
13320	https://www.google.com/maps/place/48°10'0.0"N+123°25'0.0"W/@48.1667,-123.4167	12906	map
13321	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ediz+Hook+Light%2C+5%2E3+miles+ENE+of%2C+Washington+Current	12907	current
13322	https://www.google.com/maps/place/48°10'59.0"N+123°16'59.0"W/@48.1833,-123.2833	12907	map
13323	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Edmonds%2C+2%2E7+miles+WSW+of%2C+Washington+Current	12908	current
13324	https://www.google.com/maps/place/47°48'22.0"N+122°26'40.0"W/@47.8063,-122.4445	12908	map
13325	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Edmonds%2C+2%2E7+wsW+of%2C+Washington+Current	12909	current
13326	https://www.google.com/maps/place/47°57'0.0"N+122°34'59.0"W/@47.95,-122.5833	12909	map
13327	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Edwards+Pt%2E+and+Sandy+Pt%2E%2C+between%2C+Rhode+Island+Current+%284d%29	12910	current
13328	https://www.google.com/maps/place/41°19'54.0"N+71°53'52.0"W/@41.3317,-71.898	12910	map
13329	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Eel+Pt%2E%2C+Nantucket+I%2E+2%2E5+miles+NE+of%2C+Massachusetts+Current	12911	current
13330	https://www.google.com/maps/place/41°19'18.0"N+70°10'12.0"W/@41.3217,-70.17	12911	map
13331	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Egg+Bank%2C+St%2E+Helena+Sound%2C+South+Carolina+Current+%2810d%29	12912	current
13332	https://www.google.com/maps/place/32°26'6.0"N+80°26'35.0"W/@32.435,-80.4433	12912	map
13333	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Egmont+Channel+%283+mi%2E+W+of+Egmont+Key+Lt%2E%29%2C+Florida+Current	12913	current
13334	https://www.google.com/maps/place/27°36'29.0"N+82°49'5.0"W/@27.6083,-82.8183	12913	map
13335	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Egmont+Channel%2C+marker+%2710%27%2C+Florida+Current+%2815d%29	12914	current
13336	https://www.google.com/maps/place/27°36'1.0"N+82°52'3.0"W/@27.6005,-82.8677	12914	map
13337	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Elba+Island+Cut%2C+NE+of%2C+Savannah+River%2C+South+Carolina+Current+%2810d%29	12915	current
13338	https://www.google.com/maps/place/32°4'23.0"N+80°57'54.0"W/@32.0733,-80.965	12915	map
13339	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Elba+Island%2C+NE+of%2C+Savannah+River%2C+Georgia+Current+%2810d%29	12916	current
13340	https://www.google.com/maps/place/32°5'24.0"N+80°59'35.0"W/@32.09,-80.9933	12916	map
13341	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Elba+Island%2C+west+of%2C+Savannah+River%2C+Georgia+Current+%2810d%29	12917	current
13342	https://www.google.com/maps/place/32°5'41.0"N+81°1'11.0"W/@32.095,-81.02	12917	map
13343	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Eld+Inlet+entrance%2C+Washington+Current	12918	current
13344	https://www.google.com/maps/place/47°8'46.0"N+122°55'59.0"W/@47.1463,-122.9333	12918	map
13345	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Eld+Inlet+Entrance%2C+Washington+Current	12919	current
13346	https://www.google.com/maps/place/47°8'59.0"N+122°55'59.0"W/@47.15,-122.9333	12919	map
13347	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Eldred+Rock%2C+Alaska+Current	12920	current
13348	https://www.google.com/maps/place/58°58'0.0"N+135°13'59.0"W/@58.9667,-135.2333	12920	map
13349	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Eldred+Rock%2C+Alaska+Current+%2870d%29	12921	current
13350	https://www.google.com/maps/place/59°6'16.0"N+135°22'21.0"W/@59.1047,-135.3725	12921	map
13351	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Elliott+Cut%2C+west+end%2C+South+Carolina+Current	12922	current
13352	https://www.google.com/maps/place/32°46'0.0"N+80°0'0.0"W/@32.7667,-80.0	12922	map
13353	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Elm+Point%2C+0%2E2+mile+west+of%2C+New+York+Current+%2815d%29	12923	current
13354	https://www.google.com/maps/place/40°48'55.0"N+73°46'1.0"W/@40.8153,-73.767	12923	map
13355	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Entrance+Point%2C+3+miles+west+of%2C+Alaska+Current	12924	current
13356	https://www.google.com/maps/place/56°0'0.0"N+160°39'0.0"W/@56.0,-160.65	12924	map
13357	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Entrance+Point%2C+Alaska+Current	12925	current
13358	https://www.google.com/maps/place/55°58'59.0"N+160°34'59.0"W/@55.9833,-160.5833	12925	map
13359	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Entrance+to+Mississippi+Sound%2C+Pass+Aux+Herons%2C+Alabama+Current	12926	current
13360	https://www.google.com/maps/place/30°17'17.0"N+88°7'47.0"W/@30.2883,-88.13	12926	map
13361	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Entrance%2C+0%2E2+mile+south+of+north+jetty%2C+Washington+Current	12927	current
13362	https://www.google.com/maps/place/46°55'34.0"N+124°9'40.0"W/@46.9263,-124.1613	12927	map
13363	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Entrance%2C+0%2E6+mile+WNW+of+Westport%2C+Washington+Current	12928	current
13364	https://www.google.com/maps/place/46°54'52.0"N+124°7'30.0"W/@46.9147,-124.125	12928	map
13365	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Entrance%2C+1%2E1+miles+NW+of+Westport%2C+Washington+Current	12929	current
13366	https://www.google.com/maps/place/46°55'0.0"N+124°7'59.0"W/@46.9167,-124.1333	12929	map
13367	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Entrance%2C+Georgia+Current	12930	current
13368	https://www.google.com/maps/place/30°59'12.0"N+81°24'18.0"W/@30.9867,-81.405	12930	map
13369	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Entrance%2C+Georgia+Current+%2814d%29	12931	current
13370	https://www.google.com/maps/place/31°20'30.0"N+81°15'47.0"W/@31.3417,-81.2633	12931	map
13371	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Entrance%2C+Georgia+Current+%2819d%29	12932	current
13372	https://www.google.com/maps/place/31°32'23.0"N+81°10'48.0"W/@31.54,-81.18	12932	map
13373	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Entrance%2C+Georgia+Current+%2822d%29	12933	current
13374	https://www.google.com/maps/place/31°20'30.0"N+81°15'47.0"W/@31.3417,-81.2633	12933	map
13375	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Entrance%2C+Georgia+Current+%2829d%29	12934	current
13376	https://www.google.com/maps/place/31°32'23.0"N+81°10'48.0"W/@31.54,-81.18	12934	map
13377	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Entrance%2C+north+of+channel%2C+Georgia+Current+%2813d%29	12935	current
13378	https://www.google.com/maps/place/31°8'0.0"N+81°24'14.0"W/@31.1335,-81.404	12935	map
13379	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Entrance%2C+off+Beach+Hammock%2C+Georgia+Current	12936	current
13380	https://www.google.com/maps/place/31°56'30.0"N+80°55'54.0"W/@31.9417,-80.9317	12936	map
13381	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Entrance%2C+off+Wassaw+Island%2C+Georgia+Current	12937	current
13382	https://www.google.com/maps/place/31°55'0.0"N+80°56'48.0"W/@31.9167,-80.9467	12937	map
13383	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Entrance%2C+Point+Chehalis+Range%2C+Washington+Current	12938	current
13384	https://www.google.com/maps/place/46°54'29.0"N+124°9'19.0"W/@46.9083,-124.1555	12938	map
13385	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Entrance%2C+south+of+channel%2C+Georgia+Current+%2811d%29	12939	current
13386	https://www.google.com/maps/place/31°7'36.0"N+81°24'11.0"W/@31.1267,-81.4033	12939	map
13387	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Entrance%2C+south+of+channel%2C+Georgia+Current+%2829d%29	12940	current
13388	https://www.google.com/maps/place/31°7'36.0"N+81°24'11.0"W/@31.1267,-81.4033	12940	map
13389	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Etolin+Point%2C+8%2E5+miles+west+of%2C+Alaska+Current	12941	current
13390	https://www.google.com/maps/place/58°37'59.0"N+158°34'59.0"W/@58.6333,-158.5833	12941	map
13391	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Eustasia+Island%2C+0%2E6+mile+ESE+of%2C+Connecticut+River%2C+Connecticut+Current	12942	current
13392	https://www.google.com/maps/place/41°23'17.0"N+72°24'13.0"W/@41.3883,-72.4038	12942	map
13393	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Execution+Rocks%2C+0%2E4+mile+southwest+of%2C+New+York+Current+%2815d%29	12943	current
13394	https://www.google.com/maps/place/40°52'23.0"N+73°43'59.0"W/@40.8733,-73.7333	12943	map
13395	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fajardo+Harbor+%28channel%29%2C+Puerto+Rico+Current	12944	current
13396	https://www.google.com/maps/place/18°19'59.0"N+65°37'0.0"W/@18.3333,-65.6167	12944	map
13397	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fauntleroy+Point+Light%2C+0%2E8+mile+ESE+of%2C+Washington+Current	12945	current
13398	https://www.google.com/maps/place/48°31'12.0"N+122°46'10.0"W/@48.52,-122.7697	12945	map
13399	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fauntleroy+Point+Light%2C+0%2E89+mile+ESE+of%2C+Washington+Current	12946	current
13400	https://www.google.com/maps/place/48°31'0.0"N+122°46'0.0"W/@48.5167,-122.7667	12946	map
13401	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fenimore+Rock%2C+1%2E2+miles+southwest+of%2C+Alaska+Current	12947	current
13402	https://www.google.com/maps/place/51°58'0.0"N+175°34'0.0"W/@51.9667,-175.5667	12947	map
13403	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fenwick+Island+Cut%2C+South+Edisto+River%2C+South+Carolina+Current+%2815d%29	12948	current
13404	https://www.google.com/maps/place/32°32'5.0"N+80°24'47.0"W/@32.535,-80.4133	12948	map
13405	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fig+Island%2C+north+of%2C+Back+River%2C+Georgia+Current	12949	current
13406	https://www.google.com/maps/place/32°5'6.0"N+81°2'59.0"W/@32.085,-81.05	12949	map
13407	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Filbin+Creek+Reach%2C+0%2E2+mile+east+of%2C+Cooper+River%2C+South+Carolina+Current	12950	current
13408	https://www.google.com/maps/place/32°53'16.0"N+79°57'37.0"W/@32.888,-79.9605	12950	map
13409	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Filbin+Creek+Reach%2C+Buoy+%2758%27%2C+Cooper+River%2C+South+Carolina+Current	12951	current
13410	https://www.google.com/maps/place/32°53'46.0"N+79°57'40.0"W/@32.8963,-79.9612	12951	map
13411	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Filbin+Creek+Reach%2C+Cooper+River%2C+South+Carolina+Current	12952	current
13412	https://www.google.com/maps/place/32°53'19.0"N+79°57'55.0"W/@32.8887,-79.9653	12952	map
13413	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=First+Narrows%2C+British+Columbia+Current	12953	current
13414	https://www.google.com/maps/place/49°19'0.0"N+123°7'59.0"W/@49.3167,-123.1333	12953	map
13415	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fleming+Point+1%2E7+mi+SW%2C+San+Francisco+Bay%2C+California+Current	12954	current
13416	https://www.google.com/maps/place/37°51'0.0"N+122°20'59.0"W/@37.85,-122.35	12954	map
13417	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Florida+Passage+%28south%29%2C+Georgia+Current+%286d%29	12955	current
13418	https://www.google.com/maps/place/31°49'46.0"N+81°9'28.0"W/@31.8297,-81.1578	12955	map
13419	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Florida+Passage%2C+N+of%2C+Ogeechee+River%2C+Georgia+Current+%2810d%29	12956	current
13420	https://www.google.com/maps/place/31°51'24.0"N+81°8'35.0"W/@31.8567,-81.1433	12956	map
13421	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Folly+I%2E+Channel%2C+N+of+Ft%2E+Johnson%2C+South+Carolina+Current	12957	current
13422	https://www.google.com/maps/place/32°46'10.0"N+79°54'4.0"W/@32.7697,-79.9012	12957	map
13423	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Folly+Reach%2C+Buoy+%275%27%2C+South+Carolina+Current	12958	current
13424	https://www.google.com/maps/place/32°46'34.0"N+79°53'57.0"W/@32.7763,-79.8992	12958	map
13425	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Folly+River+and+Cardigan+River%2C+between%2C+Georgia+Current+%2810d%29	12959	current
13426	https://www.google.com/maps/place/31°26'30.0"N+81°20'12.0"W/@31.4417,-81.3367	12959	map
13427	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fort+Macon%2C+0%2E2+mile+NE+of%2C+Beaufort+Inlet%2C+North+Carolina+Current+%2810d%29	12960	current
13428	https://www.google.com/maps/place/34°41'58.0"N+76°40'31.0"W/@34.6997,-76.6753	12960	map
13429	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fort+Macon%2C+0%2E2+mile+NE+of%2C+Beaufort+Inlet%2C+North+Carolina+Current+%2820d%29	12961	current
13430	https://www.google.com/maps/place/34°41'58.0"N+76°40'31.0"W/@34.6997,-76.6753	12961	map
13431	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fort+Macon%2C+0%2E6+mile+SE+of%2C+Beaufort+Inlet%2C+North+Carolina+Current	12962	current
13432	https://www.google.com/maps/place/34°41'8.0"N+76°40'5.0"W/@34.6858,-76.6683	12962	map
13433	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fort+Point%2C+0%2E3+nmi%2E+west+of%2C+California+Current+%2875d%29	12963	current
13434	https://www.google.com/maps/place/37°48'33.0"N+122°28'58.0"W/@37.8092,-122.4828	12963	map
13435	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fort+Pulaski%2C+1%2E8+miles+above%2C+Georgia+Current	12964	current
13436	https://www.google.com/maps/place/32°2'42.0"N+80°55'54.0"W/@32.045,-80.9317	12964	map
13437	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fort+Pulaski%2C+4%2E8+miles+above%2C+Georgia+Current	12965	current
13438	https://www.google.com/maps/place/32°4'30.0"N+80°58'36.0"W/@32.075,-80.9767	12965	map
13439	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fort+Pulaski%2C+Georgia+Current	12966	current
13440	https://www.google.com/maps/place/32°2'12.0"N+80°54'6.0"W/@32.0367,-80.9017	12966	map
13441	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fort+Sumter+Range%2C+Buoy+%2714%27%2C+South+Carolina+Current	12967	current
13442	https://www.google.com/maps/place/32°43'27.0"N+79°48'36.0"W/@32.7243,-79.81	12967	map
13443	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fort+Sumter+Range%2C+Buoy+%272%27%2C+South+Carolina+Current	12968	current
13444	https://www.google.com/maps/place/32°40'58.0"N+79°43'33.0"W/@32.683,-79.726	12968	map
13445	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fort+Sumter+Range%2C+Buoy+%2720%27%2C+South+Carolina+Current	12969	current
13446	https://www.google.com/maps/place/32°44'25.0"N+79°50'40.0"W/@32.7405,-79.8445	12969	map
13447	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fort+Sumter+Range%2C+Buoy+%274%27%2C+South+Carolina+Current	12970	current
13448	https://www.google.com/maps/place/32°41'51.0"N+79°45'20.0"W/@32.6977,-79.7557	12970	map
13449	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fort+Sumter+Range%2C+Buoy+%278%27%2C+South+Carolina+Current	12971	current
13450	https://www.google.com/maps/place/32°42'54.0"N+79°47'32.0"W/@32.715,-79.7923	12971	map
13451	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Foulweather+Bluff%2C+Washington+Current	12972	current
13452	https://www.google.com/maps/place/47°55'54.0"N+122°38'19.0"W/@47.9317,-122.6388	12972	map
13453	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Foulweather+Bluff%2C+Washington+Current+%282%29	12973	current
13454	https://www.google.com/maps/place/47°57'15.0"N+122°34'45.0"W/@47.9542,-122.5792	12973	map
13455	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Four+Mile+Point%2C+St%2E+Marks+River%2C+Florida+Current	12974	current
13456	https://www.google.com/maps/place/30°6'42.0"N+84°12'11.0"W/@30.1117,-84.2033	12974	map
13457	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=four+miles+north+of%2C+Block+Island%2C+Rhode+Island+Current	12975	current
13458	https://www.google.com/maps/place/41°17'59.0"N+71°31'59.0"W/@41.3,-71.5333	12975	map
13459	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fowler+Island%2C+0%2E1+mile+NNW+of%2C+Housatonic+River%2C+Connecticut+Current+%285d%29	12976	current
13460	https://www.google.com/maps/place/41°14'24.0"N+73°6'13.0"W/@41.24,-73.1038	12976	map
13461	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fox+Point%2C+south+of%2C+Providence+River%2C+Rhode+Island+Current+%2810d%29	12977	current
13462	https://www.google.com/maps/place/41°48'47.0"N+71°24'0.0"W/@41.8133,-71.4	12977	map
13463	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Frazier+Point%2C+south+of%2C+South+Carolina+Current	12978	current
13464	https://www.google.com/maps/place/33°17'42.0"N+79°16'22.0"W/@33.295,-79.2728	12978	map
13465	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Frazier+Point%2C+west+of%2C+South+Carolina+Current	12979	current
13466	https://www.google.com/maps/place/33°18'34.0"N+79°17'12.0"W/@33.3097,-79.2867	12979	map
13467	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Freestone+Point%2C+2%2E3+miles+east+of%2C+Maryland+Current	12980	current
13468	https://www.google.com/maps/place/38°35'46.0"N+77°11'52.0"W/@38.5963,-77.198	12980	map
13469	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Fripps+Inlet%2C+Fripps+Island%2C+South+Carolina+Current+%2815d%29	12981	current
13470	https://www.google.com/maps/place/32°20'24.0"N+80°27'54.0"W/@32.34,-80.465	12981	map
13471	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Front+River%2C+Georgia+Current+%2813d%29	12982	current
13472	https://www.google.com/maps/place/31°30'47.0"N+81°17'53.0"W/@31.5133,-81.2983	12982	map
13473	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Frost%2DWillow+Island%2C+between%2C+Washington+Current	12983	current
13474	https://www.google.com/maps/place/48°32'21.0"N+122°49'50.0"W/@48.5392,-122.8308	12983	map
13475	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ft%2E+Sumter%2C+0%2E6+n%2Emi%2E+NW+of%2C+South+Carolina+Current	12984	current
13476	https://www.google.com/maps/place/32°45'40.0"N+79°52'1.0"W/@32.7612,-79.8672	12984	map
13477	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ft%2E+Taylor%2C+0%2E6+mile+N+of%2C+Key+West%2C+Florida+Current	12985	current
13478	https://www.google.com/maps/place/24°33'29.0"N+81°48'36.0"W/@24.5583,-81.81	12985	map
13479	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=G+St%2E+Pier+%28San+Diego%29%2C+0%2E22+nmi%2E+SW+of%2C+California+Current+%2814d%29	12986	current
13480	https://www.google.com/maps/place/32°42'29.0"N+117°10'38.0"W/@32.7083,-117.1775	12986	map
13481	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=G+St%2E+Pier+%28San+Diego%29%2C+0%2E22+nmi%2E+SW+of%2C+California+Current+%2837d%29	12987	current
13482	https://www.google.com/maps/place/32°42'29.0"N+117°10'38.0"W/@32.7083,-117.1775	12987	map
13483	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gabriola+Passage%2C+British+Columbia+Current	12988	current
13484	https://www.google.com/maps/place/49°7'41.0"N+123°42'0.0"W/@49.1283,-123.7	12988	map
13485	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Galveston+Bay+Entrance%2C+Texas+Current	12989	current
13486	https://www.google.com/maps/place/29°20'48.0"N+94°42'17.0"W/@29.3467,-94.705	12989	map
13487	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Galveston+Channel%2C+west+end%2C+Texas+Current	12990	current
13488	https://www.google.com/maps/place/29°18'35.0"N+94°49'11.0"W/@29.31,-94.82	12990	map
13489	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gandy+Bridge%2C+east+channel%2C+Florida+Current+%286d%29	12991	current
13490	https://www.google.com/maps/place/27°52'59.0"N+82°33'8.0"W/@27.8832,-82.5523	12991	map
13491	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gandy+Bridge%2C+west+channel%2C+Florida+Current	12992	current
13492	https://www.google.com/maps/place/27°52'45.0"N+82°34'49.0"W/@27.8792,-82.5805	12992	map
13493	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gardiners+Island%2C+3+miles+northeast+of%2C+Connecticut+Current+%2810d%29	12993	current
13494	https://www.google.com/maps/place/41°7'54.0"N+72°1'59.0"W/@41.1317,-72.0333	12993	map
13495	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gardiners+Point+%26+Plum+Island%2C+between%2C+New+York+Current+%2815d%29	12994	current
13496	https://www.google.com/maps/place/41°9'19.0"N+72°9'31.0"W/@41.1555,-72.1587	12994	map
13497	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gardiners+Pt%2E+Ruins%2C+1%2E1+miles+N+of%2C+New+York+Current	12995	current
13498	https://www.google.com/maps/place/41°9'29.0"N+72°8'49.0"W/@41.1583,-72.1472	12995	map
13499	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gasparilla+Pass%2C+Florida+Current	12996	current
13500	https://www.google.com/maps/place/26°48'44.0"N+82°16'51.0"W/@26.8123,-82.281	12996	map
13501	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gay+Head%2C+1%2E5+miles+northwest+of%2C+Massachusetts+Current	12997	current
13502	https://www.google.com/maps/place/41°21'47.0"N+70°51'47.0"W/@41.3633,-70.8633	12997	map
13503	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gay+Head%2C+3+miles+north+of%2C+Massachusetts+Current	12998	current
13504	https://www.google.com/maps/place/41°24'6.0"N+70°51'11.0"W/@41.4017,-70.8533	12998	map
13505	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gay+Head%2C+3+miles+northeast+of%2C+Massachusetts+Current	12999	current
13506	https://www.google.com/maps/place/41°23'5.0"N+70°46'59.0"W/@41.385,-70.7833	12999	map
13507	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=George+Washington+Bridge+%28Hudson+River%29%2C+New+York+Current	13000	current
13508	https://www.google.com/maps/place/40°51'0.0"N+73°57'0.0"W/@40.85,-73.95	13000	map
13509	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Georgetown%2C+Maryland+Current	13001	current
13510	https://www.google.com/maps/place/39°21'40.0"N+75°53'10.0"W/@39.3612,-75.8862	13001	map
13511	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Georgetown%2C+Sampit+River%2C+South+Carolina+Current	13002	current
13512	https://www.google.com/maps/place/33°21'33.0"N+79°17'14.0"W/@33.3592,-79.2875	13002	map
13513	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gibson+Point%2C+0%2E8+mile+east+of%2C+Washington+Current	13003	current
13514	https://www.google.com/maps/place/47°13'4.0"N+122°35'22.0"W/@47.218,-122.5895	13003	map
13515	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gibson+Point%2C+0%2E8+miles+E+of%2C+Washington+Current	13004	current
13516	https://www.google.com/maps/place/47°13'0.0"N+122°34'59.0"W/@47.2167,-122.5833	13004	map
13517	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gig+Harbor+Entrance%2C+Washington+Current	13005	current
13518	https://www.google.com/maps/place/47°19'59.0"N+122°34'0.0"W/@47.3333,-122.5667	13005	map
13519	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gig+Harbor+entrance%2C+Washington+Current	13006	current
13520	https://www.google.com/maps/place/47°19'32.0"N+122°34'28.0"W/@47.3258,-122.5747	13006	map
13521	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gillard+Pass%2C+British+Columbia+Current	13007	current
13522	https://www.google.com/maps/place/50°23'35.0"N+125°9'24.0"W/@50.3933,-125.1567	13007	map
13523	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Goff+Point%2C+0%2E4+mile+northwest+of%2C+New+York+Current	13008	current
13524	https://www.google.com/maps/place/41°1'29.0"N+72°3'45.0"W/@41.0248,-72.0625	13008	map
13525	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Golden+Gate+Bridge+%2E8+mi+E+%2E%2C+San+Francisco+Bay%2C+California+Current	13009	current
13526	https://www.google.com/maps/place/37°48'59.0"N+122°27'0.0"W/@37.816666,-122.45	13009	map
13527	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Golden+Gate+Point%2C+off%2C+Florida+Current	13010	current
13528	https://www.google.com/maps/place/27°19'41.0"N+82°33'24.0"W/@27.3283,-82.5567	13010	map
13529	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Goodnews+Bay+entrance%2C+Alaska+Current	13011	current
13530	https://www.google.com/maps/place/59°4'0.0"N+161°46'59.0"W/@59.0667,-161.7833	13011	map
13531	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gorge%2DTillicum+Bridge%2C+British+Columbia+Current	13012	current
13532	https://www.google.com/maps/place/48°27'0.0"N+123°24'0.0"W/@48.45,-123.4	13012	map
13533	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Goshen+Point%2C+1%2E9+miles+SSE+of%2C+New+York+Current+%2815d%29	13013	current
13534	https://www.google.com/maps/place/41°16'0.0"N+72°6'18.0"W/@41.2667,-72.105	13013	map
13535	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Goshen+Point%2C+SE+of%2C+Wadmalaw+River%2C+South+Carolina+Current+%2812d%29	13014	current
13536	https://www.google.com/maps/place/32°42'36.0"N+80°10'18.0"W/@32.71,-80.1717	13014	map
13537	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Goshen+Point%2C+south+of%2C+Wadmalaw+River%2C+South+Carolina+Current+%2812d%29	13015	current
13538	https://www.google.com/maps/place/32°42'47.0"N+80°11'12.0"W/@32.7133,-80.1867	13015	map
13539	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gould+Island%2C+southeast+of%2C+Rhode+Island+Current+%287d%29	13016	current
13540	https://www.google.com/maps/place/41°31'29.0"N+71°20'12.0"W/@41.525,-71.3367	13016	map
13541	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gould+Island%2C+west+of%2C+Rhode+Island+Current+%2815d%29	13017	current
13542	https://www.google.com/maps/place/41°31'54.0"N+71°21'29.0"W/@41.5317,-71.3583	13017	map
13543	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Grand+Manan+Channel+%28Bay+of+Fundy+Entrance%29%2C+New+Brunswick+Current	13018	current
13544	https://www.google.com/maps/place/44°45'11.0"N+66°55'54.0"W/@44.7533,-66.9317	13018	map
13545	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Grays+Harbor+Entrance%2C+Washington+Current	13019	current
13546	https://www.google.com/maps/place/46°55'0.0"N+124°7'30.0"W/@46.9167,-124.125	13019	map
13547	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Great+Gull+Island%2C+0%2E7+mile+WSW+of%2C+New+York+Current	13020	current
13548	https://www.google.com/maps/place/41°11'40.0"N+72°8'1.0"W/@41.1945,-72.1337	13020	map
13549	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Great+Point%2C+0%2E5+mile+west+of%2C+Massachusetts+Current	13021	current
13550	https://www.google.com/maps/place/41°23'35.0"N+70°3'42.0"W/@41.3933,-70.0617	13021	map
13551	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Great+Point%2C+3+miles+west+of%2C+Massachusetts+Current	13022	current
13552	https://www.google.com/maps/place/41°23'24.0"N+70°6'47.0"W/@41.39,-70.1133	13022	map
13553	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Great+Salt+Pond+ent%2E%2C+1+mile+NW+of%2C+Block+Island%2C+Rhode+Island+Current+%287d%29	13023	current
13554	https://www.google.com/maps/place/41°12'0.0"N+71°35'59.0"W/@41.2,-71.6	13023	map
13555	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Great+Salt+Pond+entrance%2C+Block+Island%2C+Rhode+Island+Current	13024	current
13556	https://www.google.com/maps/place/41°11'58.0"N+71°35'30.0"W/@41.1995,-71.5917	13024	map
13557	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Green+Hill+Point%2C+1%2E1+miles+south+of%2C+Rhode+Island+Current	13025	current
13558	https://www.google.com/maps/place/41°20'53.0"N+71°35'46.0"W/@41.3483,-71.5962	13025	map
13559	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Green+Point%2C+0%2E8+mile+northwest+of%2C+Washington+Current	13026	current
13560	https://www.google.com/maps/place/48°30'16.0"N+122°42'22.0"W/@48.5047,-122.7062	13026	map
13561	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Green+Point%2C+0%2E8+mile+NW+of%2C+Washington+Current	13027	current
13562	https://www.google.com/maps/place/48°30'0.0"N+122°42'0.0"W/@48.5,-122.7	13027	map
13563	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Greenbury+Point%2C+1%2E8+miles+east+of%2C+Maryland+Current+%288d%29	13028	current
13564	https://www.google.com/maps/place/38°58'23.0"N+76°25'0.0"W/@38.9733,-76.4167	13028	map
13565	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Greenwich+Point%2C+1%2E1+miles+south+of%2C+Connecticut+Current+%2815d%29	13029	current
13566	https://www.google.com/maps/place/40°59'1.0"N+73°34'1.0"W/@40.9837,-73.567	13029	map
13567	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Greenwich+Point%2C+1%2E1+miles+south+of%2C+Connecticut+Current+%2855d%29	13030	current
13568	https://www.google.com/maps/place/40°59'1.0"N+73°34'1.0"W/@40.9837,-73.567	13030	map
13569	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Greenwich+Point%2C+2%2E5+miles+south+of%2C+New+York+Current+%2815d%29	13031	current
13570	https://www.google.com/maps/place/40°57'36.0"N+73°33'40.0"W/@40.96,-73.5613	13031	map
13571	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Greenwich+Point%2C+2%2E5+miles+south+of%2C+New+York+Current+%2855d%29	13032	current
13572	https://www.google.com/maps/place/40°57'36.0"N+73°33'40.0"W/@40.96,-73.5613	13032	map
13573	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Grove+Point%2C+0%2E7+n%2Emi%2ENW+of%2C+Maryland+Current+%2814d%29	13033	current
13574	https://www.google.com/maps/place/39°23'46.0"N+76°3'1.0"W/@39.3963,-76.0503	13033	map
13575	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Grove+Point%2C+Maryland+Current	13034	current
13576	https://www.google.com/maps/place/39°22'41.0"N+76°2'35.0"W/@39.3783,-76.0433	13034	map
13577	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Guemes+Channel%2C+West+entrance+of%2C+Washington+Current	13035	current
13578	https://www.google.com/maps/place/48°31'0.0"N+122°39'0.0"W/@48.5167,-122.65	13035	map
13579	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Guemes+Channel%2C+west+entrance%2C+Washington+Current	13036	current
13580	https://www.google.com/maps/place/48°31'16.0"N+122°39'7.0"W/@48.5212,-122.6522	13036	map
13581	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gull+I%2E+and+Nashawena+I%2E%2C+between%2C+Massachusetts+Current	13037	current
13582	https://www.google.com/maps/place/41°26'12.0"N+70°54'11.0"W/@41.4367,-70.9033	13037	map
13583	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Gunpowder+River+entrance%2C+Maryland+Current	13038	current
13584	https://www.google.com/maps/place/39°18'42.0"N+76°18'29.0"W/@39.3117,-76.3083	13038	map
13585	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hagan+Island%2C+1+n%2Emi%2E+below%2C+Cooper+River%2C+South+Carolina+Current	13039	current
13586	https://www.google.com/maps/place/33°1'59.0"N+79°54'47.0"W/@33.0333,-79.9133	13039	map
13587	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hague+Channel%2C+east+of+Doe+Point%2C+Alaska+Current	13040	current
13588	https://www.google.com/maps/place/55°53'59.0"N+160°46'0.0"W/@55.9,-160.7667	13040	map
13589	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Haig+Point+Light%2C+NW+of%2C+Cooper+River%2C+South+Carolina+Current+%2810d%29	13041	current
13590	https://www.google.com/maps/place/32°8'53.0"N+80°50'30.0"W/@32.1483,-80.8417	13041	map
13591	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hail+Point%2C+0%2E7+n%2Emi%2Eeast+of%2C+Maryland+Current+%2816d%29	13042	current
13592	https://www.google.com/maps/place/39°0'37.0"N+76°10'57.0"W/@39.0105,-76.1825	13042	map
13593	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hains+Point%2C+D%2EC%2E+Current	13043	current
13594	https://www.google.com/maps/place/38°51'4.0"N+77°1'19.0"W/@38.8513,-77.022	13043	map
13595	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hale+Passage%2C+0%2E5+mile+SE+of+Lummi+Point%2C+Washington+Current	13044	current
13596	https://www.google.com/maps/place/48°43'52.0"N+122°40'40.0"W/@48.7313,-122.6778	13044	map
13597	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hale+Passage%2C+0%2E5+miles+SE+of+Lummi+Pt%2C+Washington+Current	13045	current
13598	https://www.google.com/maps/place/47°43'59.0"N+122°40'59.0"W/@47.7333,-122.6833	13045	map
13599	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hale+Passage%2C+West+end%2C+Washington+Current	13046	current
13600	https://www.google.com/maps/place/47°16'59.0"N+122°39'0.0"W/@47.2833,-122.65	13046	map
13601	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hale+Passage%2C+west+end%2C+Washington+Current	13047	current
13602	https://www.google.com/maps/place/47°16'40.0"N+122°39'43.0"W/@47.2778,-122.6622	13047	map
13603	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Halfmoon+Shoal%2C+1%2E9+miles+northeast+of%2C+Massachusetts+Current	13048	current
13604	https://www.google.com/maps/place/41°29'3.0"N+70°11'32.0"W/@41.4842,-70.1925	13048	map
13605	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Halfmoon+Shoal%2C+3%2E5+miles+east+of%2C+Massachusetts+Current	13049	current
13606	https://www.google.com/maps/place/41°28'5.0"N+70°9'11.0"W/@41.4683,-70.1533	13049	map
13607	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hallowing+Point%2C+Maryland+Current	13050	current
13608	https://www.google.com/maps/place/38°38'42.0"N+77°7'38.0"W/@38.645,-77.1275	13050	map
13609	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hammersley+Inlet%2C+0%2E8+mile+east+of+Libby+Point%2C+Washington+Current	13051	current
13610	https://www.google.com/maps/place/47°12'9.0"N+122°58'28.0"W/@47.2025,-122.9745	13051	map
13611	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hammersley+Inlet%2C+0%2E8+miles+E+of+Libby+Pt%2C+Washington+Current	13052	current
13612	https://www.google.com/maps/place/47°12'0.0"N+122°58'0.0"W/@47.2,-122.9667	13052	map
13613	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hammersley+Inlet%2C+W+of+Skookum+Pt%2C+Washington+Current	13053	current
13614	https://www.google.com/maps/place/47°12'0.0"N+123°1'59.0"W/@47.2,-123.0333	13053	map
13615	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hammersley+Inlet%2C+west+of+Skookum+Point%2C+Washington+Current	13054	current
13616	https://www.google.com/maps/place/47°12'25.0"N+123°2'22.0"W/@47.207,-123.0395	13054	map
13617	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hammonasset+Point%2C+1%2E2+miles+SW+of%2C+Connecticut+Current+%2815d%29	13055	current
13618	https://www.google.com/maps/place/41°14'13.0"N+72°34'0.0"W/@41.237,-72.5667	13055	map
13619	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hammonasset+Point%2C+5+miles+south+of%2C+Connecticut+Current+%2815d%29	13056	current
13620	https://www.google.com/maps/place/41°9'47.0"N+72°34'10.0"W/@41.1633,-72.5695	13056	map
13621	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hammond%2C+northeast+of+ship+channel%2C+Oregon+Current+%2815d%29	13057	current
13622	https://www.google.com/maps/place/46°12'40.0"N+123°56'4.0"W/@46.2112,-123.9345	13057	map
13623	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Handkerchief+Lighted+Whistle+Buoy+%27H%27%2C+Massachusetts+Current	13058	current
13624	https://www.google.com/maps/place/41°29'17.0"N+70°4'0.0"W/@41.4883,-70.0667	13058	map
13625	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Harbor+ent%2E%2C+south+of+Plum+Point%2C+Oyster+Bay%2C+New+York+Current	13059	current
13626	https://www.google.com/maps/place/40°53'59.0"N+73°31'0.0"W/@40.9,-73.5167	13059	map
13627	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Harbor+Island+%28east+end%29%2C+SSW+of%2C+California+Current+%2815d%29	13060	current
13628	https://www.google.com/maps/place/32°43'9.0"N+117°11'30.0"W/@32.7192,-117.1917	13060	map
13629	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Harbor+Key%2C+1%2E3+miles+west+of%2C+Florida+Current	13061	current
13630	https://www.google.com/maps/place/27°36'40.0"N+82°35'40.0"W/@27.6112,-82.5945	13061	map
13631	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Harbor+of+Refuge%2C+south+entrance%2C+Point+Judith%2C+Rhode+Island+Current	13062	current
13632	https://www.google.com/maps/place/41°21'28.0"N+71°29'44.0"W/@41.358,-71.4958	13062	map
13633	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Harbor+Point%2C+Alaska+Current	13063	current
13634	https://www.google.com/maps/place/55°55'0.0"N+160°35'59.0"W/@55.9167,-160.6	13063	map
13635	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Harbor%2C+west+of+Soper+Point%2C+Oyster+Bay%2C+New+York+Current	13064	current
13636	https://www.google.com/maps/place/40°52'59.0"N+73°31'59.0"W/@40.8833,-73.5333	13064	map
13637	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Harney+Channel%2C+Washington+Current	13065	current
13638	https://www.google.com/maps/place/48°35'26.0"N+122°55'13.0"W/@48.5908,-122.9205	13065	map
13639	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hart+Island+and+City+Island%2C+between%2C+New+York+Current+%2815d%29	13066	current
13640	https://www.google.com/maps/place/40°51'22.0"N+73°46'43.0"W/@40.8562,-73.7788	13066	map
13641	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hart+Island%2C+0%2E2+mile+north+of%2C+New+York+Current+%2815d%29	13067	current
13642	https://www.google.com/maps/place/40°51'49.0"N+73°46'16.0"W/@40.8637,-73.7712	13067	map
13643	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hart+Island%2C+0%2E3+n%2Emi%2E+SSE+of%2C+New+York+Current+%2815d%29	13068	current
13644	https://www.google.com/maps/place/40°50'25.0"N+73°45'56.0"W/@40.8405,-73.7657	13068	map
13645	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hart+Island%2C+southeast+of%2C+New+York+Current+%2815d%29	13069	current
13646	https://www.google.com/maps/place/40°50'37.0"N+73°45'46.0"W/@40.8437,-73.7628	13069	map
13647	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hartford+Jetty%2C+Connecticut+River%2C+Connecticut+Current+%289d%29+%2D+IGNORE+HEIGHTS	13070	current
13648	https://www.google.com/maps/place/41°45'4.0"N+72°39'1.0"W/@41.7512,-72.6503	13070	map
13649	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hatchett+Point%2C+1%2E1+miles+WSW+of%2C+Connecticut+Current	13071	current
13650	https://www.google.com/maps/place/41°16'21.0"N+72°16'55.0"W/@41.2725,-72.282	13071	map
13651	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hatchett+Point%2C+1%2E6+n%2Emi%2E+S+of%2C+Connecticut+Current+%2815d%29	13072	current
13652	https://www.google.com/maps/place/41°15'24.0"N+72°15'22.0"W/@41.2567,-72.2562	13072	map
13653	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hatteras+Inlet%2C+North+Carolina+Current	13073	current
13654	https://www.google.com/maps/place/35°12'0.0"N+75°45'0.0"W/@35.2,-75.75	13073	map
13655	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Haverstraw+%28Hudson+River%29%2C+New+York+Current	13074	current
13656	https://www.google.com/maps/place/41°12'0.0"N+73°57'0.0"W/@41.2,-73.95	13074	map
13657	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hay+Beach+Point%2C+0%2E3+mile+NW+of%2C+New+York+Current	13075	current
13658	https://www.google.com/maps/place/41°6'38.0"N+72°20'25.0"W/@41.1108,-72.3405	13075	map
13659	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hazel+Point%2C+Washington+Current	13076	current
13660	https://www.google.com/maps/place/47°49'0.0"N+122°40'59.0"W/@47.8167,-122.6833	13076	map
13661	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Heceta+Head%2C+Oregon+Current	13077	current
13662	https://www.google.com/maps/place/44°7'59.0"N+124°7'59.0"W/@44.1333333333333,-124.133333333333	13077	map
13663	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hedge+Fence+Lighted+Gong+Buoy+22%2C+Massachusetts+Current	13078	current
13664	https://www.google.com/maps/place/41°28'18.0"N+70°28'59.0"W/@41.4717,-70.4833	13078	map
13665	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hedge+Fence%2DL%27Hommedieu+Shoal%2C+between%2C+Massachusetts+Current	13079	current
13666	https://www.google.com/maps/place/41°30'18.0"N+70°32'12.0"W/@41.505,-70.5367	13079	map
13667	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Heikish+Narrows%2C+British+Columbia+Current	13080	current
13668	https://www.google.com/maps/place/52°52'0.0"N+128°30'0.0"W/@52.8667,-128.5	13080	map
13669	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hell+Gate+%28East+River%29%2C+New+York+Current	13081	current
13670	https://www.google.com/maps/place/40°46'59.0"N+73°55'59.0"W/@40.7833,-73.9333	13081	map
13671	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hell+Gate+%28off+Mill+Rock%29%2C+New+York+Current	13082	current
13672	https://www.google.com/maps/place/40°46'41.0"N+73°56'17.0"W/@40.7783,-73.9383	13082	map
13673	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hempstead+Harbor%2C+off+Glenwood+Landing%2C+New+York+Current+%2810d%29	13083	current
13674	https://www.google.com/maps/place/40°49'40.0"N+73°39'0.0"W/@40.828,-73.65	13083	map
13675	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hendersons+Point%2C+Maryland+Current	13084	current
13676	https://www.google.com/maps/place/39°33'11.0"N+75°51'35.0"W/@39.5533,-75.86	13084	map
13677	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Henry+Hudson+Bridge%2C+0%2E7+nmi%2E+SE+of%2C+New+York+Current+%2816d%29	13085	current
13678	https://www.google.com/maps/place/40°52'36.0"N+73°55'18.0"W/@40.8767,-73.9217	13085	map
13679	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Herbert+C%2E+Bonner+Bridge%2C+WSW+of%2C+Oregon+Inlet%2C+North+Carolina+Current+%286d%29	13086	current
13680	https://www.google.com/maps/place/35°46'12.0"N+75°32'48.0"W/@35.77,-75.5467	13086	map
13681	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Herod+Point%2C+2%2E8+miles+north+of%2C+New+York+Current+%2815d%29	13087	current
13682	https://www.google.com/maps/place/41°0'58.0"N+72°49'55.0"W/@41.0162,-72.8322	13087	map
13683	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Herod+Point%2C+5%2E0+n%2Emi%2E+NW+of%2C+New+York+Current+%2815d%29	13088	current
13684	https://www.google.com/maps/place/41°1'38.0"N+72°54'43.0"W/@41.0273,-72.9122	13088	map
13685	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Herod+Point%2C+6%2E5+miles+north+of%2C+New+York+Current+%2815d%29	13089	current
13686	https://www.google.com/maps/place/41°4'39.0"N+72°49'47.0"W/@41.0775,-72.83	13089	map
13687	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Higganum+Creek%2C+0%2E5+mile+ESE+of%2C+Connecticut+River%2C+Connecticut+Current	13090	current
13688	https://www.google.com/maps/place/41°30'1.0"N+72°32'37.0"W/@41.5003,-72.5437	13090	map
13689	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=High+Bridge%2C+New+York+Current	13091	current
13690	https://www.google.com/maps/place/40°50'30.0"N+73°55'54.0"W/@40.8417,-73.9317	13091	map
13691	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Highway+Bridge%2C+Ashley+River%2C+South+Carolina+Current	13092	current
13692	https://www.google.com/maps/place/32°46'55.0"N+79°57'35.0"W/@32.782,-79.96	13092	map
13693	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hilton+Head%2C+South+Carolina+Current	13093	current
13694	https://www.google.com/maps/place/32°15'0.0"N+80°40'0.0"W/@32.25,-80.6667	13093	map
13695	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hog+Creek+Point%2C+north+of%2C+New+York+Current	13094	current
13696	https://www.google.com/maps/place/41°4'5.0"N+72°9'42.0"W/@41.0683,-72.1617	13094	map
13806	https://www.google.com/maps/place/38°31'29.0"N+76°25'12.0"W/@38.525,-76.42	13149	map
13697	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hog+Island+Channel%2C+South+Carolina+Current	13095	current
13698	https://www.google.com/maps/place/32°46'52.0"N+79°52'34.0"W/@32.7812,-79.8763	13095	map
13699	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hog+Island+Reach%2C+Buoy+%2712%27%2C+South+Carolina+Current	13096	current
13700	https://www.google.com/maps/place/32°47'40.0"N+79°54'54.0"W/@32.7945,-79.915	13096	map
13701	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hog+Island+Reach%2C+SW+of+Remley+Point%2C+South+Carolina+Current	13097	current
13702	https://www.google.com/maps/place/32°48'42.0"N+79°54'43.0"W/@32.8118,-79.912	13097	map
13703	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hog+Island%2C+northwest+of%2C+Rhode+Island+Current+%2810d%29	13098	current
13704	https://www.google.com/maps/place/41°38'48.0"N+71°17'42.0"W/@41.6467,-71.295	13098	map
13705	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hog+Point%2C+0%2E6+n%2Emi%2E+north+of%2C+Maryland+Current+%2813d%29	13099	current
13706	https://www.google.com/maps/place/38°19'4.0"N+76°24'4.0"W/@38.318,-76.4012	13099	map
13707	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hog+Point%2C+0%2E6+n%2Emi%2E+north+of%2C+Maryland+Current+%2841d%29	13100	current
13708	https://www.google.com/maps/place/38°19'4.0"N+76°24'4.0"W/@38.318,-76.4012	13100	map
13709	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Holland+Point%2C+2%2E0+n%2Emi+east+of%2C+Maryland+Current+%2815d%29	13101	current
13710	https://www.google.com/maps/place/38°45'6.0"N+76°29'55.0"W/@38.7517,-76.4988	13101	map
13711	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Holland+Point%2C+2%2E0+n%2Emi%2E+SSW+of%2C+Maryland+Current+%2814d%29	13102	current
13712	https://www.google.com/maps/place/38°40'25.0"N+76°15'26.0"W/@38.6738,-76.2575	13102	map
13713	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hooper+Bay+entrance%2C+Alaska+Current	13103	current
13714	https://www.google.com/maps/place/61°30'0.0"N+166°3'0.0"W/@61.5,-166.05	13103	map
13715	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Horlbeck+Creek%2C+0%2E2+mile+above+entrance%2C+Wando+River%2C+South+Carolina+Current	13104	current
13716	https://www.google.com/maps/place/32°53'5.0"N+79°50'41.0"W/@32.885,-79.845	13104	map
13717	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Horlbeck+Creek%2C+2%2E5+miles+north+of%2C+Wando+River%2C+South+Carolina+Current	13105	current
13718	https://www.google.com/maps/place/32°55'5.0"N+79°50'17.0"W/@32.9183,-79.8383	13105	map
13719	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Horse+Reach%2C+South+Carolina+Current	13106	current
13720	https://www.google.com/maps/place/32°47'10.0"N+79°54'54.0"W/@32.7862,-79.915	13106	map
13721	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Horseshoe+Point%2C+1%2E7+miles+east+of%2C+Maryland+Current	13107	current
13722	https://www.google.com/maps/place/38°50'17.0"N+76°27'11.0"W/@38.8383,-76.4533	13107	map
13723	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Horseshoe+Shoal%2C+North+Carolina+Current+%2816d%29	13108	current
13724	https://www.google.com/maps/place/33°58'10.0"N+77°56'52.0"W/@33.9695,-77.9478	13108	map
13725	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Horseshoe+Shoal%2C+North+Carolina+Current+%2826d%29	13109	current
13726	https://www.google.com/maps/place/33°58'10.0"N+77°56'52.0"W/@33.9695,-77.9478	13109	map
13727	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Horseshoe+Shoal%2C+North+Carolina+Current+%286d%29	13110	current
13728	https://www.google.com/maps/place/33°58'10.0"N+77°56'52.0"W/@33.9695,-77.9478	13110	map
13729	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Horton+Point%2C+1%2E4+miles+NNW+of%2C+New+York+Current	13111	current
13730	https://www.google.com/maps/place/41°6'17.0"N+72°27'24.0"W/@41.105,-72.4567	13111	map
13731	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Houston+Channel%2C+W+of+Port+Bolivar%2C+Texas+Current+%2814d%29	13112	current
13732	https://www.google.com/maps/place/29°21'52.0"N+94°47'48.0"W/@29.3647,-94.7967	13112	map
13733	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Houston+Channel%2C+W+of+Port+Bolivar%2C+Texas+Current+%2826d%29	13113	current
13734	https://www.google.com/maps/place/29°21'52.0"N+94°47'48.0"W/@29.3647,-94.7967	13113	map
13735	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Houston+Channel%2C+W+of+Port+Bolivar%2C+Texas+Current+%283d%29	13114	current
13736	https://www.google.com/maps/place/29°21'52.0"N+94°47'48.0"W/@29.3647,-94.7967	13114	map
13737	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Houston+Ship+Channel+%28Red+Fish+Bar%29%2C+Texas+Current+%2814d%29	13115	current
13738	https://www.google.com/maps/place/29°30'26.0"N+94°52'28.0"W/@29.5073,-94.8747	13115	map
13739	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Houston+Ship+Channel+%28Red+Fish+Bar%29%2C+Texas+Current+%2824d%29	13116	current
13740	https://www.google.com/maps/place/29°30'26.0"N+94°52'28.0"W/@29.5073,-94.8747	13116	map
13741	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Houston+Ship+Channel+%28Red+Fish+Bar%29%2C+Texas+Current+%287d%29	13117	current
13742	https://www.google.com/maps/place/29°30'26.0"N+94°52'28.0"W/@29.5073,-94.8747	13117	map
13743	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Howell+Point%2C+0%2E4+mile+NNW+of%2C+Maryland+Current	13118	current
13744	https://www.google.com/maps/place/39°22'36.0"N+76°6'53.0"W/@39.3767,-76.115	13118	map
13745	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Howell+Point%2C+0%2E5+n%2Emi%2E+south+of%2C+Maryland+Current+%287d%29	13119	current
13746	https://www.google.com/maps/place/38°36'13.0"N+76°6'52.0"W/@38.6038,-76.1145	13119	map
13747	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Howell+Point%2C+0%2E8+n%2Emi%2E+west+of%2C+Maryland+Current+%2815d%29	13120	current
13748	https://www.google.com/maps/place/39°22'13.0"N+76°7'47.0"W/@39.3705,-76.13	13120	map
13749	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Huckleberry+Island%2C+0%2E2+mile+NW+of%2C+New+York+Current+%2815d%29	13121	current
13750	https://www.google.com/maps/place/40°53'25.0"N+73°45'25.0"W/@40.8905,-73.7572	13121	map
13862	https://www.google.com/maps/place/38°58'13.0"N+76°14'49.0"W/@38.9705,-76.2472	13177	map
13751	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Huckleberry+Island%2C+0%2E5+mile+north+of%2C+Washington+Current	13122	current
13752	https://www.google.com/maps/place/48°32'44.0"N+122°33'58.0"W/@48.5458,-122.5663	13122	map
13753	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Huckleberry+Island%2C+0%2E5+miles+N+of%2C+Washington+Current	13123	current
13754	https://www.google.com/maps/place/47°32'59.0"N+122°34'0.0"W/@47.55,-122.5667	13123	map
13755	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Huckleberry+Island%2C+0%2E6+mile+SE+of%2C+New+York+Current+%2815d%29	13124	current
13756	https://www.google.com/maps/place/40°52'48.0"N+73°44'44.0"W/@40.88,-73.7458	13124	map
13757	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hunting+Island%2C+south+of%2C+Washington+Current+%2820d%29	13125	current
13758	https://www.google.com/maps/place/46°12'25.0"N+123°24'15.0"W/@46.2072,-123.4042	13125	map
13759	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Huntington+Bay%2C+off+East+Fort+Point%2C+New+York+Current+%2815d%29	13126	current
13760	https://www.google.com/maps/place/40°55'36.0"N+73°25'3.0"W/@40.9267,-73.4175	13126	map
13761	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Huntington+Bay%2C+off+East+Fort+Point%2C+New+York+Current+%2830d%29	13127	current
13762	https://www.google.com/maps/place/40°55'36.0"N+73°25'3.0"W/@40.9267,-73.4175	13127	map
13763	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hunts+Point%2C+southwest+of%2C+New+York+Current	13128	current
13764	https://www.google.com/maps/place/40°47'59.0"N+73°52'59.0"W/@40.8,-73.8833	13128	map
13765	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hutchinson+Island%2C+Ashepoo+River%2C+South+Carolina+Current+%2810d%29	13129	current
13766	https://www.google.com/maps/place/32°31'54.0"N+80°26'6.0"W/@32.5317,-80.435	13129	map
13767	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Hutchinson+R%2E%2C+Pelham+Highway+Bridge%2C+New+York+Current+%285d%29	13130	current
13768	https://www.google.com/maps/place/40°51'42.0"N+73°49'0.0"W/@40.8617,-73.8167	13130	map
13769	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Iceberg+Point%2C+2%2E1+mile+SSW+of%2C+Washington+Current	13131	current
13770	https://www.google.com/maps/place/48°22'59.0"N+122°55'0.0"W/@48.3833,-122.9167	13131	map
13771	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Iceberg+Point%2C+2%2E1+miles+SSW+of%2C+Washington+Current	13132	current
13772	https://www.google.com/maps/place/48°22'59.0"N+122°55'0.0"W/@48.3833,-122.9167	13132	map
13773	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=ICW+Intersection%2C+Florida+Current+%2810d%29	13133	current
13774	https://www.google.com/maps/place/30°23'1.0"N+81°27'31.0"W/@30.3837,-81.4587	13133	map
13775	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=ICW+Intersection%2C+Florida+Current+%2816d%29	13134	current
13776	https://www.google.com/maps/place/30°23'1.0"N+81°27'31.0"W/@30.3837,-81.4587	13134	map
13777	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=ICW+Intersection%2C+Florida+Current+%2829d%29	13135	current
13778	https://www.google.com/maps/place/30°23'1.0"N+81°27'31.0"W/@30.3837,-81.4587	13135	map
13779	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Igitkin+Pass%2C+0%2E8+mile+N+of+Tanager+Pt%2C+Alaska+Current	13136	current
13780	https://www.google.com/maps/place/51°57'0.0"N+175°52'0.0"W/@51.95,-175.8667	13136	map
13781	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=India+Point+RR%2E+bridge%2C+Seekonk+River%2C+Rhode+Island+Current	13137	current
13782	https://www.google.com/maps/place/41°49'0.0"N+71°23'17.0"W/@41.8167,-71.3883	13137	map
13783	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Intracoastal+Waterway%2C+Southport%2C+North+Carolina+Current+%286d%29	13138	current
13784	https://www.google.com/maps/place/33°55'4.0"N+78°2'31.0"W/@33.9178,-78.0422	13138	map
13785	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Isaac+Shoal%2C+Florida+Current	13139	current
13786	https://www.google.com/maps/place/24°33'29.0"N+82°32'12.0"W/@24.5583,-82.5367	13139	map
13787	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Isanotski+Strait+%28False+Pass+cannery%29%2C+Alaska+Current	13140	current
13788	https://www.google.com/maps/place/54°52'0.0"N+163°24'0.0"W/@54.8667,-163.4	13140	map
13789	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Isanotski+Strait+%28False+Pass+Cannery%29%2C+Alaska+Current	13141	current
13790	https://www.google.com/maps/place/54°52'0.0"N+163°24'0.0"W/@54.8667,-163.4	13141	map
13791	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Isle+of+Hope+City%2C+SE+of%2C+Skidaway+River%2C+Georgia+Current+%2810d%29	13142	current
13792	https://www.google.com/maps/place/31°58'36.0"N+81°2'48.0"W/@31.9767,-81.0467	13142	map
13793	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Isle+of+Hope+City%2C+Skidaway+River%2C+Georgia+Current+%2810d%29	13143	current
13794	https://www.google.com/maps/place/31°58'48.0"N+81°3'18.0"W/@31.98,-81.055	13143	map
13795	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Jacksonville%2C+F%2EE%2EC%2E+RR%2E+bridge%2C+Florida+Current	13144	current
13796	https://www.google.com/maps/place/30°19'18.0"N+81°39'54.0"W/@30.3217,-81.665	13144	map
13797	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Jacksonville%2C+off+Washington+St%2C+Florida+Current	13145	current
13798	https://www.google.com/maps/place/30°19'18.0"N+81°39'11.0"W/@30.3217,-81.6533	13145	map
13799	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=James+Island%2C+1%2E6+n%2Emi%2E+SW+of%2C+Maryland+Current+%2815d%29	13146	current
13800	https://www.google.com/maps/place/38°29'8.0"N+76°21'52.0"W/@38.4857,-76.3645	13146	map
13801	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=James+Island%2C+1%2E6+n%2Emi%2E+SW+of%2C+Maryland+Current+%285d%29	13147	current
13802	https://www.google.com/maps/place/38°29'8.0"N+76°21'52.0"W/@38.4857,-76.3645	13147	map
13803	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=James+Island%2C+2%2E5+miles+WNW+of%2C+Maryland+Current	13148	current
13804	https://www.google.com/maps/place/38°31'59.0"N+76°23'35.0"W/@38.5333,-76.3933	13148	map
13805	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=James+Island%2C+3%2E4+miles+west+of%2C+Maryland+Current	13149	current
13807	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Jamestown%2DNorth+Kingstown+Bridge%2C+Rhode+Island+Current+%2815d%29	13150	current
13808	https://www.google.com/maps/place/41°31'48.0"N+71°23'48.0"W/@41.53,-71.3967	13150	map
13809	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Jehossee+Island%2C+S+tip%2C+South+Edisto+River%2C+South+Carolina+Current+%2815d%29	13151	current
13810	https://www.google.com/maps/place/32°36'11.0"N+80°25'12.0"W/@32.6033,-80.42	13151	map
13811	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Jekyll+Creek%2C+south+entrance%2C+Georgia+Current	13152	current
13812	https://www.google.com/maps/place/31°2'6.0"N+81°25'59.0"W/@31.035,-81.4333	13152	map
13813	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Jennings+Point%2C+0%2E2+mile+NNW+of%2C+New+York+Current+%2813d%29	13153	current
13814	https://www.google.com/maps/place/41°4'28.0"N+72°22'56.0"W/@41.0747,-72.3825	13153	map
13815	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Joe+Island%2C+1%2E8+miles+northwest+of%2C+Florida+Current	13154	current
13816	https://www.google.com/maps/place/27°36'45.0"N+82°37'30.0"W/@27.6125,-82.625	13154	map
13817	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Joe%27s+Cut%2C+Wilmington+River%2C+Georgia+Current+%2810d%29	13155	current
13818	https://www.google.com/maps/place/31°56'35.0"N+80°59'5.0"W/@31.9433,-80.985	13155	map
13819	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Johns+Island+Airport%2C+south+of%2C+South+Carolina+Current+%2812d%29	13156	current
13820	https://www.google.com/maps/place/32°40'59.0"N+80°0'11.0"W/@32.6833,-80.0033	13156	map
13821	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Johns+Island+Bridge%2C+South+Carolina+Current+%2814d%29	13157	current
13822	https://www.google.com/maps/place/32°45'11.0"N+80°0'36.0"W/@32.7533,-80.01	13157	map
13823	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Johns+Island%2C+0%2E8+mile+north+of%2C+Washington+Current	13158	current
13824	https://www.google.com/maps/place/48°40'59.0"N+123°9'0.0"W/@48.6833,-123.15	13158	map
13825	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Johns+Island%2C+0%2E8+mile+North+of%2C+Washington+Current	13159	current
13826	https://www.google.com/maps/place/48°40'59.0"N+123°9'0.0"W/@48.6833,-123.15	13159	map
13827	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Johns+Island%2C+South+Carolina+Current+%2812d%29	13160	current
13828	https://www.google.com/maps/place/32°47'12.0"N+80°6'24.0"W/@32.7867,-80.1067	13160	map
13829	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Johnson+Creek%2C+midway+between+ends%2C+Georgia+Current	13161	current
13830	https://www.google.com/maps/place/31°37'36.0"N+81°11'17.0"W/@31.6267,-81.1883	13161	map
13831	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Johnston+Channel%2C+off+Halftide+Rock%2C+Alaska+Current	13162	current
13832	https://www.google.com/maps/place/55°49'59.0"N+160°46'59.0"W/@55.8333,-160.7833	13162	map
13833	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Johnstone+Strait+Central%2C+British+Columbia+Current	13163	current
13834	https://www.google.com/maps/place/50°28'18.0"N+126°8'12.0"W/@50.4717,-126.1367	13163	map
13835	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Jones+Point%2C+Alexandria%2C+Virginia+Current	13164	current
13836	https://www.google.com/maps/place/38°47'37.0"N+77°2'13.0"W/@38.7937,-77.0372	13164	map
13837	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Juan+De+Fuca+Strait+%28East%29%2C+British+Columbia+Current	13165	current
13838	https://www.google.com/maps/place/48°13'54.0"N+123°31'48.0"W/@48.2317,-123.53	13165	map
13839	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kagalaska+Strait%2C+off+Galas+Point%2C+Alaska+Current	13166	current
13840	https://www.google.com/maps/place/51°47'59.0"N+176°25'0.0"W/@51.8,-176.4167	13166	map
13841	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kalohi+Channel%2C+Hawaii+Current	13167	current
13842	https://www.google.com/maps/place/21°1'59.0"N+156°55'59.0"W/@21.0333,-156.9333	13167	map
13843	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kamen+Point%2C+1%2E3+miles+southwest+of%2C+Washington+Current	13168	current
13844	https://www.google.com/maps/place/48°6'0.0"N+122°58'0.0"W/@48.1,-122.9667	13168	map
13845	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kamen+Point%2C+1%2E3+miles+SW+of%2C+Washington+Current	13169	current
13846	https://www.google.com/maps/place/48°6'0.0"N+122°58'0.0"W/@48.1,-122.9667	13169	map
13847	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kanaga+Pass%2C+0%2E3+mile+NW+of+Annoy+Rock%2C+Alaska+Current	13170	current
13848	https://www.google.com/maps/place/51°43'0.0"N+177°48'0.0"W/@51.7167,-177.8	13170	map
13849	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kanaga+Pass%2C+2%2E2+miles+NE+of+Annoy+Rock%2C+Alaska+Current	13171	current
13850	https://www.google.com/maps/place/51°45'0.0"N+177°45'0.0"W/@51.75,-177.75	13171	map
13851	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Katama+Pt%2E%2C+0%2E6+mi%2E+NNW+of%2C+Katama+Bay%2C+Massachusetts+Current	13172	current
13852	https://www.google.com/maps/place/41°21'54.0"N+70°30'17.0"W/@41.365,-70.505	13172	map
13853	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kellett+Bluff%2C+west+of%2C+Washington+Current	13173	current
13854	https://www.google.com/maps/place/48°35'21.0"N+123°13'29.0"W/@48.5892,-123.225	13173	map
13855	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kellett+Bluff%2C+West+of%2C+Washington+Current	13174	current
13856	https://www.google.com/maps/place/48°34'59.0"N+123°13'59.0"W/@48.5833,-123.2333	13174	map
13857	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kelsey+Point%2C+1+mile+south+of%2C+Connecticut+Current	13175	current
13858	https://www.google.com/maps/place/41°13'59.0"N+72°30'0.0"W/@41.2333,-72.5	13175	map
13859	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kelsey+Point%2C+2%2E1+miles+southeast+of%2C+Connecticut+Current	13176	current
13860	https://www.google.com/maps/place/41°14'5.0"N+72°27'55.0"W/@41.235,-72.4655	13176	map
13861	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kent+Island+Narrows+%28highway+bridge%29%2C+Maryland+Current+%284d%29	13177	current
13863	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kent+Point%2C+1%2E3+miles+south+of%2C+Maryland+Current	13178	current
13864	https://www.google.com/maps/place/38°49'0.0"N+76°21'51.0"W/@38.8167,-76.3642	13178	map
13865	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kent+Point%2C+1%2E4+n%2Emi%2E+east+of%2C+Maryland+Current+%2815d%29	13179	current
13866	https://www.google.com/maps/place/38°50'19.0"N+76°20'15.0"W/@38.8388,-76.3375	13179	map
13867	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kent+Point%2C+4+miles+southwest+of%2C+Maryland+Current	13180	current
13868	https://www.google.com/maps/place/38°47'30.0"N+76°25'59.0"W/@38.7917,-76.4333	13180	map
13869	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kenwood+Beach%2C+1%2E5+miles+northeast+of%2C+Maryland+Current	13181	current
13870	https://www.google.com/maps/place/38°31'5.0"N+76°28'54.0"W/@38.5183,-76.4817	13181	map
13871	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Key+West%2C+0%2E3+mi%2E+W+of+Ft%2E+Taylor%2C+Florida+Current	13182	current
13872	https://www.google.com/maps/place/24°32'53.0"N+81°49'0.0"W/@24.5483,-81.8167	13182	map
13873	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Key+West%2C+Florida+Current	13183	current
13874	https://www.google.com/maps/place/24°32'53.0"N+81°49'0.0"W/@24.5483,-81.8167	13183	map
13875	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kickamuit+R%2E+%28Narrows%29%2C+Mt%2E+Hope+Bay%2C+Rhode+Island+Current	13184	current
13876	https://www.google.com/maps/place/41°41'53.0"N+71°14'42.0"W/@41.6983,-71.245	13184	map
13877	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=King+Island%2C+west+of%2C+Georgia+Current	13185	current
13878	https://www.google.com/maps/place/32°7'23.0"N+81°8'6.0"W/@32.1233,-81.135	13185	map
13879	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kings+Island+Channel%2C+Savannah+River%2C+Georgia+Current+%2810d%29	13186	current
13880	https://www.google.com/maps/place/32°7'36.0"N+81°8'12.0"W/@32.1267,-81.1367	13186	map
13881	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kings+Point%2C+Lopez+Island%2C+1+mile+NNW+of%2C+Washington+Current	13187	current
13882	https://www.google.com/maps/place/48°28'59.0"N+122°57'20.0"W/@48.4833,-122.9558	13187	map
13883	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kings+Point%2C+Lopez+Island%2C+1+nnw+of%2C+Washington+Current	13188	current
13884	https://www.google.com/maps/place/48°28'59.0"N+122°57'0.0"W/@48.4833,-122.95	13188	map
13885	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Krysi+Pass%2C+Rat+Islands%2C+Alaska+Current	13189	current
13886	https://www.google.com/maps/place/51°51'0.0"N+178°7'0.0"E/@51.85,178.1167	13189	map
13887	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Kvichak+Bay+%28off+Naknek+River+entrance%29%2C+Alaska+Current	13190	current
13888	https://www.google.com/maps/place/58°42'11.0"N+157°15'0.0"W/@58.7033,-157.25	13190	map
13889	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=L%27Hommedieu+Shoal%2C+north+of+west+end%2C+Massachusetts+Current	13191	current
13890	https://www.google.com/maps/place/41°31'36.0"N+70°34'36.0"W/@41.5267,-70.5767	13191	map
13891	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Lafayette+swing+bridge%2C+Waccamaw+River%2C+South+Carolina+Current	13192	current
13892	https://www.google.com/maps/place/33°22'7.0"N+79°15'7.0"W/@33.3687,-79.252	13192	map
13893	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Largo+Shoals%2C+west+of%2C+Puerto+Rico+Current	13193	current
13894	https://www.google.com/maps/place/18°19'0.0"N+65°34'59.0"W/@18.3167,-65.5833	13193	map
13895	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Lawrence+Point%2C+Orcas+I%2E%2C+1%2E3+mi%2E+NE+of%2C+Washington+Current	13194	current
13896	https://www.google.com/maps/place/48°40'41.0"N+122°42'52.0"W/@48.6783,-122.7145	13194	map
13897	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Lawrence+Point%2C+Orcas+Island%2C+1%2E3+mile+East+of%2C+Washington+Current	13195	current
13898	https://www.google.com/maps/place/48°38'59.0"N+122°43'0.0"W/@48.65,-122.7167	13195	map
13899	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Lazaretto+Creek+Entrance%2C+N+of%2C+Bull+River%2C+Georgia+Current+%2810d%29	13196	current
13900	https://www.google.com/maps/place/32°0'0.0"N+80°55'41.0"W/@32.0,-80.9283	13196	map
13901	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Lemon+Island+South%2C+Chechessee+River%2C+South+Carolina+Current+%2810d%29	13197	current
13902	https://www.google.com/maps/place/32°21'0.0"N+80°48'24.0"W/@32.35,-80.8067	13197	map
13903	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Lewis+Bay+entrance+channel%2C+Massachusetts+Current	13198	current
13904	https://www.google.com/maps/place/41°37'54.0"N+70°16'23.0"W/@41.6317,-70.2733	13198	map
13905	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Lewis+Island%2C+0%2E9+mile+east+of%2C+Florida+Current	13199	current
13906	https://www.google.com/maps/place/27°43'28.0"N+82°36'34.0"W/@27.7245,-82.6097	13199	map
13907	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Lewis+Point%2C+6%2E0+miles+WNW+of%2C+Rhode+Island+Current+%2815d%29	13200	current
13908	https://www.google.com/maps/place/41°11'35.0"N+71°44'12.0"W/@41.1933,-71.7367	13200	map
13909	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Lewis+Pt%2E%2C+1%2E0+mile+southwest+of%2C+Block+Island%2C+Rhode+Island+Current	13201	current
13910	https://www.google.com/maps/place/41°8'12.0"N+71°37'18.0"W/@41.1367,-71.6217	13201	map
13911	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Lewis+Pt%2E%2C+1%2E5+miles+west+of%2C+Block+Island%2C+Rhode+Island+Current	13202	current
13912	https://www.google.com/maps/place/41°8'59.0"N+71°37'59.0"W/@41.15,-71.6333	13202	map
13913	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Liberty+Bay%2C+Port+Orchard%2C+Washington+Current	13203	current
13914	https://www.google.com/maps/place/47°47'59.0"N+122°37'0.0"W/@47.8,-122.6167	13203	map
13915	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Limestone+Point%2C+Spieden+Channel%2C+Washington+Current	13204	current
13916	https://www.google.com/maps/place/48°37'34.0"N+123°6'33.0"W/@48.6263,-123.1092	13204	map
14082	https://www.google.com/maps/place/25°45'54.0"N+80°8'12.0"W/@25.765,-80.1367	13287	map
13917	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+Barnwell+I%2E%2C+E+of%2C+Whale+Branch+River%2C+South+Carolina+Current+%286d%29	13205	current
13918	https://www.google.com/maps/place/32°30'6.0"N+80°47'12.0"W/@32.5017,-80.7867	13205	map
13919	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+Coyote+Pt+3%2E1+mi+ENE%2C+South+San+Francisco+Bay%2C+California+Current	13206	current
13920	https://www.google.com/maps/place/37°34'59.0"N+122°12'0.0"W/@37.583333,-122.2	13206	map
13921	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+Coyote+Pt+3%2E4+mi+NNE%2C+South+San+Francisco+Bay%2C+California+Current	13207	current
13922	https://www.google.com/maps/place/37°38'59.0"N+122°12'59.0"W/@37.65,-122.2166	13207	map
13923	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+Don+Island%2C+east+of%2C+Vernon+River%2C+Georgia+Current+%2810d%29	13208	current
13924	https://www.google.com/maps/place/31°52'12.0"N+81°4'23.0"W/@31.87,-81.0733	13208	map
13925	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+Egg+Island%2C+northwest+of%2C+Georgia+Current+%2812d%29	13209	current
13926	https://www.google.com/maps/place/31°19'5.0"N+81°18'18.0"W/@31.3183,-81.305	13209	map
13927	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+Gull+Island%2C+0%2E8+mile+NNW+of%2C+The+Race%2C+New+York+Current+%2815d%29	13210	current
13928	https://www.google.com/maps/place/41°13'5.0"N+72°6'55.0"W/@41.2183,-72.1155	13210	map
13929	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+Gull+Island%2C+0%2E8+mile+SSE+of%2C+New+York+Current	13211	current
13930	https://www.google.com/maps/place/41°11'40.0"N+72°6'13.0"W/@41.1945,-72.1038	13211	map
13931	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+Gull+Island%2C+1%2E1+miles+ENE+of%2C+The+Race%2C+New+York+Current	13212	current
13932	https://www.google.com/maps/place/41°13'5.0"N+72°5'5.0"W/@41.2183,-72.085	13212	map
13933	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+Gull+Island%2C+1%2E4+n%2Emi%2E+NNE+of%2C+The+Race%2C+New+York+Current+%2845d%29	13213	current
13934	https://www.google.com/maps/place/41°13'31.0"N+72°5'31.0"W/@41.2255,-72.092	13213	map
13935	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+Mud+River+Range%2C+Georgia+Current+%289d%29	13214	current
13936	https://www.google.com/maps/place/31°19'36.0"N+81°19'5.0"W/@31.3267,-81.3183	13214	map
13937	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+Narragansett+Bay+entrance%2C+Rhode+Island+Current	13215	current
13938	https://www.google.com/maps/place/41°19'59.0"N+71°52'59.0"W/@41.3333,-71.8833	13215	map
13939	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+Ogeechee+River+Entrance%2C+Georgia+Current+%2810d%29	13216	current
13940	https://www.google.com/maps/place/31°53'17.0"N+81°5'53.0"W/@31.8883,-81.0983	13216	map
13941	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+Ogeechee+River+Entrance%2C+Georgia+Current+%2820d%29	13217	current
13942	https://www.google.com/maps/place/31°53'17.0"N+81°5'53.0"W/@31.8883,-81.0983	13217	map
13943	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+Ogeechee+River+Entrance%2C+north+of%2C+Georgia+Current+%286d%29	13218	current
13944	https://www.google.com/maps/place/31°53'48.0"N+81°5'41.0"W/@31.8967,-81.095	13218	map
13945	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+Peconic+Bay+entrance%2C+New+York+Current+%2819d%29	13219	current
13946	https://www.google.com/maps/place/41°1'34.0"N+72°23'4.0"W/@41.0263,-72.3847	13219	map
13947	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+Sarasota+Bay%2C+south+end%2C+bridge%2C+Florida+Current	13220	current
13948	https://www.google.com/maps/place/27°10'47.0"N+82°29'42.0"W/@27.18,-82.495	13220	map
13949	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+St%2E+Simon+Island+%28north%29%2C+Georgia+Current+%2811d%29	13221	current
13950	https://www.google.com/maps/place/31°18'42.0"N+81°21'11.0"W/@31.3117,-81.3533	13221	map
13951	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+Tanaga+Strait%2C+off+Tana+Pt%2C+Alaska+Current	13222	current
13952	https://www.google.com/maps/place/51°49'0.0"N+176°13'59.0"W/@51.8167,-176.2333	13222	map
13953	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+Wassaw+Island%2C+SW+of%2C+Georgia+Current+%2810d%29	13223	current
13954	https://www.google.com/maps/place/31°52'12.0"N+81°2'59.0"W/@31.87,-81.05	13223	map
13955	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Lloyd+Point%2C+1%2E3+miles+NNW+of%2C+New+York+Current+%2815d%29	13224	current
13956	https://www.google.com/maps/place/40°57'56.0"N+73°29'42.0"W/@40.9658,-73.495	13224	map
13957	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Lloyd+Point%2C+1%2E3+miles+NNW+of%2C+New+York+Current+%2840d%29	13225	current
13958	https://www.google.com/maps/place/40°57'56.0"N+73°29'42.0"W/@40.9658,-73.495	13225	map
13959	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Long+Beach+Pt%2E%2C+0%2E7+mile+southwest+of%2C+New+York+Current+%2815d%29	13226	current
13960	https://www.google.com/maps/place/41°6'15.0"N+72°18'24.0"W/@41.1042,-72.3067	13226	map
13961	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Long+Island%2C+NNE+of%2C+Skidaway+River%2C+Georgia+Current+%286d%29	13227	current
13962	https://www.google.com/maps/place/31°57'24.0"N+81°3'36.0"W/@31.9567,-81.06	13227	map
13963	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Long+Island%2C+south+of%2C+Skidaway+River%2C+Georgia+Current+%2810d%29	13228	current
13964	https://www.google.com/maps/place/31°56'35.0"N+81°4'23.0"W/@31.9433,-81.0733	13228	map
13965	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Long+Key+Viaduct%2C+Florida+Current	13229	current
13966	https://www.google.com/maps/place/24°48'6.0"N+80°51'53.0"W/@24.8017,-80.865	13229	map
13967	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Long+Key%2C+drawbridge+east+of%2C+Florida+Current	13230	current
13968	https://www.google.com/maps/place/24°50'23.0"N+80°46'11.0"W/@24.84,-80.77	13230	map
13969	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Long+Key%2C+east+of+drawbridge%2C+Florida+Current	13231	current
13970	https://www.google.com/maps/place/24°50'23.0"N+80°46'11.0"W/@24.84,-80.77	13231	map
13971	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Long+Neck+Point%2C+0%2E6+mile+south+of%2C+Connecticut+Current+%2815d%29	13232	current
13972	https://www.google.com/maps/place/41°1'34.0"N+73°28'40.0"W/@41.0263,-73.478	13232	map
13973	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Long+Neck+Point%2C+0%2E6+mile+south+of%2C+Connecticut+Current+%2827d%29	13233	current
13974	https://www.google.com/maps/place/41°1'34.0"N+73°28'40.0"W/@41.0263,-73.478	13233	map
13975	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Long+Point%2C+1+mile+southeast+of%2C+Maryland+Current	13234	current
13976	https://www.google.com/maps/place/38°50'35.0"N+76°19'36.0"W/@38.8433,-76.3267	13234	map
13977	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Long+Shoal%2DNorton+Shoal%2C+between%2C+Massachusetts+Current	13235	current
13978	https://www.google.com/maps/place/41°24'29.0"N+70°19'59.0"W/@41.4083,-70.3333	13235	map
13979	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Longboat+Pass%2C+Florida+Current	13236	current
13980	https://www.google.com/maps/place/27°26'30.0"N+82°41'23.0"W/@27.4417,-82.69	13236	map
13981	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Lopez+Pass%2C+Washington+Current	13237	current
13982	https://www.google.com/maps/place/48°28'46.0"N+122°49'7.0"W/@48.4797,-122.8187	13237	map
13983	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Love+Point%2C+1%2E6+n%2Emi%2E+east+of%2C+Maryland+Current+%2816d%29	13238	current
13984	https://www.google.com/maps/place/39°2'3.0"N+76°16'4.0"W/@39.0342,-76.2678	13238	map
13985	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Love+Point%2C+2%2E0+nmi+north+of%2C+Maryland+Current+%2815d%29	13239	current
13986	https://www.google.com/maps/place/39°4'26.0"N+76°18'11.0"W/@39.074,-76.3032	13239	map
13987	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Love+Point%2C+2%2E0+nmi+north+of%2C+Maryland+Current+%285d%29	13240	current
13988	https://www.google.com/maps/place/39°4'26.0"N+76°18'11.0"W/@39.074,-76.3032	13240	map
13989	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Love+Point%2C+2%2E5+miles+north+of%2C+Maryland+Current	13241	current
13990	https://www.google.com/maps/place/39°4'46.0"N+76°18'43.0"W/@39.0797,-76.3122	13241	map
13991	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Low+Point%2C+entrance+to+Taiya+Inlet%2C+Alaska+Current	13242	current
13992	https://www.google.com/maps/place/59°16'0.0"N+135°22'0.0"W/@59.2667,-135.3667	13242	map
13993	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Lowe+Point+%28northeast+of%29%2C+Sasanoa+River%2C+Maine+Current	13243	current
13994	https://www.google.com/maps/place/43°51'6.0"N+69°43'18.0"W/@43.8517,-69.7217	13243	map
13995	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Lower+Hell+Gate+%28Knubble+Bay%2C+Maine%29+Current	13244	current
13996	https://www.google.com/maps/place/43°52'36.0"N+69°43'48.0"W/@43.8767,-69.73	13244	map
13997	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Lynch+Point%2C+Back+River%2C+Maryland+Current	13245	current
13998	https://www.google.com/maps/place/39°15'0.0"N+76°26'17.0"W/@39.25,-76.4383	13245	map
13999	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Lynde+Point%2C+channel+east+of%2C+Connecticut+River%2C+Connecticut+Current	13246	current
14000	https://www.google.com/maps/place/41°16'0.0"N+72°19'59.0"W/@41.2667,-72.3333	13246	map
14001	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Lyons+Creek+Wharf%2C+Maryland+Current	13247	current
14002	https://www.google.com/maps/place/38°44'48.0"N+76°41'6.0"W/@38.7467,-76.685	13247	map
14003	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=MacKay+Creek%2C+south+entrance%2C+South+Carolina+Current+%2810d%29	13248	current
14004	https://www.google.com/maps/place/32°13'11.0"N+80°47'24.0"W/@32.22,-80.79	13248	map
14005	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mackay+R%2E%2C+0%2E5+mi%2E+N+of+Troup+Creek+entrance%2C+Georgia+Current	13249	current
14006	https://www.google.com/maps/place/31°13'30.0"N+81°25'59.0"W/@31.225,-81.4333	13249	map
14007	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Macombs+Dam+Bridge%2C+New+York+Current	13250	current
14008	https://www.google.com/maps/place/40°49'41.0"N+73°56'6.0"W/@40.8283,-73.935	13250	map
14009	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Madison+Ave%2E+Bridge%2C+New+York+Current	13251	current
14010	https://www.google.com/maps/place/40°48'47.0"N+73°56'6.0"W/@40.8133,-73.935	13251	map
14011	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Main+Ship+Channel+entrance%2C+Key+West%2C+Florida+Current	13252	current
14012	https://www.google.com/maps/place/24°28'23.0"N+81°48'6.0"W/@24.4733,-81.8017	13252	map
14013	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mandarin+Point%2C+Florida+Current+%2815d%29	13253	current
14014	https://www.google.com/maps/place/30°9'18.0"N+81°41'6.0"W/@30.155,-81.685	13253	map
14015	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mandarin+Point%2C+Florida+Current+%2824d%29	13254	current
14016	https://www.google.com/maps/place/30°9'18.0"N+81°41'6.0"W/@30.155,-81.685	13254	map
14017	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mandarin+Point%2C+Florida+Current+%286d%29	13255	current
14018	https://www.google.com/maps/place/30°9'18.0"N+81°41'6.0"W/@30.155,-81.685	13255	map
14019	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Manhasset+Bay+entrance%2C+New+York+Current+%2815d%29	13256	current
14020	https://www.google.com/maps/place/40°49'45.0"N+73°43'46.0"W/@40.8292,-73.7297	13256	map
14021	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Manhattan+Bridge%2C+East+of%2C+New+York+Current+%2815d%29	13257	current
14022	https://www.google.com/maps/place/40°42'29.0"N+73°59'23.0"W/@40.7083,-73.99	13257	map
14023	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Manhattan%2C+off+31st+Street%2C+New+York+Current	13258	current
14024	https://www.google.com/maps/place/40°44'22.0"N+73°58'10.0"W/@40.7397,-73.9695	13258	map
14025	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Marblehead+Channel%2C+Massachusetts+Current	13259	current
14026	https://www.google.com/maps/place/42°30'0.0"N+70°49'0.0"W/@42.5,-70.8167	13259	map
14027	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mare+Island+Strait+Entrance%2C+San+Pablo+Bay%2C+California+Current	13260	current
14028	https://www.google.com/maps/place/38°3'59.0"N+122°15'0.0"W/@38.066666,-122.25	13260	map
14029	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mare+Island+Strait%2C+So+Vallejo%2C+San+Pablo+Bay%2C+California+Current	13261	current
14030	https://www.google.com/maps/place/38°4'59.0"N+122°15'0.0"W/@38.083333,-122.25	13261	map
14031	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Marrowstone+Point%2C+0%2E3+miles+NE+of%2C+Washington+Current	13262	current
14032	https://www.google.com/maps/place/48°6'0.0"N+122°40'59.0"W/@48.1,-122.6833	13262	map
14033	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Marrowstone+Point%2C+0%2E4+miles+NE+of%2C+Washington+Current	13263	current
14034	https://www.google.com/maps/place/48°6'0.0"N+122°40'59.0"W/@48.1,-122.6833	13263	map
14035	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Marrowstone+Point%2C+1%2E1+miles+NW+of%2C+Washington+Current	13264	current
14036	https://www.google.com/maps/place/48°7'0.0"N+122°42'0.0"W/@48.1167,-122.7	13264	map
14037	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Marrowstone+Point%2C+1%2E6+miles+NE+of%2C+Washington+Current	13265	current
14038	https://www.google.com/maps/place/48°7'0.0"N+122°40'0.0"W/@48.1167,-122.6667	13265	map
14039	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Martin+Point%2C+0%2E6+n%2Emi%2E+west+of%2C+Maryland+Current+%2818d%29	13266	current
14040	https://www.google.com/maps/place/38°37'37.0"N+76°8'8.0"W/@38.6272,-76.1358	13266	map
14041	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Maryland+Point%2C+Maryland+Current	13267	current
14042	https://www.google.com/maps/place/38°20'48.0"N+77°11'48.0"W/@38.3467,-77.1967	13267	map
14043	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Matia+Island%2C+0%2E8+mile+West+of%2C+Washington+Current	13268	current
14044	https://www.google.com/maps/place/48°45'0.0"N+122°52'0.0"W/@48.75,-122.8667	13268	map
14045	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Matia+Island%2C+0%2E8+mile+west+of%2C+Washington+Current	13269	current
14046	https://www.google.com/maps/place/48°44'55.0"N+122°51'56.0"W/@48.7488,-122.8658	13269	map
14047	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Matia+Island%2C+1%2E4+mile+North+of%2C+Washington+Current	13270	current
14048	https://www.google.com/maps/place/48°45'0.0"N+122°49'59.0"W/@48.75,-122.8333	13270	map
14049	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Matia+Island%2C+1%2E4+miles+north+of%2C+Washington+Current	13271	current
14050	https://www.google.com/maps/place/48°46'19.0"N+122°50'58.0"W/@48.7722,-122.8495	13271	map
14051	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Matinecock+Point%2C+0%2E7+mile+NNW+of%2C+New+York+Current+%2815d%29	13272	current
14052	https://www.google.com/maps/place/40°54'47.0"N+73°38'24.0"W/@40.9133,-73.64	13272	map
14053	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Matinecock+Point%2C+0%2E7+mile+NNW+of%2C+New+York+Current+%2840d%29	13273	current
14054	https://www.google.com/maps/place/40°54'47.0"N+73°38'24.0"W/@40.9133,-73.64	13273	map
14055	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Matinecock+Point%2C+1%2E7+miles+northwest+of%2C+New+York+Current+%2815d%29	13274	current
14056	https://www.google.com/maps/place/40°55'28.0"N+73°39'22.0"W/@40.9247,-73.6562	13274	map
14057	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mattituck+Inlet%2C+1+mile+northwest+of%2C+New+York+Current+%2815d%29	13275	current
14058	https://www.google.com/maps/place/41°1'40.0"N+72°34'13.0"W/@41.028,-72.5703	13275	map
14059	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mayport+Basin+Entrance%2C+Florida+Current+%2815d%29	13276	current
14060	https://www.google.com/maps/place/30°23'49.0"N+81°23'55.0"W/@30.397,-81.3988	13276	map
14061	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mayport+Basin+Entrance%2C+Florida+Current+%2832d%29	13277	current
14062	https://www.google.com/maps/place/30°23'49.0"N+81°23'55.0"W/@30.397,-81.3988	13277	map
14063	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mayport+Basin+Entrance%2C+Florida+Current+%289d%29	13278	current
14064	https://www.google.com/maps/place/30°23'49.0"N+81°23'55.0"W/@30.397,-81.3988	13278	map
14065	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mayport%2C+Florida+Current+%2817d%29	13279	current
14066	https://www.google.com/maps/place/30°23'35.0"N+81°25'59.0"W/@30.3933,-81.4333	13279	map
14067	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mayport%2C+Florida+Current+%2827d%29	13280	current
14068	https://www.google.com/maps/place/30°23'35.0"N+81°25'59.0"W/@30.3933,-81.4333	13280	map
14069	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mayport%2C+Florida+Current+%287d%29	13281	current
14070	https://www.google.com/maps/place/30°23'35.0"N+81°25'59.0"W/@30.3933,-81.4333	13281	map
14071	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=McGowan%2C+SSW+of%2C+Washington+Current+%2814d%29	13282	current
14072	https://www.google.com/maps/place/46°14'22.0"N+123°54'55.0"W/@46.2395,-123.9153	13282	map
14073	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=McQueen+Island+Cut%2C+Georgia+Current+%2810d%29	13283	current
14074	https://www.google.com/maps/place/32°3'53.0"N+80°59'12.0"W/@32.065,-80.9867	13283	map
14075	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Medway+River+at+Marsh+Island%2C+Georgia+Current+%2810d%29	13284	current
14076	https://www.google.com/maps/place/31°44'35.0"N+81°13'11.0"W/@31.7433,-81.22	13284	map
14077	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Medway+River%2C+northwest+of+Cedar+Point%2C+Georgia+Current+%2810d%29	13285	current
14078	https://www.google.com/maps/place/31°42'52.0"N+81°11'26.0"W/@31.7145,-81.1908	13285	map
14079	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Miacomet+Pond%2C+3%2E0+miles+SSE+of%2C+Massachusetts+Current	13286	current
14080	https://www.google.com/maps/place/41°11'23.0"N+70°5'48.0"W/@41.19,-70.0967	13286	map
14081	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Miami+Harbor+Entrance%2C+Florida+Current+%281%29+%28expired+1986%2D12%2D31%29	13287	current
14083	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Miami+Harbor+Entrance%2C+Florida+Current+%282%29	13288	current
14084	https://www.google.com/maps/place/25°45'54.0"N+80°8'12.0"W/@25.765,-80.1367	13288	map
14085	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Miami+Harbor+Entrance%2C+Florida+Current+%283%29	13289	current
14086	https://www.google.com/maps/place/25°45'54.0"N+80°8'12.0"W/@25.765,-80.1367	13289	map
14087	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Middle+Marshes%2C+S+of%2C+Beaufort+Inlet%2C+North+Carolina+Current+%286d%29	13290	current
14088	https://www.google.com/maps/place/34°40'41.0"N+76°36'49.0"W/@34.6783,-76.6138	13290	map
14089	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Middle%2C+Quicks+Hole%2C+Massachusetts+Current	13291	current
14090	https://www.google.com/maps/place/41°26'35.0"N+70°50'53.0"W/@41.4433,-70.8483	13291	map
14091	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Middle%2C+Robinsons+Hole%2C+Massachusetts+Current	13292	current
14092	https://www.google.com/maps/place/41°27'0.0"N+70°48'24.0"W/@41.45,-70.8067	13292	map
14093	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Midnight+Pass+entrance%2C+Florida+Current	13293	current
14094	https://www.google.com/maps/place/27°12'24.0"N+82°30'36.0"W/@27.2067,-82.51	13293	map
14095	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mile+Point%2C+southeast+of%2C+Florida+Current+%2818d%29	13294	current
14096	https://www.google.com/maps/place/30°22'54.0"N+81°26'41.0"W/@30.3817,-81.445	13294	map
14097	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mile+Point%2C+southeast+of%2C+Florida+Current+%2829d%29	13295	current
14098	https://www.google.com/maps/place/30°22'54.0"N+81°26'41.0"W/@30.3817,-81.445	13295	map
14099	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mile+Point%2C+southeast+of%2C+Florida+Current+%287d%29	13296	current
14100	https://www.google.com/maps/place/30°22'54.0"N+81°26'41.0"W/@30.3817,-81.445	13296	map
14101	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mile+Rock+Lt%2E%2C+0%2E2+nmi%2E+NW+of%2C+California+Current+%2815d%29	13297	current
14102	https://www.google.com/maps/place/37°47'43.0"N+122°30'40.0"W/@37.7953,-122.5113	13297	map
14103	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mile+Rock+Lt%2E%2C+0%2E2+nmi%2E+NW+of%2C+California+Current+%2835d%29	13298	current
14104	https://www.google.com/maps/place/37°47'43.0"N+122°30'40.0"W/@37.7953,-122.5113	13298	map
14105	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Milford+Point%2C+0%2E2+mile+west+of%2C+Housatonic+River%2C+Connecticut+Current+%2810d%29	13299	current
14106	https://www.google.com/maps/place/41°10'20.0"N+73°6'49.0"W/@41.1725,-73.1137	13299	map
14107	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mill+Rock%2C+northeast+of%2C+New+York+Current	13300	current
14108	https://www.google.com/maps/place/40°46'54.0"N+73°56'12.0"W/@40.7817,-73.9367	13300	map
14109	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mill+Rock%2C+west+of%2C+New+York+Current	13301	current
14110	https://www.google.com/maps/place/40°46'48.0"N+73°56'30.0"W/@40.78,-73.9417	13301	map
14111	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Miller+Island%2C+1%2E5+miles+ENE+of%2C+Maryland+Current+%287d%29	13302	current
14112	https://www.google.com/maps/place/39°16'29.0"N+76°19'54.0"W/@39.275,-76.3317	13302	map
14113	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mobile+Bay+Entrance+%28off+Mobile+Point%29%2C+Alabama+Current	13303	current
14114	https://www.google.com/maps/place/30°13'36.0"N+88°2'5.0"W/@30.2267,-88.035	13303	map
14115	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mobile+Bay+Entrance%2C+Alabama+Current	13304	current
14116	https://www.google.com/maps/place/30°13'59.0"N+88°1'59.0"W/@30.2333,-88.0333	13304	map
14117	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mobile+River+entrance%2C+Alabama+Current	13305	current
14118	https://www.google.com/maps/place/30°40'12.0"N+88°1'59.0"W/@30.67,-88.0333	13305	map
14119	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Monomoy+Point%2C+6+miles+west+of%2C+Massachusetts+Current	13306	current
14120	https://www.google.com/maps/place/41°33'29.0"N+70°9'0.0"W/@41.5583,-70.15	13306	map
14121	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Monomoy+Pt%2E%2C+channel+0%2E2+mile+west+of%2C+Massachusetts+Current	13307	current
14122	https://www.google.com/maps/place/41°32'59.0"N+70°1'18.0"W/@41.55,-70.0217	13307	map
14123	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Montauk+Harbor+entrance%2C+New+York+Current+%286d%29	13308	current
14124	https://www.google.com/maps/place/41°4'46.0"N+71°56'21.0"W/@41.0797,-71.9392	13308	map
14125	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Montauk+Point%2C+1+mile+northeast+of%2C+New+York+Current	13309	current
14126	https://www.google.com/maps/place/41°4'59.0"N+71°50'59.0"W/@41.0833,-71.85	13309	map
14127	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Montauk+Point%2C+1%2E2+miles+east+of%2C+New+York+Current	13310	current
14128	https://www.google.com/maps/place/41°4'30.0"N+71°49'47.0"W/@41.075,-71.83	13310	map
14129	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Montauk+Point%2C+5%2E4+miles+NNE+of%2C+New+York+Current+%2815d%29	13311	current
14130	https://www.google.com/maps/place/41°9'33.0"N+71°49'28.0"W/@41.1592,-71.8247	13311	map
14131	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Montezuma+Slough+1+mi+in+W+Entrance%2C+Suisun+Bay%2C+California+Current	13312	current
14132	https://www.google.com/maps/place/38°7'59.0"N+122°2'59.0"W/@38.133333,-122.05	13312	map
14133	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Montezuma+Slough+E+end+nr+Brg%2C+Suisun+Bay%2C+California+Current	13313	current
14134	https://www.google.com/maps/place/38°4'59.0"N+121°52'59.0"W/@38.083333,-121.8833	13313	map
14135	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Montezuma+Slough+West+Entrance%2C+Suisun+Bay%2C+California+Current	13314	current
14136	https://www.google.com/maps/place/38°7'59.0"N+122°2'59.0"W/@38.133333,-122.05	13314	map
14137	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Montgomery%2C+Vernon+River%2C+Georgia+Current+%286d%29	13315	current
14138	https://www.google.com/maps/place/31°56'5.0"N+81°7'41.0"W/@31.935,-81.1283	13315	map
14139	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Morakas+Point%2C+Naknek+River%2C+Alaska+Current	13316	current
14140	https://www.google.com/maps/place/58°43'59.0"N+156°55'59.0"W/@58.7333,-156.9333	13316	map
14141	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Morehead+City%2C+RR%2E+bridge%2C+N+of%2C+Beaufort+Inlet%2C+North+Carolina+Current+%286d%29	13317	current
14142	https://www.google.com/maps/place/34°43'22.0"N+76°41'37.0"W/@34.7228,-76.6938	13317	map
14143	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Morehead+City%2C+S+of%2C+Beaufort+Inlet%2C+North+Carolina+Current+%286d%29	13318	current
14144	https://www.google.com/maps/place/34°43'0.0"N+76°43'58.0"W/@34.7167,-76.7328	13318	map
14145	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Moreland%2C+0%2E5+n%2Emi%2E+below%2C+Cooper+River%2C+South+Carolina+Current	13319	current
14146	https://www.google.com/maps/place/33°0'1.0"N+79°54'16.0"W/@33.0005,-79.9047	13319	map
14147	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Morgan+Island%2C+NE+of%2C+Coosaw+River%2C+South+Carolina+Current+%2815d%29	13320	current
14148	https://www.google.com/maps/place/32°29'17.0"N+80°28'23.0"W/@32.4883,-80.4733	13320	map
14149	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Morgan+Island%2C+North+end%2C+Coosaw+River%2C+South+Carolina+Current+%2815d%29	13321	current
14150	https://www.google.com/maps/place/32°30'11.0"N+80°32'12.0"W/@32.5033,-80.5367	13321	map
14151	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Morgans+Point%2C+Texas+Current+%2815d%29	13322	current
14152	https://www.google.com/maps/place/29°40'47.0"N+94°58'54.0"W/@29.6798,-94.9817	13322	map
14153	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Morgans+Point%2C+Texas+Current+%2825d%29	13323	current
14154	https://www.google.com/maps/place/29°40'47.0"N+94°58'54.0"W/@29.6798,-94.9817	13323	map
14155	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Morgans+Point%2C+Texas+Current+%286d%29	13324	current
14156	https://www.google.com/maps/place/29°40'47.0"N+94°58'54.0"W/@29.6798,-94.9817	13324	map
14157	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Moser+Channel+%28swingbridge%29%2C+Florida+Current	13325	current
14158	https://www.google.com/maps/place/24°41'59.0"N+81°10'12.0"W/@24.7,-81.17	13325	map
14159	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Moser+Channel%2C+swingbridge%2C+Florida+Current	13326	current
14160	https://www.google.com/maps/place/24°41'59.0"N+81°10'12.0"W/@24.7,-81.17	13326	map
14161	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mount+Hope+Bridge%2C+Rhode+Island+Current+%287d%29	13327	current
14162	https://www.google.com/maps/place/41°38'24.0"N+71°15'29.0"W/@41.64,-71.2583	13327	map
14163	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mount+Hope+Point%2C+northeast+of%2C+Rhode+Island+Current+%2810d%29	13328	current
14164	https://www.google.com/maps/place/41°40'47.0"N+71°12'42.0"W/@41.68,-71.2117	13328	map
14165	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mountain+Point%2C+Magothy+River+entrance%2C+Maryland+Current	13329	current
14166	https://www.google.com/maps/place/39°3'28.0"N+76°26'13.0"W/@39.0578,-76.4372	13329	map
14167	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mt%2E+Prospect%2C+0%2E6+mile+SSE+of%2C+New+York+Current+%2815d%29	13330	current
14168	https://www.google.com/maps/place/41°14'44.0"N+71°59'48.0"W/@41.2458,-71.9967	13330	map
14169	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mulford+Gardens+Channel+%232+SSW%2C+South+San+Francisco+Bay%2C+California+Current	13331	current
14170	https://www.google.com/maps/place/37°38'59.0"N+122°12'59.0"W/@37.65,-122.2166	13331	map
14171	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mulford+Point%2C+3%2E1+miles+northwest+of%2C+Connecticut+Current+%2815d%29	13332	current
14172	https://www.google.com/maps/place/41°12'0.0"N+72°19'4.0"W/@41.2,-72.318	13332	map
14173	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mullet+Key+Channel+entrance%2C+Florida+Current	13333	current
14174	https://www.google.com/maps/place/27°36'16.0"N+82°43'25.0"W/@27.6045,-82.7238	13333	map
14175	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mullet+Key+Channel%2C+marker+%2724%27%2C+Florida+Current+%2815d%29	13334	current
14176	https://www.google.com/maps/place/27°36'29.0"N+82°41'38.0"W/@27.6083,-82.694	13334	map
14177	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Muskeget+Channel%2C+Massachusetts+Current	13335	current
14178	https://www.google.com/maps/place/41°20'53.0"N+70°25'12.0"W/@41.3483,-70.42	13335	map
14179	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Muskeget+I%2E%2C+channel+1+mile+northeast+of%2C+Massachusetts+Current	13336	current
14180	https://www.google.com/maps/place/41°21'0.0"N+70°17'5.0"W/@41.35,-70.285	13336	map
14181	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Muskeget+Rock%2C+1%2E3+miles+southwest+of%2C+Massachusetts+Current	13337	current
14182	https://www.google.com/maps/place/41°19'12.0"N+70°23'35.0"W/@41.32,-70.3933	13337	map
14183	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mutiny+Bay%2C+3%2E3+miles+SE+of%2C+Washington+Current	13338	current
14184	https://www.google.com/maps/place/48°7'59.0"N+122°37'59.0"W/@48.1333,-122.6333	13338	map
14185	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Myrtle+Sound%2C+Intracoastal+Waterway%2C+North+Carolina+Current+%286d%29	13339	current
14186	https://www.google.com/maps/place/34°4'40.0"N+77°53'24.0"W/@34.078,-77.89	13339	map
14187	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Mystic%2C+Highway+Bridge%2C+Mystic+River%2C+Connecticut+Current+%286d%29	13340	current
14188	https://www.google.com/maps/place/41°21'15.0"N+71°58'10.0"W/@41.3542,-71.9697	13340	map
14189	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=N%2E+Newport+River%2C+above+Walburg+Creek%2C+Georgia+Current+%286d%29	13341	current
14190	https://www.google.com/maps/place/31°40'25.0"N+81°11'43.0"W/@31.6738,-81.1953	13341	map
14191	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=N%2E+Newport+River%2C+ESE+of+S%2E+Newport+Cut%2C+Georgia+Current+%286d%29	13342	current
14192	https://www.google.com/maps/place/31°39'55.0"N+81°15'52.0"W/@31.6653,-81.2645	13342	map
14193	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=N%2E+Newport+River%2C+NE+of+Vandyke+Creek%2C+Georgia+Current+%2810d%29	13343	current
14194	https://www.google.com/maps/place/31°41'28.0"N+81°11'13.0"W/@31.6912,-81.187	13343	map
14195	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=N%2E+Newport+River%2C+NW+of+Johnson+Creek%2C+Georgia+Current+%2810d%29	13344	current
14196	https://www.google.com/maps/place/31°39'46.0"N+81°12'37.0"W/@31.663,-81.2105	13344	map
14197	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Nakwakto+Rapids%2C+British+Columbia+Current	13345	current
14198	https://www.google.com/maps/place/51°5'48.0"N+127°30'11.0"W/@51.0967,-127.5033	13345	map
14199	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Nantucket+Harbor+entrance+channel%2C+Massachusetts+Current	13346	current
14200	https://www.google.com/maps/place/41°18'24.0"N+70°5'59.0"W/@41.3067,-70.1	13346	map
14201	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Nantucket+Harbor+Entrance+Channel%2C+Massachusetts+Current	13347	current
14202	https://www.google.com/maps/place/41°18'24.0"N+70°5'59.0"W/@41.3067,-70.1	13347	map
14203	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Napatree+Point%2C+0%2E7+mile+southwest+of%2C+Rhode+Island+Current	13348	current
14204	https://www.google.com/maps/place/41°17'55.0"N+71°54'0.0"W/@41.2987,-71.9	13348	map
14205	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=National+City%2C+California+Current	13349	current
14206	https://www.google.com/maps/place/32°38'59.0"N+117°7'0.0"W/@32.65,-117.1167	13349	map
14207	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=National+City%2C+WSW+of+Pier+12%2C+California+Current+%2832d%29	13350	current
14208	https://www.google.com/maps/place/32°39'43.0"N+117°7'31.0"W/@32.6622,-117.1255	13350	map
14209	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Nayatt+Point%2C+WNW+of%2C+Rhode+Island+Current+%2810d%29	13351	current
14210	https://www.google.com/maps/place/41°43'41.0"N+71°21'35.0"W/@41.7283,-71.36	13351	map
14211	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=New+Dungeness+Light%2C+2%2E8+miles+NNW+of%2C+Washington+Current	13352	current
14212	https://www.google.com/maps/place/48°13'59.0"N+123°7'59.0"W/@48.2333,-123.1333	13352	map
14213	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=New+Dungeness+Light%2C+6+miles+NNE+of%2C+Washington+Current	13353	current
14214	https://www.google.com/maps/place/48°16'0.0"N+123°2'59.0"W/@48.2667,-123.05	13353	map
14215	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=New+Ground%2C+Florida+Current	13354	current
14216	https://www.google.com/maps/place/24°38'59.0"N+82°25'0.0"W/@24.65,-82.4167	13354	map
14217	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=New+Haven+Harbor+entrance%2C+Connecticut+Current	13355	current
14218	https://www.google.com/maps/place/41°13'59.0"N+72°55'0.0"W/@41.2333,-72.9167	13355	map
14219	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=New+London+Harbor+entrance%2C+Connecticut+Current	13356	current
14220	https://www.google.com/maps/place/41°19'4.0"N+72°5'1.0"W/@41.318,-72.0837	13356	map
14221	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=New+Pass%2C+Florida+Current	13357	current
14222	https://www.google.com/maps/place/27°19'54.0"N+82°34'54.0"W/@27.3317,-82.5817	13357	map
14223	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=New+Teakettle+Cr%2E%2C+0%2E8+mi%2E+N+of%2C+Mud+River%2C+Georgia+Current	13358	current
14224	https://www.google.com/maps/place/31°29'48.0"N+81°17'24.0"W/@31.4967,-81.29	13358	map
14225	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Newburyport+%28Merrimack+River%29%2C+Massachusetts+Current	13359	current
14226	https://www.google.com/maps/place/42°48'47.0"N+70°52'5.0"W/@42.8133,-70.8683	13359	map
14227	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Newport+Marshes%2C+E+of%2C+Beaufort+Inlet%2C+North+Carolina+Current+%286d%29	13360	current
14228	https://www.google.com/maps/place/34°44'16.0"N+76°40'49.0"W/@34.7378,-76.6805	13360	map
14229	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Newport+Marshes%2C+SE+of%2C+Beaufort+Inlet%2C+North+Carolina+Current+%2815d%29	13361	current
14230	https://www.google.com/maps/place/34°43'52.0"N+76°40'59.0"W/@34.7313,-76.6833	13361	map
14231	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Newport+Marshes%2C+SE+of%2C+Beaufort+Inlet%2C+North+Carolina+Current+%286d%29	13362	current
14232	https://www.google.com/maps/place/34°43'52.0"N+76°40'59.0"W/@34.7313,-76.6833	13362	map
14233	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Niantic+%28Railroad+Bridge%29%2C+Connecticut+Current+%285d%29	13363	current
14234	https://www.google.com/maps/place/41°19'23.0"N+72°10'37.0"W/@41.3233,-72.177	13363	map
14235	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Nisqually+Reach%2C+Washington+Current	13364	current
14236	https://www.google.com/maps/place/47°7'0.0"N+122°42'0.0"W/@47.1167,-122.7	13364	map
14237	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=No+Name+Key+%28northeast+of%29%2C+Florida+Current	13365	current
14238	https://www.google.com/maps/place/24°42'17.0"N+81°18'47.0"W/@24.705,-81.3133	13365	map
14239	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=No+Name+Key%2C+northeast+of%2C+Florida+Current	13366	current
14240	https://www.google.com/maps/place/24°42'17.0"N+81°18'47.0"W/@24.705,-81.3133	13366	map
14241	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Noank%2C+New+York+Current+%284d%29	13367	current
14242	https://www.google.com/maps/place/41°19'7.0"N+71°59'17.0"W/@41.3187,-71.9883	13367	map
14243	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Nobska+Point%2C+1+mile+southeast+of%2C+Massachusetts+Current	13368	current
14244	https://www.google.com/maps/place/41°30'6.0"N+70°38'35.0"W/@41.5017,-70.6433	13368	map
14245	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Nobska+Point%2C+1%2E8+miles+east+of%2C+Massachusetts+Current	13369	current
14246	https://www.google.com/maps/place/41°31'5.0"N+70°37'5.0"W/@41.5183,-70.6183	13369	map
14247	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Nodule+Point%2C+0%2E5+mile+southeast+of%2C+Washington+Current	13370	current
14248	https://www.google.com/maps/place/48°1'59.0"N+122°40'0.0"W/@48.0333,-122.6667	13370	map
14249	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Nodule+Pt%2C+0%2E5+mile+SE+of%2C+Washington+Current	13371	current
14250	https://www.google.com/maps/place/48°1'0.0"N+122°39'0.0"W/@48.0167,-122.65	13371	map
14251	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=North+Charleston%2C+Cooper+River%2C+South+Carolina+Current	13372	current
14252	https://www.google.com/maps/place/32°51'49.0"N+79°57'31.0"W/@32.8637,-79.9588	13372	map
14253	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=North+Edisto+River+entrance%2C+South+Carolina+Current	13373	current
14254	https://www.google.com/maps/place/32°33'42.0"N+80°11'12.0"W/@32.5617,-80.1867	13373	map
14255	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=North+end%2C+Quicks+Hole%2C+Massachusetts+Current	13374	current
14256	https://www.google.com/maps/place/41°27'6.0"N+70°50'59.0"W/@41.4517,-70.85	13374	map
14257	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=North+end%2C+Robinsons+Hole%2C+Massachusetts+Current	13375	current
14258	https://www.google.com/maps/place/41°27'24.0"N+70°48'42.0"W/@41.4567,-70.8117	13375	map
14259	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=North+end%2C+Woods+Hole%2C+Massachusetts+Current	13376	current
14260	https://www.google.com/maps/place/41°31'29.0"N+70°41'35.0"W/@41.525,-70.6933	13376	map
14261	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=North+Haven+Peninsula%2C+north+of%2C+New+York+Current	13377	current
14262	https://www.google.com/maps/place/41°2'28.0"N+72°19'14.0"W/@41.0412,-72.3208	13377	map
14263	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=North+Hill+Point%2C+1%2E1+miles+NNW+of%2C+New+York+Current	13378	current
14264	https://www.google.com/maps/place/41°17'34.0"N+72°1'40.0"W/@41.2928,-72.028	13378	map
14265	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=North+Inian+Pass%2C+Cross+Sound%2C+Alaska+Current	13379	current
14266	https://www.google.com/maps/place/58°16'59.0"N+136°22'59.0"W/@58.2833,-136.3833	13379	map
14267	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=North+Island%2C+California+Current+%2814d%29	13380	current
14268	https://www.google.com/maps/place/32°42'46.0"N+117°12'46.0"W/@32.713,-117.2128	13380	map
14269	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=North+Island%2C+California+Current+%2834d%29	13381	current
14270	https://www.google.com/maps/place/32°42'46.0"N+117°12'46.0"W/@32.713,-117.2128	13381	map
14271	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=North+Jetty%2C+0%2E8+mile+southeast+of%2C+South+Carolina+Current	13382	current
14272	https://www.google.com/maps/place/32°43'3.0"N+79°47'59.0"W/@32.7175,-79.8	13382	map
14273	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=North+of+Big+Tom+Creek+Entrance%2C+Bear+River%2C+Georgia+Current+%2810d%29	13383	current
14274	https://www.google.com/maps/place/31°46'59.0"N+81°9'37.0"W/@31.7833,-81.1603	13383	map
14275	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=North+Passage%2C+Alaska+Current	13384	current
14276	https://www.google.com/maps/place/58°19'0.0"N+136°7'0.0"W/@58.3167,-136.1167	13384	map
14277	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=North+Point%2C+2%2E5+miles+northeast+of%2C+Maryland+Current+%287d%29	13385	current
14278	https://www.google.com/maps/place/39°12'52.0"N+76°23'43.0"W/@39.2145,-76.3953	13385	map
14279	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=North+River+at+Darien+River%2C+Georgia+Current+%289d%29	13386	current
14280	https://www.google.com/maps/place/31°22'59.0"N+81°20'5.0"W/@31.3833,-81.335	13386	map
14281	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=North+Santee+River+entrance%2C+South+Carolina+Current+%286d%29	13387	current
14282	https://www.google.com/maps/place/33°8'8.0"N+79°14'26.0"W/@33.1358,-79.2408	13387	map
14283	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Northport+Bay+entrance+%28in+channel%29%2C+New+York+Current+%2815d%29	13388	current
14284	https://www.google.com/maps/place/40°54'31.0"N+73°24'26.0"W/@40.9088,-73.4075	13388	map
14285	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Northport+Bay%2C+south+of+Duck+I%2E+Bluff%2C+New+York+Current	13389	current
14286	https://www.google.com/maps/place/40°55'0.0"N+73°22'59.0"W/@40.9167,-73.3833	13389	map
14287	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Northwest+Channel%2C+Key+West%2C+Florida+Current	13390	current
14288	https://www.google.com/maps/place/24°34'59.0"N+81°50'53.0"W/@24.5833,-81.8483	13390	map
14289	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Northwest+Channel%2C+Key+West%2C+Florida+Current+%282%29	13391	current
14290	https://www.google.com/maps/place/24°37'18.0"N+81°52'47.0"W/@24.6217,-81.88	13391	map
14291	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Northwest+of+Newell+Creek+Entrance%2C+Bear+River%2C+Georgia+Current+%2810d%29	13392	current
14292	https://www.google.com/maps/place/31°44'55.0"N+81°9'55.0"W/@31.7488,-81.1655	13392	map
14293	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Norton+Point%2C+0%2E5+mile+north+of%2C+Massachusetts+Current	13393	current
14294	https://www.google.com/maps/place/41°28'5.0"N+70°39'54.0"W/@41.4683,-70.665	13393	map
14295	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Norwalk+River%2C+off+Gregory+Point%2C+Connecticut+Current+%2815d%29	13394	current
14296	https://www.google.com/maps/place/41°5'12.0"N+73°24'13.0"W/@41.0867,-73.4037	13394	map
14297	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Nowell+Creek+entrance%2C+Wando+River%2C+South+Carolina+Current	13395	current
14298	https://www.google.com/maps/place/32°52'41.0"N+79°52'30.0"W/@32.8783,-79.875	13395	map
14299	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Nushagak+Bay+entrance%2C+Alaska+Current	13396	current
14300	https://www.google.com/maps/place/58°34'0.0"N+158°25'0.0"W/@58.5667,-158.4167	13396	map
14301	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Oak+Neck+Point%2C+0%2E6+mile+north+of%2C+New+York+Current+%2815d%29	13397	current
14302	https://www.google.com/maps/place/40°55'29.0"N+73°34'1.0"W/@40.925,-73.567	13397	map
14412	https://www.google.com/maps/place/41°39'47.0"N+71°22'23.0"W/@41.6633,-71.3733	13452	map
14303	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Oak+Neck+Point%2C+0%2E6+mile+north+of%2C+New+York+Current+%2830d%29	13398	current
14304	https://www.google.com/maps/place/40°55'29.0"N+73°34'1.0"W/@40.925,-73.567	13398	map
14305	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Oakland+Airport+SW%2C+South+San+Francisco+Bay%2C+California+Current	13399	current
14306	https://www.google.com/maps/place/37°39'59.0"N+122°12'59.0"W/@37.666666,-122.2166	13399	map
14307	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Oakland+Harbor+High+Street+Bridge%2C+San+Francisco+Bay%2C+California+Current	13400	current
14308	https://www.google.com/maps/place/37°45'59.0"N+122°12'59.0"W/@37.766666,-122.2166	13400	map
14309	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Oakland+Harbor+WebStreeter+Street%2C+San+Francisco+Bay%2C+California+Current	13401	current
14310	https://www.google.com/maps/place/37°47'59.0"N+122°15'59.0"W/@37.8,-122.2666	13401	map
14311	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Oakland+Inner+Harbor+Entrance%2C+San+Francisco+Bay%2C+California+Current	13402	current
14312	https://www.google.com/maps/place/37°47'59.0"N+122°19'59.0"W/@37.8,-122.3333	13402	map
14313	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Oakland+Inner+Harbor+Reach%2C+33+ft%2E+below+datum+Current	13403	current
14314	https://www.google.com/maps/place/37°47'40.0"N+122°17'8.0"W/@37.7945,-122.28583333	13403	map
14315	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Oakland+Outer+Harbor+Entrance%2C+San+Francisco+Bay%2C+California+Current	13404	current
14316	https://www.google.com/maps/place/37°47'59.0"N+122°19'59.0"W/@37.8,-122.3333	13404	map
14317	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Oatland+Island%2C+north+tip%2C+Georgia+Current+%2810d%29	13405	current
14318	https://www.google.com/maps/place/32°4'23.0"N+81°0'36.0"W/@32.0733,-81.01	13405	map
14319	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Obstruction+Pass+Light%2C+0%2E4+mile+NW+of%2C+Washington+Current	13406	current
14320	https://www.google.com/maps/place/48°36'13.0"N+122°48'47.0"W/@48.6037,-122.8133	13406	map
14321	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Odingsell+River+Entrance%2C+Georgia+Current+%2810d%29	13407	current
14322	https://www.google.com/maps/place/31°52'5.0"N+81°0'0.0"W/@31.8683,-81.0	13407	map
14323	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Odingsell+River+Entrance%2C+Georgia+Current+%2820d%29	13408	current
14324	https://www.google.com/maps/place/31°52'5.0"N+81°0'0.0"W/@31.8683,-81.0	13408	map
14325	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Off+Jamaica+Point%2C+Maryland+Current	13409	current
14326	https://www.google.com/maps/place/38°36'34.0"N+75°58'58.0"W/@38.6097,-75.9828	13409	map
14327	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Off+Northeast+Cape%2C+St%2E+Lawrence+Island%2C+Alaska+Current	13410	current
14328	https://www.google.com/maps/place/63°19'59.0"N+168°49'59.0"W/@63.3333,-168.8333	13410	map
14329	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Off+Pleasant+Beach%2C+Rich+Passage%2C+Washington+Current	13411	current
14330	https://www.google.com/maps/place/47°34'59.0"N+122°31'59.0"W/@47.5833,-122.5333	13411	map
14331	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Off+Smith+Cove%2C+Thames+River%2C+Connecticut+Current+%285d%29	13412	current
14332	https://www.google.com/maps/place/41°23'58.0"N+72°5'10.0"W/@41.3997,-72.0863	13412	map
14333	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Off+Stoddard+Hill%2C+Thames+River%2C+Connecticut+Current+%2815d%29	13413	current
14334	https://www.google.com/maps/place/41°27'38.0"N+72°4'7.0"W/@41.4608,-72.0687	13413	map
14335	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Off+Winthrop+Ave%2E%2C+Astoria%2C+New+York+Current	13414	current
14336	https://www.google.com/maps/place/40°47'12.0"N+73°55'0.0"W/@40.7867,-73.9167	13414	map
14337	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ogliuga+Island%2C+pass+East+of%2C+Delarof+Is%2C+Alaska+Current	13415	current
14338	https://www.google.com/maps/place/51°37'0.0"N+178°35'59.0"W/@51.6167,-178.6	13415	map
14339	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Old+Field+Point%2C+1+mile+east+of%2C+New+York+Current+%2815d%29	13416	current
14340	https://www.google.com/maps/place/40°58'28.0"N+73°5'48.0"W/@40.9745,-73.0967	13416	map
14341	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Old+Field+Point%2C+1+mile+east+of%2C+New+York+Current+%2822d%29	13417	current
14342	https://www.google.com/maps/place/40°58'28.0"N+73°5'48.0"W/@40.9745,-73.0967	13417	map
14343	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Old+Field+Point%2C+2+miles+northeast+of%2C+New+York+Current+%2815d%29	13418	current
14344	https://www.google.com/maps/place/41°0'13.0"N+73°5'41.0"W/@41.0038,-73.095	13418	map
14345	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Old+Field+Point%2C+2+miles+northeast+of%2C+New+York+Current+%2840d%29	13419	current
14346	https://www.google.com/maps/place/41°0'13.0"N+73°5'41.0"W/@41.0038,-73.095	13419	map
14347	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Old+Field+Point%2C+2%2E9+n%2Emi%2E+NNW+of%2C+New+York+Current+%2815d%29	13420	current
14348	https://www.google.com/maps/place/41°1'19.0"N+73°8'22.0"W/@41.022,-73.1395	13420	map
14349	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Old+Harbor+Pt%2E%2C+0%2E5+mile+southeast+of%2C+Block+Island%2C+Rhode+Island+Current	13421	current
14350	https://www.google.com/maps/place/41°8'59.0"N+71°31'59.0"W/@41.15,-71.5333	13421	map
14351	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Old+Man+Shoal%2C+Nantucket+Shoals%2C+Massachusetts+Current	13422	current
14352	https://www.google.com/maps/place/41°13'36.0"N+69°58'59.0"W/@41.2267,-69.9833	13422	map
14353	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Old+Tampa+Bay+Entrance+%28Port+Tampa%29%2C+Florida+Current	13423	current
14354	https://www.google.com/maps/place/27°51'53.0"N+82°33'11.0"W/@27.865,-82.5533	13423	map
14355	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Old+Tampa+Bay+Entrance+%28Port+Tampa%29%2C+Florida+Current+%2815d%29	13424	current
14356	https://www.google.com/maps/place/27°51'53.0"N+82°33'13.0"W/@27.865,-82.5537	13424	map
14357	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Old+Teakettle+Creek+%28north%29%2C+Georgia+Current+%2813d%29	13425	current
14358	https://www.google.com/maps/place/31°28'41.0"N+81°19'41.0"W/@31.4783,-81.3283	13425	map
14359	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Old+Teakettle+Creek+%28south%29%2C+Georgia+Current+%2813d%29	13426	current
14360	https://www.google.com/maps/place/31°26'12.0"N+81°18'29.0"W/@31.4367,-81.3083	13426	map
14361	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Old+Teakettle+Creek+Entrance%2C+south+of%2C+Georgia+Current+%2815d%29	13427	current
14362	https://www.google.com/maps/place/31°25'12.0"N+81°18'53.0"W/@31.42,-81.315	13427	map
14363	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Old+Town+Point+Wharf%2C+northwest+of%2C+Maryland+Current+%2817d%29	13428	current
14364	https://www.google.com/maps/place/39°30'13.0"N+75°55'7.0"W/@39.5038,-75.9187	13428	map
14365	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Old+Town+Point+Wharf%2C+northwest+of%2C+Maryland+Current+%2829d%29	13429	current
14366	https://www.google.com/maps/place/39°30'13.0"N+75°55'7.0"W/@39.5038,-75.9187	13429	map
14367	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Olele+Point%2C+1%2E8+mile+ENE+of%2C+Washington+Current	13430	current
14368	https://www.google.com/maps/place/47°58'59.0"N+122°37'0.0"W/@47.9833,-122.6167	13430	map
14369	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Olele+Point%2C+1%2E8+miles+ENE+of%2C+Washington+Current	13431	current
14370	https://www.google.com/maps/place/47°58'59.0"N+122°37'59.0"W/@47.9833,-122.6333	13431	map
14371	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Onemile+Cut%2C+1+mile+southeast+of%2C+Georgia+Current	13432	current
14372	https://www.google.com/maps/place/31°18'47.0"N+81°21'6.0"W/@31.3133,-81.3517	13432	map
14373	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ordinary+Point%2C+0%2E4+mile+west+of%2C+Maryland+Current	13433	current
14374	https://www.google.com/maps/place/39°22'27.0"N+75°59'14.0"W/@39.3742,-75.9875	13433	map
14375	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ordnance+Reach%2C+Cooper+River%2C+South+Carolina+Current	13434	current
14376	https://www.google.com/maps/place/32°54'22.0"N+79°57'10.0"W/@32.9063,-79.9528	13434	map
14377	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Orient+Point%2C+1+mile+WNW+of%2C+New+York+Current	13435	current
14378	https://www.google.com/maps/place/41°10'1.0"N+72°15'6.0"W/@41.167,-72.2518	13435	map
14379	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Orient+Point%2C+2%2E4+miles+SSE+of%2C+New+York+Current	13436	current
14380	https://www.google.com/maps/place/41°7'30.0"N+72°12'17.0"W/@41.125,-72.205	13436	map
14381	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Otter+Point%2C+off+of%2C+north+side%2C+Alaska+Current	13437	current
14382	https://www.google.com/maps/place/55°4'0.0"N+163°46'59.0"W/@55.0667,-163.7833	13437	map
14383	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Oyster+Point+2%2E8+mi+E%2C+South+San+Francisco+Bay%2C+California+Current	13438	current
14384	https://www.google.com/maps/place/37°38'59.0"N+122°18'59.0"W/@37.65,-122.3166	13438	map
14385	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Oyster+Point%2C+California+Current	13439	current
14386	https://www.google.com/maps/place/37°39'53.0"N+122°19'23.0"W/@37.665,-122.3233	13439	map
14387	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pablo+Creek+bascule+bridge%2C+Florida+Current+%283d%29	13440	current
14388	https://www.google.com/maps/place/30°19'23.0"N+81°26'17.0"W/@30.3233,-81.4383	13440	map
14389	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Paradise+Point%2C+0%2E4+mile+east+of%2C+New+York+Current+%2813d%29	13441	current
14390	https://www.google.com/maps/place/41°2'52.0"N+72°22'34.0"W/@41.048,-72.3762	13441	map
14391	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Parker+Reef+Light%2C+0%2E5+mile+north+of%2C+Washington+Current	13442	current
14392	https://www.google.com/maps/place/48°43'58.0"N+122°53'24.0"W/@48.733,-122.89	13442	map
14393	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Parker+Reef+Light%2C+1+mile+North+of%2C+Washington+Current	13443	current
14394	https://www.google.com/maps/place/48°43'59.0"N+122°52'59.0"W/@48.7333,-122.8833	13443	map
14395	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Parris+Island+Lookout+Tower%2C+Broad+River%2C+South+Carolina+Current+%2815d%29	13444	current
14396	https://www.google.com/maps/place/32°18'42.0"N+80°42'24.0"W/@32.3117,-80.7067	13444	map
14397	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Parris+Island%2C+Beaufort+River%2C+South+Carolina+Current+%2810d%29	13445	current
14398	https://www.google.com/maps/place/32°19'36.0"N+80°39'24.0"W/@32.3267,-80.6567	13445	map
14399	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Parris+Island%2C+Beaufort+River%2C+South+Carolina+Current+%2815d%29	13446	current
14400	https://www.google.com/maps/place/32°21'35.0"N+80°40'29.0"W/@32.36,-80.675	13446	map
14401	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Parrot+Creek%2C+Coosaw+Island%2C+South+Carolina+Current+%2815d%29	13447	current
14402	https://www.google.com/maps/place/32°28'23.0"N+80°32'42.0"W/@32.4733,-80.545	13447	map
14403	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Parsonage+Point%2C+1%2E3+n%2Emi%2E+ESE+of%2C+New+York+Current+%2815d%29	13448	current
14404	https://www.google.com/maps/place/40°56'15.0"N+73°39'29.0"W/@40.9375,-73.6582	13448	map
14405	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pass+Abel%2C+Barataria+Bay%2C+Louisiana+Current	13449	current
14406	https://www.google.com/maps/place/29°17'42.0"N+89°54'11.0"W/@29.295,-89.9033	13449	map
14407	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pass%2Da%2DGrille+Channel%2C+Florida+Current	13450	current
14408	https://www.google.com/maps/place/27°41'5.0"N+82°44'5.0"W/@27.685,-82.735	13450	map
14409	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Passage+Key+Inlet+%28off+Bean+Pt%2E%29%2C+Florida+Current+%2815d%29	13451	current
14410	https://www.google.com/maps/place/27°32'21.0"N+82°44'51.0"W/@27.5393,-82.7477	13451	map
14411	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Patience+I%2E+and+Warwick+Neck%2C+between%2C+Rhode+Island+Current	13452	current
14413	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Patience+Island%2C+narrows+east+of%2C+Rhode+Island+Current	13453	current
14414	https://www.google.com/maps/place/41°39'29.0"N+71°21'11.0"W/@41.6583,-71.3533	13453	map
14415	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Patos+Island+Light%2C+1%2E4+miles+W+of%2C+Washington+Current	13454	current
14416	https://www.google.com/maps/place/47°46'59.0"N+123°0'0.0"W/@47.7833,-123.0	13454	map
14417	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Patos+Island+Light%2C+1%2E4+miles+west+of%2C+Washington+Current	13455	current
14418	https://www.google.com/maps/place/48°47'19.0"N+123°0'11.0"W/@48.7888,-123.0033	13455	map
14419	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Peale+Passage%2C+north+end%2C+Washington+Current	13456	current
14420	https://www.google.com/maps/place/47°13'20.0"N+122°55'13.0"W/@47.2225,-122.9203	13456	map
14421	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Peale+Passage%2C+North+end%2C+Washington+Current	13457	current
14422	https://www.google.com/maps/place/47°13'0.0"N+122°55'0.0"W/@47.2167,-122.9167	13457	map
14423	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Peapod+Rocks+Light%2C+1%2E2+mile+South+of%2C+Washington+Current	13458	current
14424	https://www.google.com/maps/place/48°37'0.0"N+122°43'59.0"W/@48.6167,-122.7333	13458	map
14425	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Peapod+Rocks+Light%2C+1%2E2+miles+south+of%2C+Washington+Current	13459	current
14426	https://www.google.com/maps/place/48°37'19.0"N+122°44'49.0"W/@48.6222,-122.7472	13459	map
14427	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pear+Point%2C+1%2E1+miles+east+of%2C+Washington+Current	13460	current
14428	https://www.google.com/maps/place/48°30'40.0"N+122°57'10.0"W/@48.5113,-122.9528	13460	map
14429	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pear+Point%2C+San+Juan+Island%2C+1%2E1+mile+East+of%2C+Washington+Current	13461	current
14430	https://www.google.com/maps/place/48°31'0.0"N+122°57'0.0"W/@48.5167,-122.95	13461	map
14431	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Peavine+Pass%2C+West+Entrance+of%2C+Washington+Current	13462	current
14432	https://www.google.com/maps/place/48°34'59.0"N+122°49'0.0"W/@48.5833,-122.8167	13462	map
14433	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Peavine+Pass%2C+west+entrance%2C+Washington+Current	13463	current
14434	https://www.google.com/maps/place/48°35'13.0"N+122°49'11.0"W/@48.587,-122.82	13463	map
14435	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pee+Dee+River%2C+swing+bridge%2C+South+Carolina+Current	13464	current
14436	https://www.google.com/maps/place/33°22'13.0"N+79°15'49.0"W/@33.3705,-79.2638	13464	map
14437	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pelican+Bank%2C+St%2E+Helena+Sound%2C+South+Carolina+Current+%2815d%29	13465	current
14438	https://www.google.com/maps/place/32°27'17.0"N+80°25'41.0"W/@32.455,-80.4283	13465	map
14439	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Penikese+Island%2C+0%2E2+mile+south+of%2C+Massachusetts+Current	13466	current
14440	https://www.google.com/maps/place/41°26'35.0"N+70°55'29.0"W/@41.4433,-70.925	13466	map
14441	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Penikese+Island%2C+0%2E8+mile+northwest+of%2C+Massachusetts+Current	13467	current
14442	https://www.google.com/maps/place/41°27'54.0"N+70°56'12.0"W/@41.465,-70.9367	13467	map
14443	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Peningo+Neck%2C+0%2E6+mi%2E+off+Parsonage+Pt%2C+New+York+Current+%2815d%29	13468	current
14444	https://www.google.com/maps/place/40°56'19.0"N+73°40'29.0"W/@40.9387,-73.675	13468	map
14445	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pensacola+Bay+entrance%2C+midchannel%2C+Florida+Current	13469	current
14446	https://www.google.com/maps/place/30°20'6.0"N+87°17'59.0"W/@30.335,-87.3	13469	map
14447	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Persimmon+Point%2C+Maryland+Current	13470	current
14448	https://www.google.com/maps/place/38°22'5.0"N+76°59'23.0"W/@38.3683,-76.99	13470	map
14449	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Petaluma+River+Approach+%233%2F%234%2C+San+Pablo+Bay%2C+California+Current	13471	current
14450	https://www.google.com/maps/place/38°2'59.0"N+122°24'59.0"W/@38.05,-122.4166	13471	map
14451	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Petaluma+River+Approach%2C+San+Pablo+Bay%2C+California+Current	13472	current
14452	https://www.google.com/maps/place/38°3'59.0"N+122°24'59.0"W/@38.066666,-122.4166	13472	map
14453	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Philadelphia%2C+Pennsylvania+Current	13473	current
14454	https://www.google.com/maps/place/39°57'0.0"N+75°7'59.0"W/@39.95,-75.1333	13473	map
14455	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pickering+Passage%2C+north+end%2C+Washington+Current	13474	current
14456	https://www.google.com/maps/place/47°18'20.0"N+122°51'2.0"W/@47.3058,-122.8508	13474	map
14457	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pickering+Passage%2C+North%2C+Washington+Current	13475	current
14458	https://www.google.com/maps/place/47°17'59.0"N+122°50'59.0"W/@47.3,-122.85	13475	map
14459	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pickering+Passage%2C+off+Graham+Point%2C+Washington+Current	13476	current
14460	https://www.google.com/maps/place/47°14'53.0"N+122°55'31.0"W/@47.2483,-122.9255	13476	map
14461	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pickering+Passage%2C+off+Graham+Pt%2C+Washington+Current	13477	current
14462	https://www.google.com/maps/place/47°15'0.0"N+122°55'59.0"W/@47.25,-122.9333	13477	map
14463	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pickering+Passage%2C+south+end%2C+Washington+Current	13478	current
14464	https://www.google.com/maps/place/47°13'10.0"N+122°56'4.0"W/@47.2195,-122.9347	13478	map
14465	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pickering+Passage%2C+South%2C+Washington+Current	13479	current
14466	https://www.google.com/maps/place/47°13'0.0"N+122°55'59.0"W/@47.2167,-122.9333	13479	map
14467	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pier+67%2C+off+19th+Street%2C+New+York+Current	13480	current
14468	https://www.google.com/maps/place/40°43'59.0"N+73°58'0.0"W/@40.7333,-73.9667	13480	map
14469	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pigeon+Island%2C+SSE+of%2C+Skidaway+River%2C+Georgia+Current+%2810d%29	13481	current
14470	https://www.google.com/maps/place/31°56'12.0"N+81°4'36.0"W/@31.9367,-81.0767	13481	map
14471	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pillar+Point%2C+Washington+Current	13482	current
14472	https://www.google.com/maps/place/48°16'0.0"N+124°4'0.0"W/@48.2667,-124.0667	13482	map
14473	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pine+Creek+Point%2C+2%2E3+miles+SSE+of%2C+Connecticut+Current+%2815d%29	13483	current
14474	https://www.google.com/maps/place/41°5'3.0"N+73°14'23.0"W/@41.0842,-73.24	13483	map
14475	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pine+Island%2C+South+Edisto+River%2C+South+Carolina+Current+%2815d%29	13484	current
14476	https://www.google.com/maps/place/32°30'24.0"N+80°21'42.0"W/@32.5067,-80.3617	13484	map
14477	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pine+Key+%28Pinellas+Bayway+bridge%29%2C+Florida+Current	13485	current
14478	https://www.google.com/maps/place/27°41'32.0"N+82°43'1.0"W/@27.6925,-82.7172	13485	map
14479	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Piney+Point%2C+0%2E6+mile+NNW+of%2C+Florida+Current	13486	current
14480	https://www.google.com/maps/place/27°39'13.0"N+82°33'43.0"W/@27.6537,-82.5622	13486	map
14481	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pinole+Point+1%2E2+mi+W%2C+San+Pablo+Bay%2C+California+Current	13487	current
14482	https://www.google.com/maps/place/38°0'59.0"N+122°21'59.0"W/@38.016666,-122.3666	13487	map
14483	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pitt+Passage%2C+E+of+Pitt+Island%2C+Washington+Current	13488	current
14484	https://www.google.com/maps/place/47°13'0.0"N+122°43'0.0"W/@47.2167,-122.7167	13488	map
14485	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pitt+Passage%2C+east+of+Pitt+Island%2C+Washington+Current	13489	current
14486	https://www.google.com/maps/place/47°13'25.0"N+122°42'56.0"W/@47.2237,-122.7158	13489	map
14487	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pleasant+Island%2C+3+miles+south+of%2C+Alaska+Current	13490	current
14488	https://www.google.com/maps/place/58°16'59.0"N+135°34'59.0"W/@58.2833,-135.5833	13490	map
14489	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pleasant+Point%2C+South+Carolina+Current+%2812d%29	13491	current
14490	https://www.google.com/maps/place/32°45'0.0"N+80°7'59.0"W/@32.75,-80.1333	13491	map
14491	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Plum+Gut%2C+New+York+Current+%2830d%29	13492	current
14492	https://www.google.com/maps/place/41°9'54.0"N+72°12'45.0"W/@41.1652,-72.2125	13492	map
14493	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Plum+Island%2C+0%2E8+mile+NNW+of%2C+New+York+Current	13493	current
14494	https://www.google.com/maps/place/41°11'52.0"N+72°11'55.0"W/@41.1978,-72.1987	13493	map
14495	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Plum+Point%2C+1%2E4+miles+ESE+of%2C+Maryland+Current	13494	current
14496	https://www.google.com/maps/place/38°36'44.0"N+76°28'39.0"W/@38.6125,-76.4775	13494	map
14497	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Plum+Point%2C+2%2E1+n%2Emi%2E+NNE+of%2C+Maryland+Current+%2815d%29	13495	current
14498	https://www.google.com/maps/place/38°38'42.0"N+76°29'13.0"W/@38.645,-76.4872	13495	map
14499	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Adams%2C+NNE+OF%2C+Oregon+Current+%2814d%29	13496	current
14500	https://www.google.com/maps/place/46°13'40.0"N+123°58'3.0"W/@46.2278,-123.9675	13496	map
14501	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Arena%2C+California+Current	13497	current
14502	https://www.google.com/maps/place/38°57'0.0"N+123°45'0.0"W/@38.95,-123.75	13497	map
14503	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Arguello%2C+California+Current	13498	current
14504	https://www.google.com/maps/place/34°34'0.0"N+120°40'0.0"W/@34.5667,-120.6667	13498	map
14505	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Avisadero+%2E3+mi+E%2C+South+San+Francisco+Bay%2C+California+Current	13499	current
14506	https://www.google.com/maps/place/37°42'59.0"N+122°19'59.0"W/@37.716666,-122.3333	13499	map
14507	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Avisadero+1+mi+E%2C+South+San+Francisco+Bay%2C+California+Current	13500	current
14508	https://www.google.com/maps/place/37°42'59.0"N+122°19'59.0"W/@37.716666,-122.3333	13500	map
14509	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Avisadero+2+mi+E%2C+South+San+Francisco+Bay%2C+California+Current	13501	current
14510	https://www.google.com/maps/place/37°42'59.0"N+122°17'59.0"W/@37.716666,-122.3	13501	map
14511	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Blunt+%2E3+mi+S%2C+San+Francisco+Bay%2C+California+Current	13502	current
14512	https://www.google.com/maps/place/37°49'59.0"N+122°24'59.0"W/@37.833333,-122.4166	13502	map
14513	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Blunt+%2E8+mi+SE%2C+San+Francisco+Bay%2C+California+Current	13503	current
14514	https://www.google.com/maps/place/37°49'59.0"N+122°24'0.0"W/@37.833333,-122.4	13503	map
14515	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Bonita+Lt%2E%2C+0%2E4+nmi%2E+SSE+of%2C+California+Current+%2843d%29	13504	current
14516	https://www.google.com/maps/place/37°48'43.0"N+122°31'16.0"W/@37.812,-122.5212	13504	map
14517	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Bonita+Lt%2E%2C+5%2E27+nmi%2E+WSW+of%2C+California+Current+%2839d%29	13505	current
14518	https://www.google.com/maps/place/37°48'16.0"N+122°38'19.0"W/@37.8045,-122.6388	13505	map
14519	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Bonita%2C+0%2E8+nmi%2E+NE+of%2C+California+Current+%2822d%29	13506	current
14520	https://www.google.com/maps/place/37°49'14.0"N+122°30'58.0"W/@37.8208,-122.5162	13506	map
14521	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Bonita%2C+0%2E8+nmi%2E+NE+of%2C+California+Current+%2841d%29	13507	current
14522	https://www.google.com/maps/place/37°49'14.0"N+122°30'58.0"W/@37.8208,-122.5162	13507	map
14523	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Bonita%2C+0%2E95+nmi%2E+SSE+of%2C+California+Current+%2822d%29	13508	current
14524	https://www.google.com/maps/place/37°48'4.0"N+122°31'7.0"W/@37.8012,-122.5188	13508	map
14525	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Bonita%2C+0%2E95+nmi%2E+SSE+of%2C+California+Current+%2842d%29	13509	current
14526	https://www.google.com/maps/place/37°48'4.0"N+122°31'7.0"W/@37.8012,-122.5188	13509	map
14527	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Cabrillo%2C+California+Current	13510	current
14528	https://www.google.com/maps/place/39°21'0.0"N+123°49'59.0"W/@39.35,-123.8333	13510	map
14529	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Cavallo+1%2E3+mi+E%2C+San+Francisco+Bay%2C+California+Current	13511	current
14530	https://www.google.com/maps/place/37°48'59.0"N+122°25'59.0"W/@37.816666,-122.4333	13511	map
14531	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Delgada%2C+California+Current	13512	current
14532	https://www.google.com/maps/place/40°0'0.0"N+124°4'0.0"W/@40.0,-124.0667	13512	map
14533	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Diablo%2C+0%2E2+mile+SE+of%2C+California+Current	13513	current
14534	https://www.google.com/maps/place/37°49'4.0"N+122°29'48.0"W/@37.8178,-122.4967	13513	map
14535	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Disney%2C+1%2E6+mile+East+of%2C+Washington+Current	13514	current
14536	https://www.google.com/maps/place/48°40'0.0"N+123°1'0.0"W/@48.6667,-123.0167	13514	map
14537	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Disney%2C+1%2E6+miles+east+of%2C+Washington+Current	13515	current
14538	https://www.google.com/maps/place/48°40'22.0"N+123°0'22.0"W/@48.6728,-123.0062	13515	map
14539	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Ellice%2C+east+of%2C+Washington+Current+%2817d%29	13516	current
14540	https://www.google.com/maps/place/46°14'30.0"N+123°50'53.0"W/@46.2417,-123.8483	13516	map
14541	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Gammon%2C+1%2E2+miles+south+of%2C+Massachusetts+Current	13517	current
14542	https://www.google.com/maps/place/41°35'17.0"N+70°15'24.0"W/@41.5883,-70.2567	13517	map
14543	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Hammond%2C+1%2E1+miles+northwest+of%2C+Washington+Current	13518	current
14544	https://www.google.com/maps/place/48°43'55.0"N+123°1'31.0"W/@48.732,-123.0253	13518	map
14545	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Hammond%2C+1%2E1+miles+NW+of%2C+Washington+Current	13519	current
14546	https://www.google.com/maps/place/48°43'59.0"N+123°1'59.0"W/@48.7333,-123.0333	13519	map
14547	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Hudson%2C+0%2E5+mile+E+of%2C+Washington+Current	13520	current
14548	https://www.google.com/maps/place/48°7'0.0"N+122°43'0.0"W/@48.1167,-122.7167	13520	map
14549	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Hudson%2C+0%2E5+mile+east+of%2C+Washington+Current	13521	current
14550	https://www.google.com/maps/place/48°7'0.0"N+122°43'59.0"W/@48.1167,-122.7333	13521	map
14551	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Lobos%2C+1%2E3+nmi%2E+SW+of%2C+California+Current+%2846d%29	13522	current
14552	https://www.google.com/maps/place/37°46'18.0"N+122°32'7.0"W/@37.7717,-122.5355	13522	map
14553	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Lobos%2C+3%2E73+nmi%2E+W+of%2C+California+Current+%2846d%29	13523	current
14554	https://www.google.com/maps/place/37°47'15.0"N+122°35'19.0"W/@37.7875,-122.5887	13523	map
14555	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Loma+Light%2C+0%2E8+nmi%2E+east+of%2C+California+Current+%2815d%29	13524	current
14556	https://www.google.com/maps/place/32°39'56.0"N+117°13'34.0"W/@32.6658,-117.2262	13524	map
14557	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Loma+Light%2C+0%2E8+nmi%2E+east+of%2C+California+Current+%2833d%29	13525	current
14558	https://www.google.com/maps/place/32°39'56.0"N+117°13'34.0"W/@32.6658,-117.2262	13525	map
14559	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+No+Point%2C+2%2E1+miles+south+of%2C+Connecticut+Current+%2815d%29	13526	current
14560	https://www.google.com/maps/place/41°6'44.0"N+73°7'7.0"W/@41.1125,-73.1188	13526	map
14561	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Partridge%2C+3%2E7+miles+W+of%2C+Washington+Current	13527	current
14562	https://www.google.com/maps/place/48°13'59.0"N+122°52'0.0"W/@48.2333,-122.8667	13527	map
14563	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Partridge%2C+3%2E7+miles+west+of%2C+Washington+Current	13528	current
14564	https://www.google.com/maps/place/48°13'59.0"N+122°52'0.0"W/@48.2333,-122.8667	13528	map
14565	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Patience%2C+0%2E1+mile+southwest+of%2C+Maryland+Current+%2815d%29	13529	current
14566	https://www.google.com/maps/place/38°19'41.0"N+76°29'12.0"W/@38.3283,-76.4867	13529	map
14567	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Peter%2C+North+Carolina+Current+%286d%29	13530	current
14568	https://www.google.com/maps/place/34°14'31.0"N+77°57'29.0"W/@34.2422,-77.9583	13530	map
14569	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Piedras+Blancas%2C+California+Current	13531	current
14570	https://www.google.com/maps/place/35°40'0.0"N+121°17'59.0"W/@35.6667,-121.3	13531	map
14571	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Pinos%2C+California+Current	13532	current
14572	https://www.google.com/maps/place/36°37'59.0"N+121°57'0.0"W/@36.6333,-121.95	13532	map
14573	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Retreat%2C+1+mile+west+of%2C+Alaska+Current	13533	current
14574	https://www.google.com/maps/place/58°25'0.0"N+134°58'0.0"W/@58.4167,-134.9667	13533	map
14575	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Reyes%2C+California+Current	13534	current
14576	https://www.google.com/maps/place/38°0'0.0"N+123°1'59.0"W/@38.0,-123.0333	13534	map
14577	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Richmond+%2E5+mi+W%2C+San+Francisco+Bay%2C+California+Current	13535	current
14578	https://www.google.com/maps/place/37°53'59.0"N+122°24'0.0"W/@37.9,-122.4	13535	map
14579	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Sacramento+%2E3+mi+NE%2C+Sacramento+River%2C+California+Current	13536	current
14580	https://www.google.com/maps/place/38°3'59.0"N+121°49'59.0"W/@38.066666,-121.8333	13536	map
14581	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+San+Luis%2C+California+Current	13537	current
14582	https://www.google.com/maps/place/35°8'59.0"N+120°46'0.0"W/@35.15,-120.7667	13537	map
14583	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+San+Pablo+Midchannel%2C+San+Pablo+Bay%2C+California+Current	13538	current
14584	https://www.google.com/maps/place/37°57'59.0"N+122°25'59.0"W/@37.966666,-122.4333	13538	map
14585	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+San+Quentin+1%2E9+mi+E%2C+San+Francisco+Bay%2C+California+Current	13539	current
14586	https://www.google.com/maps/place/37°57'0.0"N+122°25'59.0"W/@37.95,-122.4333	13539	map
14587	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Sur%2C+California+Current	13540	current
14588	https://www.google.com/maps/place/36°17'59.0"N+121°55'0.0"W/@36.3,-121.9167	13540	map
14589	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Wilson%2C+0%2E5+mi%2E%2C+northeast+of%2C+Washington+Current	13541	current
14590	https://www.google.com/maps/place/48°8'59.0"N+122°45'0.0"W/@48.15,-122.75	13541	map
14591	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Wilson%2C+0%2E5+miles+NE+of%2C+Washington+Current	13542	current
14592	https://www.google.com/maps/place/48°8'59.0"N+122°45'0.0"W/@48.15,-122.75	13542	map
14593	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Wilson%2C+0%2E8+mile+east+of%2C+Washington+Current	13543	current
14594	https://www.google.com/maps/place/48°8'59.0"N+122°43'59.0"W/@48.15,-122.7333	13543	map
14595	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Wilson%2C+0%2E8+miles+east+of%2C+Washington+Current	13544	current
14596	https://www.google.com/maps/place/48°8'59.0"N+122°43'59.0"W/@48.15,-122.7333	13544	map
14597	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Wilson%2C+1%2E1+miles+NW+of%2C+Washington+Current	13545	current
14598	https://www.google.com/maps/place/48°10'0.0"N+122°46'0.0"W/@48.1667,-122.7667	13545	map
14599	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Wilson%2C+1%2E4+miles+NE+of%2C+Washington+Current	13546	current
14600	https://www.google.com/maps/place/48°10'0.0"N+122°43'59.0"W/@48.1667,-122.7333	13546	map
14601	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Wilson%2C+1%2E4+miles+northeast+of%2C+Washington+Current	13547	current
14602	https://www.google.com/maps/place/48°10'0.0"N+122°43'59.0"W/@48.1667,-122.7333	13547	map
14603	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Wilson%2C+2%2E3+miles+NE+of%2C+Washington+Current	13548	current
14604	https://www.google.com/maps/place/48°10'0.0"N+122°42'0.0"W/@48.1667,-122.7	13548	map
14605	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Ybel+%280%2E4+Mi%2E+NW+of%29%2C+Florida+Current	13549	current
14606	https://www.google.com/maps/place/26°27'24.0"N+82°1'5.0"W/@26.4567,-82.0183	13549	map
14607	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Point+Ybel%2C+0%2E4+mile+northwest+of%2C+Florida+Current	13550	current
14608	https://www.google.com/maps/place/26°27'24.0"N+82°1'7.0"W/@26.4567,-82.0187	13550	map
14609	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pollock+Rip+Channel+%28Butler+Hole%29%2C+Massachusetts+Current	13551	current
14610	https://www.google.com/maps/place/41°32'59.0"N+69°58'59.0"W/@41.55,-69.9833	13551	map
14611	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pollock+Rip+Channel%2C+east+end%2C+Massachusetts+Current	13552	current
14612	https://www.google.com/maps/place/41°33'53.0"N+69°55'23.0"W/@41.565,-69.9233	13552	map
14613	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pollock+Rip+Channel%2C+Massachusetts+Current	13553	current
14614	https://www.google.com/maps/place/41°32'48.0"N+69°59'5.0"W/@41.5467,-69.985	13553	map
14615	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pond+entrance%2C+Point+Judith%2C+Rhode+Island+Current	13554	current
14616	https://www.google.com/maps/place/41°22'59.0"N+71°31'0.0"W/@41.3833,-71.5167	13554	map
14617	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pond+Point%2C+4%2E2+miles+SSE+of%2C+Connecticut+Current	13555	current
14618	https://www.google.com/maps/place/41°8'35.0"N+72°58'4.0"W/@41.1433,-72.968	13555	map
14619	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pooles+Island+2%2E0+n%2Emi%2E+SSW+of%2C+Maryland+Current+%2815d%29	13556	current
14620	https://www.google.com/maps/place/39°14'46.0"N+76°17'48.0"W/@39.2463,-76.2967	13556	map
14621	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pooles+Island%2C+0%2E8+mile+south+of%2C+Maryland+Current	13557	current
14622	https://www.google.com/maps/place/39°15'42.0"N+76°16'23.0"W/@39.2617,-76.2733	13557	map
14623	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pooles+Island%2C+1%2E6+n%2Emi%2E+east+of%2C+Maryland+Current+%2816d%29	13558	current
14624	https://www.google.com/maps/place/39°16'28.0"N+76°13'34.0"W/@39.2745,-76.2262	13558	map
14625	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Pooles+Island%2C+4+miles+southwest+of%2C+Maryland+Current	13559	current
14626	https://www.google.com/maps/place/39°13'36.0"N+76°19'52.0"W/@39.2267,-76.3313	13559	map
14627	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Poplar+Island%2C+2%2E2+n%2Emi%2E+WSW+of%2C+Maryland+Current+%2814d%29	13560	current
14628	https://www.google.com/maps/place/38°45'22.0"N+76°25'46.0"W/@38.7562,-76.4295	13560	map
14629	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Poplar+Island%2C+3%2E0+n%2Emi%2E+WSW+of%2C+Maryland+Current+%2815d%29	13561	current
14630	https://www.google.com/maps/place/38°44'58.0"N+76°26'43.0"W/@38.7497,-76.4455	13561	map
14631	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Poplar+Island%2C+3%2E0+n%2Emi%2E+WSW+of%2C+Maryland+Current+%2848d%29	13562	current
14632	https://www.google.com/maps/place/38°44'58.0"N+76°26'43.0"W/@38.7497,-76.4455	13562	map
14633	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Poplar+Island%2C+east+of+south+end%2C+Maryland+Current	13563	current
14634	https://www.google.com/maps/place/38°44'53.0"N+76°21'11.0"W/@38.7483,-76.3533	13563	map
14635	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Poplar+Point%2C+south+of%2C+Maryland+Current	13564	current
14636	https://www.google.com/maps/place/38°40'31.0"N+75°57'58.0"W/@38.6753,-75.9663	13564	map
14637	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Popof+Strait%2C+Alaska+Current	13565	current
14638	https://www.google.com/maps/place/55°19'59.0"N+160°31'0.0"W/@55.3333,-160.5167	13565	map
14639	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Porlier+Pass%2C+British+Columbia+Current	13566	current
14640	https://www.google.com/maps/place/49°0'54.0"N+123°35'5.0"W/@49.015,-123.585	13566	map
14641	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Port+Gamble+Bay+entrance%2C+Washington+Current	13567	current
14642	https://www.google.com/maps/place/47°51'16.0"N+122°34'37.0"W/@47.8545,-122.5772	13567	map
14643	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Port+Gamble+Bay%2C+Washington+Current	13568	current
14644	https://www.google.com/maps/place/47°58'59.0"N+122°32'59.0"W/@47.9833,-122.55	13568	map
14645	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Port+Heiden%2C+Alaska+Current	13569	current
14646	https://www.google.com/maps/place/56°58'59.0"N+158°52'59.0"W/@56.9833,-158.8833	13569	map
14647	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Port+Ingleside%2C+Texas+Current+%285d%29	13570	current
14648	https://www.google.com/maps/place/27°48'54.0"N+97°13'48.0"W/@27.815,-97.23	13570	map
14649	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Port+Jefferson+Harbor+entrance%2C+New+York+Current	13571	current
14650	https://www.google.com/maps/place/40°58'0.0"N+73°5'59.0"W/@40.9667,-73.1	13571	map
14651	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Port+Manatee+Channel+entrance%2C+Florida+Current+%2815d%29	13572	current
14652	https://www.google.com/maps/place/27°39'43.0"N+82°35'57.0"W/@27.662,-82.5992	13572	map
14653	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Port+Manatee+Channel%2C+marker+%274%27%2C+Florida+Current+%2815d%29	13573	current
14654	https://www.google.com/maps/place/27°39'12.0"N+82°35'23.0"W/@27.6535,-82.5898	13573	map
14655	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Port+Manatee%2C+Tampa+Bay%2C+Florida+Current	13574	current
14656	https://www.google.com/maps/place/27°39'42.0"N+82°35'59.0"W/@27.6617,-82.6	13574	map
14657	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Port+Royal+Plantation+Tower%2C+east+of%2C+South+Carolina+Current+%2815d%29	13575	current
14658	https://www.google.com/maps/place/32°13'23.0"N+80°39'24.0"W/@32.2233,-80.6567	13575	map
14659	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Port+Townsend+Canal%2C+Washington+Current	13576	current
14660	https://www.google.com/maps/place/48°1'59.0"N+122°43'59.0"W/@48.0333,-122.7333	13576	map
14661	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Port+Townsend%2C+0%2E5+miles+S+of+Point+Hudson%2C+Washington+Current	13577	current
14662	https://www.google.com/maps/place/48°7'0.0"N+122°43'59.0"W/@48.1167,-122.7333	13577	map
14663	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Port+Washington+Narrows%2C+north+ent%2C+Washington+Current	13578	current
14664	https://www.google.com/maps/place/47°36'4.0"N+122°39'42.0"W/@47.6013,-122.6617	13578	map
14665	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Port+Washington+Narrows%2C+North+Entrance+of%2C+Washington+Current	13579	current
14666	https://www.google.com/maps/place/47°34'0.0"N+122°37'0.0"W/@47.5667,-122.6167	13579	map
14667	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Port+Washington+Narrows%2C+south+ent%2C+Washington+Current	13580	current
14668	https://www.google.com/maps/place/47°34'0.0"N+122°37'0.0"W/@47.5667,-122.6167	13580	map
14669	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Port+Washington+Narrows%2C+South+Entrance+of%2C+Washington+Current	13581	current
14670	https://www.google.com/maps/place/47°34'59.0"N+122°34'0.0"W/@47.5833,-122.5667	13581	map
14671	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Port+Wentworth%2C+0%2E2+mile+above%2C+Georgia+Current	13582	current
14672	https://www.google.com/maps/place/32°8'48.0"N+81°8'24.0"W/@32.1467,-81.14	13582	map
14673	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Portsmouth+Harbor+Entrance%2C+New+Hampshire+Current	13583	current
14674	https://www.google.com/maps/place/43°4'0.0"N+70°42'0.0"W/@43.0667,-70.7	13583	map
14675	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Potomac+River+Bridge%2C+0%2E4+mile+south+of%2C+Maryland+Current	13584	current
14676	https://www.google.com/maps/place/38°21'22.0"N+76°59'12.0"W/@38.3563,-76.9867	13584	map
14677	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Potrero+Point+1%2E1+mi+E%2C+South+San+Francisco+Bay%2C+California+Current	13585	current
14678	https://www.google.com/maps/place/37°45'0.0"N+122°20'59.0"W/@37.75,-122.35	13585	map
14679	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=President+Point%2C+1%2E5+mile+E+of%2C+Washington+Current	13586	current
14680	https://www.google.com/maps/place/47°46'0.0"N+122°25'0.0"W/@47.7667,-122.4167	13586	map
14681	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Princess+Louisa+Inlet%2C+British+Columbia+Current	13587	current
14682	https://www.google.com/maps/place/50°10'0.0"N+123°50'59.0"W/@50.1667,-123.85	13587	map
14683	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Protection+Point%2C+2%2E5+miles+east+of%2C+Alaska+Current	13588	current
14684	https://www.google.com/maps/place/58°30'0.0"N+158°37'0.0"W/@58.5,-158.6167	13588	map
14685	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Puffin+Island+light%2C+4%2E8+miles+N+of%2C+Washington+Current	13589	current
14686	https://www.google.com/maps/place/47°49'0.0"N+122°47'59.0"W/@47.8167,-122.8	13589	map
14687	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Puffin+Island+Light%2C+4%2E8+miles+north+of%2C+Washington+Current	13590	current
14688	https://www.google.com/maps/place/48°49'19.0"N+122°48'29.0"W/@48.8222,-122.8083	13590	map
14689	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Punta+Gorda%2C+California+Current	13591	current
14690	https://www.google.com/maps/place/40°15'0.0"N+124°22'0.0"W/@40.25,-124.3667	13591	map
14691	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Punta+Ostiones%2C+1%2E5+miles+west+of%2C+Puerto+Rico+Current	13592	current
14692	https://www.google.com/maps/place/18°5'12.0"N+67°13'36.0"W/@18.0867,-67.2267	13592	map
14693	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Quantico+Creek+entrance%2C+Virginia+Current	13593	current
14694	https://www.google.com/maps/place/38°31'41.0"N+77°17'17.0"W/@38.5283,-77.2883	13593	map
14695	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Quantico%2C+Virginia+Current	13594	current
14696	https://www.google.com/maps/place/38°31'18.0"N+77°16'36.0"W/@38.5217,-77.2767	13594	map
14697	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Quarantine+Station%2C+La+Playa%2C+California+Current	13595	current
14698	https://www.google.com/maps/place/32°42'0.0"N+117°13'59.0"W/@32.7,-117.2333	13595	map
14699	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Quatre+Bayoux+Pass%2C+Barataria+Bay%2C+Louisiana+Current	13596	current
14700	https://www.google.com/maps/place/29°18'35.0"N+89°51'6.0"W/@29.31,-89.8517	13596	map
14701	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Quatsino+Narrows%2C+British+Columbia+Current	13597	current
14702	https://www.google.com/maps/place/50°33'17.0"N+127°33'18.0"W/@50.555,-127.555	13597	map
14703	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Quicks+Hole+%28middle%29%2C+Massachusetts+Current	13598	current
14704	https://www.google.com/maps/place/41°26'35.0"N+70°50'53.0"W/@41.4433,-70.8483	13598	map
14705	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Quillayute+River+entrance%2C+Washington+Current	13599	current
14706	https://www.google.com/maps/place/47°55'0.0"N+124°37'59.0"W/@47.9167,-124.6333	13599	map
14707	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Quinn+Island%2C+Prairie+Channel%2C+Washington+Current+%288d%29	13600	current
14708	https://www.google.com/maps/place/46°14'13.0"N+123°30'11.0"W/@46.2372,-123.5033	13600	map
14709	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Quonochontaug+Beach%2C+1%2E1+miles+S+of%2C+Rhode+Island+Current	13601	current
14710	https://www.google.com/maps/place/41°18'47.0"N+71°42'49.0"W/@41.3133,-71.7137	13601	map
14711	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Quonochontaug+Beach%2C+3%2E8+miles+S+of%2C+Rhode+Island+Current+%2815d%29	13602	current
14712	https://www.google.com/maps/place/41°16'21.0"N+71°43'0.0"W/@41.2725,-71.7167	13602	map
14713	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rabbit+Island%2C+northwest+of%2C+South+Carolina+Current	13603	current
14714	https://www.google.com/maps/place/33°20'22.0"N+79°16'52.0"W/@33.3395,-79.2813	13603	map
14715	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Raccoon+Key+%26+Egg+Island+Shoal%2C+between%2C+Georgia+Current+%2810d%29	13604	current
14716	https://www.google.com/maps/place/31°50'34.0"N+81°4'2.0"W/@31.8428,-81.0675	13604	map
14717	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Raccoon+Key%2C+Georgia+Current+%2810d%29	13605	current
14718	https://www.google.com/maps/place/31°51'42.0"N+81°3'18.0"W/@31.8617,-81.055	13605	map
14719	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Raccoon+Point%2C+0%2E6+mile+NNE+of%2C+Washington+Current	13606	current
14720	https://www.google.com/maps/place/48°42'22.0"N+122°49'45.0"W/@48.7063,-122.8292	13606	map
14721	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Raccoon+Strait+off+Hospital+Cove%2C+San+Francisco+Bay%2C+California+Current	13607	current
14722	https://www.google.com/maps/place/37°51'59.0"N+122°25'59.0"W/@37.866666,-122.4333	13607	map
14723	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Raccoon+Strait+off+Point+Stuart%2C+San+Francisco+Bay%2C+California+Current	13608	current
14724	https://www.google.com/maps/place/37°51'59.0"N+122°27'0.0"W/@37.866666,-122.45	13608	map
14725	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Race+Passage%2C+British+Columbia+Current	13609	current
14726	https://www.google.com/maps/place/48°18'24.0"N+123°32'12.0"W/@48.3067,-123.5367	13609	map
14727	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Race+Point%2C+0%2E4+mile+southwest+of%2C+The+Race%2C+New+York+Current	13610	current
14728	https://www.google.com/maps/place/41°14'41.0"N+72°2'35.0"W/@41.245,-72.0433	13610	map
14729	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Racoon+Point%2C+0%2E6++mile+NNE+of%2C+Washington+Current	13611	current
14730	https://www.google.com/maps/place/48°42'0.0"N+122°49'0.0"W/@48.7,-122.8167	13611	map
14731	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Radio+Island%2C+E+of%2C+Beaufort+Inlet%2C+North+Carolina+Current+%286d%29	13612	current
14732	https://www.google.com/maps/place/34°42'42.0"N+76°40'46.0"W/@34.7117,-76.6797	13612	map
14733	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ragged+Point%2C+1%2E5+miles+east+of%2C+Maryland+Current	13613	current
14734	https://www.google.com/maps/place/38°31'48.0"N+76°14'39.0"W/@38.53,-76.2442	13613	map
14735	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Railroad+drawbridge%2C+above%2C+Housatonic+River%2C+Connecticut+Current+%285d%29	13614	current
14736	https://www.google.com/maps/place/41°12'31.0"N+73°6'40.0"W/@41.2088,-73.1112	13614	map
14737	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Railroad+drawbridge%2C+Connecticut+River%2C+Connecticut+Current+%2815d%29	13615	current
14738	https://www.google.com/maps/place/41°19'0.0"N+72°20'46.0"W/@41.3167,-72.3462	13615	map
14739	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ram+Island+Reef%2C+south+of%2C+New+York+Current+%287d%29	13616	current
14740	https://www.google.com/maps/place/41°18'6.0"N+71°58'29.0"W/@41.3017,-71.975	13616	map
14741	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ram+Island%2C+1%2E4+miles+NNE+of%2C+New+York+Current	13617	current
14742	https://www.google.com/maps/place/41°5'48.0"N+72°15'47.0"W/@41.0967,-72.2633	13617	map
14743	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ram+Island%2C+2%2E2+miles+east+of%2C+New+York+Current	13618	current
14744	https://www.google.com/maps/place/41°4'41.0"N+72°13'48.0"W/@41.0783,-72.23	13618	map
14745	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ramshorn+Creek+Light%2C+E+of%2C+Cooper+River%2C+South+Carolina+Current+%286d%29	13619	current
14746	https://www.google.com/maps/place/32°7'48.0"N+80°52'54.0"W/@32.13,-80.8817	13619	map
14747	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Range+D%2C+off+Mosquito+Creek%2C+South+Carolina+Current	13620	current
14748	https://www.google.com/maps/place/33°14'39.0"N+79°12'20.0"W/@33.2442,-79.2058	13620	map
14749	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rathall+Creek+entrance%2C+Wando+River%2C+South+Carolina+Current	13621	current
14750	https://www.google.com/maps/place/32°51'34.0"N+79°53'46.0"W/@32.8595,-79.8962	13621	map
14751	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rattlesnake+Key%2C+1%2E1+miles+northwest+of%2C+Florida+Current	13622	current
14752	https://www.google.com/maps/place/27°34'14.0"N+82°38'37.0"W/@27.5708,-82.6438	13622	map
14753	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rattlesnake+Key%2C+3%2E1+miles+west+of%2C+Florida+Current	13623	current
14754	https://www.google.com/maps/place/27°33'11.0"N+82°41'17.0"W/@27.5533,-82.6883	13623	map
14755	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Reaves+Point+Channel%2C+North+Carolina+Current+%2816d%29	13624	current
14756	https://www.google.com/maps/place/33°59'4.0"N+77°55'50.0"W/@33.9847,-77.9308	13624	map
14757	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Reaves+Point+Channel%2C+North+Carolina+Current+%2826d%29	13625	current
14758	https://www.google.com/maps/place/33°59'4.0"N+77°55'50.0"W/@33.9847,-77.9308	13625	map
14759	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Reaves+Point+Channel%2C+North+Carolina+Current+%286d%29	13626	current
14760	https://www.google.com/maps/place/33°59'4.0"N+77°55'50.0"W/@33.9847,-77.9308	13626	map
14761	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Reaves+Point%2C+0%2E3+mile+east+of%2C+North+Carolina+Current+%2816d%29	13627	current
14762	https://www.google.com/maps/place/33°59'55.0"N+77°56'58.0"W/@33.9987,-77.9495	13627	map
14763	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Reaves+Point%2C+0%2E3+mile+east+of%2C+North+Carolina+Current+%2826d%29	13628	current
14764	https://www.google.com/maps/place/33°59'55.0"N+77°56'58.0"W/@33.9987,-77.9495	13628	map
14765	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Reaves+Point%2C+0%2E3+mile+east+of%2C+North+Carolina+Current+%286d%29	13629	current
14766	https://www.google.com/maps/place/33°59'55.0"N+77°56'58.0"W/@33.9987,-77.9495	13629	map
14767	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Reaves+Point%2C+0%2E4+mile+north+of%2C+North+Carolina+Current+%2816d%29	13630	current
14768	https://www.google.com/maps/place/34°0'22.0"N+77°57'9.0"W/@34.0062,-77.9525	13630	map
14769	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Reaves+Point%2C+0%2E4+mile+north+of%2C+North+Carolina+Current+%2826d%29	13631	current
14770	https://www.google.com/maps/place/34°0'22.0"N+77°57'9.0"W/@34.0062,-77.9525	13631	map
14771	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Reaves+Point%2C+0%2E4+mile+north+of%2C+North+Carolina+Current+%286d%29	13632	current
14772	https://www.google.com/maps/place/34°0'22.0"N+77°57'9.0"W/@34.0062,-77.9525	13632	map
14773	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Reaves+Point%2C+0%2E8+mile+northeast+of%2C+North+Carolina+Current+%2816d%29	13633	current
14774	https://www.google.com/maps/place/34°0'25.0"N+77°56'28.0"W/@34.0072,-77.9412	13633	map
14775	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Reaves+Point%2C+0%2E8+mile+northeast+of%2C+North+Carolina+Current+%2826d%29	13634	current
14776	https://www.google.com/maps/place/34°0'25.0"N+77°56'28.0"W/@34.0072,-77.9412	13634	map
14777	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Reaves+Point%2C+0%2E8+mile+northeast+of%2C+North+Carolina+Current+%286d%29	13635	current
14778	https://www.google.com/maps/place/34°0'25.0"N+77°56'28.0"W/@34.0072,-77.9412	13635	map
14779	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rebellion+Reach%2C+0%2E8+n%2Emi%2E+N%2E+of+Ft%2E+Sumter%2C+South+Carolina+Current	13636	current
14780	https://www.google.com/maps/place/32°45'58.0"N+79°52'23.0"W/@32.7663,-79.8733	13636	map
14781	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Red+Bay+Point%2C+draw+bridge%2C+Florida+Current+%2814d%29	13637	current
14782	https://www.google.com/maps/place/29°59'5.0"N+81°37'47.0"W/@29.985,-81.63	13637	map
14783	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Red+Bay+Point%2C+draw+bridge%2C+Florida+Current+%284d%29	13638	current
14784	https://www.google.com/maps/place/29°59'5.0"N+81°37'47.0"W/@29.985,-81.63	13638	map
14785	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Red+Bay+Point%2C+draw+bridge%2C+Florida+Current+%286d%29	13639	current
14786	https://www.google.com/maps/place/29°59'5.0"N+81°37'47.0"W/@29.985,-81.63	13639	map
14787	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Red+Point%2C+0%2E2+mile+W+of%2C+Northeast+River%2C+Maryland+Current+%287d%29	13640	current
14788	https://www.google.com/maps/place/39°31'45.0"N+75°59'4.0"W/@39.5292,-75.9847	13640	map
14789	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Red+Rock+%2E1+E%2C+San+Francisco+Bay%2C+California+Current	13641	current
14790	https://www.google.com/maps/place/37°55'59.0"N+122°25'59.0"W/@37.933333,-122.4333	13641	map
14791	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Redding+Rock+Light%2C+California+Current	13642	current
14792	https://www.google.com/maps/place/41°21'0.0"N+124°10'59.0"W/@41.35,-124.1833	13642	map
14793	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Remley+Point%2C+0%2E2+mile+northwest+of%2C+Wando+River%2C+South+Carolina+Current	13643	current
14794	https://www.google.com/maps/place/32°48'58.0"N+79°54'34.0"W/@32.8162,-79.9095	13643	map
14795	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Restoration+Point%2C+0%2E6+miles+ESE+of%2C+Washington+Current	13644	current
14796	https://www.google.com/maps/place/47°34'59.0"N+122°25'59.0"W/@47.5833,-122.4333	13644	map
14797	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ribbon+Reef%2DSow+%26+Pigs+Reef%2C+between%2C+Massachusetts+Current	13645	current
14798	https://www.google.com/maps/place/41°25'18.0"N+70°58'11.0"W/@41.4217,-70.97	13645	map
14799	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rich+Passage%2C+East+End%2C+Washington+Current	13646	current
14800	https://www.google.com/maps/place/47°34'0.0"N+122°30'0.0"W/@47.5667,-122.5	13646	map
14801	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rich+Passage%2C+North+of+Blake+Island%2C+Washington+Current	13647	current
14802	https://www.google.com/maps/place/47°34'59.0"N+122°28'0.0"W/@47.5833,-122.4667	13647	map
14803	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rich+Passage%2C+off+Pleasant+Beach%2C+Washington+Current	13648	current
14804	https://www.google.com/maps/place/47°34'59.0"N+122°31'59.0"W/@47.5833,-122.5333	13648	map
14805	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rich+Passage%2C+West+end%2C+Washington+Current	13649	current
14806	https://www.google.com/maps/place/47°34'0.0"N+122°31'59.0"W/@47.5667,-122.5333	13649	map
14807	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Richardson+Bay+Entrance%2C+San+Francisco+Bay%2C+California+Current	13650	current
14808	https://www.google.com/maps/place/37°51'0.0"N+122°27'59.0"W/@37.85,-122.4666	13650	map
14809	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rikers+I%2E+chan%2E%2C+off+La+Guardia+Field%2C+New+York+Current	13651	current
14810	https://www.google.com/maps/place/40°46'59.0"N+73°52'59.0"W/@40.7833,-73.8833	13651	map
14811	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rincon+Point+midbay%2C+South+San+Francisco+Bay%2C+California+Current	13652	current
14812	https://www.google.com/maps/place/37°46'59.0"N+122°20'59.0"W/@37.783333,-122.35	13652	map
14813	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Roanoke+Point%2C+2%2E3+miles+NNW+of%2C+New+York+Current	13653	current
14814	https://www.google.com/maps/place/41°0'55.0"N+72°42'58.0"W/@41.0153,-72.7162	13653	map
14815	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Roanoke+Point%2C+5%2E6+miles+north+of%2C+New+York+Current+%2815d%29	13654	current
14816	https://www.google.com/maps/place/41°4'22.0"N+72°42'31.0"W/@41.0728,-72.7088	13654	map
14817	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Robins+Island%2C+0%2E5+mile+south+of%2C+New+York+Current	13655	current
14818	https://www.google.com/maps/place/40°56'58.0"N+72°27'10.0"W/@40.9497,-72.453	13655	map
14819	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Robins+Point%2C+0%2E7+mile+ESE+of%2C+Maryland+Current+%285d%29	13656	current
14820	https://www.google.com/maps/place/39°17'44.0"N+76°16'5.0"W/@39.2958,-76.2683	13656	map
14821	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Robinsons+Hole%2C+1%2E2+miles+southeast+of%2C+Massachusetts+Current	13657	current
14822	https://www.google.com/maps/place/41°26'6.0"N+70°46'48.0"W/@41.435,-70.78	13657	map
14823	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rocky+Hill%2C+Connecticut+River%2C+Connecticut+Current+%289d%29	13658	current
14824	https://www.google.com/maps/place/41°39'49.0"N+72°37'43.0"W/@41.6637,-72.6288	13658	map
14825	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rocky+Point%2C+0%2E3+mile+north+of%2C+New+York+Current+%2815d%29	13659	current
14826	https://www.google.com/maps/place/41°8'37.0"N+72°21'25.0"W/@41.1438,-72.357	13659	map
14827	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rocky+Point%2C+1+mile+east+of%2C+Oyster+Bay%2C+New+York+Current+%2815d%29	13660	current
14828	https://www.google.com/maps/place/40°55'9.0"N+73°30'1.0"W/@40.9192,-73.5005	13660	map
14829	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rocky+Point%2C+2+miles+WNW+of%2C+New+York+Current+%2815d%29	13661	current
14830	https://www.google.com/maps/place/41°3'33.0"N+72°1'48.0"W/@41.0592,-72.03	13661	map
14831	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rocky+Pt%2E+%28Elk+Neck%29%2C+0%2E25+n%2Emi%2E+SW+of%2C+Maryland+Current+%289d%29	13662	current
14832	https://www.google.com/maps/place/39°29'17.0"N+75°59'51.0"W/@39.4883,-75.9975	13662	map
14833	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Roe+Island+S%2C+Suisun+Bay%2C+California+Current	13663	current
14834	https://www.google.com/maps/place/38°3'59.0"N+122°1'59.0"W/@38.066666,-122.0333	13663	map
14835	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rosario+Strait%2C+Washington+Current	13664	current
14836	https://www.google.com/maps/place/48°27'29.0"N+122°46'48.0"W/@48.4583,-122.78	13664	map
14837	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rose+Island%2C+northeast+of%2C+Rhode+Island+Current+%2815d%29	13665	current
14838	https://www.google.com/maps/place/41°30'11.0"N+71°19'54.0"W/@41.5033,-71.3317	13665	map
14839	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rose+Island%2C+northwest+of%2C+Rhode+Island+Current+%2815d%29	13666	current
14840	https://www.google.com/maps/place/41°30'24.0"N+71°21'6.0"W/@41.5067,-71.3517	13666	map
14841	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Rose+Island%2C+west+of%2C+Rhode+Island+Current	13667	current
14842	https://www.google.com/maps/place/41°29'48.0"N+71°20'59.0"W/@41.4967,-71.35	13667	map
14843	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ross+Island%2C+1+mile+east+of%2C+marker+%274%27%2C+Florida+Current+%2815d%29	13668	current
14844	https://www.google.com/maps/place/27°50'13.0"N+82°34'23.0"W/@27.837,-82.5732	13668	map
14845	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=S%2E+Newport+River%2C+above+Swain+River+Ent%2C+Georgia+Current+%2810d%29	13669	current
14846	https://www.google.com/maps/place/31°37'28.0"N+81°13'0.0"W/@31.6245,-81.2167	13669	map
14847	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=S%2E+Newport+River%2C+below+S%2E+Newport+Cut%2C+Georgia+Current+%2810d%29	13670	current
14848	https://www.google.com/maps/place/31°39'1.0"N+81°18'7.0"W/@31.6503,-81.302	13670	map
14849	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=S%2EC%2EL%2E+RR%2E+bridge%2C+0%2E1+mile+below%2C+Ashley+River%2C+South+Carolina+Current	13671	current
14850	https://www.google.com/maps/place/32°47'43.0"N+79°58'23.0"W/@32.7955,-79.9733	13671	map
14851	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=S%2EC%2EL%2E+RR%2E+bridge%2C+1%2E5+miles+above%2C+Ashley+River%2C+South+Carolina+Current	13672	current
14852	https://www.google.com/maps/place/32°49'12.0"N+79°57'54.0"W/@32.82,-79.965	13672	map
14853	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sachem+Head+6%2E2+miles+south+of%2C+Connecticut+Current+%2815d%29	13673	current
14854	https://www.google.com/maps/place/41°8'43.0"N+72°42'17.0"W/@41.1455,-72.705	13673	map
14855	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sachem+Head%2C+1+mile+SSE+of%2C+Connecticut+Current	13674	current
14856	https://www.google.com/maps/place/41°13'38.0"N+72°42'17.0"W/@41.2275,-72.705	13674	map
14857	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sagamore+Bridge%2C+Massachusetts+Current	13675	current
14858	https://www.google.com/maps/place/41°46'0.0"N+70°32'59.0"W/@41.7667,-70.55	13675	map
14859	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Saginaw+Channel%2C+2+mi%2E+E+of+Pt%2ERetreat%2C+Alaska+Current+%2825d%29	13676	current
14860	https://www.google.com/maps/place/58°24'18.0"N+134°53'5.0"W/@58.405,-134.885	13676	map
14861	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Saginaw+Channel%2C+2+mi%2E+E+of+Pt%2ERetreat%2C+Alaska+Current+%2870d%29	13677	current
14862	https://www.google.com/maps/place/58°24'18.0"N+134°53'5.0"W/@58.405,-134.885	13677	map
14863	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Salisbury%2C+Maryland+%282+miles+below%29+Current	13678	current
14864	https://www.google.com/maps/place/38°20'24.0"N+75°38'17.0"W/@38.34,-75.6383	13678	map
14865	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Salt+Point%2C+California+Current	13679	current
14866	https://www.google.com/maps/place/38°34'0.0"N+123°20'59.0"W/@38.5667,-123.35	13679	map
14867	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sampit+River+entrance%2C+South+Carolina+Current	13680	current
14868	https://www.google.com/maps/place/33°21'4.0"N+79°16'49.0"W/@33.3513,-79.2803	13680	map
14869	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sampson+Island%2C+NE+end%2C+South+Edisto+River%2C+South+Carolina+Current+%2815d%29	13681	current
14870	https://www.google.com/maps/place/32°37'0.0"N+80°23'12.0"W/@32.6167,-80.3867	13681	map
14871	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sampson+Island%2C+S+end%2C+South+Edisto+River%2C+South+Carolina+Current+%2815d%29	13682	current
14872	https://www.google.com/maps/place/32°33'47.0"N+80°23'30.0"W/@32.5633,-80.3917	13682	map
14873	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sams+Point%2C+Northwest+of%2C+Coosaw+River%2C+South+Carolina+Current+%2810d%29	13683	current
14874	https://www.google.com/maps/place/32°29'35.0"N+80°35'35.0"W/@32.4933,-80.5933	13683	map
14875	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=San+Diego+Bay+Entrance%2C+California+Current	13684	current
14876	https://www.google.com/maps/place/32°40'54.0"N+117°10'23.0"W/@32.6817,-117.1733	13684	map
14877	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=San+Diego%2C+0%2E5+mile+west+of%2C+California+Current	13685	current
14878	https://www.google.com/maps/place/32°43'0.0"N+117°10'59.0"W/@32.7167,-117.1833	13685	map
14879	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=San+Francisco+Bay+Entrance+%28Golden+Gate%29%2C+California+Current	13686	current
14880	https://www.google.com/maps/place/37°49'0.0"N+122°28'59.0"W/@37.8167,-122.4833	13686	map
14881	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=San+Francisco+Bay+Entrance+%28outside%29%2C+California+Current	13687	current
14882	https://www.google.com/maps/place/37°48'37.0"N+122°30'7.0"W/@37.8105,-122.5022	13687	map
14883	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=San+Juan+Channel+%28south+entrance%29%2C+Washington+Current	13688	current
14884	https://www.google.com/maps/place/48°27'40.0"N+122°57'2.0"W/@48.4613,-122.9508	13688	map
14885	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=San+Juan+Channel+%28South+Entrance%29%2C+Washington+Current	13689	current
14886	https://www.google.com/maps/place/48°28'0.0"N+122°57'0.0"W/@48.4667,-122.95	13689	map
14887	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=San+Mateo+Bridge%2C+South+San+Francisco+Bay%2C+California+Current	13690	current
14888	https://www.google.com/maps/place/37°34'59.0"N+122°15'0.0"W/@37.583333,-122.25	13690	map
14889	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sand+Island+Tower%2C+0%2E9nm+SE+of+%28north+channel%29%2C+Washington+Current+%2815d%29	13691	current
14890	https://www.google.com/maps/place/46°15'28.0"N+123°59'40.0"W/@46.2578,-123.9945	13691	map
14891	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sand+Island+Tower%2C+1nm+SE+of+%28midchannel%29%2C+Washington+Current+%2815d%29	13692	current
14892	https://www.google.com/maps/place/46°15'10.0"N+123°59'26.0"W/@46.2528,-123.9908	13692	map
14893	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sand+Island%2C+SSE+of%2C+Washington+Current+%2812d%29	13693	current
14894	https://www.google.com/maps/place/46°15'19.0"N+123°58'4.0"W/@46.2555,-123.968	13693	map
14895	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sandy+Point%2C+0%2E5+mile+south+of%2C+Maryland+Current	13694	current
14896	https://www.google.com/maps/place/38°18'29.0"N+76°27'17.0"W/@38.3083,-76.455	13694	map
14897	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sandy+Point%2C+0%2E8+n%2Emi%2E+ESE+of%2C+Maryland+Current+%2815d%29	13695	current
14898	https://www.google.com/maps/place/39°0'14.0"N+76°22'47.0"W/@39.004,-76.38	13695	map
14899	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sandy+Point%2C+0%2E8+n%2Emi%2E+ESE+of%2C+Maryland+Current+%2843d%29	13696	current
14900	https://www.google.com/maps/place/39°0'14.0"N+76°22'47.0"W/@39.004,-76.38	13696	map
14901	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sandy+Point%2C+2%2E1+miles+NNE+of%2C+Block+Island%2C+Rhode+Island+Current+%2815d%29	13697	current
14902	https://www.google.com/maps/place/41°15'51.0"N+71°34'0.0"W/@41.2642,-71.5667	13697	map
14903	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sandy+Point%2C+2%2E3+n%2Emi%2E+east+of%2C+Maryland+Current+%2815d%29	13698	current
14904	https://www.google.com/maps/place/39°0'9.0"N+76°20'55.0"W/@39.0027,-76.3488	13698	map
14905	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sandy+Point%2C+2%2E3+n%2Emi%2E+east+of%2C+Maryland+Current+%2841d%29	13699	current
14906	https://www.google.com/maps/place/39°0'9.0"N+76°20'55.0"W/@39.0027,-76.3488	13699	map
14907	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sandy+Point%2C+4%2E1+miles+northwest+of%2C+Rhode+Island+Current+%2815d%29	13700	current
14908	https://www.google.com/maps/place/41°17'5.0"N+71°37'59.0"W/@41.285,-71.6333	13700	map
14909	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sandy+Pt%2E%2C+1%2E5+miles+north+of%2C+Block+Island%2C+Rhode+Island+Current+%287d%29	13701	current
14910	https://www.google.com/maps/place/41°15'0.0"N+71°34'0.0"W/@41.25,-71.5667	13701	map
14911	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sansum+Narrows%2C+British+Columbia+Current	13702	current
14912	https://www.google.com/maps/place/48°46'59.0"N+123°32'59.0"W/@48.7833,-123.55	13702	map
14913	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sapelo+River+Entrance%2C+Georgia+Current+%2811d%29	13703	current
14914	https://www.google.com/maps/place/31°32'6.0"N+81°16'18.0"W/@31.535,-81.2717	13703	map
14915	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sarasota+Bay%2C+south+end%2C+bridge%2C+Florida+Current	13704	current
14916	https://www.google.com/maps/place/27°18'6.0"N+82°32'48.0"W/@27.3017,-82.5467	13704	map
14917	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Saugatuck+River%2C+0%2E3+mi%2E+NW+of+Bluff+Pt%2C+Connecticut+Current+%2815d%29	13705	current
14918	https://www.google.com/maps/place/41°6'16.0"N+73°21'55.0"W/@41.1045,-73.3653	13705	map
14919	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Savannah+River+Entrance+%28between+jetties%29%2C+Georgia+Current+%2811d%29	13706	current
14920	https://www.google.com/maps/place/32°2'8.0"N+80°53'25.0"W/@32.0357,-80.8903	13706	map
14921	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Savannah+River+Entrance%2C+Georgia+Current	13707	current
14922	https://www.google.com/maps/place/32°2'12.0"N+80°51'29.0"W/@32.0367,-80.8583	13707	map
14923	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Savannah+River+Entrance%2C+Georgia+Current+%282%29+%28expired+1999%2D12%2D31%29	13708	current
14924	https://www.google.com/maps/place/32°2'12.0"N+80°51'29.0"W/@32.0367,-80.8583	13708	map
14925	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Savannah%2C+Georgia+Current	13709	current
14926	https://www.google.com/maps/place/32°4'59.0"N+81°4'59.0"W/@32.0833,-81.0833	13709	map
14927	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Savannah%2C+southeast+of+highway+bridge%2C+Georgia+Current+%2810d%29	13710	current
14928	https://www.google.com/maps/place/32°5'12.0"N+81°5'48.0"W/@32.0867,-81.0967	13710	map
14929	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Saybrook+Breakwater%2C+1%2E5+miles+SE+of%2C+Connecticut+Current	13711	current
14930	https://www.google.com/maps/place/41°14'46.0"N+72°19'2.0"W/@41.2463,-72.3175	13711	map
14931	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Saybrook+Point%2C+0%2E2+mile+northeast+of%2C+Connecticut+River%2C+Connecticut+Current	13712	current
14932	https://www.google.com/maps/place/41°17'1.0"N+72°20'52.0"W/@41.2837,-72.3478	13712	map
14933	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sea+Lion+Pass%2C+Rat+Islands%2C+Alaska+Current	13713	current
14934	https://www.google.com/maps/place/51°53'59.0"N+177°54'0.0"E/@51.9,177.9	13713	map
14935	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Seaboard+Coast+Line+Railroad%2C+Georgia+Current	13714	current
14936	https://www.google.com/maps/place/32°6'11.0"N+81°7'5.0"W/@32.1033,-81.1183	13714	map
14937	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sechelt+Rapids%2C+British+Columbia+Current+%28use+with+caution%29	13715	current
14938	https://www.google.com/maps/place/49°44'17.0"N+123°53'53.0"W/@49.7383,-123.8983	13715	map
14939	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Second+Narrows%2C+British+Columbia+Current	13716	current
14940	https://www.google.com/maps/place/49°17'59.0"N+123°1'0.0"W/@49.3,-123.0167	13716	map
14941	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sergius+Narrows%2C+Peril+Strait%2C+Alaska+Current	13717	current
14942	https://www.google.com/maps/place/57°24'24.0"N+135°37'36.0"W/@57.4067,-135.6267	13717	map
14943	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Seymour+Narrows%2C+British+Columbia+Current	13718	current
14944	https://www.google.com/maps/place/50°7'59.0"N+125°20'59.0"W/@50.1333,-125.35	13718	map
14945	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Shackleford+Banks%2C+0%2E8+mile+S+of%2C+Beaufort+Inlet%2C+North+Carolina+Current+%286d%29	13719	current
14946	https://www.google.com/maps/place/34°39'58.0"N+76°39'19.0"W/@34.6663,-76.6555	13719	map
14947	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Shackleford+Point%2C+NE+of%2C+Beaufort+Inlet%2C+North+Carolina+Current+%286d%29	13720	current
14948	https://www.google.com/maps/place/34°41'31.0"N+76°39'7.0"W/@34.6922,-76.6522	13720	map
14949	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Shagwong+Reef+%26+Cerberus+Shoal%2C+between%2C+New+York+Current	13721	current
14950	https://www.google.com/maps/place/41°7'54.0"N+71°55'29.0"W/@41.1317,-71.925	13721	map
14951	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Shannon+Point%2C+2+mile+W+of%2C+Washington+Current	13722	current
14952	https://www.google.com/maps/place/48°30'0.0"N+122°43'0.0"W/@48.5,-122.7167	13722	map
14953	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Shannon+Point%2C+2%2E0+miles+west+of%2C+Washington+Current	13723	current
14954	https://www.google.com/maps/place/48°30'37.0"N+122°43'49.0"W/@48.5105,-122.7305	13723	map
14955	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sharp+Island+Lt%2E%2C+2%2E1+n%2Emi%2E+west+of%2C+Maryland+Current+%2818d%29	13724	current
14956	https://www.google.com/maps/place/38°38'35.0"N+76°25'13.0"W/@38.6433,-76.4203	13724	map
14957	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sharp+Island+Lt%2E%2C+2%2E3+n%2Emi%2E+SE+of%2C+Maryland+Current+%2820d%29	13725	current
14958	https://www.google.com/maps/place/38°36'25.0"N+76°20'52.0"W/@38.6072,-76.348	13725	map
14959	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sharp+Island+Lt%2E%2C+3%2E4+n%2Emi%2E+west+of%2C+Maryland+Current+%2818d%29	13726	current
14960	https://www.google.com/maps/place/38°38'37.0"N+76°26'52.0"W/@38.6438,-76.448	13726	map
14961	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sharp+Island+Lt%2E%2C+3%2E4+n%2Emi%2E+west+of%2C+Maryland+Current+%2835d%29	13727	current
14962	https://www.google.com/maps/place/38°38'37.0"N+76°26'52.0"W/@38.6438,-76.448	13727	map
14963	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sheep+Island+Slue%2C+North+Carolina+Current	13728	current
14964	https://www.google.com/maps/place/35°4'0.0"N+76°5'59.0"W/@35.0667,-76.1	13728	map
14965	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sheepscot+River+%28off+Barter+Island%29%2C+Maine+Current	13729	current
14966	https://www.google.com/maps/place/43°53'59.0"N+69°41'30.0"W/@43.9,-69.6917	13729	map
14967	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sheffield+I%2E+Hbr%2E%2C+0%2E5+mile+southeast+of%2C+Connecticut+Current+%2812d%29	13730	current
14968	https://www.google.com/maps/place/41°3'19.0"N+73°25'14.0"W/@41.0553,-73.4208	13730	map
14969	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sheffield+I%2E+Tower%2C+1%2E1+miles+SE+of%2C+Connecticut+Current+%2815d%29	13731	current
14970	https://www.google.com/maps/place/41°1'58.0"N+73°24'19.0"W/@41.0328,-73.4055	13731	map
14971	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sheffield+I%2E+Tower%2C+1%2E1+miles+SE+of%2C+Connecticut+Current+%2860d%29	13732	current
14972	https://www.google.com/maps/place/41°1'58.0"N+73°24'19.0"W/@41.0328,-73.4055	13732	map
14973	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sheridan+Point%2C+0%2E1+mile+southwest+of%2C+Maryland+Current	13733	current
14974	https://www.google.com/maps/place/38°27'58.0"N+76°38'52.0"W/@38.4662,-76.648	13733	map
14975	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sherman+Island+%28East%29%2C+California+Current	13734	current
14976	https://www.google.com/maps/place/38°3'31.0"N+121°47'59.0"W/@38.0587,-121.8	13734	map
14977	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Shinnecock+Canal%2C+Railroad+Bridge%2C+New+York+Current	13735	current
14978	https://www.google.com/maps/place/40°53'12.0"N+72°30'6.0"W/@40.8867,-72.5017	13735	map
14979	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Shippan+Point%2C+1%2E3+miles+SSE+of%2C+Connecticut+Current+%2815d%29	13736	current
14980	https://www.google.com/maps/place/40°59'53.0"N+73°31'0.0"W/@40.9983,-73.5167	13736	map
14981	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Shippan+Point%2C+1%2E3+miles+SSE+of%2C+Connecticut+Current+%2840d%29	13737	current
14982	https://www.google.com/maps/place/40°59'58.0"N+73°31'1.0"W/@40.9997,-73.5172	13737	map
14983	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Shipyard+Creek+entrance%2C+Cooper+River%2C+South+Carolina+Current	13738	current
14984	https://www.google.com/maps/place/32°49'47.0"N+79°56'6.0"W/@32.83,-79.935	13738	map
14985	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Shoal+Point%2C+6+miles+south+of%2C+New+York+Current+%2815d%29	13739	current
14986	https://www.google.com/maps/place/41°1'41.0"N+73°14'1.0"W/@41.0283,-73.2338	13739	map
14987	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Shutes+Folly+Island%2C+0%2E4+mile+west+of%2C+South+Carolina+Current	13740	current
14988	https://www.google.com/maps/place/32°46'34.0"N+79°55'14.0"W/@32.7763,-79.9208	13740	map
14989	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Shutes+Reach%2C+Buoy+%278%27%2C+South+Carolina+Current	13741	current
14990	https://www.google.com/maps/place/32°46'55.0"N+79°54'38.0"W/@32.7822,-79.9108	13741	map
14991	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sierra+Point+1%2E3+mi+ENE%2C+South+San+Francisco+Bay%2C+California+Current	13742	current
14992	https://www.google.com/maps/place/37°40'59.0"N+122°21'59.0"W/@37.683333,-122.3666	13742	map
14993	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sierra+Point+4%2E4+mi+E%2C+South+San+Francisco+Bay%2C+California+Current	13743	current
14994	https://www.google.com/maps/place/37°39'59.0"N+122°16'59.0"W/@37.666666,-122.2833	13743	map
14995	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sinclair+Island+Light%2C+0%2E6+mile+SE+of%2C+Washington+Current	13744	current
14996	https://www.google.com/maps/place/48°36'10.0"N+122°38'55.0"W/@48.6028,-122.6487	13744	map
14997	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sinclair+Island%2C+1+mile+NE+of%2C+Washington+Current	13745	current
14998	https://www.google.com/maps/place/48°37'0.0"N+122°39'0.0"W/@48.6167,-122.65	13745	map
14999	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sisters+Creek+entrance+%28bridge%29%2C+Florida+Current+%2810d%29	13746	current
15000	https://www.google.com/maps/place/30°23'24.0"N+81°27'42.0"W/@30.39,-81.4617	13746	map
15001	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sisters+Creek+entrance+%28bridge%29%2C+Florida+Current+%284d%29	13747	current
15002	https://www.google.com/maps/place/30°23'24.0"N+81°27'42.0"W/@30.39,-81.4617	13747	map
15003	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sitkinak+Strait%2C+Alaska+Current	13748	current
15004	https://www.google.com/maps/place/56°38'59.0"N+154°9'0.0"W/@56.65,-154.15	13748	map
15005	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Six+Mile+Reef%2C+1%2E5+miles+north+of%2C+Connecticut+Current	13749	current
15006	https://www.google.com/maps/place/41°12'39.0"N+72°28'52.0"W/@41.211,-72.4812	13749	map
15007	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Six+Mile+Reef%2C+2+miles+east+of%2C+New+York+Current	13750	current
15008	https://www.google.com/maps/place/41°10'49.0"N+72°26'53.0"W/@41.1805,-72.4483	13750	map
15009	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Skagit+Bay%2C+1+mi%2E+S+of+Goat+Island%2C+Washington+Current	13751	current
15010	https://www.google.com/maps/place/48°20'40.0"N+122°32'37.0"W/@48.3445,-122.5437	13751	map
15011	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Skagit+Bay%2C+1+mile+N+of+Rocky+Point%2C+Washington+Current	13752	current
15012	https://www.google.com/maps/place/47°31'59.0"N+122°30'0.0"W/@47.5333,-122.5	13752	map
15013	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Skagit+Bay%2C+1+mile+S+of+Goat+Island%2C+Washington+Current	13753	current
15014	https://www.google.com/maps/place/47°21'0.0"N+122°31'59.0"W/@47.35,-122.5333	13753	map
15015	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Skagit+Bay%2C+channel+SW+of+Hope+Island%2C+Washington+Current	13754	current
15016	https://www.google.com/maps/place/48°23'34.0"N+122°34'47.0"W/@48.393,-122.58	13754	map
15017	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Skagway%2C+Taiya+Inlet%2C+Alaska+Current	13755	current
15018	https://www.google.com/maps/place/59°27'0.0"N+135°19'59.0"W/@59.45,-135.3333	13755	map
15019	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Skidaway+Island%2C+N+End%2C+Wilmington+River%2C+Georgia+Current+%2810d%29	13756	current
15020	https://www.google.com/maps/place/32°0'35.0"N+81°0'29.0"W/@32.01,-81.0083	13756	map
15021	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Skidaway+Narrows%2C+Georgia+Current	13757	current
15022	https://www.google.com/maps/place/31°57'11.0"N+81°3'53.0"W/@31.9533,-81.065	13757	map
15023	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Skidaway+River%2C+north+entrance%2C+Georgia+Current	13758	current
15024	https://www.google.com/maps/place/32°0'29.0"N+81°1'0.0"W/@32.0083,-81.0167	13758	map
15025	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Skipjack+Island%2C+1%2E5+miles+northwest+of%2C+Washington+Current	13759	current
15026	https://www.google.com/maps/place/48°44'58.0"N+123°3'38.0"W/@48.7495,-123.0608	13759	map
15027	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Skipjack+Island%2C+2+mile+nne+of%2C+Washington+Current	13760	current
15028	https://www.google.com/maps/place/48°45'0.0"N+123°2'59.0"W/@48.75,-123.05	13760	map
15029	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Skipjack+Island%2C+2+miles+NNE+of%2C+Washington+Current	13761	current
15030	https://www.google.com/maps/place/48°46'0.0"N+123°1'0.0"W/@48.7667,-123.0167	13761	map
15031	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Skull+Creek%2C+north+entrance%2C+South+Carolina+Current	13762	current
15032	https://www.google.com/maps/place/32°15'47.0"N+80°44'30.0"W/@32.2633,-80.7417	13762	map
15033	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Skull+Creek%2C+south+entrance%2C+South+Carolina+Current+%2810d%29	13763	current
15034	https://www.google.com/maps/place/32°13'23.0"N+80°47'5.0"W/@32.2233,-80.785	13763	map
15035	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Smith+Island%2C+1%2E4+miles+SSW+of%2C+Washington+Current	13764	current
15036	https://www.google.com/maps/place/48°17'59.0"N+122°50'59.0"W/@48.3,-122.85	13764	map
15037	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Smith+Island%2C+2+miles+east+of%2C+Washington+Current	13765	current
15038	https://www.google.com/maps/place/48°19'0.0"N+122°47'59.0"W/@48.3167,-122.8	13765	map
15039	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Smith+Island%2C+3%2E7+miles+ESE+of%2C+Washington+Current	13766	current
15040	https://www.google.com/maps/place/48°17'59.0"N+122°45'0.0"W/@48.3,-122.75	13766	map
15041	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Smuggedy+Swamp%2C+South+Edisto+River%2C+South+Carolina+Current+%286d%29	13767	current
15042	https://www.google.com/maps/place/32°39'35.0"N+80°24'42.0"W/@32.66,-80.4117	13767	map
15043	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Snake+Island%2C+South+Carolina+Current+%2812d%29	13768	current
15044	https://www.google.com/maps/place/32°38'24.0"N+80°1'11.0"W/@32.64,-80.02	13768	map
15045	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Snell+Isle%2C+1%2E8+miles+east+of%2C+Florida+Current	13769	current
15046	https://www.google.com/maps/place/27°47'37.0"N+82°34'19.0"W/@27.7937,-82.5722	13769	map
15047	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Snow+Point%2C+0%2E5+mile+north+of%2C+Cooper+River%2C+South+Carolina+Current	13770	current
15048	https://www.google.com/maps/place/32°57'6.0"N+79°55'48.0"W/@32.9517,-79.93	13770	map
15049	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Snows+Cut%2C+Intracoastal+Waterway%2C+North+Carolina+Current+%286d%29	13771	current
15050	https://www.google.com/maps/place/34°3'22.0"N+77°53'55.0"W/@34.0563,-77.8988	13771	map
15051	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sound+Beach%2C+2%2E2+miles+north+of%2C+New+York+Current	13772	current
15052	https://www.google.com/maps/place/41°0'19.0"N+72°58'27.0"W/@41.0055,-72.9742	13772	map
15053	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+Bend%2C+Willapa+River%2C+Washington+Current	13773	current
15054	https://www.google.com/maps/place/46°39'52.0"N+123°48'4.0"W/@46.6647,-123.8013	13773	map
15055	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+Brother+Island%2C+NW+of%2C+New+York+Current+%2815d%29	13774	current
15056	https://www.google.com/maps/place/40°47'48.0"N+73°54'6.0"W/@40.7967,-73.9017	13774	map
15057	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+Chan%2E%2C+0%2E4+mi%2E+NW+of+Ft%2E+Johnson%2C+South+Carolina+Current	13775	current
15058	https://www.google.com/maps/place/32°45'28.0"N+79°54'22.0"W/@32.758,-79.9063	13775	map
15059	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+Chan%2E%2C+0%2E8+mi%2E+ENE+of+Ft%2E+Johnson%2C+South+Carolina+Current	13776	current
15060	https://www.google.com/maps/place/32°45'31.0"N+79°53'4.0"W/@32.7587,-79.8847	13776	map
15061	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+Channel%2C+Buoy+%2732%27%2C+South+Carolina+Current	13777	current
15062	https://www.google.com/maps/place/32°45'43.0"N+79°54'39.0"W/@32.7622,-79.911	13777	map
15063	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+Channel%2C+California+Current	13778	current
15064	https://www.google.com/maps/place/37°45'0.0"N+122°31'59.0"W/@37.75,-122.5333	13778	map
15065	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+Channel%2C+San+Francisco+Bay+Approach%2C+California+Current	13779	current
15066	https://www.google.com/maps/place/37°45'0.0"N+122°31'59.0"W/@37.75,-122.5333	13779	map
15067	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+Channel%2C+western+end%2C+Georgia+Current	13780	current
15068	https://www.google.com/maps/place/32°5'17.0"N+81°1'0.0"W/@32.0883,-81.0167	13780	map
15069	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+Edisto+River+entrance%2C+South+Carolina+Current	13781	current
15070	https://www.google.com/maps/place/32°29'17.0"N+80°20'53.0"W/@32.4883,-80.3483	13781	map
15071	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+end+%28midstream%29%2C+The+Narrows%2C+Washington+Current	13782	current
15072	https://www.google.com/maps/place/47°15'38.0"N+122°33'29.0"W/@47.2608,-122.5583	13782	map
15073	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+end%2C+Quicks+Hole%2C+Massachusetts+Current	13783	current
15074	https://www.google.com/maps/place/41°26'17.0"N+70°50'30.0"W/@41.4383,-70.8417	13783	map
15075	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+end%2C+Robinsons+Hole%2C+Massachusetts+Current	13784	current
15076	https://www.google.com/maps/place/41°26'42.0"N+70°48'11.0"W/@41.445,-70.8033	13784	map
15077	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+end%2C+Woods+Hole%2C+Massachusetts+Current	13785	current
15078	https://www.google.com/maps/place/41°30'47.0"N+70°40'12.0"W/@41.5133,-70.67	13785	map
15079	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+Inian+Pass%2C+Alaska+Current	13786	current
15080	https://www.google.com/maps/place/58°13'0.0"N+136°20'59.0"W/@58.2167,-136.35	13786	map
15081	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+Jetty%2C+break+in%2C+South+Carolina+Current	13787	current
15082	https://www.google.com/maps/place/32°43'52.0"N+79°51'1.0"W/@32.7312,-79.8503	13787	map
15083	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+of+Kilkenny+Creek+Entrance%2C+Bear+River%2C+Georgia+Current	13788	current
15084	https://www.google.com/maps/place/31°45'29.0"N+81°10'23.0"W/@31.7583,-81.1733	13788	map
15085	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+Passage%2C+Alaska+Current	13789	current
15086	https://www.google.com/maps/place/58°13'59.0"N+136°5'59.0"W/@58.2333,-136.1	13789	map
15087	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+Point%2C+Washington+Current	13790	current
15088	https://www.google.com/maps/place/47°51'0.0"N+122°34'59.0"W/@47.85,-122.5833	13790	map
15089	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+River%2C+Georgia+Current+%2813d%29	13791	current
15090	https://www.google.com/maps/place/31°22'0.0"N+81°18'42.0"W/@31.3667,-81.3117	13791	map
15091	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+River%2C+Georgia+Current+%2821d%29	13792	current
15092	https://www.google.com/maps/place/31°22'0.0"N+81°18'42.0"W/@31.3667,-81.3117	13792	map
15093	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=South+Santee+River+entrance%2C+South+Carolina+Current+%285d%29	13793	current
15094	https://www.google.com/maps/place/33°7'11.0"N+79°16'30.0"W/@33.12,-79.275	13793	map
15095	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Southampton+Shoal+Light+%2E2+mi+E%2C+San+Francisco+Bay%2C+California+Current	13794	current
15096	https://www.google.com/maps/place/37°52'59.0"N+122°24'0.0"W/@37.883333,-122.4	13794	map
15097	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Southeast+Channel+entrance%2C+South+Carolina+Current	13795	current
15098	https://www.google.com/maps/place/32°7'59.0"N+80°34'59.0"W/@32.1333,-80.5833	13795	map
15099	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Southeast+Channel%2C+Florida+Current	13796	current
15100	https://www.google.com/maps/place/24°37'37.0"N+82°51'4.0"W/@24.627,-82.8512	13796	map
15101	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Southport%2C+North+Carolina+Current+%2816d%29	13797	current
15102	https://www.google.com/maps/place/33°55'1.0"N+78°0'31.0"W/@33.9172,-78.0088	13797	map
15103	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Southport%2C+North+Carolina+Current+%2826d%29	13798	current
15104	https://www.google.com/maps/place/33°55'1.0"N+78°0'31.0"W/@33.9172,-78.0088	13798	map
15105	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Southport%2C+North+Carolina+Current+%286d%29	13799	current
15106	https://www.google.com/maps/place/33°54'52.0"N+78°0'42.0"W/@33.9145,-78.0117	13799	map
15107	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Southwest+Channel+%28S+of+Egmont+Key%29%2C+Florida+Current+%2815d%29	13800	current
15108	https://www.google.com/maps/place/27°33'42.0"N+82°46'2.0"W/@27.5617,-82.7673	13800	map
15109	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Southwest+Channel%2C+Florida+Current	13801	current
15110	https://www.google.com/maps/place/24°36'55.0"N+82°54'42.0"W/@24.6153,-82.9117	13801	map
15111	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Southwest+Ledge%2C+2%2E0+miles+west+of%2C+Rhode+Island+Current+%2815d%29	13802	current
15112	https://www.google.com/maps/place/41°6'47.0"N+71°43'0.0"W/@41.1133,-71.7167	13802	map
15113	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Southwest+Ledge%2C+Rhode+Island+Current	13803	current
15114	https://www.google.com/maps/place/41°7'0.0"N+71°42'0.0"W/@41.1167,-71.7	13803	map
15115	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Spanish+Wells%2C+Calibogue+Sound%2C+South+Carolina+Current+%2830d%29	13804	current
15116	https://www.google.com/maps/place/32°11'12.0"N+80°47'5.0"W/@32.1867,-80.785	13804	map
15117	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Spesutie+Island%2C+channel+north+of%2C+Maryland+Current+%287d%29	13805	current
15118	https://www.google.com/maps/place/39°28'49.0"N+76°4'54.0"W/@39.4805,-76.0817	13805	map
15119	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Spoonbill+Creek+near+Bridge%2C+Suisun+Bay%2C+California+Current	13806	current
15120	https://www.google.com/maps/place/38°3'59.0"N+121°54'0.0"W/@38.066666,-121.9	13806	map
15121	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Spring+Passage%2C+South+entrance+of%2C+Washington+Current	13807	current
15122	https://www.google.com/maps/place/48°36'0.0"N+123°1'59.0"W/@48.6,-123.0333	13807	map
15123	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Spring+Passage%2C+south+entrance%2C+Washington+Current	13808	current
15124	https://www.google.com/maps/place/48°36'40.0"N+123°2'3.0"W/@48.6113,-123.0342	13808	map
15125	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Squaxin+Passage%2C+N+of+Hunter+Point%2C+Washington+Current	13809	current
15126	https://www.google.com/maps/place/47°10'59.0"N+122°55'0.0"W/@47.1833,-122.9167	13809	map
15127	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Squaxin+Passage%2C+north+of+Hunter+Point%2C+Washington+Current	13810	current
15128	https://www.google.com/maps/place/47°10'37.0"N+122°55'9.0"W/@47.177,-122.9192	13810	map
15129	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+Catherines+Sound+Entrance%2C+Georgia+Current+%2810d%29	13811	current
15130	https://www.google.com/maps/place/31°42'53.0"N+81°8'25.0"W/@31.715,-81.1405	13811	map
15131	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+George+Reef%2C+California+Current	13812	current
15132	https://www.google.com/maps/place/41°49'0.0"N+124°19'59.0"W/@41.8167,-124.3333	13812	map
15133	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+Johns+Bar+Cut+0%2E13+n%2Emi%2E+ENE+of+south+jetty%2C+Florida+Current+%2814d%29	13813	current
15134	https://www.google.com/maps/place/30°23'51.0"N+81°22'27.0"W/@30.3975,-81.3742	13813	map
15135	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+Johns+Bar+Cut+0%2E13+n%2Emi%2E+ENE+of+south+jetty%2C+Florida+Current+%2833d%29	13814	current
15136	https://www.google.com/maps/place/30°23'51.0"N+81°22'27.0"W/@30.3975,-81.3742	13814	map
15137	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+Johns+Bar+Cut+0%2E13+n%2Emi%2E+ENE+of+south+jetty%2C+Florida+Current+%2846d%29	13815	current
15138	https://www.google.com/maps/place/30°23'51.0"N+81°22'27.0"W/@30.3975,-81.3742	13815	map
15139	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+Johns+Bar+Cut%2C+0%2E7+n%2Emi%2E+east+of+jetties%2C+Florida+Current+%2814d%29	13816	current
15140	https://www.google.com/maps/place/30°23'52.0"N+81°21'49.0"W/@30.398,-81.3638	13816	map
15141	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+Johns+Bar+Cut%2C+0%2E7+n%2Emi%2E+east+of+jetties%2C+Florida+Current+%2831d%29	13817	current
15142	https://www.google.com/maps/place/30°23'52.0"N+81°21'49.0"W/@30.398,-81.3638	13817	map
15143	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+Johns+Bar+Cut%2C+0%2E7+n%2Emi%2E+east+of+jetties%2C+Florida+Current+%285d%29	13818	current
15144	https://www.google.com/maps/place/30°23'52.0"N+81°21'49.0"W/@30.398,-81.3638	13818	map
15145	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+Johns+Bluff%2C+Florida+Current+%2817d%29	13819	current
15146	https://www.google.com/maps/place/30°23'24.0"N+81°29'30.0"W/@30.39,-81.4917	13819	map
15147	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+Johns+Bluff%2C+Florida+Current+%2826d%29	13820	current
15148	https://www.google.com/maps/place/30°23'24.0"N+81°29'30.0"W/@30.39,-81.4917	13820	map
15149	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+Johns+Bluff%2C+Florida+Current+%287d%29	13821	current
15150	https://www.google.com/maps/place/30°23'24.0"N+81°29'30.0"W/@30.39,-81.4917	13821	map
15151	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+Johns+River+Ent%2E+%28between+jetties%29%2C+Florida+Current+%2810d%29	13822	current
15152	https://www.google.com/maps/place/30°24'1.0"N+81°23'8.0"W/@30.4003,-81.3858	13822	map
15153	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+Johns+River+Ent%2E+%28between+jetties%29%2C+Florida+Current+%2830d%29	13823	current
15154	https://www.google.com/maps/place/30°24'1.0"N+81°23'8.0"W/@30.4003,-81.3858	13823	map
15155	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+Johns+River+Entrance+%28between+jetties%29%2C+Florida+Current+%2816d%29	13824	current
15156	https://www.google.com/maps/place/30°24'1.0"N+81°23'8.0"W/@30.4003,-81.3858	13824	map
15157	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+Johns+River+Entrance%2C+Florida+Current	13825	current
15158	https://www.google.com/maps/place/30°23'59.0"N+81°22'59.0"W/@30.4,-81.3833	13825	map
15159	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+Johns+River+Entrance%2C+Florida+Current+%282%29+%28expired+1999%2D12%2D31%29	13826	current
15160	https://www.google.com/maps/place/30°23'59.0"N+81°22'59.0"W/@30.4,-81.3833	13826	map
15161	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+Johns+River+Entrance%2C+Florida+Current+%283%29	13827	current
15162	https://www.google.com/maps/place/30°47'48.0"N+81°30'54.0"W/@30.7967,-81.515	13827	map
15163	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+Marks+River+approach%2C+Florida+Current	13828	current
15164	https://www.google.com/maps/place/30°2'48.0"N+84°10'48.0"W/@30.0467,-84.18	13828	map
15165	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+Marks%2C+St%2E+Marks+River%2C+Florida+Current	13829	current
15166	https://www.google.com/maps/place/30°9'18.0"N+84°12'6.0"W/@30.155,-84.2017	13829	map
15167	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=St%2E+Mathew+I%2E%2C+southwest+coast%2C+Alaska+Current	13830	current
15168	https://www.google.com/maps/place/60°21'0.0"N+172°43'0.0"W/@60.35,-172.7167	13830	map
15169	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Stage+Harbor%2C+west+of+Morris+Island%2C+Massachusetts+Current	13831	current
15170	https://www.google.com/maps/place/41°39'24.0"N+69°58'29.0"W/@41.6567,-69.975	13831	map
15171	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Stake+Point+%2E9+Mi+NNW%2C+Suisun+Bay%2C+California+Current	13832	current
15172	https://www.google.com/maps/place/38°2'59.0"N+121°57'0.0"W/@38.05,-121.95	13832	map
15173	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Stamford+Harbor+entrance%2C+Connecticut+Current+%2812d%29	13833	current
15174	https://www.google.com/maps/place/41°0'52.0"N+73°32'12.0"W/@41.0147,-73.5367	13833	map
15175	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=State+Hwy%2E+7+bridge%2C+Ashley+River%2C+South+Carolina+Current	13834	current
15176	https://www.google.com/maps/place/32°50'13.0"N+79°58'55.0"W/@32.8372,-79.982	13834	map
15177	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Stono+Inlet%2C+South+Carolina+Current	13835	current
15178	https://www.google.com/maps/place/32°37'36.0"N+79°59'35.0"W/@32.6267,-79.9933	13835	map
15179	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Strait+of+Juan+de+Fuca+Entrance%2C+Washington+Current	13836	current
15180	https://www.google.com/maps/place/48°27'0.0"N+124°34'59.0"W/@48.45,-124.5833	13836	map
15181	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Stratford+Point%2C+4%2E3+miles+south+of%2C+Connecticut+Current+%2815d%29	13837	current
15182	https://www.google.com/maps/place/41°4'46.0"N+73°6'40.0"W/@41.0795,-73.1112	13837	map
15183	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Stratford+Point%2C+4%2E3+miles+south+of%2C+Connecticut+Current+%2860d%29	13838	current
15184	https://www.google.com/maps/place/41°4'46.0"N+73°6'40.0"W/@41.0795,-73.1112	13838	map
15185	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Stratford+Point%2C+6%2E1+miles+south+of%2C+New+York+Current+%2815d%29	13839	current
15186	https://www.google.com/maps/place/41°2'58.0"N+73°5'48.0"W/@41.0495,-73.0967	13839	map
15187	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Stratford+Point%2C+6%2E1+miles+south+of%2C+New+York+Current+%2851d%29	13840	current
15188	https://www.google.com/maps/place/41°2'58.0"N+73°5'48.0"W/@41.0495,-73.0967	13840	map
15189	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Stratford+Shoal%2C+6+miles+east+of%2C+New+York+Current	13841	current
15190	https://www.google.com/maps/place/41°4'31.0"N+72°58'25.0"W/@41.0753,-72.9738	13841	map
15191	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Strawberry+Island%2C+0%2E8+mile+W+of%2C+Washington+Current	13842	current
15192	https://www.google.com/maps/place/48°34'0.0"N+122°45'0.0"W/@48.5667,-122.75	13842	map
15193	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Strawberry+Island%2C+0%2E8+mile+west+of%2C+Washington+Current	13843	current
15194	https://www.google.com/maps/place/48°33'40.0"N+122°45'15.0"W/@48.5612,-122.7542	13843	map
15195	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sugarloaf+Island%2C+0%2E2+mile+S+of%2C+Beaufort+Inlet%2C+North+Carolina+Current+%286d%29	13844	current
15196	https://www.google.com/maps/place/34°42'44.0"N+76°42'49.0"W/@34.7125,-76.7138	13844	map
15197	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Suisun+Slough+Entrance%2C+Suisun+Bay%2C+California+Current	13845	current
15198	https://www.google.com/maps/place/38°6'59.0"N+122°3'59.0"W/@38.116666,-122.0666	13845	map
15199	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sullivans+I%2E%2C+0%2E7+mi%2E+NE+of+Ft%2E+Sumter%2C+South+Carolina+Current	13846	current
15200	https://www.google.com/maps/place/32°45'43.0"N+79°52'3.0"W/@32.762,-79.8675	13846	map
15201	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sunny+Point%2C+North+Carolina+Current+%2816d%29	13847	current
15202	https://www.google.com/maps/place/33°59'10.0"N+77°57'16.0"W/@33.9863,-77.9547	13847	map
15203	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sunny+Point%2C+North+Carolina+Current+%2826d%29	13848	current
15204	https://www.google.com/maps/place/33°59'10.0"N+77°57'16.0"W/@33.9863,-77.9547	13848	map
15205	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sunny+Point%2C+North+Carolina+Current+%286d%29	13849	current
15206	https://www.google.com/maps/place/33°59'10.0"N+77°57'16.0"W/@33.9863,-77.9547	13849	map
15207	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Surge+Narrows%2C+British+Columbia+Current	13850	current
15208	https://www.google.com/maps/place/50°13'59.0"N+125°9'0.0"W/@50.2333,-125.15	13850	map
15209	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sutherland+Bluff%2C+Sapelo+River%2C+Georgia+Current	13851	current
15210	https://www.google.com/maps/place/31°32'53.0"N+81°19'59.0"W/@31.5483,-81.3333	13851	map
15211	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=SW+Point%2C+St%2E+Paul+Island%2C+1+mile+off%2C+Pribilof+Islands%2C+Alaska+Current	13852	current
15212	https://www.google.com/maps/place/57°8'59.0"N+170°26'59.0"W/@57.15,-170.45	13852	map
15213	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Swan+Point%2C+1%2E6+miles+northwest+of%2C+Maryland+Current	13853	current
15214	https://www.google.com/maps/place/39°9'45.0"N+76°18'16.0"W/@39.1625,-76.3047	13853	map
15215	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Swan+Point%2C+2%2E15+n%2Emi%2E+west+of%2C+Maryland+Current+%2818d%29	13854	current
15216	https://www.google.com/maps/place/39°8'51.0"N+76°19'28.0"W/@39.1475,-76.3247	13854	map
15217	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Swan+Point%2C+2%2E7+n%2Emi%2E+SW+of%2C+Maryland+Current+%2814d%29	13855	current
15218	https://www.google.com/maps/place/39°6'28.0"N+76°18'19.0"W/@39.108,-76.3053	13855	map
15219	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Swan+Point%2C+2%2E7+n%2Emi%2E+SW+of%2C+Maryland+Current+%2827d%29	13856	current
15220	https://www.google.com/maps/place/39°6'28.0"N+76°18'19.0"W/@39.108,-76.3053	13856	map
15221	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Swan+Point%2C+Virginia+Current	13857	current
15222	https://www.google.com/maps/place/38°16'23.0"N+76°56'41.0"W/@38.2733,-76.945	13857	map
15223	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Sweetwater+Channel%2C+southwest+of%2C+California+Current+%2814d%29	13858	current
15224	https://www.google.com/maps/place/32°38'42.0"N+117°7'22.0"W/@32.645,-117.1228	13858	map
15225	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Table+Bluff+Light%2C+California+Current	13859	current
15226	https://www.google.com/maps/place/40°42'0.0"N+124°16'59.0"W/@40.7,-124.2833	13859	map
15227	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tampa+Bay+%28Sunshine+Skyway+Bridge%29%2C+Florida+Current	13860	current
15228	https://www.google.com/maps/place/27°37'12.0"N+82°39'18.0"W/@27.62,-82.655	13860	map
15229	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tampa+Bay+%28Sunshine+Skyway+Bridge%29%2C+Florida+Current+%2815d%29	13861	current
15230	https://www.google.com/maps/place/27°37'13.0"N+82°39'19.0"W/@27.6203,-82.6553	13861	map
15231	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tampa+Bay+Entrance+%28Egmont+Channel%29%2C+Florida+Current	13862	current
15232	https://www.google.com/maps/place/27°36'18.0"N+82°45'36.0"W/@27.605,-82.76	13862	map
15233	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tampa+Bay+Entrance+%28Egmont+Channel%29%2C+Florida+Current+%2815d%29	13863	current
15234	https://www.google.com/maps/place/27°36'15.0"N+82°45'37.0"W/@27.6043,-82.7603	13863	map
15235	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tampa+Bay+Entrance%2C+Florida+Current	13864	current
15236	https://www.google.com/maps/place/27°36'29.0"N+82°46'5.0"W/@27.6083,-82.7683	13864	map
15237	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tanaga+Pass%2C+4+mi%2E+off+C%2E+Amagalik%2C+Alaska+Current	13865	current
15238	https://www.google.com/maps/place/51°38'59.0"N+178°13'0.0"W/@51.65,-178.2167	13865	map
15239	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tarpaulin+Cove%2C+1%2E5+miles+east+of%2C+Massachusetts+Current	13866	current
15240	https://www.google.com/maps/place/41°28'18.0"N+70°43'29.0"W/@41.4717,-70.725	13866	map
15241	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Teaches+Hole+Channel%2C+Ocracoke+Inlet%2C+North+Carolina+Current+%2810d%29	13867	current
15242	https://www.google.com/maps/place/35°4'45.0"N+76°0'16.0"W/@35.0792,-76.0047	13867	map
15243	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tensaw+River+entrance+%28bridge%29%2C+Alabama+Current	13868	current
15244	https://www.google.com/maps/place/30°40'54.0"N+88°0'42.0"W/@30.6817,-88.0117	13868	map
15245	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Terminal+Channel+%28north+end%29%2C+Florida+Current+%2817d%29	13869	current
15246	https://www.google.com/maps/place/30°21'25.0"N+81°37'4.0"W/@30.357,-81.618	13869	map
15247	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Terminal+Channel+%28north+end%29%2C+Florida+Current+%2827d%29	13870	current
15248	https://www.google.com/maps/place/30°21'25.0"N+81°37'4.0"W/@30.357,-81.618	13870	map
15249	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Terminal+Channel+%28north+end%29%2C+Florida+Current+%287d%29	13871	current
15250	https://www.google.com/maps/place/30°21'25.0"N+81°37'4.0"W/@30.357,-81.618	13871	map
15251	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Thatcher+Pass%2C+Washington+Current	13872	current
15252	https://www.google.com/maps/place/48°31'39.0"N+122°48'10.0"W/@48.5275,-122.803	13872	map
15253	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=The+Cove%2C+entrance+on+the+Cove+Range%2C+South+Carolina+Current	13873	current
15254	https://www.google.com/maps/place/32°46'2.0"N+79°52'19.0"W/@32.7675,-79.872	13873	map
15255	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=The+Great+Bend%2C+Washington+Current	13874	current
15256	https://www.google.com/maps/place/47°42'0.0"N+122°46'0.0"W/@47.7,-122.7667	13874	map
15257	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=The+Narrows+%28Indian+Rocks+Beach+Bridge%29%2C+Florida+Current	13875	current
15258	https://www.google.com/maps/place/27°52'36.0"N+82°50'59.0"W/@27.8767,-82.85	13875	map
15259	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=The+Narrows+%28North+End%29%2C+Puget+Sound%2C+Washington+Current	13876	current
15260	https://www.google.com/maps/place/47°17'59.0"N+122°32'59.0"W/@47.3,-122.55	13876	map
15261	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=The+Narrows%2C+0%2E1+miles+E+of+Pt%2E+Evans%2C+Washington+Current	13877	current
15262	https://www.google.com/maps/place/47°16'59.0"N+122°32'59.0"W/@47.2833,-122.55	13877	map
15263	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=The+Narrows%2C+Midchannel%2C+New+York+Harbor%2C+New+York+Current	13878	current
15264	https://www.google.com/maps/place/40°36'35.0"N+74°2'48.0"W/@40.61,-74.0467	13878	map
15265	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=The+Narrows%2C+Midchannel%2C+New+York+Harbor%2C+New+York+Current+%282%29	13879	current
15266	https://www.google.com/maps/place/40°36'35.0"N+74°2'48.0"W/@40.61,-74.0467	13879	map
15267	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=The+Narrows%2C+north+end+%28midstream%29%2C+Washington+Current	13880	current
15268	https://www.google.com/maps/place/47°18'22.0"N+122°32'58.0"W/@47.3062,-122.5497	13880	map
15269	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=The+Narrows%2C+North+end+E+side%2C+Washington+Current	13881	current
15270	https://www.google.com/maps/place/47°17'59.0"N+122°31'59.0"W/@47.3,-122.5333	13881	map
15271	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=The+Narrows%2C+North+End%2C+W+side%2C+Washington+Current	13882	current
15272	https://www.google.com/maps/place/47°17'59.0"N+122°32'59.0"W/@47.3,-122.55	13882	map
15273	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=The+Narrows%2C+S+end+midstream%2C+Washington+Current	13883	current
15274	https://www.google.com/maps/place/47°16'0.0"N+122°32'59.0"W/@47.2667,-122.55	13883	map
15275	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=The+Race%2C+0%2E6+n%2Emi%2E+NW+of+Valiant+Rock%2C+New+York+Current+%2838d%29	13884	current
15276	https://www.google.com/maps/place/41°13'59.0"N+72°3'34.0"W/@41.2333,-72.0597	13884	map
15277	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=The+Race%2C+Long+Island+Sound%2C+New+York+Current	13885	current
15278	https://www.google.com/maps/place/41°14'12.0"N+72°3'36.0"W/@41.2367,-72.06	13885	map
15279	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=The+Race%2C+Long+Island+Sound%2C+New+York+Current+%282%29+%28expired+1993%2D12%2D31%29	13886	current
15280	https://www.google.com/maps/place/41°14'12.0"N+72°3'36.0"W/@41.2367,-72.06	13886	map
15281	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=The+Tee%2C+0%2E4+mile+southwest+of%2C+Cooper+River%2C+South+Carolina+Current	13887	current
15282	https://www.google.com/maps/place/33°3'47.0"N+79°55'46.0"W/@33.0633,-79.9297	13887	map
15283	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=The+Tee%2C+Cooper+River%2C+South+Carolina+Current	13888	current
15284	https://www.google.com/maps/place/33°3'56.0"N+79°55'22.0"W/@33.0658,-79.923	13888	map
15285	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Thomas+Pt%2E+Shoal+Lt%2E%2C+0%2E5+n%2Emi%2E+SE+of%2C+Maryland+Current+%2816d%29	13889	current
15286	https://www.google.com/maps/place/38°53'27.0"N+76°25'37.0"W/@38.891,-76.427	13889	map
15287	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Thomas+Pt%2E+Shoal+Lt%2E%2C+0%2E5+n%2Emi%2E+SE+of%2C+Maryland+Current+%2833d%29	13890	current
15288	https://www.google.com/maps/place/38°53'27.0"N+76°25'37.0"W/@38.891,-76.427	13890	map
15289	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Thomas+Pt%2E+Shoal+Lt%2E%2C+1%2E8+mi%2E+SW+of%2C+Maryland+Current	13891	current
15290	https://www.google.com/maps/place/38°52'30.0"N+76°27'42.0"W/@38.875,-76.4617	13891	map
15291	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Thomas+Pt%2E+Shoal+Lt%2E%2C+2%2E0+n%2Emi%2E+east+of%2C+Maryland+Current+%2822d%29	13892	current
15292	https://www.google.com/maps/place/38°53'44.0"N+76°23'12.0"W/@38.8958,-76.3868	13892	map
15293	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Throg%27s+Neck%2C+Long+Island+Sound%2C+New+York+Current	13893	current
15294	https://www.google.com/maps/place/40°48'6.0"N+73°47'17.0"W/@40.8017,-73.7883	13893	map
15295	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Throgs+Neck+Bridge%2C+New+York+Current+%2815d%29	13894	current
15296	https://www.google.com/maps/place/40°48'6.0"N+73°47'35.0"W/@40.8017,-73.7933	13894	map
15297	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Throgs+Neck%2C+0%2E2+mile+S+of+%28Willets+Point%29%2C+New+York+Current+%2815d%29	13895	current
15298	https://www.google.com/maps/place/40°48'7.0"N+73°47'28.0"W/@40.802,-73.7913	13895	map
15299	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Throgs+Neck%2C+0%2E3+n%2Emi%2E+NE+of%2C+Long+Island+Sound%2C+New+York+Current+%2815d%29	13896	current
15300	https://www.google.com/maps/place/40°48'38.0"N+73°47'7.0"W/@40.8107,-73.7855	13896	map
15301	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Throgs+Neck%2C+0%2E4+mile+south+of%2C+New+York+Current+%2815d%29	13897	current
15302	https://www.google.com/maps/place/40°47'53.0"N+73°47'26.0"W/@40.7983,-73.7908	13897	map
15303	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Thunderbolt%2C+SE+of%2C+Wilmington+River%2C+Georgia+Current+%2810d%29	13898	current
15304	https://www.google.com/maps/place/32°1'23.0"N+81°2'42.0"W/@32.0233,-81.045	13898	map
15305	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tillamook+Bay+entrance%2C+Oregon+Current	13899	current
15306	https://www.google.com/maps/place/45°33'43.0"N+123°56'17.0"W/@45.5621666666667,-123.938333333333	13899	map
15307	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tiverton%2C+RR%2E+bridge%2C+Sakonnet+R%2E%2C+Rhode+Island+Current	13900	current
15308	https://www.google.com/maps/place/41°38'17.0"N+71°12'54.0"W/@41.6383,-71.215	13900	map
15309	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tiverton%2C+Stone+bridge%2C+Sakonnet+R%2E%2C+Rhode+Island+Current	13901	current
15310	https://www.google.com/maps/place/41°37'30.0"N+71°13'0.0"W/@41.625,-71.2167	13901	map
15311	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Toe+Point%2C+Patos+Island%2C+0%2E5+mile+S+of%2C+Washington+Current	13902	current
15312	https://www.google.com/maps/place/48°46'41.0"N+122°56'26.0"W/@48.7783,-122.9408	13902	map
15313	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Toe+Point%2C+Patos+Island%2C+0%2E5+mile+South+of%2C+Washington+Current	13903	current
15314	https://www.google.com/maps/place/48°46'0.0"N+122°55'59.0"W/@48.7667,-122.9333	13903	map
15315	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tolchester+Beach%2C+0%2E33+n%2Emi%2E+west+of%2C+Maryland+Current+%2815d%29	13904	current
15316	https://www.google.com/maps/place/39°13'1.0"N+76°14'53.0"W/@39.2172,-76.2483	13904	map
15317	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tolchester+Channel%2C+Buoy+%2722%27%2C+Maryland+Current+%2815d%29	13905	current
15318	https://www.google.com/maps/place/39°11'28.0"N+76°15'56.0"W/@39.1912,-76.2658	13905	map
15319	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tolchester+Channel%2C+south+of+Buoy+%2738B%27%2C+Maryland+Current+%2815d%29	13906	current
15320	https://www.google.com/maps/place/39°11'34.0"N+76°17'16.0"W/@39.1928,-76.2878	13906	map
15321	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tolchester+Channel%2C+SW+of+Bouy+%2758B%27%2C+Maryland+Current+%2817d%29	13907	current
15322	https://www.google.com/maps/place/39°10'56.0"N+76°16'52.0"W/@39.1825,-76.2812	13907	map
15323	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tolchester+Channel%2C+SW+of+Bouy+%2758B%27%2C+Maryland+Current+%2825d%29	13908	current
15324	https://www.google.com/maps/place/39°10'56.0"N+76°16'52.0"W/@39.1825,-76.2812	13908	map
15325	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tolly+Point%2C+1%2E6+miles+east+of%2C+Maryland+Current	13909	current
15326	https://www.google.com/maps/place/38°56'4.0"N+76°25'1.0"W/@38.9345,-76.417	13909	map
15327	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tombstone+Point%2C+0%2E1+mile+E+of%2C+Beaufort+Inlet%2C+North+Carolina+Current+%2815d%29	13910	current
15328	https://www.google.com/maps/place/34°42'13.0"N+76°41'10.0"W/@34.7038,-76.6862	13910	map
15329	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tongue+Point%2C+northwest+of%2C+Oregon+Current+%2815d%29	13911	current
15330	https://www.google.com/maps/place/46°13'9.0"N+123°46'0.0"W/@46.2192,-123.7667	13911	map
15331	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Totten+Inlet+entrance%2C+Washington+Current	13912	current
15332	https://www.google.com/maps/place/47°11'19.0"N+122°56'41.0"W/@47.1888,-122.945	13912	map
15333	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Towhead+Island%2C+0%2E4+mile+East+of%2C+Washington+Current	13913	current
15334	https://www.google.com/maps/place/48°36'0.0"N+122°42'0.0"W/@48.6,-122.7	13913	map
15335	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Towhead+Island%2C+0%2E4+mile+east+of%2C+Washington+Current	13914	current
15336	https://www.google.com/maps/place/48°36'43.0"N+122°42'7.0"W/@48.6122,-122.7022	13914	map
15337	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Town+Creek+Lower+Reach%2C+South+Carolina+Current	13915	current
15338	https://www.google.com/maps/place/32°47'32.0"N+79°55'28.0"W/@32.7925,-79.9245	13915	map
15339	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Town+Creek%2C+0%2E2+mile+above+bridge%2C+South+Carolina+Current	13916	current
15340	https://www.google.com/maps/place/32°48'19.0"N+79°55'54.0"W/@32.8053,-79.9317	13916	map
15341	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Treasure+Island+%2E3+mi+E%2C+San+Francisco+Bay%2C+California+Current	13917	current
15342	https://www.google.com/maps/place/37°48'59.0"N+122°20'59.0"W/@37.816666,-122.35	13917	map
15343	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Treasure+Island+%2E5+mi+N%2C+San+Francisco+Bay%2C+California+Current	13918	current
15344	https://www.google.com/maps/place/37°49'59.0"N+122°21'59.0"W/@37.833333,-122.3666	13918	map
15345	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Trial+Island%2C+5%2E2+miles+SSW+of%2C+Washington+Current	13919	current
15346	https://www.google.com/maps/place/48°19'0.0"N+123°22'0.0"W/@48.3167,-123.3667	13919	map
15347	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Trinidad+Head%2C+California+Current	13920	current
15348	https://www.google.com/maps/place/41°2'59.0"N+124°10'0.0"W/@41.05,-124.1667	13920	map
15349	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Trout+River+Cut%2C+Florida+Current+%2815d%29	13921	current
15350	https://www.google.com/maps/place/30°23'1.0"N+81°37'41.0"W/@30.3838,-81.6282	13921	map
15351	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Trout+River+Cut%2C+Florida+Current+%2832d%29	13922	current
15352	https://www.google.com/maps/place/30°23'1.0"N+81°37'41.0"W/@30.3838,-81.6282	13922	map
15353	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Trout+River+Cut%2C+Florida+Current+%286d%29	13923	current
15354	https://www.google.com/maps/place/30°23'1.0"N+81°37'41.0"W/@30.3838,-81.6282	13923	map
15355	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tuckernuck+Island%2C+4%2E2+miles+SSW+of%2C+Massachusetts+Current	13924	current
15356	https://www.google.com/maps/place/41°13'34.0"N+70°16'54.0"W/@41.2262,-70.2817	13924	map
15357	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Tuckernuck+Shoal%2C+off+east+end%2C+Massachusetts+Current	13925	current
15358	https://www.google.com/maps/place/41°24'18.0"N+70°10'23.0"W/@41.405,-70.1733	13925	map
15359	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Turkey+Point%2C+1%2E2+n%2Emi%2E+SW+of%2C+Maryland+Current+%289d%29	13926	current
15360	https://www.google.com/maps/place/39°26'35.0"N+76°2'1.0"W/@39.4433,-76.0338	13926	map
15361	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Turn+Point%2C+Boundary+Pass%2C+Washington+Current	13927	current
15362	https://www.google.com/maps/place/48°41'43.0"N+123°14'7.0"W/@48.6953,-123.2355	13927	map
15363	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Turn+Rock+Light%2C+1%2E9+miles+northwest+of%2C+Washington+Current	13928	current
15364	https://www.google.com/maps/place/48°33'24.0"N+122°59'53.0"W/@48.5567,-122.9983	13928	map
15365	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Turn+Rock%2C+1%2E9+mile+NW+of%2C+Washington+Current	13929	current
15366	https://www.google.com/maps/place/48°32'59.0"N+122°58'59.0"W/@48.55,-122.9833	13929	map
15367	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Turning+Basin%2C+Beaufort+Inlet%2C+North+Carolina+Current+%2815d%29	13930	current
15368	https://www.google.com/maps/place/34°42'46.0"N+76°41'39.0"W/@34.713,-76.6942	13930	map
15369	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Turning+Basin%2C+Beaufort+Inlet%2C+North+Carolina+Current+%286d%29	13931	current
15370	https://www.google.com/maps/place/34°42'46.0"N+76°41'39.0"W/@34.713,-76.6942	13931	map
15371	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Turning+Basin%2C+Key+West%2C+Florida+Current	13932	current
15372	https://www.google.com/maps/place/24°34'0.0"N+81°48'15.0"W/@24.5667,-81.8042	13932	map
15373	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Turning+Basin%2C+Northeast+River%2C+North+Carolina+Current+%2820d%29	13933	current
15374	https://www.google.com/maps/place/34°14'51.0"N+77°57'13.0"W/@34.2475,-77.9538	13933	map
15375	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Turning+Basin%2C+Northeast+River%2C+North+Carolina+Current+%286d%29	13934	current
15376	https://www.google.com/maps/place/34°14'51.0"N+77°57'13.0"W/@34.2475,-77.9538	13934	map
15377	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Turtle+River%2C+off+Allied+Chemical+Corp%2C+Georgia+Current	13935	current
15378	https://www.google.com/maps/place/31°10'36.0"N+81°31'30.0"W/@31.1767,-81.525	13935	map
15379	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Turtle+River%2C+off+Andrews+Island%2C+Georgia+Current+%2820d%29	13936	current
15380	https://www.google.com/maps/place/31°8'35.0"N+81°31'36.0"W/@31.1433,-81.5267	13936	map
15381	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Twotree+Island+Channel%2C+Connecticut+Current+%2811d%29	13937	current
15382	https://www.google.com/maps/place/41°17'52.0"N+72°8'28.0"W/@41.2978,-72.1412	13937	map
15383	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Udagak+Strait+%28narrows%29%2C+Alaska+Current	13938	current
15384	https://www.google.com/maps/place/53°43'59.0"N+166°18'0.0"W/@53.7333,-166.3	13938	map
15385	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ugamak+Strait+%28North+end%29%2C+Alaska+Current	13939	current
15386	https://www.google.com/maps/place/54°12'0.0"N+164°55'0.0"W/@54.2,-164.9167	13939	map
15387	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ugamak+Strait%2C+off+Kaligagan+Island%2C+Alaska+Current	13940	current
15388	https://www.google.com/maps/place/54°8'59.0"N+164°52'59.0"W/@54.15,-164.8833	13940	map
15389	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Ulak+Pass%2C+Delarof+Islands%2C+Alaska+Current	13941	current
15390	https://www.google.com/maps/place/51°19'0.0"N+179°1'59.0"W/@51.3167,-179.0333	13941	map
15391	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Umak+Pass%2C+off+Narrows+Point%2C+Alaska+Current	13942	current
15392	https://www.google.com/maps/place/51°51'0.0"N+176°4'0.0"W/@51.85,-176.0667	13942	map
15393	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Umnak+Pass%2C+northwest+of+Ship+Rock%2C+Alaska+Current	13943	current
15394	https://www.google.com/maps/place/53°22'59.0"N+167°50'59.0"W/@53.3833,-167.85	13943	map
15395	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Umnak+Pass%2C+south+approach%2C+Alaska+Current	13944	current
15396	https://www.google.com/maps/place/53°15'0.0"N+167°55'0.0"W/@53.25,-167.9167	13944	map
15397	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Umnak+Pass%2C+southeast+of+Ship+Rock%2C+Alaska+Current	13945	current
15398	https://www.google.com/maps/place/53°21'0.0"N+167°48'0.0"W/@53.35,-167.8	13945	map
15399	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Umpqua+River+entrance%2C+Oregon+Current	13946	current
15400	https://www.google.com/maps/place/43°40'41.0"N+124°11'35.0"W/@43.6783333333333,-124.193333333333	13946	map
15401	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Unalga+Pass%2C+Alaska+Current	13947	current
15402	https://www.google.com/maps/place/53°57'0.0"N+166°11'59.0"W/@53.95,-166.2	13947	map
15403	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Unga+Strait+%281%2E4+miles+N+of+Unga+Spit%29%2C+Alaska+Current	13948	current
15404	https://www.google.com/maps/place/55°25'59.0"N+160°43'59.0"W/@55.4333,-160.7333	13948	map
15405	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Unimak+Pass+%28off+Scotch+Cap%29%2C+Alaska+Current	13949	current
15406	https://www.google.com/maps/place/54°21'54.0"N+164°48'0.0"W/@54.365,-164.8	13949	map
15407	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Unimak+Pass%2C+11+miles+WSW+of+Sennett+Pt%2C+Alaska+Current	13950	current
15408	https://www.google.com/maps/place/54°25'0.0"N+165°11'59.0"W/@54.4167,-165.2	13950	map
15409	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Unimak+Pass%2C+2%2E4+miles+N+of+Tanginak+I%2C+Alaska+Current	13951	current
15410	https://www.google.com/maps/place/54°13'59.0"N+165°18'0.0"W/@54.2333,-165.3	13951	map
15411	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Upper+Hell+Gate+%28Sasanoa+River%2C+Maine%29+Current	13952	current
15412	https://www.google.com/maps/place/43°53'42.0"N+69°46'18.0"W/@43.895,-69.7717	13952	map
15413	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Upper+Midnight+channel%2C+North+Carolina+Current	13953	current
15414	https://www.google.com/maps/place/34°1'43.0"N+77°56'25.0"W/@34.0287,-77.9405	13953	map
15415	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Vanderbilt+Reef%2C+2+miles+west+of%2C+Alaska+Current	13954	current
15416	https://www.google.com/maps/place/58°34'59.0"N+135°4'0.0"W/@58.5833,-135.0667	13954	map
15417	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Venice+Inlet%2C+Florida+Current	13955	current
15418	https://www.google.com/maps/place/27°6'47.0"N+82°28'0.0"W/@27.1133,-82.4667	13955	map
15419	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Vernon+R%2E%2C+1%2E2+miles+S+of+Possum+Point%2C+Georgia+Current	13956	current
15420	https://www.google.com/maps/place/31°53'53.0"N+81°5'53.0"W/@31.8983,-81.0983	13956	map
15421	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Vieques+Passage%2C+Puerto+Rico+Current	13957	current
15422	https://www.google.com/maps/place/18°11'17.0"N+65°37'5.0"W/@18.1883,-65.6183	13957	map
15423	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Vieques+Passage%2C+Puerto+Rico+Current+%282%29	13958	current
15424	https://www.google.com/maps/place/18°11'17.0"N+65°37'5.0"W/@18.1883,-65.6183	13958	map
15425	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Vieques+Sound%2C+Puerto+Rico+Current	13959	current
15426	https://www.google.com/maps/place/18°15'52.0"N+65°34'11.0"W/@18.2645,-65.57	13959	map
15427	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Violet+Point%2C+3%2E2+miles+northwest+of%2C+Washington+Current	13960	current
15428	https://www.google.com/maps/place/48°10'0.0"N+122°58'0.0"W/@48.1667,-122.9667	13960	map
15429	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Violet+Point%2C+3%2E2+miles+NW+of%2C+Washington+Current	13961	current
15430	https://www.google.com/maps/place/48°10'0.0"N+122°58'0.0"W/@48.1667,-122.9667	13961	map
15431	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Violet+Point%2C+3%2E7+miles+N+of%2C+Washington+Current	13962	current
15432	https://www.google.com/maps/place/48°10'59.0"N+122°55'0.0"W/@48.1833,-122.9167	13962	map
15433	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Vulcan+Island+%2E5+mi+E%2C+San+Joaquin+River%2C+California+Current	13963	current
15434	https://www.google.com/maps/place/37°58'59.0"N+121°22'59.0"W/@37.983333,-121.3833	13963	map
15435	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=W+Howard+Frankland+Bridge%2C+Florida+Current	13964	current
15436	https://www.google.com/maps/place/27°55'32.0"N+82°35'10.0"W/@27.9258,-82.5862	13964	map
15437	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wadmalaw+Island%2C+Wadmalaw+River+entrance%2C+South+Carolina+Current+%2812d%29	13965	current
15438	https://www.google.com/maps/place/32°39'53.0"N+80°14'5.0"W/@32.665,-80.235	13965	map
15439	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Waldron+Island%2C+1%2E7+miles+West+of%2C+Washington+Current	13966	current
15440	https://www.google.com/maps/place/48°42'0.0"N+123°7'0.0"W/@48.7,-123.1167	13966	map
15441	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Waldron+Island%2C+1%2E7+miles+west+of%2C+Washington+Current	13967	current
15442	https://www.google.com/maps/place/48°42'15.0"N+123°6'31.0"W/@48.7042,-123.1087	13967	map
15443	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Walker+Island%2C+south+of%2C+Washington+Current+%2812d%29	13968	current
15444	https://www.google.com/maps/place/46°8'28.0"N+123°2'44.0"W/@46.1412,-123.0458	13968	map
15445	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wallace+Channel%2C+Ocracoke+Inlet%2C+North+Carolina+Current+%289d%29	13969	current
15446	https://www.google.com/maps/place/35°4'46.0"N+76°3'7.0"W/@35.0797,-76.052	13969	map
15447	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Walls+Cut%2C+Turtle+Island%2C+South+Carolina+Current+%286d%29	13970	current
15448	https://www.google.com/maps/place/32°4'54.0"N+80°55'0.0"W/@32.0817,-80.9167	13970	map
15449	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Walrus+Island%2C+0%2E5+mile+west+of%2C+Pribilof+Islands%2C+Alaska+Current	13971	current
15450	https://www.google.com/maps/place/57°10'59.0"N+169°56'59.0"W/@57.1833,-169.95	13971	map
15451	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wando+River+Upper+Reach%2C+Turning+Basin%2C+Wando+River%2C+South+Carolina+Current	13972	current
15452	https://www.google.com/maps/place/32°49'59.0"N+79°53'48.0"W/@32.8333,-79.8967	13972	map
15453	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wappoo+Creek%2C+off+of%2C+Ashley+River%2C+South+Carolina+Current	13973	current
15454	https://www.google.com/maps/place/32°46'22.0"N+79°57'0.0"W/@32.773,-79.95	13973	map
15455	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Waquoit+Bay+entrance%2C+Massachusetts+Current	13974	current
15456	https://www.google.com/maps/place/41°32'53.0"N+70°31'48.0"W/@41.5483,-70.53	13974	map
15457	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wareham+River%2C+off+Barneys+Point%2C+Massachusetts+Current	13975	current
15458	https://www.google.com/maps/place/41°44'41.0"N+70°42'24.0"W/@41.745,-70.7067	13975	map
15459	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wareham+River%2C+off+Long+Beach+Point%2C+Massachusetts+Current	13976	current
15460	https://www.google.com/maps/place/41°43'59.0"N+70°43'0.0"W/@41.7333,-70.7167	13976	map
15461	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Warehouse+Bluff%2C+southwest+of%2C+Alaska+Current	13977	current
15462	https://www.google.com/maps/place/59°46'59.0"N+162°13'59.0"W/@59.7833,-162.2333	13977	map
15463	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Warren%2C+Warren+River%2C+Rhode+Island+Current	13978	current
15464	https://www.google.com/maps/place/41°43'41.0"N+71°17'17.0"W/@41.7283,-71.2883	13978	map
15465	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wasp+Passage+Light%2C+0%2E5+mile+WSW+of%2C+Washington+Current	13979	current
15466	https://www.google.com/maps/place/48°35'31.0"N+122°59'22.0"W/@48.5922,-122.9895	13979	map
15467	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wasque+Point%2C+2%2E0+miles+southwest+of%2C+Massachusetts+Current	13980	current
15468	https://www.google.com/maps/place/41°19'54.0"N+70°29'14.0"W/@41.3317,-70.4875	13980	map
15469	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wassaw+Island%2C+N+of+E+end%2C+Wassaw+Sound%2C+Georgia+Current+%2810d%29	13981	current
15470	https://www.google.com/maps/place/31°54'53.0"N+80°56'17.0"W/@31.915,-80.9383	13981	map
15471	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wassaw+Island%2C+SSW+of%2C+Georgia+Current+%2810d%29	13982	current
15472	https://www.google.com/maps/place/31°51'24.0"N+81°0'29.0"W/@31.8567,-81.0083	13982	map
15473	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wassaw+Island%2C+SSW+of%2C+Georgia+Current+%2820d%29	13983	current
15474	https://www.google.com/maps/place/31°51'24.0"N+81°0'29.0"W/@31.8567,-81.0083	13983	map
15475	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Watch+Hill+Point%2C+2%2E2+miles+east+of%2C+Rhode+Island+Current	13984	current
15476	https://www.google.com/maps/place/41°18'9.0"N+71°48'36.0"W/@41.3027,-71.81	13984	map
15477	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Watch+Hill+Point%2C+5%2E2+miles+SSE+of%2C+Rhode+Island+Current+%2815d%29	13985	current
15478	https://www.google.com/maps/place/41°13'11.0"N+71°49'0.0"W/@41.22,-71.8167	13985	map
15479	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Watch+Hill+Point%2C+5%2E3+n%2Emi%2E+SE+of%2C+Rhode+Island+Current+%2815d%29	13986	current
15480	https://www.google.com/maps/place/41°14'39.0"N+71°46'25.0"W/@41.2442,-71.7738	13986	map
15481	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Weedon+I%2E+powerplant+channel%2C+marker+%2710%27%2C+Florida+Current+%2823d%29	13987	current
15482	https://www.google.com/maps/place/27°51'43.0"N+82°35'7.0"W/@27.862,-82.5853	13987	map
15483	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Weepecket+Island%2C+south+of%2C+Massachusetts+Current	13988	current
15484	https://www.google.com/maps/place/41°30'24.0"N+70°44'17.0"W/@41.5067,-70.7383	13988	map
15485	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=West+207th+Street+Bridge%2C+New+York+Current	13989	current
15486	https://www.google.com/maps/place/40°51'47.0"N+73°54'54.0"W/@40.8633,-73.915	13989	map
15487	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=West+Chop%2C+0%2E2+mile+west+of%2C+Massachusetts+Current	13990	current
15488	https://www.google.com/maps/place/41°28'59.0"N+70°36'35.0"W/@41.4833,-70.61	13990	map
15489	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=West+Chop%2C+0%2E8+mile+north+of%2C+Massachusetts+Current	13991	current
15490	https://www.google.com/maps/place/41°29'35.0"N+70°35'41.0"W/@41.4933,-70.595	13991	map
15491	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=West+end%2C+Rich+Passage%2C+Washington+Current	13992	current
15492	https://www.google.com/maps/place/47°35'24.0"N+122°33'43.0"W/@47.59,-122.5622	13992	map
15493	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=West+Island+Lt+%2E5+mi+SE%2C+San+Joaquin+River%2C+California+Current	13993	current
15494	https://www.google.com/maps/place/38°0'59.0"N+121°46'0.0"W/@38.01666,-121.76667	13993	map
15495	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=West+Island%2C+1+mile+southeast+of%2C+Massachusetts+Current+%286d%29	13994	current
15496	https://www.google.com/maps/place/41°34'0.0"N+70°48'36.0"W/@41.5667,-70.81	13994	map
15497	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=West+Marsh+Island%2C+0%2E1+mile+east+of%2C+Ashley+River%2C+South+Carolina+Current	13995	current
15498	https://www.google.com/maps/place/32°49'41.0"N+80°0'29.0"W/@32.8283,-80.0083	13995	map
15499	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=west+of%2C+off+63rd+Street%2C+Roosevelt+Island%2C+New+York+Current	13996	current
15500	https://www.google.com/maps/place/40°45'34.0"N+73°57'16.0"W/@40.7597,-73.9545	13996	map
15501	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=west+of%2C+off+67th+Street%2C+Roosevelt+Island%2C+New+York+Current	13997	current
15502	https://www.google.com/maps/place/40°45'44.0"N+73°57'14.0"W/@40.7623,-73.954	13997	map
15503	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=west+of%2C+off+75th+Street%2C+Roosevelt+Island%2C+New+York+Current	13998	current
15504	https://www.google.com/maps/place/40°46'0.0"N+73°57'0.0"W/@40.7667,-73.95	13998	map
15505	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=West+Point%2C+0%2E3+mile+west+of%2C+Washington+Current	13999	current
15506	https://www.google.com/maps/place/47°39'40.0"N+122°26'19.0"W/@47.6612,-122.4388	13999	map
15507	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=West+Point%2C+Seattle%2C+0%2E3+miles+W+of%2C+Washington+Current	14000	current
15508	https://www.google.com/maps/place/47°42'0.0"N+122°37'59.0"W/@47.7,-122.6333	14000	map
15509	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=West+Point%2C+Whidbey+Island%2C+1%2E8+miles+SW+of%2C+Washington+Current	14001	current
15510	https://www.google.com/maps/place/47°22'59.0"N+122°42'0.0"W/@47.3833,-122.7	14001	map
15511	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Westport+River+entrance%2C+Massachusetts+Current	14002	current
15512	https://www.google.com/maps/place/41°30'29.0"N+71°5'17.0"W/@41.5083,-71.0883	14002	map
15513	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Westport+River+Entrance%2C+Massachusetts+Current	14003	current
15514	https://www.google.com/maps/place/41°30'29.0"N+71°5'17.0"W/@41.5083,-71.0883	14003	map
15515	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Westport%2C+channel+0%2E4+mile+NE+of%2C+Washington+Current	14004	current
15516	https://www.google.com/maps/place/46°54'51.0"N+124°6'29.0"W/@46.9142,-124.1083	14004	map
15517	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Weynton+Passage%2C+British+Columbia+Current	14005	current
15518	https://www.google.com/maps/place/50°36'11.0"N+126°48'42.0"W/@50.6033,-126.8117	14005	map
15519	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Whale+Branch+River%2C+South+Carolina+Current+%2810d%29	14006	current
15520	https://www.google.com/maps/place/32°31'36.0"N+80°41'30.0"W/@32.5267,-80.6917	14006	map
15521	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=White+Point%2C+south+of%2C+Dawho+River%2C+South+Carolina+Current+%2812d%29	14007	current
15522	https://www.google.com/maps/place/32°37'30.0"N+80°16'54.0"W/@32.625,-80.2817	14007	map
15523	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Whooping+Island%2C+Dawho+River%2C+South+Carolina+Current+%2812d%29	14008	current
15524	https://www.google.com/maps/place/32°38'12.0"N+80°20'24.0"W/@32.6367,-80.34	14008	map
15525	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wicopesset+Island%2C+1%2E1+miles+SSE+of%2C+Rhode+Island+Current	14009	current
15526	https://www.google.com/maps/place/41°16'29.0"N+71°54'47.0"W/@41.275,-71.9133	14009	map
15527	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wilcox+Island+Park%2C+east+of%2C+Connecticut+River%2C+Connecticut+Current	14010	current
15528	https://www.google.com/maps/place/41°34'19.0"N+72°38'52.0"W/@41.5722,-72.648	14010	map
15529	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=William+Point+Light%2C+0%2E8+miles+W+of%2C+Washington+Current	14011	current
15530	https://www.google.com/maps/place/47°34'59.0"N+122°34'59.0"W/@47.5833,-122.5833	14011	map
15531	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Williamsburg+Bridge%2C+0%2E3+mile+north+of%2C+New+York+Current	14012	current
15532	https://www.google.com/maps/place/40°43'4.0"N+73°58'14.0"W/@40.718,-73.9707	14012	map
15533	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Williman+Creek%2C+South+Carolina+Current+%2810d%29	14013	current
15534	https://www.google.com/maps/place/32°33'42.0"N+80°35'30.0"W/@32.5617,-80.5917	14013	map
15535	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Willis+Ave%2E+Bridge%2C+0%2E1+mile+NW+of%2C+New+York+Current	14014	current
15536	https://www.google.com/maps/place/40°48'17.0"N+73°55'48.0"W/@40.805,-73.93	14014	map
15537	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wilmington+Island%2C+SSE+of%2C+Bull+River%2C+Georgia+Current+%2810d%29	14015	current
15538	https://www.google.com/maps/place/31°58'0.0"N+80°55'48.0"W/@31.9667,-80.93	14015	map
15539	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wilmington+R%2E+ent%2E%2C+south+channel%2C+Georgia+Current	14016	current
15540	https://www.google.com/maps/place/32°4'36.0"N+81°0'6.0"W/@32.0767,-81.0017	14016	map
15541	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wilmington+R%2E%2C+0%2E5+mi%2E+S+of+Turners+Creek%2C+Georgia+Current	14017	current
15542	https://www.google.com/maps/place/32°0'18.0"N+81°0'11.0"W/@32.005,-81.0033	14017	map
15543	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wilmington+River+ent%2E+off+Cabbage+Island%2C+Georgia+Current	14018	current
15544	https://www.google.com/maps/place/31°56'17.0"N+80°58'36.0"W/@31.9383,-80.9767	14018	map
15545	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wilmington%2C+North+Carolina+Current+%2820d%29	14019	current
15546	https://www.google.com/maps/place/34°14'12.0"N+77°57'10.0"W/@34.2367,-77.9528	14019	map
15547	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wilmington%2C+North+Carolina+Current+%286d%29	14020	current
15548	https://www.google.com/maps/place/34°14'12.0"N+77°57'10.0"W/@34.2367,-77.9528	14020	map
15549	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wilson+Point+3%2E9+mi+NNW%2C+San+Pablo+Bay%2C+California+Current	14021	current
15550	https://www.google.com/maps/place/38°3'59.0"N+122°19'59.0"W/@38.066666,-122.3333	14021	map
15551	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Winter+Point%2C+Florida+Current	14022	current
15552	https://www.google.com/maps/place/30°18'29.0"N+81°40'29.0"W/@30.3083,-81.675	14022	map
15553	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Winthrop+Point%2C+Thames+River%2C+Connecticut+Current	14023	current
15554	https://www.google.com/maps/place/41°21'37.0"N+72°5'17.0"W/@41.3605,-72.0883	14023	map
15555	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Winyah+Bay+entrance%2C+South+Carolina+Current	14024	current
15556	https://www.google.com/maps/place/33°12'25.0"N+79°11'4.0"W/@33.2072,-79.1845	14024	map
15557	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Woods+Hole%2C+Massachusetts+Current+%28use+with+caution%29	14025	current
15558	https://www.google.com/maps/place/41°31'12.0"N+70°41'6.0"W/@41.52,-70.685	14025	map
15559	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Woods+Point%2C+Cooper+River%2C+South+Carolina+Current	14026	current
15560	https://www.google.com/maps/place/32°55'54.0"N+79°56'17.0"W/@32.9317,-79.9383	14026	map
15561	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Woods+Point%2C+SE+of%2C+Cooper+River%2C+South+Carolina+Current	14027	current
15562	https://www.google.com/maps/place/32°55'32.0"N+79°55'58.0"W/@32.9258,-79.9328	14027	map
15563	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Woody+Island+Channel+%28off+Seal+Island%29%2C+Oregon+Current+%2812d%29	14028	current
15564	https://www.google.com/maps/place/46°13'3.0"N+123°37'45.0"W/@46.2175,-123.6292	14028	map
15565	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Woody+Island+Channel%2C+Washington+Current+%2815d%29	14029	current
15566	https://www.google.com/maps/place/46°14'22.0"N+123°40'23.0"W/@46.2395,-123.6733	14029	map
15567	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wooster+Island%2C+0%2E1+mile+southwest+of%2C+Housatonic+River%2C+Connecticut+Current+%285d%29	14030	current
15568	https://www.google.com/maps/place/41°16'40.0"N+73°5'12.0"W/@41.2778,-73.0867	14030	map
15569	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Worton+Point%2C+1%2E1+miles+northwest+of%2C+Maryland+Current	14031	current
15570	https://www.google.com/maps/place/39°19'54.0"N+76°12'0.0"W/@39.3317,-76.2	14031	map
15571	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Worton+Point%2C+1%2E5+n%2Emi%2E+WSW+of%2C+Maryland+Current+%2817d%29	14032	current
15572	https://www.google.com/maps/place/39°18'42.0"N+76°13'1.0"W/@39.3117,-76.2172	14032	map
15573	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wrangell+Narrows+%28off+Petersburg%29%2C+Alaska+Current	14033	current
15574	https://www.google.com/maps/place/56°49'0.0"N+132°58'0.0"W/@56.8167,-132.9667	14033	map
15575	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wreck+Shoal%2DEldridge+Shoal%2C+between%2C+Massachusetts+Current	14034	current
15576	https://www.google.com/maps/place/41°31'59.0"N+70°25'41.0"W/@41.5333,-70.4283	14034	map
15577	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wright+R%2E%2C+0%2E2+mile+above+Walls+Cut%2C+South+Carolina+Current	14035	current
15578	https://www.google.com/maps/place/32°5'6.0"N+80°55'18.0"W/@32.085,-80.9217	14035	map
15579	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Wye+River%2C+west+of+Bruffs+Island%2C+Maryland+Current+%289d%29	14036	current
15580	https://www.google.com/maps/place/38°51'16.0"N+76°11'52.0"W/@38.8547,-76.198	14036	map
15581	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Yakobi+Rock%2C+1+mile+west+of%2C+Alaska+Current	14037	current
15582	https://www.google.com/maps/place/58°4'59.0"N+136°35'59.0"W/@58.0833,-136.6	14037	map
15583	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Yaquina+Bay+entrance%2C+Oregon+Current	14038	current
15584	https://www.google.com/maps/place/44°37'0.0"N+124°4'0.0"W/@44.6166666666667,-124.066666666667	14038	map
15585	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Yaquina+Bay%2C+Highway+Bridge%2C+Oregon+Current	14039	current
15586	https://www.google.com/maps/place/44°37'23.0"N+124°3'25.0"W/@44.6233333333333,-124.057	14039	map
15587	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Yaquina+River%2C+1+mile+below+Toledo%2C+Oregon+Current	14040	current
15588	https://www.google.com/maps/place/44°36'1.0"N+123°56'30.0"W/@44.6005,-123.941666666667	14040	map
15589	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Yaquina%2C+Yaquina+River%2C+Oregon+Current	14041	current
15590	https://www.google.com/maps/place/44°36'7.0"N+124°0'40.0"W/@44.602,-124.011333333333	14041	map
15591	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Yellow+Bluff+%2E8+mi+E%2C+San+Francisco+Bay%2C+California+Current	14042	current
15592	https://www.google.com/maps/place/37°49'59.0"N+122°27'0.0"W/@37.833333,-122.45	14042	map
15593	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Yellow+House+Creek%2C+Cooper+River%2C+South+Carolina+Current	14043	current
15594	https://www.google.com/maps/place/32°54'31.0"N+79°56'10.0"W/@32.9088,-79.9363	14043	map
15595	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Yellow+House+Landing%2C+1+mile+NW+of%2C+Cooper+River%2C+South+Carolina+Current	14044	current
15596	https://www.google.com/maps/place/32°55'10.0"N+79°55'49.0"W/@32.9197,-79.9305	14044	map
15597	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Yerba+Buena+Island+W+of%2C+San+Francisco+Bay%2C+California+Current	14045	current
15598	https://www.google.com/maps/place/37°47'59.0"N+122°22'59.0"W/@37.8,-122.3833	14045	map
15599	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Yokeko+Point%2C+Deception+Pass%2C+Washington+Current	14046	current
15600	https://www.google.com/maps/place/48°24'46.0"N+122°36'49.0"W/@48.4128,-122.6137	14046	map
15601	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Youngs+Bay+Bridge%2C+Oregon+Current+%289d%29	14047	current
15602	https://www.google.com/maps/place/46°10'40.0"N+123°52'5.0"W/@46.1778,-123.8683	14047	map
15603	http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Youngs+Bay+Entrance%2C+Oregon+Current+%2817d%29	14048	current
15604	https://www.google.com/maps/place/46°11'10.0"N+123°53'16.0"W/@46.1863,-123.8878	14048	map
15606	https://www.google.com/maps/place/0°44'49.0"N+1°14'9.0"W/@0.7471149596668983,-1.2358575378808156	14050	map
\.


--
-- TOC entry 3506 (class 0 OID 26586)
-- Dependencies: 225
-- Data for Name: fishes; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.fishes (id, species, weight, length, description, image, date_time_caught, angler_id, fishing_spot_id, bait_id, gear_id) FROM stdin;
\.


--
-- TOC entry 3508 (class 0 OID 26610)
-- Dependencies: 227
-- Data for Name: fishing_conditions; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.fishing_conditions (id, weather, tide_phase, time_stamp, current_flow, current_speed, moon_phase, wind_direction, wind_speed, pressure_yesterday, pressure_today) FROM stdin;
\.


--
-- TOC entry 3495 (class 0 OID 26489)
-- Dependencies: 214
-- Data for Name: fishing_gear; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.fishing_gear (id, rod, reel, line, hook, leader) FROM stdin;
2	Dark Matter John Skinner 2 9'2"	Van Staal VR 151	PowerPro braid 30 lb		Seaguar 50 lb
1	Penn Carnage II 10'	Penn Battle III 6000	PowerPro braid 30lb		Seaquar Gold 50lb
\.


--
-- TOC entry 3497 (class 0 OID 26498)
-- Dependencies: 216
-- Data for Name: fishing_outings; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.fishing_outings (id, name, outing_date, fishing_spot_id, fishing_conditions_id) FROM stdin;
\.


--
-- TOC entry 3513 (class 0 OID 26824)
-- Dependencies: 232
-- Data for Name: fishing_spots; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.fishing_spots (id, name, description, nickname, is_public, global_position_id, current_url_id) FROM stdin;
7	Plum Island Beach North	Next to the jetty on the beach front	Plum Island Beach Shallows	f	14050	14225
\.


--
-- TOC entry 3519 (class 0 OID 26970)
-- Dependencies: 238
-- Data for Name: global_positions; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.global_positions (id, latitude, longitude) FROM stdin;
3150	0.8252928994395348	-2.138805005210191
3151	0.7246607054280457	-1.233685981772192
3152	0.8395033702092726	-2.1412275222119592
3153	0.5965744822826857	-1.360759913951395
3154	0.5965744822826857	-1.360759913951395
3155	0.8395033702092726	-2.1412275222119592
3156	0.7193671218067469	-1.2583823906879115
3157	0.48340384292486943	-1.4422091941542143
3158	0.8397948401943556	-2.1415189921970423
3159	0.8397948401943556	-2.1409377975561283
3160	0.5969985972909204	-1.3609117575963185
3161	0.4831891674268741	-1.4418112590847598
3162	0.7213655238002804	-1.248098910735161
3163	0.4827667977478915	-1.4423697644453979
3164	0.5704224687708027	-2.0445275550052133
3165	0.5704224687708027	-2.0445275550052133
3166	0.5702810971013912	-2.044644492065097
3167	0.4829849639043908	-1.4415197890996767
3168	0.5551979617056563	-1.4168006909036808
3169	0.7275404986938363	-1.2334817782497085
3170	0.7159637297653579	-1.2587890524036263
3171	0.8528848095843131	-2.151990967709008
3172	0.9037890825479796	-3.0892327760299634
3173	0.9040805525330626	-3.088360111403966
3174	0.8403760348352697	-2.1415189921970423
3175	0.8383392355981922	-2.140354857585962
3176	0.8382816397328765	-2.14041419878053
3177	0.8328135231863782	-2.138900998319051
3178	0.8325220532012952	-2.1391924683041337
3179	0.832906025636734	-2.1389882647816507
3180	0.8327454553455504	-2.13917152435311
3181	0.9428565325246208	-2.898148893533868
3182	0.6585708986014296	-2.133954735218899
3183	0.6602004601641391	-2.1365744744261423
3184	0.6600253338269939	-2.1362830044410597
36	0.8252928994395348	-2.138805005210191
37	0.7246607054280457	-1.233685981772192
38	0.8395033702092726	-2.1412275222119592
39	0.5965744822826857	-1.360759913951395
40	0.5965744822826857	-1.360759913951395
41	0.8395033702092726	-2.1412275222119592
42	0.7193671218067469	-1.2583823906879115
43	0.48340384292486943	-1.4422091941542143
44	0.8397948401943556	-2.1415189921970423
45	0.8397948401943556	-2.1409377975561283
46	0.5969985972909204	-1.3609117575963185
47	0.4831891674268741	-1.4418112590847598
48	0.7213655238002804	-1.248098910735161
49	0.4827667977478915	-1.4423697644453979
50	0.5704224687708027	-2.0445275550052133
51	0.5704224687708027	-2.0445275550052133
52	0.5702810971013912	-2.044644492065097
53	0.4829849639043908	-1.4415197890996767
54	0.5551979617056563	-1.4168006909036808
55	0.7275404986938363	-1.2334817782497085
56	0.7159637297653579	-1.2587890524036263
57	0.8528848095843131	-2.151990967709008
58	0.9037890825479796	-3.0892327760299634
59	0.9040805525330626	-3.088360111403966
60	0.8403760348352697	-2.1415189921970423
61	0.8383392355981922	-2.140354857585962
62	0.8382816397328765	-2.14041419878053
63	0.8328135231863782	-2.138900998319051
64	0.8325220532012952	-2.1391924683041337
65	0.832906025636734	-2.1389882647816507
66	0.8327454553455504	-2.13917152435311
67	0.9428565325246208	-2.898148893533868
68	0.6585708986014296	-2.133954735218899
69	0.6602004601641391	-2.1365744744261423
70	0.6600253338269939	-2.1362830044410597
71	0.6600253338269939	-2.1365727290968906
72	0.6603162278534239	-2.1368641990819737
73	0.6603162278534239	-2.1365727290968906
74	0.8333947178272924	-2.1464635099679423
75	0.8509841460288913	-2.1464111500903824
76	0.8303491182825622	-2.1367716966316177
77	0.831940858560381	-2.1368641990819737
78	0.7264357052773238	-1.2430234932703614
79	0.9686577348568529	-2.8477961446138313
80	0.9660397409788615	-2.84517815073584
81	0.5752465588233151	-1.3948322316088284
82	0.6606071218798537	-2.1362830044410597
83	0.6606071218798537	-2.1362830044410597
84	0.6638068863574125	-2.1261007535849243
85	1.101594227993505	-2.9484423012593366
86	1.049524075089506	-2.8303428520938883
87	0.8345588524383726	-2.1374471390521395
88	0.605135322263718	-1.3381439375040525
89	0.48578272669533773	-1.6937547725978972
90	0.4857914533415977	-1.6937408099638813
91	0.4857914533415977	-1.6937408099638813
92	0.4857914533415977	-1.6937408099638813
93	0.6887732453485382	-1.3259999365686759
94	0.5675810727485561	-1.404785844332952
95	0.5674065398233565	-1.4050773143180348
96	0.5676683392111557	-1.404174979094754
97	0.5673489439580408	-1.4034192515286403
98	0.9445145953140154	-2.8879387174097015
99	0.7213742504465402	-1.253940527741586
100	0.9421863260918549	-2.8984106929216673
101	0.5754053837852465	-1.3950992669843834
102	0.5436403913989497	-1.421425813421466
103	0.5436403913989497	-1.421425813421466
104	0.43034059767648586	-1.4187484783489066
105	0.43034059767648586	-1.4187484783489066
106	0.8074242185576167	-2.1641733658879287
107	0.6596960600103128	-2.1378276208290745
108	0.6596960600103128	-2.1378276208290745
109	0.8235772407848243	-2.1414701229779864
110	0.6759520566633879	-1.3317734857342733
111	0.5912093401620553	-1.3614877162494765
112	0.5706493615735619	-2.0460931153442523
113	0.5706493615735619	-2.0460931153442523
114	0.5704311954170628	-2.0461070779782684
115	0.5704521393680866	-2.0460878793564965
116	0.6809053010805478	-1.3328782791507856
117	0.6809105370683037	-1.3328782791507856
118	0.5428846638328362	-1.4196211429749037
119	0.5470734540376225	-1.4178182178575935
120	0.5137673359218148	-1.5700981950940986
121	0.5108875426560241	-1.5698939915716157
122	0.694059847652829	-1.2935804457128812
123	0.8497275089674553	-2.1430688445728134
124	0.8496838757361554	-2.1426831268081226
125	0.7202973822980598	-1.258876318866226
126	1.033526387165726	-2.362303142574325
127	0.571895526659486	-1.3951079936306434
128	0.5625772137830882	-1.4072589758830278
129	0.7093314786077795	-1.2940447032939117
130	0.7093314786077795	-1.2940447032939117
131	1.0204364177757688	-2.3742289773532024
132	0.56635934227216	-1.407840170523942
133	0.563537144871685	-1.4076377123307107
134	0.5655442735114786	-1.4079867781811095
135	0.566010276421761	-1.4080740446437092
136	0.7235838372795651	-1.2463692894464347
137	0.9596396186117983	-2.8524491923996487
138	0.5732830634148214	-1.3971360662214607
139	0.8475371207562024	-2.1408854376785684
140	0.8473573518432469	-2.1406463275710452
141	0.6721559655403002	-1.3381823347475965
142	0.7093314786077795	-1.2940447032939117
143	0.7093314786077795	-1.2940447032939117
144	0.6606071218798537	-2.134537675189065
145	0.6606455191233976	-2.1347331520652886
146	0.47647488579445196	-1.4410014263118343
147	0.6056379770882923	-1.3378611941652294
148	0.7196568464625779	-1.2602149864025056
149	0.7203549781633756	-1.2602725822678214
150	0.7244285766375305	-1.2430234932703614
151	0.473390889006178	-1.4393730341197235
152	0.6122841908798867	-1.3270401528028646
153	0.8294677270103051	-2.1380196070467936
154	0.8307767239493009	-2.1409377975561283
155	0.48444580448831004	-1.4444641595477912
156	0.6778771548283377	-1.3334804177427235
157	0.5600464863676964	-1.4116222990130136
158	0.5599312946370648	-1.4116798948783296
159	0.5304404662661166	-1.4225916933617981
160	0.5304404662661166	-1.4225916933617981
161	0.5304404662661166	-1.4225916933617981
162	0.661188892479421	-2.1368641990819737
163	0.8520121449583158	-2.149954168471931
164	0.42876980134969095	-1.4323341212464304
165	0.46626470967028516	-1.4356502468252197
166	0.6244212104982553	-1.3183344504939167
167	0.6244212104982553	-1.3183344504939167
168	0.5121371984004521	-1.6542527356375094
169	0.5121371984004521	-1.6542457543205016
170	0.5121371984004521	-1.6542457543205016
171	0.5121371984004521	-1.6542457543205016
172	0.5772100542318087	-1.3942266023583862
173	0.7389427346971151	-1.2384280413498603
174	0.8336861878123755	-2.1470464499381086
175	0.7286749627076325	-1.2319109819229135
176	0.7289664326927157	-1.2316212572670826
177	0.5603379563527795	-1.4108665714469
178	0.555567971507079	-1.4143851552189208
179	0.6608979984529911	-2.117374107324953
180	0.7192414581006032	-1.2711320208737302
181	0.7181017580990509	-1.2710848969839263
182	0.7231195796985346	-1.2457584242082367
183	0.6835232949585393	-1.3332517796107124
184	0.5667660039878747	-1.4083358440315084
185	0.48333926574254565	-1.4430382255489118
186	0.7182029871956666	-1.2772895424747661
187	0.5651672823930478	-1.4098193738957037
188	0.5625492885150563	-1.4074335088082273
189	0.7133736611553984	-1.2900025207462928
190	0.7251843042036439	-1.2267046647642144
191	0.7121240054109703	-1.2885189908820978
192	0.710406601427008	-1.2915436464758039
193	0.7104537253168118	-1.291500013244504
194	0.6701191663032229	-1.336122846230243
195	0.5464625887994246	-1.4209301399138996
196	0.5430591967580356	-1.4220366786596639
197	0.5430591967580356	-1.4220366786596639
198	0.5430016008927198	-1.421977337465096
199	0.5434658584737503	-1.422385744510063
200	0.7239625737272478	-1.245292421297954
201	0.5588247558913004	-1.4126694965642104
202	0.48253117829887227	-1.4440766964538485
203	0.573724631715576	-1.3939159337515312
204	0.557138767833874	-1.4151129575170023
205	0.5579520912653032	-1.4146469546067197
206	0.8284502000563925	-2.1412275222119592
207	0.845835424735508	-2.1412187955656994
208	0.8459907590389354	-2.1415137562092865
209	0.8284502000563925	-2.1415189921970423
210	0.8461932172321668	-2.1421001868379563
211	0.8287399247122235	-2.1421001868379563
212	0.8383392355981922	-2.140065132930131
213	0.6869039977196523	-1.3309304917055598
214	0.5832314401511891	-1.3825102070897484
215	0.7101448020392087	-1.291775775266319
216	0.710101168807909	-1.291779265924823
217	0.5482951845140186	-1.4202616788103857
218	0.5664762793320435	-1.410545430864533
219	0.5389873436131328	-1.4226754691658938
220	0.4430815012160445	-1.4002200630097348
221	0.6733427894316564	-1.327518373017911
222	0.5096064709850603	-1.571611395555578
223	0.48359233848408484	-1.4407692975213189
224	0.5955115767682212	-1.3602450418220566
225	0.5955115767682212	-1.3602450418220566
226	0.5955115767682212	-1.3602450418220566
227	0.7229729720413671	-1.2375833019918951
228	0.7475821144944872	-2.1743887779998516
229	0.7285301003797171	-1.2324345806985118
230	0.7291112950206311	-1.2304571226560024
231	0.7285301003797171	-1.2324345806985118
232	1.0181081485536083	-2.771001657526081
233	0.4667883084458835	-1.4338176511106258
234	0.9730210579868387	-2.8309240467348022
235	0.722988680004635	-1.2301656526709193
236	0.7225663103256524	-1.2291777963142905
237	0.7235838372795651	-1.2287117934040082
238	0.7388554682345155	-2.1717707841218603
239	1.0149089600347025	-2.384700952865168
240	0.6934769076826629	-2.161298808609894
241	0.7154837642210594	-1.2844663363589668
242	0.7154837642210594	-1.2844663363589668
243	0.46441989665092714	-1.4350498535625338
244	0.6643019839063258	-2.1331117411901857
245	0.6056676476855762	-1.3372276396467555
246	1.0469060812115147	-2.469117292796378
247	1.0469654224060825	-2.468536098155464
248	1.0466739524209994	-2.4681276911104972
249	1.0346887764475543	-2.833833510597877
250	0.7235559120115331	-1.2457863494762684
251	0.571892036000982	-1.3947222758659525
252	0.5718798186962181	-1.3948584115476081
253	0.8055776602090067	-2.1522527670968072
254	0.48360106513034484	-1.4438183877245532
255	0.8450308279503386	-2.1458823153270283
256	0.8453292792524295	-2.1458299554494684
257	0.8447393579652555	-2.1467549799530254
258	0.8444478879801725	-2.1470464499381086
259	0.5505641125416113	-1.418022421380077
260	0.7162778890307169	-1.261311053172758
261	0.6685396433301679	-1.3325885544949545
262	0.6686495990730437	-1.3319183480621886
263	0.6686495990730437	-1.3319183480621886
264	0.6684384142335522	-1.3312149803736348
265	0.6684384142335522	-1.3312149803736348
266	0.7193671218067469	-1.2560558667950033
267	0.7186253568746492	-1.2552320713880618
268	0.6640977803838424	-2.126973418210922
269	0.6120049381995677	-1.3267783534150654
270	0.8191406138262547	-2.1659536017249628
271	0.8191406138262547	-2.1656621317398796
272	0.5293583621298801	-1.5363836699333244
273	0.7187178593250049	-1.2748548081682343
274	0.5717000497832626	-1.393999709555627
275	0.5717122670880266	-1.393994473567871
276	0.5717401923560584	-1.3939648029705871
277	0.5713038600430599	-1.393353937732389
278	0.5302048468170973	-1.424703541756711
279	0.5302048468170973	-1.424703541756711
280	0.5302048468170973	-1.424703541756711
281	0.6899862491786742	-1.3232510429967848
282	0.680533545949873	-1.3331697491358687
283	0.645422757387503	-1.326567168575574
284	0.645422757387503	-1.3264205609184065
285	0.6842947304879208	-1.327518373017911
286	0.5775957719964995	-1.395259837275567
287	0.8070786433657218	-2.163583444600755
288	0.6741910194481257	-1.3290978959909658
289	0.6741910194481257	-1.3290978959909658
290	0.5649630788705644	-1.4074038382109435
291	0.9061173517701401	-3.071198288869106
292	0.9064070764259712	-3.0697426842729425
293	0.9064070764259712	-3.0706153488989396
294	0.7131031351213392	-1.2879360509119315
295	0.7125952443090088	-1.2876079290125566
296	0.7207721118546022	-1.2724671977515059
297	0.8505565403621526	-2.1426831268081226
298	0.8505216337771127	-2.1427983185387545
299	1.0268347948135799	-2.7678007236779236
300	0.7120890988259305	-1.2888698020617486
301	0.8071484565358017	-2.164107043376353
302	0.7194683509033625	-1.2484479765855598
303	0.7207860744886182	-1.2562094557691785
304	1.0462672907052848	-2.469989957422375
305	1.0456267548698028	-2.471298954361371
306	0.48793646299229876	-1.4455392823670197
307	0.8066527830282352	-2.154875996962555
308	0.6241594111104561	-1.318276854628601
309	0.6241594111104561	-1.318276854628601
310	0.7300136302439123	-1.2458160200735524
311	0.7121117881062065	-1.289007683072656
312	0.8447393579652555	-2.1435557914341197
313	0.8272860654453121	-2.1435557914341197
314	0.8275775354303953	-2.1429728514639534
315	0.8450308279503386	-2.1429728514639534
316	0.5681046715241542	-1.4060948412719476
317	0.5676980098084395	-1.405630583690917
318	0.5291401959733808	-1.4246476912206474
319	0.5291401959733808	-1.4246476912206474
320	0.5291401959733808	-1.4246476912206474
321	0.7270744957835538	-1.242819289747878
322	0.7269296334556382	-1.2434598255833602
323	0.7256206365166425	-1.2451475589700387
324	0.6745208866767525	-1.331803156331557
325	0.6745208866767525	-1.331803156331557
326	0.7566874972021416	-2.1701627541043615
327	0.5663890128694439	-1.4064439071223465
328	0.752615062280822	-2.1715328375671774
329	0.7198470873510453	-1.2634438455186952
330	0.7197964728027375	-1.2639971148915774
331	0.719642883828562	-1.2625502369416741
332	0.719337451209463	-1.263152375533612
333	0.5706877588171059	-2.0448940741481323
334	0.5706877588171059	-2.0448940741481323
335	0.4794419455228423	-1.4432703543394267
336	0.7158764633027581	-1.2845623294678266
337	0.7262315017548405	-1.2292353921796064
338	0.4881336851977741	-1.442064331826299
339	0.6698870375127076	-1.33273341682287
340	0.6698800561956997	-1.332738652810626
341	0.6698800561956997	-1.332738652810626
342	0.6698573669154237	-1.332127787572428
343	0.6698573669154237	-1.332127787572428
344	0.6698573669154237	-1.332127787572428
345	0.66977533644058	-1.3316635299913975
346	0.6713792940231627	-1.333024886807953
347	0.6713792940231627	-1.333024886807953
348	0.6713792940231627	-1.333024886807953
349	0.6829176657080973	-1.3332186183549244
350	0.6813817759663423	-1.333044085429725
351	0.6813817759663423	-1.333044085429725
352	0.6823312350794272	-1.3333093754760281
353	0.6820973609596599	-1.333335555414808
354	0.8480467568977847	-2.1467322906727495
355	0.8479385464841611	-2.1467549799530254
356	0.715003798676761	-1.2769998178189352
357	0.7152935233325921	-1.2781255551864714
358	0.7145081251691946	-1.2781255551864714
359	0.5495465855876985	-1.4190696189312737
360	0.7234093043543658	-1.2268216018240983
361	0.7120995708014425	-1.2880302986915393
362	0.5403242658201606	-1.4212512804962665
363	0.5721102021574812	-1.394910771425168
364	0.572162562035041	-1.3948671381938682
365	0.4823880613002087	-1.4420870211065748
366	0.485407480906159	-1.4389768443795208
367	0.48600438351034103	-1.4389140125264492
368	0.4838977711031839	-1.440519715438284
369	0.530344473157257	-1.4233823275129514
370	0.530344473157257	-1.4233823275129514
371	0.530344473157257	-1.4233823275129514
372	0.530313057230721	-1.4233980354762195
373	0.530313057230721	-1.4233980354762195
374	0.530313057230721	-1.4233980354762195
375	0.8231548711058416	-2.1444476546818887
376	0.5733109886828534	-1.3950277084850515
377	0.5729427242106825	-1.3950207271680437
378	0.5730404626487942	-1.3950416711190676
379	0.5602803604874637	-1.4119416942661287
380	0.6643072198940817	-2.1341310134733504
381	0.6640977803838424	-2.133665010563068
382	0.5637710189914523	-1.4089170386724224
383	0.5635092196036533	-1.4092364339255377
384	0.8275775354303953	-2.1415189921970423
385	0.8272860654453121	-2.1415189921970423
386	0.8450308279503386	-2.1421001868379563
387	0.8449575241217548	-2.14220839725158
388	0.8448475683788791	-2.1405241545234057
389	0.8447393579652555	-2.140354857585962
390	0.6825336932726584	-1.3285533532643437
391	0.6772837428826596	-1.3301014603108625
392	0.7141311340507638	-1.286520588888564
393	0.676868354520685	-1.3097526665618608
394	0.676868354520685	-1.3097526665618608
395	0.7263484388147242	-1.2237376050358242
396	0.9442231253289323	-2.883865118935547
397	0.5680174050615546	-1.3989983325333388
398	0.8444478879801725	-2.150245638457014
399	0.8249595415524038	-2.138609528333968
400	0.8456120225912527	-2.1493729738310168
401	0.8429940287132611	-2.1496644438161
402	0.5480909809915353	-1.4194466100497043
403	0.5480909809915353	-1.4194466100497043
404	0.5947855197993915	-1.3601787193104808
405	0.5947855197993915	-1.3601787193104808
406	0.5947855197993915	-1.3601787193104808
407	0.8575971985646977	-2.1610090839540628
408	0.6764320222076864	-1.3264275422354146
409	0.5967664685004052	-1.3606150516234794
410	0.855050763186038	-2.1427023254298945
411	0.5727507379929632	-1.3949160074129239
412	0.5728118245167829	-1.3950277084850515
413	0.5723720015452803	-1.394881100827884
414	0.5725465344704798	-1.3947851077190245
415	0.6687316295478873	-1.3337666517400508
416	0.5307406628974596	-1.4242375388464288
417	0.5307406628974596	-1.4242375388464288
418	0.5307406628974596	-1.4242375388464288
419	0.7169603127682467	-1.2665016623681893
420	0.654673002423073	-2.1313960825354754
421	0.6544984694978736	-2.1313367413409074
422	0.6539166814450137	-2.1304640767149103
423	0.7248928342185608	-1.2377578349170946
424	0.7242540437123309	-1.2462226817892672
425	0.7243692354429626	-1.2460778194613515
426	0.5583604983102699	-1.4140657599658057
427	0.7243989060402465	-1.2463396188491507
428	0.7258248400391258	-1.2445646189998725
429	0.7256206365166425	-1.244362160806641
430	0.711919801888487	-1.2904091824620076
431	0.5771507130372409	-1.3948671381938682
432	0.7240498401898476	-1.2314746496099152
433	0.7237007743394488	-1.2310976584914841
434	0.7115131401727723	-1.2906709818498068
435	0.7113647871863529	-1.2906936711300827
436	0.7194823135373785	-1.2553280644969216
437	0.7127348706491684	-1.2879709574969713
438	0.7176566991397924	-1.2580472874715287
439	0.7176357551887684	-1.2565794655706015
440	0.7207633852083423	-1.2579163877776292
441	0.7155064535013353	-1.2812462038890373
442	0.7151783316019604	-1.2810053484522619
443	0.714712328691678	-1.2816528656047521
444	0.7156949490605508	-1.281014075098522
445	0.7156949490605508	-1.281014075098522
446	0.7156949490605508	-1.281014075098522
447	0.723313311245506	-1.264717935872651
448	0.722391777400453	-1.230601984983918
449	0.8406675048203527	-2.154027766946086
450	0.8406675048203527	-2.154027766946086
451	0.8409572294761838	-2.1516994977239254
452	0.8343773381961652	-2.137059675958197
453	0.836885376331281	-2.139482192959965
454	0.7213742504465402	-1.254856825598883
455	0.7211997175213408	-1.224697536124421
456	0.5660975428843609	-1.4040004461695543
457	0.48185573587835046	-1.4454520159044197
458	0.4817196001966949	-1.446314208554905
459	0.5597846869798974	-1.413105828877209
460	0.5600761569649804	-1.4135997570555234
461	0.5601634234275801	-1.4140657599658057
462	0.8228581651330026	-2.145590845341945
463	0.8229227423153264	-2.145590845341945
464	1.0291630640357403	-2.3602663433372477
465	1.0315716184034924	-2.362695841656024
466	0.571886800013226	-1.3962634015954636
467	0.7123613701892416	-1.287477029318657
468	0.9773843811168246	-2.8038714433288905
469	0.9770929111317415	-2.8027073087178103
470	0.5286305598317985	-1.5381586697826026
471	0.8190184407786151	-2.1670234885564352
472	0.8188159825853838	-2.1663899340379618
473	0.8188508891704236	-2.166534796365877
474	0.5408199393277269	-1.420785277585984
475	0.5470158581723068	-1.418312146035908
476	0.5504768460790115	-1.416858286768997
477	0.5470158581723068	-1.418312146035908
478	0.5504768460790115	-1.416858286768997
479	0.5433820826696546	-1.420767824293464
480	0.5574878336842728	-1.412524634236295
481	0.5570515013712741	-1.412786433624094
482	0.818704281513256	-2.16692225945982
483	0.543263400280519	-1.4207556069887002
484	0.543263400280519	-1.4207556069887002
485	1.0233441363095912	-2.7678007236779236
486	0.7223621068031691	-1.2636847009554704
487	0.7133736611553984	-1.286888853360735
488	0.3199764477558764	-1.1452274592933631
489	0.8468337530676487	-2.1427354866856825
490	0.8467761572023329	-2.1426831268081226
491	0.9069900163961373	-3.0642169718611285
492	0.5678428721363551	-1.4034768473939563
493	0.5599888905023807	-1.414589358741404
494	0.5740038843958951	-1.3955739965409257
495	0.5741487467238106	-1.39558621384569
496	0.5740161017006591	-1.3956577723450216
497	0.8607387912182874	-2.1490815038459337
498	0.6606071218798537	-2.135410339815062
499	0.5555330649220391	-1.4164708236750538
500	0.5560043038200776	-1.4162177509335148
501	0.5719391598907858	-1.3945390162944933
502	0.5720543516214174	-1.3945041097094533
503	0.5487611874243011	-1.4195932177068717
504	0.6056240144542764	-1.338236439954408
505	0.6056240144542764	-1.338236439954408
506	0.6053814136882492	-1.3381142669067685
507	0.65989502754504	-2.1377281370617105
508	0.559290758801583	-1.412524634236295
509	0.5598143575771812	-1.413310032399692
510	0.5591458964736674	-1.4120010354606967
511	0.5711467804103804	-1.3929472760166743
512	0.5704259594293067	-1.3914811994449992
513	0.5714295237492034	-1.3935494146086125
514	0.5706825228293498	-1.3919995622328416
515	0.570984464789945	-1.3926383527390713
516	0.836565981078166	-2.140450850694822
517	0.8369586801598647	-2.139410634460633
518	0.5255483083727766	-1.4696248260445413
519	0.7208209810736581	-1.2484916098168597
520	0.7197737835224616	-1.2759020057194308
521	0.7297797561241449	-1.2461650859239515
522	0.5811073744515121	-1.383571367274961
523	0.5813639378515552	-1.383813968040988
524	0.6736325140874874	-1.3473592759545825
525	0.5644394800949663	-1.4043791826172374
526	0.5500108431687291	-1.418923011274106
527	0.8471688562840316	-2.143801882858651
528	0.5717908069043663	-1.3939456043488152
529	0.42862319369252344	-1.427853861056561
530	0.5708675277300613	-2.0451331842556555
531	0.5708675277300613	-2.0451331842556555
532	0.8574505909075303	-2.158972284716986
533	0.5121965395950199	-1.6529140681012298
534	0.5115560037595379	-1.6549211967410231
535	0.4866536459920829	-1.440809440094115
536	0.4865838328220031	-1.4413016229431774
537	0.7178835919425517	-1.2572182560768312
538	0.7182989803045263	-1.2594068989588323
539	0.7183478495235821	-1.259206186094853
540	0.4679629150324756	-1.4360743618334544
541	0.7219257744901706	-1.2367979038284977
542	0.7225959809229363	-1.2366233709032983
543	0.7223045109378532	-1.2354016404269021
544	0.7129669994396837	-1.2906709818498068
545	0.686982537535992	-1.3244640468269209
546	0.5822278758312924	-1.3838279306750039
547	0.8241095662066826	-2.139590403373589
548	0.8240868769264067	-2.139482192959965
549	0.826121930834232	-2.1391924683041337
550	0.8259910311403325	-2.1393320946442937
551	0.8795290059452585	-2.184396495930787
552	0.7160178349721696	-1.2577278922184136
553	0.6600253338269939	-2.137155669067057
554	0.47696881397276636	-1.4408862345812028
555	1.0309083932877345	-2.8236512597417422
556	0.8456120225912527	-2.1537362969610028
557	0.720239786432744	-1.2584696571505114
558	0.5708971983273452	-1.399260131921138
559	0.5709547941926609	-1.399521931308937
560	0.7247479718906453	-1.2450602925074388
561	0.724864908950529	-1.2454372836258696
562	0.7810924361327783	-1.1681785389570887
563	0.8188508891704236	-2.1663899340379618
564	0.718979658712804	-1.2589705666458337
565	0.7224493732657689	-1.2228073445445111
566	0.722391777400453	-1.2237079344385402
567	0.7190756518216638	-1.24965574442794
568	0.7190669251754038	-1.2495108821000245
569	0.7216639751023713	-1.2495894219163641
570	0.8465667176920936	-2.1416272026106657
571	0.8464846872172498	-2.1415189921970423
572	0.680212405367506	-1.333723018508751
573	0.7153005046496	-1.2839863708146684
574	0.7153005046496	-1.2839863708146684
575	0.7148868616168774	-1.2838868870473048
576	0.7148868616168774	-1.2838868870473048
577	0.687595148103442	-1.3273281321294434
578	0.6872809888380831	-1.327205959081804
579	0.8467761572023329	-2.1406463275710452
580	0.8468546970186727	-2.140684724814589
581	0.7232068461611344	-1.2374960355292954
582	0.6861185995562549	-1.331831081599589
583	0.5765398477990428	-1.3947502011339847
584	0.9756390518648302	-2.8059082425659674
585	0.561093683918893	-1.4109538379095
586	0.680861667849248	-1.3296354574005802
587	0.678083103680073	-1.3442874964710727
588	0.8505216337771127	-2.1411315291030997
589	0.8331032478422093	-2.1412275222119592
590	0.8252492662082348	-2.1406463275710452
591	0.8251532730993751	-2.1408592577397885
592	0.7240358775558317	-1.2250902352061197
593	0.7237583702047645	-1.2244060661393381
594	0.6744824894332087	-1.3461288188319265
595	0.8238390401726234	-2.146309920993767
596	0.8237954069413236	-2.1461737853121114
597	0.8237954069413236	-2.1473361745939394
598	0.8239175799889632	-2.1474443850075633
599	0.7197214236449017	-1.266527842306969
600	0.7184351159861818	-1.2665767115260251
601	0.8065375912976036	-2.1630650818129125
602	0.7241074360551635	-1.2228946110071108
603	0.7138396640656808	-1.2831084702009152
604	0.5710577686185286	-2.0453810210094385
605	0.4819063504266583	-1.4415459690384564
606	0.7218332720398147	-1.2478371113473619
607	0.9759305218499132	-2.802998778702893
608	0.7135481940805977	-1.2833981948567463
609	0.8480694461780607	-2.14536744319769
610	0.7130752098533073	-1.2876829781703925
611	0.7132061095472069	-1.2875503331472407
612	0.7128011931607441	-1.287454340038381
613	0.7128570436968079	-1.2874037254900732
614	0.7286959066586565	-1.2679869375616364
615	0.7203410155293597	-1.2615588899265413
616	0.7200652535075446	-1.2611085949795269
617	0.6143558967020041	-1.3220869083857045
618	0.7190756518216638	-1.2906709818498068
619	0.7175188181288847	-1.262579907538958
620	0.8345588524383726	-2.1412275222119592
621	0.7702719765468301	-2.1665353781422887
622	0.7238177113993324	-1.2301656526709193
623	0.7243989060402465	-1.2310976584914841
624	0.9226979796640863	-2.2427480888127134
625	0.7118028648286033	-1.2903795118647237
626	0.7117155983660037	-1.2904667783273234
627	0.7125830270042449	-1.285434994093824
628	0.6903353150290732	-1.3240067705628984
629	0.7134330023499661	-1.2901770536714923
630	0.6243042734383717	-1.3185386540164001
631	0.7158677366564982	-1.271161691471014
632	0.7160614682034695	-1.2725579548726096
633	0.7169376234879707	-1.2711232942274702
634	0.7243168755654028	-1.2661264165790105
635	0.7128221371117681	-1.290351586596692
636	0.5721538353887811	-1.395565269894666
637	0.5628686837681712	-1.40789951171851
638	0.7167770531967873	-1.259459258836392
639	0.5721398727547651	-1.3941044293107467
640	0.5723720015452803	-1.3947798717312685
641	0.5726739435058754	-1.3947275118537088
642	0.7268720375903225	-1.2443324902093573
643	0.6687752627791872	-1.3334524924746918
644	0.6687752627791872	-1.3334524924746918
645	0.6763447557450866	-1.3351559338246382
646	0.674985144257783	-1.3309444543395756
647	1.0733774899765127	-2.898119222936584
648	0.5739515245183352	-1.3935581412548723
649	0.5745327191592494	-1.3934412041949888
650	0.5722271392173649	-1.3947798717312685
651	0.6778562108773136	-1.3343618090149807
652	0.5928796202562138	-1.360445754686036
653	0.5928796202562138	-1.360445754686036
654	0.5928796202562138	-1.360445754686036
655	0.7174175890322692	-1.2646079801297754
656	0.5125106988603789	-1.6545145350253085
657	0.5125106988603789	-1.6545145350253085
658	0.5125106988603789	-1.6545145350253085
659	0.5149995383737228	-1.6558758918418643
660	0.5149995383737228	-1.6558758918418643
661	0.5149995383737228	-1.6558758918418643
662	0.6872530635700511	-1.3284573601554839
663	0.6737634137813869	-1.328448633509224
664	0.6871448531564275	-1.328719159543283
665	0.7136738577867414	-1.2873059870519616
666	0.8472840480146633	-2.139185486987126
667	0.8299040593233037	-2.1391924683041337
668	0.7134905982152819	-1.2871070195172343
669	0.8064677781275238	-2.1538096007895864
670	0.7143056669759632	-1.2813771035829369
671	0.7143056669759632	-1.2813771035829369
672	0.7120943348136864	-1.2895068472387266
673	0.5677852762710394	-1.403855583841639
674	0.713171202962167	-1.2883444579568981
675	0.8444478879801725	-2.1453011206861143
676	0.8444478879801725	-2.1453011206861143
677	0.5302956039382011	-1.4217225193943048
678	0.5302956039382011	-1.4217225193943048
679	0.5302956039382011	-1.4217225193943048
680	0.9066985464110543	-3.0694529596171116
681	0.7298390973187128	-1.245960882401468
682	0.5919772850329327	-1.3620933454999185
683	0.42862319369252344	-1.4405371687308037
684	0.9576045647039728	-2.8518679977587347
685	0.9576045647039728	-2.8518679977587347
686	0.5580986989224708	-1.4145317628760883
687	0.5581562947877866	-1.414676625204004
688	0.5292134998019646	-1.4253231336411694
689	0.5292134998019646	-1.425118930118686
690	0.6717021799347818	-1.3328119566392098
691	0.6717021799347818	-1.3328119566392098
692	0.6725329566587309	-1.3333146114637842
693	0.6723880943308155	-1.3337806143740667
694	0.724835238353245	-1.2461074900586353
695	0.5690349320154672	-1.4035937844538398
696	0.5416629333564402	-1.4212792057642984
697	0.7168887542689149	-1.2633129458247954
698	0.48192903970693424	-1.4420782944603148
699	0.5575157589523047	-1.4134548947276078
700	0.5704311954170628	-1.3963209974607793
701	0.5716529258934588	-1.3964379345206632
702	0.8496838757361554	-2.1493729738310168
703	0.8496838757361554	-2.1493729738310168
704	0.5722358658636248	-1.3981256679073417
705	0.5519900465404907	-1.4170031490969122
706	0.97447491725375	-2.8061979672217987
707	0.880897344078822	-2.2015007226003314
708	0.6770777940309243	-1.3445527865173756
709	0.8418019688341489	-2.1560052249885953
710	0.9040805525330626	-3.0790522705030803
711	0.3671003375597233	-2.739002791020017
712	0.8395033702092726	-2.1461737853121114
713	0.8395033702092726	-2.1461737853121114
714	0.9026266932661515	-3.103195410045918
715	0.9032078879070655	-3.102322745419921
716	0.7219554450874545	-1.2305443891186019
717	0.8480415209100287	-2.1506819707700124
718	0.8479385464841611	-2.1508268330979283
719	0.7196568464625779	-1.265363707695889
720	0.7196865170598618	-1.2647615691039509
721	0.6801635361484503	-1.3307646854266206
722	0.6774792197588829	-1.3328067206514538
723	0.6778649375235737	-1.3323407177411715
724	0.6770428874458844	-1.3340127431645818
725	0.6722711572709319	-1.3348574825225472
726	0.428448660767324	-1.4279707981164447
727	0.428448660767324	-1.4279707981164447
728	0.7277726274843516	-1.2434598255833602
729	0.5606573516058945	-1.4160728886055993
730	0.5607166928004622	-1.4161025592028833
731	0.8461932172321668	-2.1459835444236437
732	0.8461932172321668	-2.1458823153270283
733	0.9049532171590599	3.1087228677869843
734	1.0245658667859872	-2.7445302487610834
735	0.7247776424879292	-1.231795790192282
736	0.5823936821102318	-1.383208338790546
737	0.31968672310004537	-1.144644519323197
738	0.8495966092735557	-2.1417720649385816
739	0.8491026810952413	-2.1418104621821255
740	0.5585053606381855	-1.412465293041727
741	0.5646140130201657	-1.410342972671302
742	0.7266102382025234	-1.2265004612417314
743	0.4838838084691679	-1.4418112590847598
744	0.7189587147617802	-1.252041609515416
745	0.7179708584051513	-1.2500344808756227
746	0.7182029871956666	-1.2502369390688541
747	0.8342673824532895	-2.140065132930131
748	0.8486890380625187	-2.148660879496203
749	0.567261677495441	-1.4099939068209029
750	0.655952904723438	-2.132792345937071
751	0.657116463375865	-2.1330820705929017
752	0.5562364326105929	-1.4149960204571188
753	0.5466074511273401	-1.4190399483339897
754	0.7193950470747787	-1.2586529167219707
755	0.718979658712804	-1.2584487131994875
756	0.7193950470747787	-1.2581205913001123
757	0.7195207107809223	-1.258242764347752
758	0.5467540587845077	-1.4192720771245049
759	0.7214021757145722	-1.25460026219884
760	0.5565558278637078	-1.4154323527701174
761	0.5565558278637078	-1.4154323527701174
762	0.5567024355208753	-1.4153747569048016
763	0.7160440149109496	-1.2633513430683394
764	0.4743804906920588	-1.4398093664327223
765	0.5464922593967084	-1.419882942362703
766	0.9043720225181457	-3.075851336654923
767	0.5562364326105929	-1.414589358741404
768	0.7149880907134931	-1.2827297337532326
769	0.7149880907134931	-1.2827297337532326
770	0.7174036263982532	-1.261989986251784
771	0.5577496330720719	-1.4147638916666037
772	0.5575157589523047	-1.4149960204571188
773	0.43287132509187765	-1.4113604996252145
774	0.43353978619539146	-1.40970243683582
775	0.43353978619539146	-1.40970243683582
776	0.7160440149109496	-1.2824330277803935
777	0.7160440149109496	-1.2824330277803935
778	0.6779434773399134	-1.332152222181956
779	0.7227111726535679	-1.2275476587929277
780	0.47894801734452797	-1.443212758474111
781	0.846130385379095	-2.14359069801916
782	0.6812753108819706	-1.331124223252531
783	0.6819699519242642	-1.3317420698077373
784	0.6819699519242642	-1.3317420698077373
785	0.682069435691628	-1.3318991494404169
786	1.0343990517917234	-2.362594612559408
787	0.7653565475967974	-1.2168732250877305
788	0.7657928799097959	-1.217018087415646
789	0.6850417314077744	-1.3341000096271816
790	0.720239786432744	-1.2624542438328143
791	0.6762574892824869	-1.3384057368918516
792	0.562345084992573	-1.410051502686219
793	0.5449790589352295	-1.4212792057642984
794	0.7125882629920008	-1.2904091824620076
795	0.7123264636042017	-1.2904091824620076
796	0.42713966382832824	-1.4277089987286453
797	0.5263040359388901	-1.4256721994915682
798	0.5263040359388901	-1.4256721994915682
799	0.5263040359388901	-1.4256721994915682
800	0.7126039709552688	-1.286826021507663
801	0.7104938678896077	-1.2913691135506042
802	0.7110419012747339	-1.2910113210539456
803	0.7417649320975901	-1.2359845803970684
804	0.6643886569569797	-2.133665010563068
805	0.6646795509834097	-2.133665010563068
806	0.8395033702092726	-2.1412275222119592
807	0.8395033702092726	-2.1412275222119592
808	0.8397948401943556	-2.1415189921970423
809	0.8397948401943556	-2.1409377975561283
810	0.6741718208263537	-1.3288203886398988
811	0.6692761722745095	-1.3473365866743068
812	0.8508480103472357	-2.144428456060117
813	0.8508270663962118	-2.144412748096849
814	0.8508480103472357	-2.1438455160899506
815	0.8512354734411783	-2.144128259428774
816	0.714071792856196	-1.2852604611686242
817	0.714071792856196	-1.2852604611686242
818	0.7142707603909234	-1.2855432045074473
819	0.7160736855082335	-1.266590674160041
820	0.5305277327287163	-1.4206770671723603
821	0.5305277327287163	-1.4206770671723603
822	0.5305277327287163	-1.4206770671723603
823	0.5304631555463926	-1.4212792057642984
824	0.5304631555463926	-1.4212792057642984
825	0.5304631555463926	-1.4212792057642984
826	0.807031519475918	-2.1627299785965293
827	0.5596398246519817	-1.4134845653248918
828	0.554025100448316	-1.4175564184697944
829	0.5535224456237416	-1.417046782328212
830	0.7189011188964644	-1.223418209782709
831	0.449684081776339	-1.39864926668294
832	0.449684081776339	-1.39864926668294
833	0.449684081776339	-1.39864926668294
834	0.6052505139943496	-1.3371630624644315
835	0.723322037891766	-1.2365361044406984
836	0.7234389749516497	-1.235810047471869
837	0.47484649360234127	-1.4400711658205214
838	0.5302606973531612	-1.4214834092867816
839	0.5302606973531612	-1.4214834092867816
840	0.5302606973531612	-1.4214834092867816
841	0.6596524267790128	-2.1382255558985293
842	0.6596524267790128	-2.1382255558985293
843	0.7185956862773654	-1.276074793315378
844	0.7117749395605715	-1.2904388530592914
845	0.7117452689632876	-1.2905261195218911
846	0.6854780637207729	-1.3322394886445557
847	0.52755543701257	-1.536500606993208
848	0.5276706287432016	-1.5364709363959241
849	0.5352924815866609	-1.5364709363959241
850	0.7253291665315595	-1.2243484702740224
851	0.7251843042036439	-1.2221092128437134
852	0.7169760207315147	-1.2555759012507046
853	0.7170388525845864	-1.2540190675579257
854	0.7168939902566709	-1.2536700017075268
855	0.7183635574868501	-1.2535774992571713
856	0.6655522156094068	-2.130174352059079
857	0.6646795509834097	-2.1272648881960046
858	0.6655522156094068	-2.130174352059079
859	0.5573708966243891	-1.4159559515457156
860	1.0250894655615856	-2.739002791020017
861	0.606027185511487	-1.338559325866027
862	0.6059207204271154	-1.339240004274305
863	0.5759673798043887	-1.394600102818313
864	0.5670278033756738	-1.4045240449451528
865	0.567289602763473	-1.405630583690917
866	0.5180102313334131	-1.657743394141498
867	0.5180102313334131	-1.657743394141498
868	0.5180102313334131	-1.657743394141498
869	0.4310963252425994	-1.4166837538437973
870	0.4310963252425994	-1.4166837538437973
871	0.7267551005304388	-1.2436919543738754
872	0.7274532322312366	-1.2428786309424458
873	0.6816872085854413	-1.3340808110054097
874	0.7198750126190773	-1.2565794655706015
875	0.657116463375865	-2.1330820705929017
876	0.7190756518216638	-1.2621872084572592
877	0.4817894133667747	-1.443802679761285
878	0.48185573587835046	-1.4432825716441908
879	0.7216639751023713	-1.229060859254407
880	0.7216936456996553	-1.2267046647642144
881	0.721170046924057	-1.2285948563441242
882	0.8400845648501866	-2.140354857585962
883	0.5947733024946277	-1.3594369543783833
884	0.721766949528239	-1.256108226672563
885	0.55281209661818	-1.417125322144552
886	0.5526637436317604	-1.418333089986932
887	0.553115783908027	-1.4169804598166362
888	0.5526236010589646	-1.4173906121908548
889	0.8918056519037866	-2.225352392158086
890	0.7209379181335417	-1.2234758056480248
891	0.7209379181335417	-1.2234758056480248
892	0.7207982917933822	-1.254891732183923
893	0.5698500007761486	-2.044072024070443
894	0.5700629309448919	-2.0442256130446186
895	0.7282962262599497	-1.2454669542231536
896	0.8418298941021809	-2.1490815038459337
897	0.842412834072347	-2.1476276445790226
898	0.4302236606166022	-1.4384427736284107
899	0.7196568464625779	-1.2726364946889495
900	0.721135140339017	-1.2580979020198364
901	0.4770281551673342	-1.4413225668942011
902	0.549721118512898	-1.4187781489461906
903	0.7472330486440882	-1.2368851702910975
904	0.6062889848992862	-1.3383271970755117
905	0.6061755384979065	-1.3383760662945678
906	0.6061755384979065	-1.3383760662945678
907	0.7212276427893728	-1.2597262942119474
908	0.8223415476744123	-2.1415189921970423
909	0.4311835917051991	-1.4191848106619052
910	0.4311835917051991	-1.4191848106619052
911	0.721147357643781	-1.2564328579134338
912	0.7243413101749306	-1.2329581794741102
913	0.7246310348307617	-1.2325218471611117
914	0.8383392355981922	-2.1409377975561283
915	0.8380495109423612	-2.1406463275710452
916	0.5735797693876605	-1.395544325943642
917	0.5683088750466376	-1.399521931308937
918	0.7234686455489335	-1.2365657750379824
919	0.7235559120115331	-1.2358973139344687
920	0.7247479718906453	-1.2338308441001073
921	0.7163040689694968	-1.262236077676315
922	0.7206953173675145	-1.2571257536264757
923	1.017235483927611	-2.380337629735182
924	0.570949558204905	-2.0457492854816097
925	0.570949558204905	-2.0457492854816097
926	0.5710280980212448	-1.392772743091475
927	0.5547232321491138	-1.416514456906354
928	1.0178184238977772	-2.3756845819493657
929	0.6844221395233164	-1.3333495180488242
930	0.5477419151411363	-1.4195635471095878
931	0.5783288102823371	-1.3830128619143225
932	0.7139932530398563	-1.2812025706577375
933	0.7141311340507638	-1.280780200978755
934	0.42905952600552205	-1.4285223221600747
935	0.4297297324382878	-1.429075591532957
936	0.5541210935571756	-1.4166052140274574
937	0.7237583702047645	-1.233336915921793
938	0.7170981937791542	-1.2811362481461617
939	0.5738345874584517	-1.3940817400304708
940	1.022181747027763	-2.764893005144101
941	0.7142759963786793	-1.2839863708146684
942	0.7142759963786793	-1.2839863708146684
943	0.6574073399490025	-2.1330820705929017
944	0.6591526692009968	-2.1330820705929017
945	0.6597344572538565	-2.133954735218899
946	0.6597344572538565	-2.135118869829979
947	0.6596384641449968	-2.1342904201535218
948	0.6597344572538565	-2.135118869829979
949	0.5597846869798974	-1.4138912270406065
950	0.848294593651568	-2.1434964502395517
951	0.556206762013309	-1.413716694115407
952	0.556206762013309	-1.413716694115407
953	0.6738663882072546	-1.3261500348843474
954	1.1053746111533247	-2.9466969720073424
955	0.8304852539642178	-2.138609528333968
956	0.7225610743378965	-1.2581432805803883
957	0.723627470510865	-1.2578361026320375
958	0.7118622060231713	-1.2900897872088928
959	0.9008813640141571	-3.1171580440618727
960	0.7151399343584165	-1.275778087342539
961	0.7151399343584165	-1.275778087342539
962	0.7156513158292509	-1.275748416745255
963	0.7156513158292509	-1.275748416745255
964	0.7159689657531139	-1.2765250882623926
965	0.7182029871956666	-1.2484916098168597
966	0.7195416547319463	-1.2214390064109477
967	0.4863359960682199	-1.4408268933866348
968	0.4863359960682199	-1.4408338747036429
969	0.5493999779305311	-1.4194466100497043
970	0.5486739209617014	-1.4190975441993054
971	0.5483824509766184	-1.4192144812591891
972	0.6894713770493359	-1.325031278833819
973	0.6894713770493359	-1.325031278833819
974	0.8374665709721951	-2.140065132930131
975	0.8374665709721951	-2.140354857585962
976	0.5465201846647404	-1.4198550170946709
977	0.6872094303387514	-1.326232065359191
978	0.5743232796490101	-1.3954396061885221
979	0.7184996931685057	-1.261031800492439
980	0.717766654882668	-1.2602149864025056
981	0.9610952232079614	-2.858557844781629
982	0.657116463375865	-2.134827399844896
983	0.6573782627636642	-2.1349443369047796
984	0.5292414250699965	-1.421366472226898
985	0.7164227513586324	-1.26320299008192
986	0.8505513043743965	-2.144835117775832
987	0.8505565403621526	-2.144718180715948
988	0.5639455519166519	-1.4085976434193075
989	0.564207351304451	-1.4077249787933104
990	0.564788545945365	-1.4080443740464252
991	0.5667660039878747	-1.4057754460188328
992	0.7144941625351786	-1.285578111092487
993	0.5112942043717389	-1.569108593408218
994	0.4831944034146301	-1.4439981566375086
995	0.4806514586944744	-1.4442198134525117
996	0.7271617622461535	-1.2456990830136687
997	0.7270744957835538	-1.24535001716327
998	0.8339759124682065	-2.1467549799530254
999	0.8515251980970094	-2.146812575818341
1000	0.8241881060230222	-2.145363952539186
1001	0.8240868769264067	-2.1453011206861143
1002	0.8485214864543272	-2.1421001868379563
1003	0.8486174795631869	-2.142342787603984
1004	0.8466819094227251	-2.145931184546084
1005	0.8467761572023329	-2.1458823153270283
1006	0.8479385464841611	-2.1435557914341197
1007	0.848003123666485	-2.1436133872994354
1008	0.5824250980367678	-1.3834142876422815
1009	0.5664466087347596	-1.4037386467817552
1010	0.723322037891766	-1.2378747719769783
1011	0.7237007743394488	-1.2380789754994617
1012	0.7145151064862025	-1.2858713264068222
1013	0.5294456285924799	-1.5236724369910497
1014	0.6696531633929403	-1.3437289911104342
1015	0.6640977803838424	-2.1365727290968906
1016	0.6643886569569797	-2.1365727290968906
1017	0.6972590361717347	-1.3113234628886556
1018	0.8256419652899335	-2.1441509487090498
1019	0.8255407361933178	-2.1441369860750337
1020	0.8246384009700368	-2.1454547096602896
1021	0.8246680715673207	-2.145590845341945
1022	0.8241357461454624	-2.145615279951473
1023	0.8240868769264067	-2.145590845341945
1024	0.7109302002026062	-1.29096245183489
1025	0.557400567221673	-1.4150553616516865
1026	0.842412834072347	-2.1653724070840488
1027	0.7170545605478544	-1.278279144160647
1028	0.5673489439580408	-1.4025762574999272
1029	0.48332530310852967	-1.4436874880306536
1030	0.4826481153587559	-1.4409822276900623
1031	0.6635159923309826	-2.1357000644708934
1032	0.8240868769264067	-2.1418104621821255
1033	0.8242090499740462	-2.1417947542188576
1034	1.017235483927611	-2.366374995719228
1035	0.5715953300281429	-1.3985899254883722
1036	0.7184682772419697	-1.2603458860964054
1037	0.71903725457812	-1.26010503065963
1038	0.6739152574263104	-1.3347841786939636
1039	0.6744824894332087	-1.3349534756314068
1040	0.8068273159534347	-2.1636410404660706
1041	0.6798057436517914	-2.159844949342983
1042	0.6033027265491239	-2.1060312125162417
1043	0.6582800045749996	-2.135118869829979
1044	0.6582800045749996	-2.135118869829979
1045	0.6582800045749996	-2.134537675189065
1046	0.6603162278534239	-2.1365727290968906
1047	0.6603162278534239	-2.1362830044410597
1048	0.6599438967640958	-2.1383983434944764
1049	0.6598129970701962	-2.140450850694822
1050	0.6600974857382713	-2.1383110770318767
1051	0.6600974857382713	-2.1383110770318767
1052	0.6597554012048805	-2.1383564555924286
1053	0.6597554012048805	-2.1383564555924286
1054	0.6867870606597687	-2.161298808609894
1055	0.6600253338269939	-2.1368641990819737
1056	0.6981317007977318	-2.1653724070840488
1057	0.6600451258607115	-2.137970737827738
1058	0.8493941510803243	-2.1470464499381086
1059	0.8495006161646961	-2.1468631903666493
1060	0.8070699167194619	-2.1615606079976932
1061	0.7258527653071577	-1.2262107365859
1062	0.8505338510818766	-2.14719654825378
1063	0.8505565403621526	-2.1473361745939394
1064	0.8397948401943556	-2.1418104621821255
1065	0.8397948401943556	-2.1421001868379563
1066	0.6592405290755422	-2.1386479255775117
1067	0.6595162910973573	-2.1395764407395728
1068	0.5701257627979637	-2.0459831596013767
1069	0.5701257627979637	-2.0459831596013767
1070	0.7175484887261687	-1.2761638051072297
1071	0.8418298941021809	-2.144428456060117
1072	0.8418298941021809	-2.144428456060117
1073	0.6689550316921425	-1.334944748985147
1074	0.5976391331264023	-1.3606290142574953
1075	0.6225013483210615	-2.117084382669122
1076	0.6393717008708387	-2.128429022807085
1077	1.0195637531497714	-2.355613295551431
1078	0.6632251157578453	-2.1473361745939394
1079	0.6614797865058508	-2.1362830044410597
1080	0.6643886569569797	-2.1263922235700075
1081	0.6134832320760069	-2.107776541768236
1082	0.6626433277049854	-2.1368641990819737
1083	0.6623524511318482	-2.1368641990819737
1084	0.6335545184739416	-2.127847828166171
1085	0.8403760348352697	-2.1423916568230394
1086	0.8403760348352697	-2.1423916568230394
1087	0.8403760348352697	-2.1421001868379563
1088	0.8403760348352697	-2.1421001868379563
1089	0.8406675048203527	-2.1426831268081226
1090	0.8406675048203527	-2.1421001868379563
1091	0.8406675048203527	-2.1421001868379563
1092	0.8406675048203527	-2.1415189921970423
1093	0.46175652421238383	-1.431489381888465
1094	0.46175652421238383	-1.4314963632054731
1095	0.7251843042036439	-1.2214390064109477
1096	0.725446103591443	-1.220391808859751
1097	0.7251267083383282	-1.2214686770082315
1098	0.7222748403405693	-1.2482018851610286
1099	0.7180860501357831	-1.2735318485952225
1100	0.6849771542254505	-1.3316286234063577
1101	0.6852459349302576	-1.331220216361391
1102	0.685469337074513	-1.3303981662837017
1103	0.6846350696920597	-1.3322325073275476
1104	0.6764232955614263	-1.3339464206530063
1105	0.6763098491600467	-1.334225673333325
1106	0.6763098491600467	-1.334225673333325
1107	0.6762854145505188	-1.3326164797629865
1108	0.675011324196563	-1.3258620555577685
1109	0.9657482709937784	-2.801544919435982
1110	0.8554731328650207	-2.156965156077192
1111	0.8352185868956264	-2.1393757278755934
1112	0.8374665709721951	-2.138900998319051
1113	0.9945462036516848	-2.7730367114339063
1114	0.4854633314422228	-1.6969836317140867
1115	0.715003798676761	-1.2758356832078548
1116	0.4827929776866714	-1.4416279995133001
1117	0.48264462470025193	-1.4414639385636128
1118	0.4827877416989155	-1.4416419621473162
1119	0.5624026808578888	-1.4077249787933104
1120	0.8383392355981922	-2.1421001868379563
1121	0.8397948401943556	-2.1421001868379563
1122	0.8307994132295768	-2.1408505310935286
1123	0.8301955293083867	-2.140065132930131
1124	0.8301955293083867	-2.140065132930131
1125	0.8304852539642178	-2.1391924683041337
1126	0.5610657586508612	-1.416160155068199
1127	0.7516557129686419	-1.233947781159991
1128	0.669443723882701	-1.3436713952451185
1129	0.6588617926278594	-2.135410339815062
1130	0.8336861878123755	-2.1365744744261423
1131	0.8755740898602393	-2.161590278594977
1132	1.0210176124166828	-2.76838366364809
1133	0.8345588524383726	-2.1432643214490366
1134	0.8521081380671756	-2.1434091837769524
1135	0.7024950239277177	-2.170608394840032
1136	0.31567246582045844	-1.1733272602504718
1137	0.6724456901961313	-1.3489353082691335
1138	0.6723304984654996	-1.3487328500759022
1139	0.5707226654021458	-2.0461070779782684
1140	0.5115560037595379	-1.568208003514189
1141	0.8823512033457332	-2.226254727381367
1142	0.723322037891766	-1.2365361044406984
1143	0.8363041816903669	-2.1752614426258488
1144	0.8069913769031222	-2.1555392220783127
1145	0.7210531098641734	-1.2516401837874576
1146	0.7203410155293597	-1.2516925436650175
1147	0.5818840459686495	-1.3837197202613805
1148	0.5557617030540504	-1.414894791360503
1149	0.5560915702826773	-1.414676625204004
1150	0.8500853014641141	-2.143773957590619
1151	0.6608979984529911	-2.1368641990819737
1152	0.6608979984529911	-2.137155669067057
1153	0.8431109657731448	-2.156122162048479
1154	0.7198610499850612	-1.2573927890020309
1155	0.8499753457212386	-2.1435557914341197
1156	0.6058334539645157	-1.3383132344414959
1157	0.6724753607934152	-1.3307123255490607
1158	0.7192292407958392	-1.2760311600840781
1159	0.7211124510587411	-1.2626793913063217
1160	0.720850651670942	-1.2562007291229187
1161	0.7172727267043536	-1.2612325133564184
1162	0.7169515861219866	-1.2606513187155044
1163	0.5607742886657782	-1.4116519696102976
1164	0.5802207471914989	-1.3824019966761245
1165	0.5735064655590767	-1.3944517498318934
1166	0.48120123740885257	-1.4424064163596897
1167	0.4808958047897536	-1.4431830878768273
1168	0.5931449103025168	-1.360149048713197
1169	0.5931449103025168	-1.360149048713197
1170	0.5931449103025168	-1.360149048713197
1171	0.5933892563977962	-1.36047542528332
1172	0.5933892563977962	-1.36047542528332
1173	0.5933892563977962	-1.36047542528332
1174	0.5935201560916957	-1.3605277851608797
1175	0.5935201560916957	-1.3605277851608797
1176	0.5935201560916957	-1.3605277851608797
1177	0.5935376093842156	-1.3603305629554043
1178	0.5935376093842156	-1.3603305629554043
1179	0.5935376093842156	-1.3603305629554043
1180	0.5718798186962181	-1.3940520694331868
1181	0.5233369762104997	-1.4247122684029712
1182	0.5233369762104997	-1.4247122684029712
1183	0.5233369762104997	-1.4247122684029712
1184	0.6899146906793425	-1.3261831961401354
1185	0.6620615571054181	-2.1368641990819737
1186	0.7216936456996553	-2.1674074609918743
1187	0.5727507379929632	-1.3946838786224087
1188	0.8304852539642178	-2.1368641990819737
1189	0.7229450467733353	-1.2386601701403757
1190	0.8301955293083867	-2.138028333693054
1191	0.8304852539642178	-2.1374471390521395
1192	0.8304852539642178	-2.138609528333968
1193	0.8301955293083867	-2.138609528333968
1194	0.6606071218798537	-2.1374453937228877
1195	0.7118028648286033	-1.2895068472387266
1196	0.6594435632274267	-2.135410339815062
1197	0.7158520286932303	-1.2691371095387007
1198	0.716855593013127	-1.269007955174053
1199	0.714707092703922	-1.2645434029474516
1200	0.6858410922051877	-1.3311329498987912
1201	0.7231771755638505	-1.2353440445615864
1202	0.7271687435631614	-1.2676116917724576
1203	0.7180947767820429	-1.262867886865537
1204	0.7141747672820636	-1.2828257268620922
1205	0.7166182282348557	-1.2571606602115155
1206	0.6892008510152768	-1.3264065982843907
1207	0.6643886569569797	-2.129882882073996
1208	0.8457568849191682	-2.1429152555986377
1209	0.7243692354429626	-1.244973026044839
1210	0.7244285766375305	-1.245322091895238
1211	0.7242540437123309	-1.245292421297954
1212	0.4858473038776615	-1.4411742139077817
1213	0.5519516492969467	-1.4174988226044787
1214	0.5524019442439613	-1.41898758845643
1215	0.5723894548378003	-1.395797398685181
1216	0.572817060504539	-1.3956525363572656
1217	0.7181244473793268	-1.2689416326624772
1218	0.7195556173659622	-1.2689416326624772
1219	0.7289664326927157	-1.2313297872819995
1220	1.0193595496272883	-2.354187361552551
1221	1.0193595496272883	-2.354187361552551
1222	0.6691592352146261	-1.320137375611227
1223	0.673115896628897	-2.152863632335005
1224	0.5820899948203848	-1.3837022669688603
1225	0.5692688061352346	-1.4030125898129258
1226	0.5683368003146695	-1.4030998562755255
1227	0.5671150698382734	-1.4066184400475459
1228	0.5704032701490308	-2.045059880427072
1229	0.5710141353872289	-2.0452344133522713
1230	0.6600259272389396	-2.137736863707971
1231	0.659917716825316	-2.1380667309365977
1232	0.845809244796728	-2.145896277961044
1233	0.8459034925763358	-2.1458823153270283
1234	0.655952904723438	-2.133665010563068
1235	0.807350914729033	-2.164112279364109
1236	0.8072636482664333	-2.164047702181785
1237	0.807310772156237	-2.1636497671123305
1238	0.6686059658417438	-1.3343914796122647
1239	0.6807482214478683	-1.3330824826732688
1240	0.6807482214478683	-1.3330824826732688
1241	0.7201961532014441	-1.2490745497870257
1242	0.6807255321675924	-1.3325379399466466
1243	0.6807255321675924	-1.3325379399466466
1244	0.7205591816858589	-1.2502369390688541
1245	0.7199483164476609	-1.2490745497870257
1246	0.8514292049881497	-2.156354290838994
1247	0.5503895796164118	-1.4184587536930755
1248	0.4765045563917359	-1.4407117016560032
1249	0.7174088623860092	-1.280466041713396
1250	0.5591284431811474	-1.411802067925969
1251	0.5591458964736674	-1.411243562565331
1252	0.5591458964736674	-1.411243562565331
1253	0.5599592199050968	-1.415170553382318
1254	0.5600185610996645	-1.4154044275020854
1255	0.7198837392653371	-1.2621784818109991
1256	0.720536492405583	-1.2627073165743536
1257	0.905825881785057	3.1049407392979123
1258	0.5603082857554955	-1.4157814186205162
1259	0.8680970993446957	-2.1624332726236903
1260	0.8604473212332044	-2.1470464499381086
1261	1.0019359277046287	-2.367132468614593
1262	0.8749911498900732	-2.187770217374892
1263	0.6050410744841103	-1.3378908647625134
1264	0.6054931147603768	-1.3378332688971974
1265	0.7178835919425517	-1.2553280644969216
1266	0.8464846872172498	-2.1418104621821255
1267	0.8466679467887093	-2.142051317618901
1268	0.6744528188359248	-1.3337858503618225
1269	0.6738227549759548	-1.3325239773126307
1270	0.6744615454821847	-1.334269306564625
1271	0.6744615454821847	-1.334269306564625
1272	0.6120293728090955	-1.3281955607676847
1273	0.7661995416255106	-1.216349626312132
1274	0.716550160394028	-1.2814346994482526
1275	0.7161574613123293	-1.2811676640726977
1276	0.7161574613123293	-1.2811676640726977
1277	0.6713618407306428	-1.3377599650686136
1278	0.664249624028766	-2.1258110289290935
1279	0.7136075352751655	-1.2653933782931728
1280	0.7155553227203912	-1.2831084702009152
1281	0.7155797573299191	-1.2831171968471753
1282	0.5729915934297384	-1.3951289375816673
1283	0.7160789214959895	-1.2781709337470233
1284	0.5720543516214174	-1.394881100827884
1285	0.5721573260472852	-1.3947065679026847
1286	0.6576982339754323	-2.1357000644708934
1287	0.6574073399490025	-2.134246205203982
1288	0.8482788856883	-2.1406236382907693
1289	0.8485214864543272	-2.1406463275710452
1290	0.5304055596810767	-1.4217748792718647
1291	0.5304055596810767	-1.4217748792718647
1292	0.9887290212547877	-2.690425041949259
1293	0.7192676380393831	-1.265035585796514
1294	0.7187353126175249	-1.264461372472608
1295	0.8437707002303986	-2.1387910425761754
1296	0.8296125893382206	-2.138028333693054
1297	0.826413400819315	-2.138609528333968
1298	0.844617184917616	-2.1394245970946493
1299	1.037598240310629	-2.362011672589242
1300	0.5586798935633849	-1.4138615564433226
1301	0.5576902918775041	-1.4148511581292031
1302	0.558650222966101	-1.41400816410049
1303	0.8508392837009756	-2.147816140138238
1304	0.8508480103472357	-2.1476276445790226
1305	0.8511394803323187	-2.1470464499381086
1306	0.5631008125586865	-1.4092085086575055
1307	0.5624026808578888	-1.409964236223619
1308	0.8429940287132611	-2.1441369860750337
1309	0.8432854986983441	-2.1432643214490366
1310	0.8429940287132611	-2.1423916568230394
1311	0.570024533701348	-1.4034489221259243
1312	0.5696754678509491	-1.3966124674458624
1313	0.485091576311548	-1.4411567606152618
1314	0.5751156591294155	-1.3950416711190676
1315	0.5943945660469448	-1.3595905433525586
1316	0.7156809864265348	-1.273640059008846
1317	0.8144526594553979	-2.160740303249256
1318	0.7120367389483707	-1.2898279878210934
1319	0.5717349563683025	-1.394628028086345
1320	0.5717471736730664	-1.3942510369679142
1321	0.5718082601968862	-1.3947100585611887
1322	0.6588617926278594	-2.138609528333968
1323	0.6588617926278594	-2.138609528333968
1324	0.5600464863676964	-1.41400816410049
1325	0.5670278033756738	-1.4023423833801598
1326	0.8248565671265362	-2.1390458606469664
1327	0.7232347714291663	-1.236420912710067
1328	0.7233517084890498	-1.235750706277301
1329	0.724543768368162	-1.2334241823843928
1330	1.016073094645783	-2.379756435094268
1331	0.571267208128768	-1.3936506437052283
1332	0.5542868998361151	-1.416741349709113
1333	1.0163628193016139	-2.3753931119642826
1334	0.8351400470792867	-2.139482192959965
1335	0.5474521904853054	-1.4191568853938732
1336	0.5474521904853054	-1.4191568853938732
1337	0.578053048260522	-1.3836097645185048
1338	0.661188892479421	-2.1362830044410597
1339	0.5608318845310939	-1.4064439071223465
1340	0.4298222348886435	-1.4460262292283261
1341	0.5919668130574207	-1.3615104055297524
1342	0.5919668130574207	-1.3615104055297524
1343	0.5919196891676168	-1.3615610200780606
1344	0.4810424124469211	-1.4445618979859027
1345	0.4296180313661602	-1.4470821534257825
1346	0.7175624513601847	-1.2516925436650175
1347	0.7176217925547526	-1.2514010736799344
1348	0.5617638903516589	-1.409964236223619
1349	0.6890647153336212	-1.3278761655145699
1350	0.6643886569569797	-2.1275563581810877
1351	0.8482300164692442	-2.1473361745939394
1352	0.8484272386747195	-2.1473518825572073
1353	0.8235039369562406	-2.1453011206861143
1354	0.8233939812133648	-2.145344753917414
1355	0.5535311722700016	-1.416168881714459
1356	0.7298390973187128	-2.1700254548698656
1357	0.5305364593749763	-1.4202477161763698
1358	0.5305364593749763	-1.4202477161763698
1359	0.5305364593749763	-1.4202477161763698
1360	0.5305451860212362	-1.4200662019341623
1361	0.5305451860212362	-1.4200662019341623
1362	0.5305451860212362	-1.4200662019341623
1363	0.5304055596810767	-1.422298478047463
1364	0.5304055596810767	-1.422298478047463
1365	0.5304055596810767	-1.422298478047463
1366	0.5305853285940322	-1.4204501743696012
1367	0.5305853285940322	-1.4204501743696012
1368	0.5305853285940322	-1.4204501743696012
1369	0.5305800926062761	-1.4204065411383013
1370	0.5305800926062761	-1.4204065411383013
1371	0.5375038137489377	-1.4227051397631778
1372	0.5244138443589802	-1.4692181643288267
1373	0.5263040359388901	-1.4695969007765095
1374	1.0533062035785778	-3.01447508817929
1375	0.7270465705155219	-1.221294144083032
1376	0.6640977803838424	-2.128429022807085
1377	0.7158415567177182	-1.283457536051314
1378	0.573117257135882	-1.3959492423301048
1379	0.5694433390604339	-1.3961464645355801
1380	0.8456120225912527	-2.1743887779998516
1381	0.7169725300730106	-1.2760311600840781
1382	0.7169725300730106	-1.2760311600840781
1383	0.7164489312974124	-1.275778087342539
1384	0.7164489312974124	-1.275778087342539
1385	0.7168992262444268	-1.273633077691838
1386	0.84764882182833	-2.1423916568230394
1387	0.8475528287194704	-2.142464960651623
1388	0.6058474165985316	-1.3389083917164262
1389	0.665261321582977	-2.1304640767149103
1390	0.5718047695383822	-1.3939508403365712
1391	0.5931728355705488	-1.3605661824044237
1392	0.5931728355705488	-1.3605661824044237
1393	0.5931728355705488	-1.3605661824044237
1394	0.8767364791420675	-2.1842795588709034
1395	0.550621708406927	-1.419533876512304
1396	0.9974556675147593	-2.9749137100243344
1397	0.6835145683122793	-1.331768249746517
1398	0.6832527689244802	-1.3321173155969162
1399	0.6825633638699423	-1.3317787217220292
1400	0.6825633638699423	-1.3317787217220292
1401	0.6679951006035457	-1.3429435929470368
1402	0.569762734313549	-2.0441784891548145
1403	0.7103490055616922	-2.1691527902438685
1404	0.48205993940083386	-1.442601893235913
1405	0.4820651753885898	-1.442607129223669
1406	0.48179814001303467	-1.4444344889505072
1407	0.4817859227082707	-1.4444397249382632
1408	0.48185573587835046	-1.4445793512784226
1409	0.9014625586550712	-3.1104681970389785
1410	0.7238177113993324	-1.2343841134729894
1411	0.6122475389655948	-1.3265322619905342
1412	0.5354966851091442	-1.5360939452774933
1413	0.5298296010279187	-1.4245028288927317
1414	0.5298296010279187	-1.4245028288927317
1415	0.5298296010279187	-1.4245028288927317
1416	0.8469646527615483	-2.1433166813265965
1417	0.5719007626472419	-1.394029380152911
1418	0.8325220532012952	-2.1426831268081226
1419	0.48654019959070327	-1.446005285277302
1420	0.8255407361933178	-2.138900998319051
1421	0.8252492662082348	-2.138900998319051
1422	0.7087782092348972	-1.2923587152364853
1423	0.7087782092348972	-1.2923587152364853
1424	0.8256489466069414	-2.1388957623312947
1425	0.8255407361933178	-2.138609528333968
1426	0.8255407361933178	-2.138900998319051
1427	0.8249595415524038	-2.138900998319051
1428	0.7196568464625779	-1.257679022999358
1429	0.7197161876571456	-1.257684258987114
1430	0.7197161876571456	-1.257684258987114
1431	0.5770634465746411	-1.3950364351313116
1432	0.5771070798059411	-1.3949194980714281
1433	0.6787759993931147	-1.3339027874217064
1434	0.6787759993931147	-1.3339027874217064
1435	0.6784967467127956	-1.3345084166721481
1436	0.6788597751972104	-1.3332011650624045
1437	0.7121240054109703	-1.287848784449332
1438	0.7121240054109703	-1.2879360509119315
1439	0.7121292413987264	-1.2879011443268917
1440	0.7122810850436498	-1.287799915230276
1441	0.7120646642164025	-1.287892417680632
1442	0.5589120223539001	-1.4145020922788043
1443	0.7952098226757436	-2.1631319861009
1444	0.7267254299331549	-1.242936226807762
1445	0.7264933011426397	-1.2429658974050457
1446	0.8513419385255501	-2.1457217450358446
1447	0.8511394803323187	-2.145590845341945
1448	0.6844692634131202	-1.3307838840483923
1449	0.6840154778076017	-1.3310893166674913
1450	0.6840434030756336	-1.3314732891029302
1451	0.6838636341626781	-1.3313580973722985
1452	0.6838636341626781	-1.3313580973722985
1453	0.6795352176177323	-1.3337282544965068
1454	0.6056955729536082	-1.3384266808428755
1455	0.8066772176377631	-2.1601364193280657
1456	0.8235999300651002	-2.145795048864428
1457	0.8482300164692442	-2.1415189921970423
1458	0.8484429466379875	-2.141557389440586
1459	0.5723370949602404	-1.3949456780102079
1460	0.5725604971044959	-1.3950713417163516
1461	0.6600253338269939	-2.135410339815062
1462	0.6603162278534239	-2.1357000644708934
1463	0.8432854986983441	-2.1531551023200883
1464	0.7164576579436722	-2.1671177363360434
1465	0.5302973492674531	-1.4246808524764354
1466	0.5302973492674531	-1.4246808524764354
1467	0.5302973492674531	-1.4246808524764354
1468	0.7195329280856863	-1.2266470688988986
1469	0.7226535767882521	-1.2247551319897367
1470	0.6884154528518794	-1.3270401528028646
1471	0.8498933152463948	-2.150865230341472
1472	0.8474742889031306	-2.1467253093557415
1473	0.8473573518432469	-2.1464635099679423
1474	0.6058561432447916	-1.338566307183035
1475	0.6058561432447916	-1.338566307183035
1476	0.42876980134969095	-1.4277526319599452
1477	0.597731635576758	-1.3605504744411556
1478	0.597731635576758	-1.3605504744411556
1479	0.5441360649065161	-1.4228796726883772
1480	0.54355312493635	-1.4229093432856612
1481	0.7207825838301143	-1.2591014663397333
1482	0.937823002961869	-2.90248254606657
1483	0.9459684545809267	-2.8783394065237324
1484	0.9450957899549294	-2.877756466553566
1485	0.8956453762581741	-3.124720555710764
1486	0.9049532171590599	-3.0729436181211
1487	0.9317143505798889	-2.929535149472482
1488	0.9293878266869805	-2.930699284083562
1489	0.9311331559389748	-2.9286624848464853
1490	0.762330728450256	-2.1675825756934852
1491	0.9416051314509408	-2.9007372168145755
1492	0.9674936002457727	-2.805325302595802
1493	0.9488482478467173	-2.876302607286655
1494	0.9497505830699983	-2.8832839242946324
1495	0.9465496492218407	-2.885029253546627
1496	0.766112275162911	-1.2177458897137277
1497	0.5939128551733944	-1.3603183456506405
1498	1.022471471683594	-2.357358624803425
1499	0.4732163560809785	-1.4393154382544078
1500	0.5567303607889073	-1.4154323527701174
1501	0.3174457203404847	-1.1452553845613953
1502	0.3174457203404847	-1.1452553845613953
1503	0.3187756612305043	-1.1444123905326817
1504	0.8406675048203527	-2.1461737853121114
1505	0.8406675048203527	-2.1461737853121114
1506	0.8409572294761838	-2.1453011206861143
1507	0.6629342217314154	-2.118538241936033
1508	0.48739715625343244	-1.441401106710541
1509	0.5701118001639477	-1.4003649253376502
1510	0.8499753457212386	-2.148791779190103
1511	0.8500486495498223	-2.148652152849943
1512	0.8053158608212075	-2.147554340750439
1513	0.6122562656118549	-1.3273578027267277
1514	0.5599312946370648	-1.4122628348484958
1515	0.9980368621556734	-2.966187063764363
1516	0.5730491892950542	-1.3944604764781534
1517	0.5719967557561016	-1.3953907369694665
1518	0.72515463360636	-1.2309807214316006
1519	0.7285876962450328	-1.2340647182198745
1520	0.7283834927225495	-1.2342392511450742
1521	1.043415422707526	-2.8315052413757167
1522	0.7282962262599497	-1.2442155531494739
1523	0.8480938807875886	-2.146571720381566
1524	0.7213742504465402	-1.230238956499503
1525	0.5570218307739903	-1.4126398259669264
1526	0.5560043038200776	-1.4138615564433226
1527	0.5560043038200776	-1.4138615564433226
1528	0.720868104963462	-1.253320935857128
1529	0.7194247176720626	-1.2534378729170117
1530	0.7198470873510453	-1.252689126667906
1531	0.48628363619066006	-1.4413853987472731
1532	0.7244285766375305	-1.2346162422635047
1533	0.7131991282301989	-1.2900601166116088
1534	0.7240201695925637	-1.232376984833196
1535	0.7241947025177631	-1.2321151854453969
1536	0.8306021910241015	-2.1391139284877942
1537	0.6635158876112275	-2.1252293106894036
1538	0.7254757741887269	-1.2358676433371847
1539	0.5729619228324545	-1.3964082639233792
1540	0.7113909671251328	-1.2907495216661464
1541	0.7114363456856847	-1.2907407950198864
1542	0.7115131401727723	-1.2906709818498068
1543	0.8318448654515214	-2.136960192190833
1544	0.8325220532012952	-2.140354857585962
1545	0.8269945954602291	-2.1415189921970423
1546	0.7244565019055622	-1.240724894645485
1547	0.7244565019055622	-1.240724894645485
1548	0.8188072559391237	-2.1660984640528786
1549	0.8831941973744465	-2.2132816950512932
1550	0.5676980098084395	-1.4083358440315084
1551	0.56941366846315	-1.4011799940983316
1552	0.5696178719856333	-1.4021975210522444
1553	0.7203846487606594	-1.2551238609744384
1554	0.7255717672975867	-1.2679467949888406
1555	0.8304852539642178	-2.139482192959965
1556	0.7106631648270512	-1.2910322650049695
1557	0.5683088750466376	-1.4065905147795141
1558	0.7121816012762862	-1.290321915999408
1559	0.5579241659972713	-1.412494963639011
1560	0.5598440281744651	-1.4137463647126909
1561	0.5585926271007852	-1.4137742899807226
1562	0.5574284924897049	-1.413310032399692
1563	0.5975431400175426	-1.3605330211486357
1564	0.5975431400175426	-1.3605330211486357
1565	0.6643886569569797	-2.135118869829979
1566	0.5289796256821974	-1.4254976665663686
1567	0.7218769052711147	-1.2581781871654283
1568	0.579574975368261	-1.38203024154545
1569	0.7246607054280457	-1.233685981772192
1570	0.5747665932790166	-1.395186533446983
1571	0.574663618853149	-1.3950905403381235
1572	0.8066475470404793	-2.157736591606574
1573	0.807031519475918	-2.1585062818067033
1574	0.7204335179797153	-1.2756035544173396
1575	0.6864676654066537	-1.3299408900196792
1576	0.6861185995562549	-1.3302410866510221
1577	0.9916384851178622	-2.320706710511544
1578	0.7248928342185608	-1.2292057215823222
1579	0.5599888905023807	-1.4123501013110953
1580	0.6781424448746408	-1.3299059834346392
1581	1.0137448254236225	-2.384119758224254
1582	0.7787077345981374	-2.1653718253076373
1583	0.7788240898816023	-2.1652031101466056
1584	0.7784255730357309	-2.1631901637426445
1585	0.7784517529745109	-2.1644060764548554
1586	0.6603162278534239	-2.137155669067057
1587	0.5743669128803099	-1.3951516268619433
1588	0.5745571537687773	-1.3950503977653275
1589	0.6597344572538565	-2.1359915344559766
1590	0.8449627601095108	-2.1400127730525713
1591	0.8059546513274375	-2.161909673848092
1592	0.8061030043138571	-2.162250013052231
3185	0.6600253338269939	-2.1365727290968906
3186	0.6603162278534239	-2.1368641990819737
3187	0.6603162278534239	-2.1365727290968906
3188	0.8333947178272924	-2.1464635099679423
3189	0.8509841460288913	-2.1464111500903824
3190	0.8303491182825622	-2.1367716966316177
3191	0.831940858560381	-2.1368641990819737
3192	0.7264357052773238	-1.2430234932703614
3193	0.9686577348568529	-2.8477961446138313
3194	0.9660397409788615	-2.84517815073584
3195	0.5752465588233151	-1.3948322316088284
3196	0.6606071218798537	-2.1362830044410597
3197	0.6606071218798537	-2.1362830044410597
3198	0.6638068863574125	-2.1261007535849243
3199	1.101594227993505	-2.9484423012593366
3200	1.049524075089506	-2.8303428520938883
3201	0.8345588524383726	-2.1374471390521395
3202	0.605135322263718	-1.3381439375040525
3203	0.48578272669533773	-1.6937547725978972
3204	0.4857914533415977	-1.6937408099638813
3205	0.4857914533415977	-1.6937408099638813
3206	0.4857914533415977	-1.6937408099638813
3207	0.6887732453485382	-1.3259999365686759
3208	0.5675810727485561	-1.404785844332952
3209	0.5674065398233565	-1.4050773143180348
3210	0.5676683392111557	-1.404174979094754
3211	0.5673489439580408	-1.4034192515286403
3212	0.9445145953140154	-2.8879387174097015
3213	0.7213742504465402	-1.253940527741586
3214	0.9421863260918549	-2.8984106929216673
3215	0.5754053837852465	-1.3950992669843834
3216	0.5436403913989497	-1.421425813421466
3217	0.5436403913989497	-1.421425813421466
3218	0.43034059767648586	-1.4187484783489066
3219	0.43034059767648586	-1.4187484783489066
3220	0.8074242185576167	-2.1641733658879287
3221	0.6596960600103128	-2.1378276208290745
3222	0.6596960600103128	-2.1378276208290745
3223	0.8235772407848243	-2.1414701229779864
3224	0.6759520566633879	-1.3317734857342733
3225	0.5912093401620553	-1.3614877162494765
3226	0.5706493615735619	-2.0460931153442523
3227	0.5706493615735619	-2.0460931153442523
3228	0.5704311954170628	-2.0461070779782684
3229	0.5704521393680866	-2.0460878793564965
3230	0.6809053010805478	-1.3328782791507856
3231	0.6809105370683037	-1.3328782791507856
3232	0.5428846638328362	-1.4196211429749037
3233	0.5470734540376225	-1.4178182178575935
3234	0.5137673359218148	-1.5700981950940986
3235	0.5108875426560241	-1.5698939915716157
3236	0.694059847652829	-1.2935804457128812
3237	0.8497275089674553	-2.1430688445728134
3238	0.8496838757361554	-2.1426831268081226
3239	0.7202973822980598	-1.258876318866226
3240	1.033526387165726	-2.362303142574325
3241	0.571895526659486	-1.3951079936306434
3242	0.5625772137830882	-1.4072589758830278
3243	0.7093314786077795	-1.2940447032939117
3244	0.7093314786077795	-1.2940447032939117
3245	1.0204364177757688	-2.3742289773532024
3246	0.56635934227216	-1.407840170523942
3247	0.563537144871685	-1.4076377123307107
3248	0.5655442735114786	-1.4079867781811095
3249	0.566010276421761	-1.4080740446437092
3250	0.7235838372795651	-1.2463692894464347
3251	0.9596396186117983	-2.8524491923996487
3252	0.5732830634148214	-1.3971360662214607
3253	0.8475371207562024	-2.1408854376785684
3254	0.8473573518432469	-2.1406463275710452
3255	0.6721559655403002	-1.3381823347475965
3256	0.7093314786077795	-1.2940447032939117
3257	0.7093314786077795	-1.2940447032939117
3258	0.6606071218798537	-2.134537675189065
3259	0.6606455191233976	-2.1347331520652886
3260	0.47647488579445196	-1.4410014263118343
3261	0.6056379770882923	-1.3378611941652294
3262	0.7196568464625779	-1.2602149864025056
3263	0.7203549781633756	-1.2602725822678214
3264	0.7244285766375305	-1.2430234932703614
3265	0.473390889006178	-1.4393730341197235
3266	0.6122841908798867	-1.3270401528028646
3267	0.8294677270103051	-2.1380196070467936
3268	0.8307767239493009	-2.1409377975561283
3269	0.48444580448831004	-1.4444641595477912
3270	0.6778771548283377	-1.3334804177427235
3271	0.5600464863676964	-1.4116222990130136
3272	0.5599312946370648	-1.4116798948783296
3273	0.5304404662661166	-1.4225916933617981
3274	0.5304404662661166	-1.4225916933617981
3275	0.5304404662661166	-1.4225916933617981
3276	0.661188892479421	-2.1368641990819737
3277	0.8520121449583158	-2.149954168471931
3278	0.42876980134969095	-1.4323341212464304
3279	0.46626470967028516	-1.4356502468252197
3280	0.6244212104982553	-1.3183344504939167
3281	0.6244212104982553	-1.3183344504939167
3282	0.5121371984004521	-1.6542527356375094
3283	0.5121371984004521	-1.6542457543205016
3284	0.5121371984004521	-1.6542457543205016
3285	0.5121371984004521	-1.6542457543205016
3286	0.5772100542318087	-1.3942266023583862
3287	0.7389427346971151	-1.2384280413498603
3288	0.8336861878123755	-2.1470464499381086
3289	0.7286749627076325	-1.2319109819229135
3290	0.7289664326927157	-1.2316212572670826
3291	0.5603379563527795	-1.4108665714469
3292	0.555567971507079	-1.4143851552189208
3293	0.6608979984529911	-2.117374107324953
3294	0.7192414581006032	-1.2711320208737302
3295	0.7181017580990509	-1.2710848969839263
3296	0.7231195796985346	-1.2457584242082367
3297	0.6835232949585393	-1.3332517796107124
3298	0.5667660039878747	-1.4083358440315084
3299	0.48333926574254565	-1.4430382255489118
3300	0.7182029871956666	-1.2772895424747661
3301	0.5651672823930478	-1.4098193738957037
3302	0.5625492885150563	-1.4074335088082273
3303	0.7133736611553984	-1.2900025207462928
3304	0.7251843042036439	-1.2267046647642144
3305	0.7121240054109703	-1.2885189908820978
3306	0.710406601427008	-1.2915436464758039
3307	0.7104537253168118	-1.291500013244504
3308	0.6701191663032229	-1.336122846230243
3309	0.5464625887994246	-1.4209301399138996
3310	0.5430591967580356	-1.4220366786596639
3311	0.5430591967580356	-1.4220366786596639
3312	0.5430016008927198	-1.421977337465096
3313	0.5434658584737503	-1.422385744510063
3314	0.7239625737272478	-1.245292421297954
3315	0.5588247558913004	-1.4126694965642104
3316	0.48253117829887227	-1.4440766964538485
3317	0.573724631715576	-1.3939159337515312
3318	0.557138767833874	-1.4151129575170023
3319	0.5579520912653032	-1.4146469546067197
3320	0.8284502000563925	-2.1412275222119592
3321	0.845835424735508	-2.1412187955656994
3322	0.8459907590389354	-2.1415137562092865
3323	0.8284502000563925	-2.1415189921970423
3324	0.8461932172321668	-2.1421001868379563
3325	0.8287399247122235	-2.1421001868379563
3326	0.8383392355981922	-2.140065132930131
3327	0.6869039977196523	-1.3309304917055598
3328	0.5832314401511891	-1.3825102070897484
3329	0.7101448020392087	-1.291775775266319
3330	0.710101168807909	-1.291779265924823
3331	0.5482951845140186	-1.4202616788103857
3332	0.5664762793320435	-1.410545430864533
3333	0.5389873436131328	-1.4226754691658938
3334	0.4430815012160445	-1.4002200630097348
3335	0.6733427894316564	-1.327518373017911
3336	0.5096064709850603	-1.571611395555578
3337	0.48359233848408484	-1.4407692975213189
3338	0.5955115767682212	-1.3602450418220566
3339	0.5955115767682212	-1.3602450418220566
3340	0.5955115767682212	-1.3602450418220566
3341	0.7229729720413671	-1.2375833019918951
3342	0.7475821144944872	-2.1743887779998516
3343	0.7285301003797171	-1.2324345806985118
3344	0.7291112950206311	-1.2304571226560024
3345	0.7285301003797171	-1.2324345806985118
3346	1.0181081485536083	-2.771001657526081
3347	0.4667883084458835	-1.4338176511106258
3348	0.9730210579868387	-2.8309240467348022
3349	0.722988680004635	-1.2301656526709193
3350	0.7225663103256524	-1.2291777963142905
3351	0.7235838372795651	-1.2287117934040082
3352	0.7388554682345155	-2.1717707841218603
3353	1.0149089600347025	-2.384700952865168
3354	0.6934769076826629	-2.161298808609894
3355	0.7154837642210594	-1.2844663363589668
3356	0.7154837642210594	-1.2844663363589668
3357	0.46441989665092714	-1.4350498535625338
3358	0.6643019839063258	-2.1331117411901857
3359	0.6056676476855762	-1.3372276396467555
3360	1.0469060812115147	-2.469117292796378
3361	1.0469654224060825	-2.468536098155464
3362	1.0466739524209994	-2.4681276911104972
3363	1.0346887764475543	-2.833833510597877
3364	0.7235559120115331	-1.2457863494762684
3365	0.571892036000982	-1.3947222758659525
3366	0.5718798186962181	-1.3948584115476081
3367	0.8055776602090067	-2.1522527670968072
3368	0.48360106513034484	-1.4438183877245532
3369	0.8450308279503386	-2.1458823153270283
3370	0.8453292792524295	-2.1458299554494684
3371	0.8447393579652555	-2.1467549799530254
3372	0.8444478879801725	-2.1470464499381086
3373	0.5505641125416113	-1.418022421380077
3374	0.7162778890307169	-1.261311053172758
3375	0.6685396433301679	-1.3325885544949545
3376	0.6686495990730437	-1.3319183480621886
3377	0.6686495990730437	-1.3319183480621886
3378	0.6684384142335522	-1.3312149803736348
3379	0.6684384142335522	-1.3312149803736348
3380	0.7193671218067469	-1.2560558667950033
3381	0.7186253568746492	-1.2552320713880618
3382	0.6640977803838424	-2.126973418210922
3383	0.6120049381995677	-1.3267783534150654
3384	0.8191406138262547	-2.1659536017249628
3385	0.8191406138262547	-2.1656621317398796
3386	0.5293583621298801	-1.5363836699333244
3387	0.7187178593250049	-1.2748548081682343
3388	0.5717000497832626	-1.393999709555627
3389	0.5717122670880266	-1.393994473567871
3390	0.5717401923560584	-1.3939648029705871
3391	0.5713038600430599	-1.393353937732389
3392	0.5302048468170973	-1.424703541756711
3393	0.5302048468170973	-1.424703541756711
3394	0.5302048468170973	-1.424703541756711
3395	0.6899862491786742	-1.3232510429967848
3396	0.680533545949873	-1.3331697491358687
3397	0.645422757387503	-1.326567168575574
3398	0.645422757387503	-1.3264205609184065
3399	0.6842947304879208	-1.327518373017911
3400	0.5775957719964995	-1.395259837275567
3401	0.8070786433657218	-2.163583444600755
3402	0.6741910194481257	-1.3290978959909658
3403	0.6741910194481257	-1.3290978959909658
3404	0.5649630788705644	-1.4074038382109435
3405	0.9061173517701401	-3.071198288869106
3406	0.9064070764259712	-3.0697426842729425
3407	0.9064070764259712	-3.0706153488989396
3408	0.7131031351213392	-1.2879360509119315
3409	0.7125952443090088	-1.2876079290125566
3410	0.7207721118546022	-1.2724671977515059
3411	0.8505565403621526	-2.1426831268081226
3412	0.8505216337771127	-2.1427983185387545
3413	1.0268347948135799	-2.7678007236779236
3414	0.7120890988259305	-1.2888698020617486
3415	0.8071484565358017	-2.164107043376353
3416	0.7194683509033625	-1.2484479765855598
3417	0.7207860744886182	-1.2562094557691785
3418	1.0462672907052848	-2.469989957422375
3419	1.0456267548698028	-2.471298954361371
3420	0.48793646299229876	-1.4455392823670197
3421	0.8066527830282352	-2.154875996962555
3422	0.6241594111104561	-1.318276854628601
3423	0.6241594111104561	-1.318276854628601
3424	0.7300136302439123	-1.2458160200735524
3425	0.7121117881062065	-1.289007683072656
3426	0.8447393579652555	-2.1435557914341197
3427	0.8272860654453121	-2.1435557914341197
3428	0.8275775354303953	-2.1429728514639534
3429	0.8450308279503386	-2.1429728514639534
3430	0.5681046715241542	-1.4060948412719476
3431	0.5676980098084395	-1.405630583690917
3432	0.5291401959733808	-1.4246476912206474
3433	0.5291401959733808	-1.4246476912206474
3434	0.5291401959733808	-1.4246476912206474
3435	0.7270744957835538	-1.242819289747878
3436	0.7269296334556382	-1.2434598255833602
3437	0.7256206365166425	-1.2451475589700387
3438	0.6745208866767525	-1.331803156331557
3439	0.6745208866767525	-1.331803156331557
3440	0.7566874972021416	-2.1701627541043615
3441	0.5663890128694439	-1.4064439071223465
3442	0.752615062280822	-2.1715328375671774
3443	0.7198470873510453	-1.2634438455186952
3444	0.7197964728027375	-1.2639971148915774
3445	0.719642883828562	-1.2625502369416741
3446	0.719337451209463	-1.263152375533612
3447	0.5706877588171059	-2.0448940741481323
3448	0.5706877588171059	-2.0448940741481323
3449	0.4794419455228423	-1.4432703543394267
3450	0.7158764633027581	-1.2845623294678266
3451	0.7262315017548405	-1.2292353921796064
3452	0.4881336851977741	-1.442064331826299
3453	0.6698870375127076	-1.33273341682287
3454	0.6698800561956997	-1.332738652810626
3455	0.6698800561956997	-1.332738652810626
3456	0.6698573669154237	-1.332127787572428
3457	0.6698573669154237	-1.332127787572428
3458	0.6698573669154237	-1.332127787572428
3459	0.66977533644058	-1.3316635299913975
3460	0.6713792940231627	-1.333024886807953
3461	0.6713792940231627	-1.333024886807953
3462	0.6713792940231627	-1.333024886807953
3463	0.6829176657080973	-1.3332186183549244
3464	0.6813817759663423	-1.333044085429725
3465	0.6813817759663423	-1.333044085429725
3466	0.6823312350794272	-1.3333093754760281
3467	0.6820973609596599	-1.333335555414808
3468	0.8480467568977847	-2.1467322906727495
3469	0.8479385464841611	-2.1467549799530254
3470	0.715003798676761	-1.2769998178189352
3471	0.7152935233325921	-1.2781255551864714
3472	0.7145081251691946	-1.2781255551864714
3473	0.5495465855876985	-1.4190696189312737
3474	0.7234093043543658	-1.2268216018240983
3475	0.7120995708014425	-1.2880302986915393
3476	0.5403242658201606	-1.4212512804962665
3477	0.5721102021574812	-1.394910771425168
3478	0.572162562035041	-1.3948671381938682
3479	0.4823880613002087	-1.4420870211065748
3480	0.485407480906159	-1.4389768443795208
3481	0.48600438351034103	-1.4389140125264492
3482	0.4838977711031839	-1.440519715438284
3483	0.530344473157257	-1.4233823275129514
3484	0.530344473157257	-1.4233823275129514
3485	0.530344473157257	-1.4233823275129514
3486	0.530313057230721	-1.4233980354762195
3487	0.530313057230721	-1.4233980354762195
3488	0.530313057230721	-1.4233980354762195
3489	0.8231548711058416	-2.1444476546818887
3490	0.5733109886828534	-1.3950277084850515
3491	0.5729427242106825	-1.3950207271680437
3492	0.5730404626487942	-1.3950416711190676
3493	0.5602803604874637	-1.4119416942661287
3494	0.6643072198940817	-2.1341310134733504
3495	0.6640977803838424	-2.133665010563068
3496	0.5637710189914523	-1.4089170386724224
3497	0.5635092196036533	-1.4092364339255377
3498	0.8275775354303953	-2.1415189921970423
3499	0.8272860654453121	-2.1415189921970423
3500	0.8450308279503386	-2.1421001868379563
3501	0.8449575241217548	-2.14220839725158
3502	0.8448475683788791	-2.1405241545234057
3503	0.8447393579652555	-2.140354857585962
3504	0.6825336932726584	-1.3285533532643437
3505	0.6772837428826596	-1.3301014603108625
3506	0.7141311340507638	-1.286520588888564
3507	0.676868354520685	-1.3097526665618608
3508	0.676868354520685	-1.3097526665618608
3509	0.7263484388147242	-1.2237376050358242
3510	0.9442231253289323	-2.883865118935547
3511	0.5680174050615546	-1.3989983325333388
3512	0.8444478879801725	-2.150245638457014
3513	0.8249595415524038	-2.138609528333968
3514	0.8456120225912527	-2.1493729738310168
3515	0.8429940287132611	-2.1496644438161
3516	0.5480909809915353	-1.4194466100497043
3517	0.5480909809915353	-1.4194466100497043
3518	0.5947855197993915	-1.3601787193104808
3519	0.5947855197993915	-1.3601787193104808
3520	0.5947855197993915	-1.3601787193104808
3521	0.8575971985646977	-2.1610090839540628
3522	0.6764320222076864	-1.3264275422354146
3523	0.5967664685004052	-1.3606150516234794
3524	0.855050763186038	-2.1427023254298945
3525	0.5727507379929632	-1.3949160074129239
3526	0.5728118245167829	-1.3950277084850515
3527	0.5723720015452803	-1.394881100827884
3528	0.5725465344704798	-1.3947851077190245
3529	0.6687316295478873	-1.3337666517400508
3530	0.5307406628974596	-1.4242375388464288
3531	0.5307406628974596	-1.4242375388464288
3532	0.5307406628974596	-1.4242375388464288
3533	0.7169603127682467	-1.2665016623681893
3534	0.654673002423073	-2.1313960825354754
3535	0.6544984694978736	-2.1313367413409074
3536	0.6539166814450137	-2.1304640767149103
3537	0.7248928342185608	-1.2377578349170946
3538	0.7242540437123309	-1.2462226817892672
3539	0.7243692354429626	-1.2460778194613515
3540	0.5583604983102699	-1.4140657599658057
3541	0.7243989060402465	-1.2463396188491507
3542	0.7258248400391258	-1.2445646189998725
3543	0.7256206365166425	-1.244362160806641
3544	0.711919801888487	-1.2904091824620076
3545	0.5771507130372409	-1.3948671381938682
3546	0.7240498401898476	-1.2314746496099152
3547	0.7237007743394488	-1.2310976584914841
3548	0.7115131401727723	-1.2906709818498068
3549	0.7113647871863529	-1.2906936711300827
3550	0.7194823135373785	-1.2553280644969216
3551	0.7127348706491684	-1.2879709574969713
3552	0.7176566991397924	-1.2580472874715287
3553	0.7176357551887684	-1.2565794655706015
3554	0.7207633852083423	-1.2579163877776292
3555	0.7155064535013353	-1.2812462038890373
3556	0.7151783316019604	-1.2810053484522619
3557	0.714712328691678	-1.2816528656047521
3558	0.7156949490605508	-1.281014075098522
3559	0.7156949490605508	-1.281014075098522
3560	0.7156949490605508	-1.281014075098522
3561	0.723313311245506	-1.264717935872651
3562	0.722391777400453	-1.230601984983918
3563	0.8406675048203527	-2.154027766946086
3564	0.8406675048203527	-2.154027766946086
3565	0.8409572294761838	-2.1516994977239254
3566	0.8343773381961652	-2.137059675958197
3567	0.836885376331281	-2.139482192959965
3568	0.7213742504465402	-1.254856825598883
3569	0.7211997175213408	-1.224697536124421
3570	0.5660975428843609	-1.4040004461695543
3571	0.48185573587835046	-1.4454520159044197
3572	0.4817196001966949	-1.446314208554905
3573	0.5597846869798974	-1.413105828877209
3574	0.5600761569649804	-1.4135997570555234
3575	0.5601634234275801	-1.4140657599658057
3576	0.8228581651330026	-2.145590845341945
3577	0.8229227423153264	-2.145590845341945
3578	1.0291630640357403	-2.3602663433372477
3579	1.0315716184034924	-2.362695841656024
3580	0.571886800013226	-1.3962634015954636
3581	0.7123613701892416	-1.287477029318657
3582	0.9773843811168246	-2.8038714433288905
3583	0.9770929111317415	-2.8027073087178103
3584	0.5286305598317985	-1.5381586697826026
3585	0.8190184407786151	-2.1670234885564352
3586	0.8188159825853838	-2.1663899340379618
3587	0.8188508891704236	-2.166534796365877
3588	0.5408199393277269	-1.420785277585984
3589	0.5470158581723068	-1.418312146035908
3590	0.5504768460790115	-1.416858286768997
3591	0.5470158581723068	-1.418312146035908
3592	0.5504768460790115	-1.416858286768997
3593	0.5433820826696546	-1.420767824293464
3594	0.5574878336842728	-1.412524634236295
3595	0.5570515013712741	-1.412786433624094
3596	0.818704281513256	-2.16692225945982
3597	0.543263400280519	-1.4207556069887002
3598	0.543263400280519	-1.4207556069887002
3599	1.0233441363095912	-2.7678007236779236
3600	0.7223621068031691	-1.2636847009554704
3601	0.7133736611553984	-1.286888853360735
3602	0.3199764477558764	-1.1452274592933631
3603	0.8468337530676487	-2.1427354866856825
3604	0.8467761572023329	-2.1426831268081226
3605	0.9069900163961373	-3.0642169718611285
3606	0.5678428721363551	-1.4034768473939563
3607	0.5599888905023807	-1.414589358741404
3608	0.5740038843958951	-1.3955739965409257
3609	0.5741487467238106	-1.39558621384569
3610	0.5740161017006591	-1.3956577723450216
3611	0.8607387912182874	-2.1490815038459337
3612	0.6606071218798537	-2.135410339815062
3613	0.5555330649220391	-1.4164708236750538
3614	0.5560043038200776	-1.4162177509335148
3615	0.5719391598907858	-1.3945390162944933
3616	0.5720543516214174	-1.3945041097094533
3617	0.5487611874243011	-1.4195932177068717
3618	0.6056240144542764	-1.338236439954408
3619	0.6056240144542764	-1.338236439954408
3620	0.6053814136882492	-1.3381142669067685
3621	0.65989502754504	-2.1377281370617105
3622	0.559290758801583	-1.412524634236295
3623	0.5598143575771812	-1.413310032399692
3624	0.5591458964736674	-1.4120010354606967
3625	0.5711467804103804	-1.3929472760166743
3626	0.5704259594293067	-1.3914811994449992
3627	0.5714295237492034	-1.3935494146086125
3628	0.5706825228293498	-1.3919995622328416
3629	0.570984464789945	-1.3926383527390713
3630	0.836565981078166	-2.140450850694822
3631	0.8369586801598647	-2.139410634460633
3632	0.5255483083727766	-1.4696248260445413
3633	0.7208209810736581	-1.2484916098168597
3634	0.7197737835224616	-1.2759020057194308
3635	0.7297797561241449	-1.2461650859239515
3636	0.5811073744515121	-1.383571367274961
3637	0.5813639378515552	-1.383813968040988
3638	0.6736325140874874	-1.3473592759545825
3639	0.5644394800949663	-1.4043791826172374
3640	0.5500108431687291	-1.418923011274106
3641	0.8471688562840316	-2.143801882858651
3642	0.5717908069043663	-1.3939456043488152
3643	0.42862319369252344	-1.427853861056561
3644	0.5708675277300613	-2.0451331842556555
3645	0.5708675277300613	-2.0451331842556555
3646	0.8574505909075303	-2.158972284716986
3647	0.5121965395950199	-1.6529140681012298
3648	0.5115560037595379	-1.6549211967410231
3649	0.4866536459920829	-1.440809440094115
3650	0.4865838328220031	-1.4413016229431774
3651	0.7178835919425517	-1.2572182560768312
3652	0.7182989803045263	-1.2594068989588323
3653	0.7183478495235821	-1.259206186094853
3654	0.4679629150324756	-1.4360743618334544
3655	0.7219257744901706	-1.2367979038284977
3656	0.7225959809229363	-1.2366233709032983
3657	0.7223045109378532	-1.2354016404269021
3658	0.7129669994396837	-1.2906709818498068
3659	0.686982537535992	-1.3244640468269209
3660	0.5822278758312924	-1.3838279306750039
3661	0.8241095662066826	-2.139590403373589
3662	0.8240868769264067	-2.139482192959965
3663	0.826121930834232	-2.1391924683041337
3664	0.8259910311403325	-2.1393320946442937
3665	0.8795290059452585	-2.184396495930787
3666	0.7160178349721696	-1.2577278922184136
3667	0.6600253338269939	-2.137155669067057
3668	0.47696881397276636	-1.4408862345812028
3669	1.0309083932877345	-2.8236512597417422
3670	0.8456120225912527	-2.1537362969610028
3671	0.720239786432744	-1.2584696571505114
3672	0.5708971983273452	-1.399260131921138
3673	0.5709547941926609	-1.399521931308937
3674	0.7247479718906453	-1.2450602925074388
3675	0.724864908950529	-1.2454372836258696
3676	0.7810924361327783	-1.1681785389570887
3677	0.8188508891704236	-2.1663899340379618
3678	0.718979658712804	-1.2589705666458337
3679	0.7224493732657689	-1.2228073445445111
3680	0.722391777400453	-1.2237079344385402
3681	0.7190756518216638	-1.24965574442794
3682	0.7190669251754038	-1.2495108821000245
3683	0.7216639751023713	-1.2495894219163641
3684	0.8465667176920936	-2.1416272026106657
3685	0.8464846872172498	-2.1415189921970423
3686	0.680212405367506	-1.333723018508751
3687	0.7153005046496	-1.2839863708146684
3688	0.7153005046496	-1.2839863708146684
3689	0.7148868616168774	-1.2838868870473048
3690	0.7148868616168774	-1.2838868870473048
3691	0.687595148103442	-1.3273281321294434
3692	0.6872809888380831	-1.327205959081804
3693	0.8467761572023329	-2.1406463275710452
3694	0.8468546970186727	-2.140684724814589
3695	0.7232068461611344	-1.2374960355292954
3696	0.6861185995562549	-1.331831081599589
3697	0.5765398477990428	-1.3947502011339847
3698	0.9756390518648302	-2.8059082425659674
3699	0.561093683918893	-1.4109538379095
3700	0.680861667849248	-1.3296354574005802
3701	0.678083103680073	-1.3442874964710727
3702	0.8505216337771127	-2.1411315291030997
3703	0.8331032478422093	-2.1412275222119592
3704	0.8252492662082348	-2.1406463275710452
3705	0.8251532730993751	-2.1408592577397885
3706	0.7240358775558317	-1.2250902352061197
3707	0.7237583702047645	-1.2244060661393381
3708	0.6744824894332087	-1.3461288188319265
3709	0.8238390401726234	-2.146309920993767
3710	0.8237954069413236	-2.1461737853121114
3711	0.8237954069413236	-2.1473361745939394
3712	0.8239175799889632	-2.1474443850075633
3713	0.7197214236449017	-1.266527842306969
3714	0.7184351159861818	-1.2665767115260251
3715	0.8065375912976036	-2.1630650818129125
3716	0.7241074360551635	-1.2228946110071108
3717	0.7138396640656808	-1.2831084702009152
3718	0.5710577686185286	-2.0453810210094385
3719	0.4819063504266583	-1.4415459690384564
3720	0.7218332720398147	-1.2478371113473619
3721	0.9759305218499132	-2.802998778702893
3722	0.7135481940805977	-1.2833981948567463
3723	0.8480694461780607	-2.14536744319769
3724	0.7130752098533073	-1.2876829781703925
3725	0.7132061095472069	-1.2875503331472407
3726	0.7128011931607441	-1.287454340038381
3727	0.7128570436968079	-1.2874037254900732
3728	0.7286959066586565	-1.2679869375616364
3729	0.7203410155293597	-1.2615588899265413
3730	0.7200652535075446	-1.2611085949795269
3731	0.6143558967020041	-1.3220869083857045
3732	0.7190756518216638	-1.2906709818498068
3733	0.7175188181288847	-1.262579907538958
3734	0.8345588524383726	-2.1412275222119592
3735	0.7702719765468301	-2.1665353781422887
3736	0.7238177113993324	-1.2301656526709193
3737	0.7243989060402465	-1.2310976584914841
3738	0.9226979796640863	-2.2427480888127134
3739	0.7118028648286033	-1.2903795118647237
3740	0.7117155983660037	-1.2904667783273234
3741	0.7125830270042449	-1.285434994093824
3742	0.6903353150290732	-1.3240067705628984
3743	0.7134330023499661	-1.2901770536714923
3744	0.6243042734383717	-1.3185386540164001
3745	0.7158677366564982	-1.271161691471014
3746	0.7160614682034695	-1.2725579548726096
3747	0.7169376234879707	-1.2711232942274702
3748	0.7243168755654028	-1.2661264165790105
3749	0.7128221371117681	-1.290351586596692
3750	0.5721538353887811	-1.395565269894666
3751	0.5628686837681712	-1.40789951171851
3752	0.7167770531967873	-1.259459258836392
3753	0.5721398727547651	-1.3941044293107467
3754	0.5723720015452803	-1.3947798717312685
3755	0.5726739435058754	-1.3947275118537088
3756	0.7268720375903225	-1.2443324902093573
3757	0.6687752627791872	-1.3334524924746918
3758	0.6687752627791872	-1.3334524924746918
3759	0.6763447557450866	-1.3351559338246382
3760	0.674985144257783	-1.3309444543395756
3761	1.0733774899765127	-2.898119222936584
3762	0.5739515245183352	-1.3935581412548723
3763	0.5745327191592494	-1.3934412041949888
3764	0.5722271392173649	-1.3947798717312685
3765	0.6778562108773136	-1.3343618090149807
3766	0.5928796202562138	-1.360445754686036
3767	0.5928796202562138	-1.360445754686036
3768	0.5928796202562138	-1.360445754686036
3769	0.7174175890322692	-1.2646079801297754
3770	0.5125106988603789	-1.6545145350253085
3771	0.5125106988603789	-1.6545145350253085
3772	0.5125106988603789	-1.6545145350253085
3773	0.5149995383737228	-1.6558758918418643
3774	0.5149995383737228	-1.6558758918418643
3775	0.5149995383737228	-1.6558758918418643
3776	0.6872530635700511	-1.3284573601554839
3777	0.6737634137813869	-1.328448633509224
3778	0.6871448531564275	-1.328719159543283
3779	0.7136738577867414	-1.2873059870519616
3780	0.8472840480146633	-2.139185486987126
3781	0.8299040593233037	-2.1391924683041337
3782	0.7134905982152819	-1.2871070195172343
3783	0.8064677781275238	-2.1538096007895864
3784	0.7143056669759632	-1.2813771035829369
3785	0.7143056669759632	-1.2813771035829369
3786	0.7120943348136864	-1.2895068472387266
3787	0.5677852762710394	-1.403855583841639
3788	0.713171202962167	-1.2883444579568981
3789	0.8444478879801725	-2.1453011206861143
3790	0.8444478879801725	-2.1453011206861143
3791	0.5302956039382011	-1.4217225193943048
3792	0.5302956039382011	-1.4217225193943048
3793	0.5302956039382011	-1.4217225193943048
3794	0.9066985464110543	-3.0694529596171116
3795	0.7298390973187128	-1.245960882401468
3796	0.5919772850329327	-1.3620933454999185
3797	0.42862319369252344	-1.4405371687308037
3798	0.9576045647039728	-2.8518679977587347
3799	0.9576045647039728	-2.8518679977587347
3800	0.5580986989224708	-1.4145317628760883
3801	0.5581562947877866	-1.414676625204004
3802	0.5292134998019646	-1.4253231336411694
3803	0.5292134998019646	-1.425118930118686
3804	0.6717021799347818	-1.3328119566392098
3805	0.6717021799347818	-1.3328119566392098
3806	0.6725329566587309	-1.3333146114637842
3807	0.6723880943308155	-1.3337806143740667
3808	0.724835238353245	-1.2461074900586353
3809	0.5690349320154672	-1.4035937844538398
3810	0.5416629333564402	-1.4212792057642984
3811	0.7168887542689149	-1.2633129458247954
3812	0.48192903970693424	-1.4420782944603148
3813	0.5575157589523047	-1.4134548947276078
3814	0.5704311954170628	-1.3963209974607793
3815	0.5716529258934588	-1.3964379345206632
3816	0.8496838757361554	-2.1493729738310168
3817	0.8496838757361554	-2.1493729738310168
3818	0.5722358658636248	-1.3981256679073417
3819	0.5519900465404907	-1.4170031490969122
3820	0.97447491725375	-2.8061979672217987
3821	0.880897344078822	-2.2015007226003314
3822	0.6770777940309243	-1.3445527865173756
3823	0.8418019688341489	-2.1560052249885953
3824	0.9040805525330626	-3.0790522705030803
3825	0.3671003375597233	-2.739002791020017
3826	0.8395033702092726	-2.1461737853121114
3827	0.8395033702092726	-2.1461737853121114
3828	0.9026266932661515	-3.103195410045918
3829	0.9032078879070655	-3.102322745419921
3830	0.7219554450874545	-1.2305443891186019
3831	0.8480415209100287	-2.1506819707700124
3832	0.8479385464841611	-2.1508268330979283
3833	0.7196568464625779	-1.265363707695889
3834	0.7196865170598618	-1.2647615691039509
3835	0.6801635361484503	-1.3307646854266206
3836	0.6774792197588829	-1.3328067206514538
3837	0.6778649375235737	-1.3323407177411715
3838	0.6770428874458844	-1.3340127431645818
3839	0.6722711572709319	-1.3348574825225472
3840	0.428448660767324	-1.4279707981164447
3841	0.428448660767324	-1.4279707981164447
3842	0.7277726274843516	-1.2434598255833602
3843	0.5606573516058945	-1.4160728886055993
3844	0.5607166928004622	-1.4161025592028833
3845	0.8461932172321668	-2.1459835444236437
3846	0.8461932172321668	-2.1458823153270283
3847	0.9049532171590599	3.1087228677869843
3848	1.0245658667859872	-2.7445302487610834
3849	0.7247776424879292	-1.231795790192282
3850	0.5823936821102318	-1.383208338790546
3851	0.31968672310004537	-1.144644519323197
3852	0.8495966092735557	-2.1417720649385816
3853	0.8491026810952413	-2.1418104621821255
3854	0.5585053606381855	-1.412465293041727
3855	0.5646140130201657	-1.410342972671302
3856	0.7266102382025234	-1.2265004612417314
3857	0.4838838084691679	-1.4418112590847598
3858	0.7189587147617802	-1.252041609515416
3859	0.7179708584051513	-1.2500344808756227
3860	0.7182029871956666	-1.2502369390688541
3861	0.8342673824532895	-2.140065132930131
3862	0.8486890380625187	-2.148660879496203
3863	0.567261677495441	-1.4099939068209029
3864	0.655952904723438	-2.132792345937071
3865	0.657116463375865	-2.1330820705929017
3866	0.5562364326105929	-1.4149960204571188
3867	0.5466074511273401	-1.4190399483339897
3868	0.7193950470747787	-1.2586529167219707
3869	0.718979658712804	-1.2584487131994875
3870	0.7193950470747787	-1.2581205913001123
3871	0.7195207107809223	-1.258242764347752
3872	0.5467540587845077	-1.4192720771245049
3873	0.7214021757145722	-1.25460026219884
3874	0.5565558278637078	-1.4154323527701174
3875	0.5565558278637078	-1.4154323527701174
3876	0.5567024355208753	-1.4153747569048016
3877	0.7160440149109496	-1.2633513430683394
3878	0.4743804906920588	-1.4398093664327223
3879	0.5464922593967084	-1.419882942362703
3880	0.9043720225181457	-3.075851336654923
3881	0.5562364326105929	-1.414589358741404
3882	0.7149880907134931	-1.2827297337532326
3883	0.7149880907134931	-1.2827297337532326
3884	0.7174036263982532	-1.261989986251784
3885	0.5577496330720719	-1.4147638916666037
3886	0.5575157589523047	-1.4149960204571188
3887	0.43287132509187765	-1.4113604996252145
3888	0.43353978619539146	-1.40970243683582
3889	0.43353978619539146	-1.40970243683582
3890	0.7160440149109496	-1.2824330277803935
3891	0.7160440149109496	-1.2824330277803935
3892	0.6779434773399134	-1.332152222181956
3893	0.7227111726535679	-1.2275476587929277
3894	0.47894801734452797	-1.443212758474111
3895	0.846130385379095	-2.14359069801916
3896	0.6812753108819706	-1.331124223252531
3897	0.6819699519242642	-1.3317420698077373
3898	0.6819699519242642	-1.3317420698077373
3899	0.682069435691628	-1.3318991494404169
3900	1.0343990517917234	-2.362594612559408
3901	0.7653565475967974	-1.2168732250877305
3902	0.7657928799097959	-1.217018087415646
3903	0.6850417314077744	-1.3341000096271816
3904	0.720239786432744	-1.2624542438328143
3905	0.6762574892824869	-1.3384057368918516
3906	0.562345084992573	-1.410051502686219
3907	0.5449790589352295	-1.4212792057642984
3908	0.7125882629920008	-1.2904091824620076
3909	0.7123264636042017	-1.2904091824620076
3910	0.42713966382832824	-1.4277089987286453
3911	0.5263040359388901	-1.4256721994915682
3912	0.5263040359388901	-1.4256721994915682
3913	0.5263040359388901	-1.4256721994915682
3914	0.7126039709552688	-1.286826021507663
3915	0.7104938678896077	-1.2913691135506042
3916	0.7110419012747339	-1.2910113210539456
3917	0.7417649320975901	-1.2359845803970684
3918	0.6643886569569797	-2.133665010563068
3919	0.6646795509834097	-2.133665010563068
3920	0.8395033702092726	-2.1412275222119592
3921	0.8395033702092726	-2.1412275222119592
3922	0.8397948401943556	-2.1415189921970423
3923	0.8397948401943556	-2.1409377975561283
3924	0.6741718208263537	-1.3288203886398988
3925	0.6692761722745095	-1.3473365866743068
3926	0.8508480103472357	-2.144428456060117
3927	0.8508270663962118	-2.144412748096849
3928	0.8508480103472357	-2.1438455160899506
3929	0.8512354734411783	-2.144128259428774
3930	0.714071792856196	-1.2852604611686242
3931	0.714071792856196	-1.2852604611686242
3932	0.7142707603909234	-1.2855432045074473
3933	0.7160736855082335	-1.266590674160041
3934	0.5305277327287163	-1.4206770671723603
3935	0.5305277327287163	-1.4206770671723603
3936	0.5305277327287163	-1.4206770671723603
3937	0.5304631555463926	-1.4212792057642984
3938	0.5304631555463926	-1.4212792057642984
3939	0.5304631555463926	-1.4212792057642984
3940	0.807031519475918	-2.1627299785965293
3941	0.5596398246519817	-1.4134845653248918
3942	0.554025100448316	-1.4175564184697944
3943	0.5535224456237416	-1.417046782328212
3944	0.7189011188964644	-1.223418209782709
3945	0.449684081776339	-1.39864926668294
3946	0.449684081776339	-1.39864926668294
3947	0.449684081776339	-1.39864926668294
3948	0.6052505139943496	-1.3371630624644315
3949	0.723322037891766	-1.2365361044406984
3950	0.7234389749516497	-1.235810047471869
3951	0.47484649360234127	-1.4400711658205214
3952	0.5302606973531612	-1.4214834092867816
3953	0.5302606973531612	-1.4214834092867816
3954	0.5302606973531612	-1.4214834092867816
3955	0.6596524267790128	-2.1382255558985293
3956	0.6596524267790128	-2.1382255558985293
3957	0.7185956862773654	-1.276074793315378
3958	0.7117749395605715	-1.2904388530592914
3959	0.7117452689632876	-1.2905261195218911
3960	0.6854780637207729	-1.3322394886445557
3961	0.52755543701257	-1.536500606993208
3962	0.5276706287432016	-1.5364709363959241
3963	0.5352924815866609	-1.5364709363959241
3964	0.7253291665315595	-1.2243484702740224
3965	0.7251843042036439	-1.2221092128437134
3966	0.7169760207315147	-1.2555759012507046
3967	0.7170388525845864	-1.2540190675579257
3968	0.7168939902566709	-1.2536700017075268
3969	0.7183635574868501	-1.2535774992571713
3970	0.6655522156094068	-2.130174352059079
3971	0.6646795509834097	-2.1272648881960046
3972	0.6655522156094068	-2.130174352059079
3973	0.5573708966243891	-1.4159559515457156
3974	1.0250894655615856	-2.739002791020017
3975	0.606027185511487	-1.338559325866027
3976	0.6059207204271154	-1.339240004274305
3977	0.5759673798043887	-1.394600102818313
3978	0.5670278033756738	-1.4045240449451528
3979	0.567289602763473	-1.405630583690917
3980	0.5180102313334131	-1.657743394141498
3981	0.5180102313334131	-1.657743394141498
3982	0.5180102313334131	-1.657743394141498
3983	0.4310963252425994	-1.4166837538437973
3984	0.4310963252425994	-1.4166837538437973
3985	0.7267551005304388	-1.2436919543738754
3986	0.7274532322312366	-1.2428786309424458
3987	0.6816872085854413	-1.3340808110054097
3988	0.7198750126190773	-1.2565794655706015
3989	0.657116463375865	-2.1330820705929017
3990	0.7190756518216638	-1.2621872084572592
3991	0.4817894133667747	-1.443802679761285
3992	0.48185573587835046	-1.4432825716441908
3993	0.7216639751023713	-1.229060859254407
3994	0.7216936456996553	-1.2267046647642144
3995	0.721170046924057	-1.2285948563441242
3996	0.8400845648501866	-2.140354857585962
3997	0.5947733024946277	-1.3594369543783833
3998	0.721766949528239	-1.256108226672563
3999	0.55281209661818	-1.417125322144552
4000	0.5526637436317604	-1.418333089986932
4001	0.553115783908027	-1.4169804598166362
4002	0.5526236010589646	-1.4173906121908548
4003	0.8918056519037866	-2.225352392158086
4004	0.7209379181335417	-1.2234758056480248
4005	0.7209379181335417	-1.2234758056480248
4006	0.7207982917933822	-1.254891732183923
4007	0.5698500007761486	-2.044072024070443
4008	0.5700629309448919	-2.0442256130446186
4009	0.7282962262599497	-1.2454669542231536
4010	0.8418298941021809	-2.1490815038459337
4011	0.842412834072347	-2.1476276445790226
4012	0.4302236606166022	-1.4384427736284107
4013	0.7196568464625779	-1.2726364946889495
4014	0.721135140339017	-1.2580979020198364
4015	0.4770281551673342	-1.4413225668942011
4016	0.549721118512898	-1.4187781489461906
4017	0.7472330486440882	-1.2368851702910975
4018	0.6062889848992862	-1.3383271970755117
4019	0.6061755384979065	-1.3383760662945678
4020	0.6061755384979065	-1.3383760662945678
4021	0.7212276427893728	-1.2597262942119474
4022	0.8223415476744123	-2.1415189921970423
4023	0.4311835917051991	-1.4191848106619052
4024	0.4311835917051991	-1.4191848106619052
4025	0.721147357643781	-1.2564328579134338
4026	0.7243413101749306	-1.2329581794741102
4027	0.7246310348307617	-1.2325218471611117
4028	0.8383392355981922	-2.1409377975561283
4029	0.8380495109423612	-2.1406463275710452
4030	0.5735797693876605	-1.395544325943642
4031	0.5683088750466376	-1.399521931308937
4032	0.7234686455489335	-1.2365657750379824
4033	0.7235559120115331	-1.2358973139344687
4034	0.7247479718906453	-1.2338308441001073
4035	0.7163040689694968	-1.262236077676315
4036	0.7206953173675145	-1.2571257536264757
4037	1.017235483927611	-2.380337629735182
4038	0.570949558204905	-2.0457492854816097
4039	0.570949558204905	-2.0457492854816097
4040	0.5710280980212448	-1.392772743091475
4041	0.5547232321491138	-1.416514456906354
4042	1.0178184238977772	-2.3756845819493657
4043	0.6844221395233164	-1.3333495180488242
4044	0.5477419151411363	-1.4195635471095878
4045	0.5783288102823371	-1.3830128619143225
4046	0.7139932530398563	-1.2812025706577375
4047	0.7141311340507638	-1.280780200978755
4048	0.42905952600552205	-1.4285223221600747
4049	0.4297297324382878	-1.429075591532957
4050	0.5541210935571756	-1.4166052140274574
4051	0.7237583702047645	-1.233336915921793
4052	0.7170981937791542	-1.2811362481461617
4053	0.5738345874584517	-1.3940817400304708
4054	1.022181747027763	-2.764893005144101
4055	0.7142759963786793	-1.2839863708146684
4056	0.7142759963786793	-1.2839863708146684
4057	0.6574073399490025	-2.1330820705929017
4058	0.6591526692009968	-2.1330820705929017
4059	0.6597344572538565	-2.133954735218899
4060	0.6597344572538565	-2.135118869829979
4061	0.6596384641449968	-2.1342904201535218
4062	0.6597344572538565	-2.135118869829979
4063	0.5597846869798974	-1.4138912270406065
4064	0.848294593651568	-2.1434964502395517
4065	0.556206762013309	-1.413716694115407
4066	0.556206762013309	-1.413716694115407
4067	0.6738663882072546	-1.3261500348843474
4068	1.1053746111533247	-2.9466969720073424
4069	0.8304852539642178	-2.138609528333968
4070	0.7225610743378965	-1.2581432805803883
4071	0.723627470510865	-1.2578361026320375
4072	0.7118622060231713	-1.2900897872088928
4073	0.9008813640141571	-3.1171580440618727
4074	0.7151399343584165	-1.275778087342539
4075	0.7151399343584165	-1.275778087342539
4076	0.7156513158292509	-1.275748416745255
4077	0.7156513158292509	-1.275748416745255
4078	0.7159689657531139	-1.2765250882623926
4079	0.7182029871956666	-1.2484916098168597
4080	0.7195416547319463	-1.2214390064109477
4081	0.4863359960682199	-1.4408268933866348
4082	0.4863359960682199	-1.4408338747036429
4083	0.5493999779305311	-1.4194466100497043
4084	0.5486739209617014	-1.4190975441993054
4085	0.5483824509766184	-1.4192144812591891
4086	0.6894713770493359	-1.325031278833819
4087	0.6894713770493359	-1.325031278833819
4088	0.8374665709721951	-2.140065132930131
4089	0.8374665709721951	-2.140354857585962
4090	0.5465201846647404	-1.4198550170946709
4091	0.6872094303387514	-1.326232065359191
4092	0.5743232796490101	-1.3954396061885221
4093	0.7184996931685057	-1.261031800492439
4094	0.717766654882668	-1.2602149864025056
4095	0.9610952232079614	-2.858557844781629
4096	0.657116463375865	-2.134827399844896
4097	0.6573782627636642	-2.1349443369047796
4098	0.5292414250699965	-1.421366472226898
4099	0.7164227513586324	-1.26320299008192
4100	0.8505513043743965	-2.144835117775832
4101	0.8505565403621526	-2.144718180715948
4102	0.5639455519166519	-1.4085976434193075
4103	0.564207351304451	-1.4077249787933104
4104	0.564788545945365	-1.4080443740464252
4105	0.5667660039878747	-1.4057754460188328
4106	0.7144941625351786	-1.285578111092487
4107	0.5112942043717389	-1.569108593408218
4108	0.4831944034146301	-1.4439981566375086
4109	0.4806514586944744	-1.4442198134525117
4110	0.7271617622461535	-1.2456990830136687
4111	0.7270744957835538	-1.24535001716327
4112	0.8339759124682065	-2.1467549799530254
4113	0.8515251980970094	-2.146812575818341
4114	0.8241881060230222	-2.145363952539186
4115	0.8240868769264067	-2.1453011206861143
4116	0.8485214864543272	-2.1421001868379563
4117	0.8486174795631869	-2.142342787603984
4118	0.8466819094227251	-2.145931184546084
4119	0.8467761572023329	-2.1458823153270283
4120	0.8479385464841611	-2.1435557914341197
4121	0.848003123666485	-2.1436133872994354
4122	0.5824250980367678	-1.3834142876422815
4123	0.5664466087347596	-1.4037386467817552
4124	0.723322037891766	-1.2378747719769783
4125	0.7237007743394488	-1.2380789754994617
4126	0.7145151064862025	-1.2858713264068222
4127	0.5294456285924799	-1.5236724369910497
4128	0.6696531633929403	-1.3437289911104342
4129	0.6640977803838424	-2.1365727290968906
4130	0.6643886569569797	-2.1365727290968906
4131	0.6972590361717347	-1.3113234628886556
4132	0.8256419652899335	-2.1441509487090498
4133	0.8255407361933178	-2.1441369860750337
4134	0.8246384009700368	-2.1454547096602896
4135	0.8246680715673207	-2.145590845341945
4136	0.8241357461454624	-2.145615279951473
4137	0.8240868769264067	-2.145590845341945
4138	0.7109302002026062	-1.29096245183489
4139	0.557400567221673	-1.4150553616516865
4140	0.842412834072347	-2.1653724070840488
4141	0.7170545605478544	-1.278279144160647
4142	0.5673489439580408	-1.4025762574999272
4143	0.48332530310852967	-1.4436874880306536
4144	0.4826481153587559	-1.4409822276900623
4145	0.6635159923309826	-2.1357000644708934
4146	0.8240868769264067	-2.1418104621821255
4147	0.8242090499740462	-2.1417947542188576
4148	1.017235483927611	-2.366374995719228
4149	0.5715953300281429	-1.3985899254883722
4150	0.7184682772419697	-1.2603458860964054
4151	0.71903725457812	-1.26010503065963
4152	0.6739152574263104	-1.3347841786939636
4153	0.6744824894332087	-1.3349534756314068
4154	0.8068273159534347	-2.1636410404660706
4155	0.6798057436517914	-2.159844949342983
4156	0.6033027265491239	-2.1060312125162417
4157	0.6582800045749996	-2.135118869829979
4158	0.6582800045749996	-2.135118869829979
4159	0.6582800045749996	-2.134537675189065
4160	0.6603162278534239	-2.1365727290968906
4161	0.6603162278534239	-2.1362830044410597
4162	0.6599438967640958	-2.1383983434944764
4163	0.6598129970701962	-2.140450850694822
4164	0.6600974857382713	-2.1383110770318767
4165	0.6600974857382713	-2.1383110770318767
4166	0.6597554012048805	-2.1383564555924286
4167	0.6597554012048805	-2.1383564555924286
4168	0.6867870606597687	-2.161298808609894
4169	0.6600253338269939	-2.1368641990819737
4170	0.6981317007977318	-2.1653724070840488
4171	0.6600451258607115	-2.137970737827738
4172	0.8493941510803243	-2.1470464499381086
4173	0.8495006161646961	-2.1468631903666493
4174	0.8070699167194619	-2.1615606079976932
4175	0.7258527653071577	-1.2262107365859
4176	0.8505338510818766	-2.14719654825378
4177	0.8505565403621526	-2.1473361745939394
4178	0.8397948401943556	-2.1418104621821255
4179	0.8397948401943556	-2.1421001868379563
4180	0.6592405290755422	-2.1386479255775117
4181	0.6595162910973573	-2.1395764407395728
4182	0.5701257627979637	-2.0459831596013767
4183	0.5701257627979637	-2.0459831596013767
4184	0.7175484887261687	-1.2761638051072297
4185	0.8418298941021809	-2.144428456060117
4186	0.8418298941021809	-2.144428456060117
4187	0.6689550316921425	-1.334944748985147
4188	0.5976391331264023	-1.3606290142574953
4189	0.6225013483210615	-2.117084382669122
4190	0.6393717008708387	-2.128429022807085
4191	1.0195637531497714	-2.355613295551431
4192	0.6632251157578453	-2.1473361745939394
4193	0.6614797865058508	-2.1362830044410597
4194	0.6643886569569797	-2.1263922235700075
4195	0.6134832320760069	-2.107776541768236
4196	0.6626433277049854	-2.1368641990819737
4197	0.6623524511318482	-2.1368641990819737
4198	0.6335545184739416	-2.127847828166171
4199	0.8403760348352697	-2.1423916568230394
4200	0.8403760348352697	-2.1423916568230394
4201	0.8403760348352697	-2.1421001868379563
4202	0.8403760348352697	-2.1421001868379563
4203	0.8406675048203527	-2.1426831268081226
4204	0.8406675048203527	-2.1421001868379563
4205	0.8406675048203527	-2.1421001868379563
4206	0.8406675048203527	-2.1415189921970423
4207	0.46175652421238383	-1.431489381888465
4208	0.46175652421238383	-1.4314963632054731
4209	0.7251843042036439	-1.2214390064109477
4210	0.725446103591443	-1.220391808859751
4211	0.7251267083383282	-1.2214686770082315
4212	0.7222748403405693	-1.2482018851610286
4213	0.7180860501357831	-1.2735318485952225
4214	0.6849771542254505	-1.3316286234063577
4215	0.6852459349302576	-1.331220216361391
4216	0.685469337074513	-1.3303981662837017
4217	0.6846350696920597	-1.3322325073275476
4218	0.6764232955614263	-1.3339464206530063
4219	0.6763098491600467	-1.334225673333325
4220	0.6763098491600467	-1.334225673333325
4221	0.6762854145505188	-1.3326164797629865
4222	0.675011324196563	-1.3258620555577685
4223	0.9657482709937784	-2.801544919435982
4224	0.8554731328650207	-2.156965156077192
4225	0.8352185868956264	-2.1393757278755934
4226	0.8374665709721951	-2.138900998319051
4227	0.9945462036516848	-2.7730367114339063
4228	0.4854633314422228	-1.6969836317140867
4229	0.715003798676761	-1.2758356832078548
4230	0.4827929776866714	-1.4416279995133001
4231	0.48264462470025193	-1.4414639385636128
4232	0.4827877416989155	-1.4416419621473162
4233	0.5624026808578888	-1.4077249787933104
4234	0.8383392355981922	-2.1421001868379563
4235	0.8397948401943556	-2.1421001868379563
4236	0.8307994132295768	-2.1408505310935286
4237	0.8301955293083867	-2.140065132930131
4238	0.8301955293083867	-2.140065132930131
4239	0.8304852539642178	-2.1391924683041337
4240	0.5610657586508612	-1.416160155068199
4241	0.7516557129686419	-1.233947781159991
4242	0.669443723882701	-1.3436713952451185
4243	0.6588617926278594	-2.135410339815062
4244	0.8336861878123755	-2.1365744744261423
4245	0.8755740898602393	-2.161590278594977
4246	1.0210176124166828	-2.76838366364809
4247	0.8345588524383726	-2.1432643214490366
4248	0.8521081380671756	-2.1434091837769524
4249	0.7024950239277177	-2.170608394840032
4250	0.31567246582045844	-1.1733272602504718
4251	0.6724456901961313	-1.3489353082691335
4252	0.6723304984654996	-1.3487328500759022
4253	0.5707226654021458	-2.0461070779782684
4254	0.5115560037595379	-1.568208003514189
4255	0.8823512033457332	-2.226254727381367
4256	0.723322037891766	-1.2365361044406984
4257	0.8363041816903669	-2.1752614426258488
4258	0.8069913769031222	-2.1555392220783127
4259	0.7210531098641734	-1.2516401837874576
4260	0.7203410155293597	-1.2516925436650175
4261	0.5818840459686495	-1.3837197202613805
4262	0.5557617030540504	-1.414894791360503
4263	0.5560915702826773	-1.414676625204004
4264	0.8500853014641141	-2.143773957590619
4265	0.6608979984529911	-2.1368641990819737
4266	0.6608979984529911	-2.137155669067057
4267	0.8431109657731448	-2.156122162048479
4268	0.7198610499850612	-1.2573927890020309
4269	0.8499753457212386	-2.1435557914341197
4270	0.6058334539645157	-1.3383132344414959
4271	0.6724753607934152	-1.3307123255490607
4272	0.7192292407958392	-1.2760311600840781
4273	0.7211124510587411	-1.2626793913063217
4274	0.720850651670942	-1.2562007291229187
4275	0.7172727267043536	-1.2612325133564184
4276	0.7169515861219866	-1.2606513187155044
4277	0.5607742886657782	-1.4116519696102976
4278	0.5802207471914989	-1.3824019966761245
4279	0.5735064655590767	-1.3944517498318934
4280	0.48120123740885257	-1.4424064163596897
4281	0.4808958047897536	-1.4431830878768273
4282	0.5931449103025168	-1.360149048713197
4283	0.5931449103025168	-1.360149048713197
4284	0.5931449103025168	-1.360149048713197
4285	0.5933892563977962	-1.36047542528332
4286	0.5933892563977962	-1.36047542528332
4287	0.5933892563977962	-1.36047542528332
4288	0.5935201560916957	-1.3605277851608797
4289	0.5935201560916957	-1.3605277851608797
4290	0.5935201560916957	-1.3605277851608797
4291	0.5935376093842156	-1.3603305629554043
4292	0.5935376093842156	-1.3603305629554043
4293	0.5935376093842156	-1.3603305629554043
4294	0.5718798186962181	-1.3940520694331868
4295	0.5233369762104997	-1.4247122684029712
4296	0.5233369762104997	-1.4247122684029712
4297	0.5233369762104997	-1.4247122684029712
4298	0.6899146906793425	-1.3261831961401354
4299	0.6620615571054181	-2.1368641990819737
4300	0.7216936456996553	-2.1674074609918743
4301	0.5727507379929632	-1.3946838786224087
4302	0.8304852539642178	-2.1368641990819737
4303	0.7229450467733353	-1.2386601701403757
4304	0.8301955293083867	-2.138028333693054
4305	0.8304852539642178	-2.1374471390521395
4306	0.8304852539642178	-2.138609528333968
4307	0.8301955293083867	-2.138609528333968
4308	0.6606071218798537	-2.1374453937228877
4309	0.7118028648286033	-1.2895068472387266
4310	0.6594435632274267	-2.135410339815062
4311	0.7158520286932303	-1.2691371095387007
4312	0.716855593013127	-1.269007955174053
4313	0.714707092703922	-1.2645434029474516
4314	0.6858410922051877	-1.3311329498987912
4315	0.7231771755638505	-1.2353440445615864
4316	0.7271687435631614	-1.2676116917724576
4317	0.7180947767820429	-1.262867886865537
4318	0.7141747672820636	-1.2828257268620922
4319	0.7166182282348557	-1.2571606602115155
4320	0.6892008510152768	-1.3264065982843907
4321	0.6643886569569797	-2.129882882073996
4322	0.8457568849191682	-2.1429152555986377
4323	0.7243692354429626	-1.244973026044839
4324	0.7244285766375305	-1.245322091895238
4325	0.7242540437123309	-1.245292421297954
4326	0.4858473038776615	-1.4411742139077817
4327	0.5519516492969467	-1.4174988226044787
4328	0.5524019442439613	-1.41898758845643
4329	0.5723894548378003	-1.395797398685181
4330	0.572817060504539	-1.3956525363572656
4331	0.7181244473793268	-1.2689416326624772
4332	0.7195556173659622	-1.2689416326624772
4333	0.7289664326927157	-1.2313297872819995
4334	1.0193595496272883	-2.354187361552551
4335	1.0193595496272883	-2.354187361552551
4336	0.6691592352146261	-1.320137375611227
4337	0.673115896628897	-2.152863632335005
4338	0.5820899948203848	-1.3837022669688603
4339	0.5692688061352346	-1.4030125898129258
4340	0.5683368003146695	-1.4030998562755255
4341	0.5671150698382734	-1.4066184400475459
4342	0.5704032701490308	-2.045059880427072
4343	0.5710141353872289	-2.0452344133522713
4344	0.6600259272389396	-2.137736863707971
4345	0.659917716825316	-2.1380667309365977
4346	0.845809244796728	-2.145896277961044
4347	0.8459034925763358	-2.1458823153270283
4348	0.655952904723438	-2.133665010563068
4349	0.807350914729033	-2.164112279364109
4350	0.8072636482664333	-2.164047702181785
4351	0.807310772156237	-2.1636497671123305
4352	0.6686059658417438	-1.3343914796122647
4353	0.6807482214478683	-1.3330824826732688
4354	0.6807482214478683	-1.3330824826732688
4355	0.7201961532014441	-1.2490745497870257
4356	0.6807255321675924	-1.3325379399466466
4357	0.6807255321675924	-1.3325379399466466
4358	0.7205591816858589	-1.2502369390688541
4359	0.7199483164476609	-1.2490745497870257
4360	0.8514292049881497	-2.156354290838994
4361	0.5503895796164118	-1.4184587536930755
4362	0.4765045563917359	-1.4407117016560032
4363	0.7174088623860092	-1.280466041713396
4364	0.5591284431811474	-1.411802067925969
4365	0.5591458964736674	-1.411243562565331
4366	0.5591458964736674	-1.411243562565331
4367	0.5599592199050968	-1.415170553382318
4368	0.5600185610996645	-1.4154044275020854
4369	0.7198837392653371	-1.2621784818109991
4370	0.720536492405583	-1.2627073165743536
4371	0.905825881785057	3.1049407392979123
4372	0.5603082857554955	-1.4157814186205162
4373	0.8680970993446957	-2.1624332726236903
4374	0.8604473212332044	-2.1470464499381086
4375	1.0019359277046287	-2.367132468614593
4376	0.8749911498900732	-2.187770217374892
4377	0.6050410744841103	-1.3378908647625134
4378	0.6054931147603768	-1.3378332688971974
4379	0.7178835919425517	-1.2553280644969216
4380	0.8464846872172498	-2.1418104621821255
4381	0.8466679467887093	-2.142051317618901
4382	0.6744528188359248	-1.3337858503618225
4383	0.6738227549759548	-1.3325239773126307
4384	0.6744615454821847	-1.334269306564625
4385	0.6744615454821847	-1.334269306564625
4386	0.6120293728090955	-1.3281955607676847
4387	0.7661995416255106	-1.216349626312132
4388	0.716550160394028	-1.2814346994482526
4389	0.7161574613123293	-1.2811676640726977
4390	0.7161574613123293	-1.2811676640726977
4391	0.6713618407306428	-1.3377599650686136
4392	0.664249624028766	-2.1258110289290935
4393	0.7136075352751655	-1.2653933782931728
4394	0.7155553227203912	-1.2831084702009152
4395	0.7155797573299191	-1.2831171968471753
4396	0.5729915934297384	-1.3951289375816673
4397	0.7160789214959895	-1.2781709337470233
4398	0.5720543516214174	-1.394881100827884
4399	0.5721573260472852	-1.3947065679026847
4400	0.6576982339754323	-2.1357000644708934
4401	0.6574073399490025	-2.134246205203982
4402	0.8482788856883	-2.1406236382907693
4403	0.8485214864543272	-2.1406463275710452
4404	0.5304055596810767	-1.4217748792718647
4405	0.5304055596810767	-1.4217748792718647
4406	0.9887290212547877	-2.690425041949259
4407	0.7192676380393831	-1.265035585796514
4408	0.7187353126175249	-1.264461372472608
4409	0.8437707002303986	-2.1387910425761754
4410	0.8296125893382206	-2.138028333693054
4411	0.826413400819315	-2.138609528333968
4412	0.844617184917616	-2.1394245970946493
4413	1.037598240310629	-2.362011672589242
4414	0.5586798935633849	-1.4138615564433226
4415	0.5576902918775041	-1.4148511581292031
4416	0.558650222966101	-1.41400816410049
4417	0.8508392837009756	-2.147816140138238
4418	0.8508480103472357	-2.1476276445790226
4419	0.8511394803323187	-2.1470464499381086
4420	0.5631008125586865	-1.4092085086575055
4421	0.5624026808578888	-1.409964236223619
4422	0.8429940287132611	-2.1441369860750337
4423	0.8432854986983441	-2.1432643214490366
4424	0.8429940287132611	-2.1423916568230394
4425	0.570024533701348	-1.4034489221259243
4426	0.5696754678509491	-1.3966124674458624
4427	0.485091576311548	-1.4411567606152618
4428	0.5751156591294155	-1.3950416711190676
4429	0.5943945660469448	-1.3595905433525586
4430	0.7156809864265348	-1.273640059008846
4431	0.8144526594553979	-2.160740303249256
4432	0.7120367389483707	-1.2898279878210934
4433	0.5717349563683025	-1.394628028086345
4434	0.5717471736730664	-1.3942510369679142
4435	0.5718082601968862	-1.3947100585611887
4436	0.6588617926278594	-2.138609528333968
4437	0.6588617926278594	-2.138609528333968
4438	0.5600464863676964	-1.41400816410049
4439	0.5670278033756738	-1.4023423833801598
4440	0.8248565671265362	-2.1390458606469664
4441	0.7232347714291663	-1.236420912710067
4442	0.7233517084890498	-1.235750706277301
4443	0.724543768368162	-1.2334241823843928
4444	1.016073094645783	-2.379756435094268
4445	0.571267208128768	-1.3936506437052283
4446	0.5542868998361151	-1.416741349709113
4447	1.0163628193016139	-2.3753931119642826
4448	0.8351400470792867	-2.139482192959965
4449	0.5474521904853054	-1.4191568853938732
4450	0.5474521904853054	-1.4191568853938732
4451	0.578053048260522	-1.3836097645185048
4452	0.661188892479421	-2.1362830044410597
4453	0.5608318845310939	-1.4064439071223465
4454	0.4298222348886435	-1.4460262292283261
4455	0.5919668130574207	-1.3615104055297524
4456	0.5919668130574207	-1.3615104055297524
4457	0.5919196891676168	-1.3615610200780606
4458	0.4810424124469211	-1.4445618979859027
4459	0.4296180313661602	-1.4470821534257825
4460	0.7175624513601847	-1.2516925436650175
4461	0.7176217925547526	-1.2514010736799344
4462	0.5617638903516589	-1.409964236223619
4463	0.6890647153336212	-1.3278761655145699
4464	0.6643886569569797	-2.1275563581810877
4465	0.8482300164692442	-2.1473361745939394
4466	0.8484272386747195	-2.1473518825572073
4467	0.8235039369562406	-2.1453011206861143
4468	0.8233939812133648	-2.145344753917414
4469	0.5535311722700016	-1.416168881714459
4470	0.7298390973187128	-2.1700254548698656
4471	0.5305364593749763	-1.4202477161763698
4472	0.5305364593749763	-1.4202477161763698
4473	0.5305364593749763	-1.4202477161763698
4474	0.5305451860212362	-1.4200662019341623
4475	0.5305451860212362	-1.4200662019341623
4476	0.5305451860212362	-1.4200662019341623
4477	0.5304055596810767	-1.422298478047463
4478	0.5304055596810767	-1.422298478047463
4479	0.5304055596810767	-1.422298478047463
4480	0.5305853285940322	-1.4204501743696012
4481	0.5305853285940322	-1.4204501743696012
4482	0.5305853285940322	-1.4204501743696012
4483	0.5305800926062761	-1.4204065411383013
4484	0.5305800926062761	-1.4204065411383013
4485	0.5375038137489377	-1.4227051397631778
4486	0.5244138443589802	-1.4692181643288267
4487	0.5263040359388901	-1.4695969007765095
4488	1.0533062035785778	-3.01447508817929
4489	0.7270465705155219	-1.221294144083032
4490	0.6640977803838424	-2.128429022807085
4491	0.7158415567177182	-1.283457536051314
4492	0.573117257135882	-1.3959492423301048
4493	0.5694433390604339	-1.3961464645355801
4494	0.8456120225912527	-2.1743887779998516
4495	0.7169725300730106	-1.2760311600840781
4496	0.7169725300730106	-1.2760311600840781
4497	0.7164489312974124	-1.275778087342539
4498	0.7164489312974124	-1.275778087342539
4499	0.7168992262444268	-1.273633077691838
4500	0.84764882182833	-2.1423916568230394
4501	0.8475528287194704	-2.142464960651623
4502	0.6058474165985316	-1.3389083917164262
4503	0.665261321582977	-2.1304640767149103
4504	0.5718047695383822	-1.3939508403365712
4505	0.5931728355705488	-1.3605661824044237
4506	0.5931728355705488	-1.3605661824044237
4507	0.5931728355705488	-1.3605661824044237
4508	0.8767364791420675	-2.1842795588709034
4509	0.550621708406927	-1.419533876512304
4510	0.9974556675147593	-2.9749137100243344
4511	0.6835145683122793	-1.331768249746517
4512	0.6832527689244802	-1.3321173155969162
4513	0.6825633638699423	-1.3317787217220292
4514	0.6825633638699423	-1.3317787217220292
4515	0.6679951006035457	-1.3429435929470368
4516	0.569762734313549	-2.0441784891548145
4517	0.7103490055616922	-2.1691527902438685
4518	0.48205993940083386	-1.442601893235913
4519	0.4820651753885898	-1.442607129223669
4520	0.48179814001303467	-1.4444344889505072
4521	0.4817859227082707	-1.4444397249382632
4522	0.48185573587835046	-1.4445793512784226
4523	0.9014625586550712	-3.1104681970389785
4524	0.7238177113993324	-1.2343841134729894
4525	0.6122475389655948	-1.3265322619905342
4526	0.5354966851091442	-1.5360939452774933
4527	0.5298296010279187	-1.4245028288927317
4528	0.5298296010279187	-1.4245028288927317
4529	0.5298296010279187	-1.4245028288927317
4530	0.8469646527615483	-2.1433166813265965
4531	0.5719007626472419	-1.394029380152911
4532	0.8325220532012952	-2.1426831268081226
4533	0.48654019959070327	-1.446005285277302
4534	0.8255407361933178	-2.138900998319051
4535	0.8252492662082348	-2.138900998319051
4536	0.7087782092348972	-1.2923587152364853
4537	0.7087782092348972	-1.2923587152364853
4538	0.8256489466069414	-2.1388957623312947
4539	0.8255407361933178	-2.138609528333968
4540	0.8255407361933178	-2.138900998319051
4541	0.8249595415524038	-2.138900998319051
4542	0.7196568464625779	-1.257679022999358
4543	0.7197161876571456	-1.257684258987114
4544	0.7197161876571456	-1.257684258987114
4545	0.5770634465746411	-1.3950364351313116
4546	0.5771070798059411	-1.3949194980714281
4547	0.6787759993931147	-1.3339027874217064
4548	0.6787759993931147	-1.3339027874217064
4549	0.6784967467127956	-1.3345084166721481
4550	0.6788597751972104	-1.3332011650624045
4551	0.7121240054109703	-1.287848784449332
4552	0.7121240054109703	-1.2879360509119315
4553	0.7121292413987264	-1.2879011443268917
4554	0.7122810850436498	-1.287799915230276
4555	0.7120646642164025	-1.287892417680632
4556	0.5589120223539001	-1.4145020922788043
4557	0.7952098226757436	-2.1631319861009
4558	0.7267254299331549	-1.242936226807762
4559	0.7264933011426397	-1.2429658974050457
4560	0.8513419385255501	-2.1457217450358446
4561	0.8511394803323187	-2.145590845341945
4562	0.6844692634131202	-1.3307838840483923
4563	0.6840154778076017	-1.3310893166674913
4564	0.6840434030756336	-1.3314732891029302
4565	0.6838636341626781	-1.3313580973722985
4566	0.6838636341626781	-1.3313580973722985
4567	0.6795352176177323	-1.3337282544965068
4568	0.6056955729536082	-1.3384266808428755
4569	0.8066772176377631	-2.1601364193280657
4570	0.8235999300651002	-2.145795048864428
4571	0.8482300164692442	-2.1415189921970423
4572	0.8484429466379875	-2.141557389440586
4573	0.5723370949602404	-1.3949456780102079
4574	0.5725604971044959	-1.3950713417163516
4575	0.6600253338269939	-2.135410339815062
4576	0.6603162278534239	-2.1357000644708934
4577	0.8432854986983441	-2.1531551023200883
4578	0.7164576579436722	-2.1671177363360434
4579	0.5302973492674531	-1.4246808524764354
4580	0.5302973492674531	-1.4246808524764354
4581	0.5302973492674531	-1.4246808524764354
4582	0.7195329280856863	-1.2266470688988986
4583	0.7226535767882521	-1.2247551319897367
4584	0.6884154528518794	-1.3270401528028646
4585	0.8498933152463948	-2.150865230341472
4586	0.8474742889031306	-2.1467253093557415
4587	0.8473573518432469	-2.1464635099679423
4588	0.6058561432447916	-1.338566307183035
4589	0.6058561432447916	-1.338566307183035
4590	0.42876980134969095	-1.4277526319599452
4591	0.597731635576758	-1.3605504744411556
4592	0.597731635576758	-1.3605504744411556
4593	0.5441360649065161	-1.4228796726883772
4594	0.54355312493635	-1.4229093432856612
4595	0.7207825838301143	-1.2591014663397333
4596	0.937823002961869	-2.90248254606657
4597	0.9459684545809267	-2.8783394065237324
4598	0.9450957899549294	-2.877756466553566
4599	0.8956453762581741	-3.124720555710764
4600	0.9049532171590599	-3.0729436181211
4601	0.9317143505798889	-2.929535149472482
4602	0.9293878266869805	-2.930699284083562
4603	0.9311331559389748	-2.9286624848464853
4604	0.762330728450256	-2.1675825756934852
4605	0.9416051314509408	-2.9007372168145755
4606	0.9674936002457727	-2.805325302595802
4607	0.9488482478467173	-2.876302607286655
4608	0.9497505830699983	-2.8832839242946324
4609	0.9465496492218407	-2.885029253546627
4610	0.766112275162911	-1.2177458897137277
4611	0.5939128551733944	-1.3603183456506405
4612	1.022471471683594	-2.357358624803425
4613	0.4732163560809785	-1.4393154382544078
4614	0.5567303607889073	-1.4154323527701174
4615	0.3174457203404847	-1.1452553845613953
4616	0.3174457203404847	-1.1452553845613953
4617	0.3187756612305043	-1.1444123905326817
4618	0.8406675048203527	-2.1461737853121114
4619	0.8406675048203527	-2.1461737853121114
4620	0.8409572294761838	-2.1453011206861143
4621	0.6629342217314154	-2.118538241936033
4622	0.48739715625343244	-1.441401106710541
4623	0.5701118001639477	-1.4003649253376502
4624	0.8499753457212386	-2.148791779190103
4625	0.8500486495498223	-2.148652152849943
4626	0.8053158608212075	-2.147554340750439
4627	0.6122562656118549	-1.3273578027267277
4628	0.5599312946370648	-1.4122628348484958
4629	0.9980368621556734	-2.966187063764363
4630	0.5730491892950542	-1.3944604764781534
4631	0.5719967557561016	-1.3953907369694665
4632	0.72515463360636	-1.2309807214316006
4633	0.7285876962450328	-1.2340647182198745
4634	0.7283834927225495	-1.2342392511450742
4635	1.043415422707526	-2.8315052413757167
4636	0.7282962262599497	-1.2442155531494739
4637	0.8480938807875886	-2.146571720381566
4638	0.7213742504465402	-1.230238956499503
4639	0.5570218307739903	-1.4126398259669264
4640	0.5560043038200776	-1.4138615564433226
4641	0.5560043038200776	-1.4138615564433226
4642	0.720868104963462	-1.253320935857128
4643	0.7194247176720626	-1.2534378729170117
4644	0.7198470873510453	-1.252689126667906
4645	0.48628363619066006	-1.4413853987472731
4646	0.7244285766375305	-1.2346162422635047
4647	0.7131991282301989	-1.2900601166116088
4648	0.7240201695925637	-1.232376984833196
4649	0.7241947025177631	-1.2321151854453969
4650	0.8306021910241015	-2.1391139284877942
4651	0.6635158876112275	-2.1252293106894036
4652	0.7254757741887269	-1.2358676433371847
4653	0.5729619228324545	-1.3964082639233792
4654	0.7113909671251328	-1.2907495216661464
4655	0.7114363456856847	-1.2907407950198864
4656	0.7115131401727723	-1.2906709818498068
4657	0.8318448654515214	-2.136960192190833
4658	0.8325220532012952	-2.140354857585962
4659	0.8269945954602291	-2.1415189921970423
4660	0.7244565019055622	-1.240724894645485
4661	0.7244565019055622	-1.240724894645485
4662	0.8188072559391237	-2.1660984640528786
4663	0.8831941973744465	-2.2132816950512932
4664	0.5676980098084395	-1.4083358440315084
4665	0.56941366846315	-1.4011799940983316
4666	0.5696178719856333	-1.4021975210522444
4667	0.7203846487606594	-1.2551238609744384
4668	0.7255717672975867	-1.2679467949888406
4669	0.8304852539642178	-2.139482192959965
4670	0.7106631648270512	-1.2910322650049695
4671	0.5683088750466376	-1.4065905147795141
4672	0.7121816012762862	-1.290321915999408
4673	0.5579241659972713	-1.412494963639011
4674	0.5598440281744651	-1.4137463647126909
4675	0.5585926271007852	-1.4137742899807226
4676	0.5574284924897049	-1.413310032399692
4677	0.5975431400175426	-1.3605330211486357
4678	0.5975431400175426	-1.3605330211486357
4679	0.6643886569569797	-2.135118869829979
4680	0.5289796256821974	-1.4254976665663686
4681	0.7218769052711147	-1.2581781871654283
4682	0.579574975368261	-1.38203024154545
4683	0.7246607054280457	-1.233685981772192
4684	0.5747665932790166	-1.395186533446983
4685	0.574663618853149	-1.3950905403381235
4686	0.8066475470404793	-2.157736591606574
4687	0.807031519475918	-2.1585062818067033
4688	0.7204335179797153	-1.2756035544173396
4689	0.6864676654066537	-1.3299408900196792
4690	0.6861185995562549	-1.3302410866510221
4691	0.9916384851178622	-2.320706710511544
4692	0.7248928342185608	-1.2292057215823222
4693	0.5599888905023807	-1.4123501013110953
4694	0.6781424448746408	-1.3299059834346392
4695	1.0137448254236225	-2.384119758224254
4696	0.7787077345981374	-2.1653718253076373
4697	0.7788240898816023	-2.1652031101466056
4698	0.7784255730357309	-2.1631901637426445
4699	0.7784517529745109	-2.1644060764548554
4700	0.6603162278534239	-2.137155669067057
4701	0.5743669128803099	-1.3951516268619433
4702	0.5745571537687773	-1.3950503977653275
4703	0.6597344572538565	-2.1359915344559766
4704	0.8449627601095108	-2.1400127730525713
4705	0.8059546513274375	-2.161909673848092
4706	0.8061030043138571	-2.162250013052231
7821	0.8252928994395348	-2.138805005210191
7822	0.7246607054280457	-1.233685981772192
7823	0.8395033702092726	-2.1412275222119592
7824	0.5965744822826857	-1.360759913951395
7825	0.5965744822826857	-1.360759913951395
7826	0.8395033702092726	-2.1412275222119592
7827	0.7193671218067469	-1.2583823906879115
7828	0.48340384292486943	-1.4422091941542143
7829	0.8397948401943556	-2.1415189921970423
7830	0.8397948401943556	-2.1409377975561283
7831	0.5969985972909204	-1.3609117575963185
7832	0.4831891674268741	-1.4418112590847598
7833	0.7213655238002804	-1.248098910735161
7834	0.4827667977478915	-1.4423697644453979
7835	0.5704224687708027	-2.0445275550052133
7836	0.5704224687708027	-2.0445275550052133
7837	0.5702810971013912	-2.044644492065097
7838	0.4829849639043908	-1.4415197890996767
7839	0.5551979617056563	-1.4168006909036808
7840	0.7275404986938363	-1.2334817782497085
7841	0.7159637297653579	-1.2587890524036263
7842	0.8528848095843131	-2.151990967709008
7843	0.9037890825479796	-3.0892327760299634
7844	0.9040805525330626	-3.088360111403966
7845	0.8403760348352697	-2.1415189921970423
7846	0.8383392355981922	-2.140354857585962
7847	0.8382816397328765	-2.14041419878053
7848	0.8328135231863782	-2.138900998319051
7849	0.8325220532012952	-2.1391924683041337
7850	0.832906025636734	-2.1389882647816507
7851	0.8327454553455504	-2.13917152435311
7852	0.9428565325246208	-2.898148893533868
7853	0.6585708986014296	-2.133954735218899
7854	0.6602004601641391	-2.1365744744261423
7855	0.6600253338269939	-2.1362830044410597
7856	0.6600253338269939	-2.1365727290968906
7857	0.6603162278534239	-2.1368641990819737
7858	0.6603162278534239	-2.1365727290968906
7859	0.8333947178272924	-2.1464635099679423
7860	0.8509841460288913	-2.1464111500903824
7861	0.8303491182825622	-2.1367716966316177
7862	0.831940858560381	-2.1368641990819737
7863	0.7264357052773238	-1.2430234932703614
7864	0.9686577348568529	-2.8477961446138313
7865	0.9660397409788615	-2.84517815073584
7866	0.5752465588233151	-1.3948322316088284
7867	0.6606071218798537	-2.1362830044410597
7868	0.6606071218798537	-2.1362830044410597
7869	0.6638068863574125	-2.1261007535849243
7870	1.101594227993505	-2.9484423012593366
7871	1.049524075089506	-2.8303428520938883
7872	0.8345588524383726	-2.1374471390521395
7873	0.605135322263718	-1.3381439375040525
7874	0.48578272669533773	-1.6937547725978972
7875	0.4857914533415977	-1.6937408099638813
7876	0.4857914533415977	-1.6937408099638813
7877	0.4857914533415977	-1.6937408099638813
7878	0.6887732453485382	-1.3259999365686759
7879	0.5675810727485561	-1.404785844332952
7880	0.5674065398233565	-1.4050773143180348
7881	0.5676683392111557	-1.404174979094754
7882	0.5673489439580408	-1.4034192515286403
7883	0.9445145953140154	-2.8879387174097015
7884	0.7213742504465402	-1.253940527741586
7885	0.9421863260918549	-2.8984106929216673
7886	0.5754053837852465	-1.3950992669843834
7887	0.5436403913989497	-1.421425813421466
7888	0.5436403913989497	-1.421425813421466
7889	0.43034059767648586	-1.4187484783489066
7890	0.43034059767648586	-1.4187484783489066
7891	0.8074242185576167	-2.1641733658879287
7892	0.6596960600103128	-2.1378276208290745
7893	0.6596960600103128	-2.1378276208290745
7894	0.8235772407848243	-2.1414701229779864
7895	0.6759520566633879	-1.3317734857342733
7896	0.5912093401620553	-1.3614877162494765
7897	0.5706493615735619	-2.0460931153442523
7898	0.5706493615735619	-2.0460931153442523
7899	0.5704311954170628	-2.0461070779782684
7900	0.5704521393680866	-2.0460878793564965
7901	0.6809053010805478	-1.3328782791507856
7902	0.6809105370683037	-1.3328782791507856
7903	0.5428846638328362	-1.4196211429749037
7904	0.5470734540376225	-1.4178182178575935
7905	0.5137673359218148	-1.5700981950940986
7906	0.5108875426560241	-1.5698939915716157
7907	0.694059847652829	-1.2935804457128812
7908	0.8497275089674553	-2.1430688445728134
7909	0.8496838757361554	-2.1426831268081226
7910	0.7202973822980598	-1.258876318866226
7911	1.033526387165726	-2.362303142574325
7912	0.571895526659486	-1.3951079936306434
7913	0.5625772137830882	-1.4072589758830278
7914	0.7093314786077795	-1.2940447032939117
7915	0.7093314786077795	-1.2940447032939117
7916	1.0204364177757688	-2.3742289773532024
7917	0.56635934227216	-1.407840170523942
7918	0.563537144871685	-1.4076377123307107
7919	0.5655442735114786	-1.4079867781811095
7920	0.566010276421761	-1.4080740446437092
7921	0.7235838372795651	-1.2463692894464347
7922	0.9596396186117983	-2.8524491923996487
7923	0.5732830634148214	-1.3971360662214607
7924	0.8475371207562024	-2.1408854376785684
7925	0.8473573518432469	-2.1406463275710452
7926	0.6721559655403002	-1.3381823347475965
7927	0.7093314786077795	-1.2940447032939117
7928	0.7093314786077795	-1.2940447032939117
7929	0.6606071218798537	-2.134537675189065
7930	0.6606455191233976	-2.1347331520652886
7931	0.47647488579445196	-1.4410014263118343
7932	0.6056379770882923	-1.3378611941652294
7933	0.7196568464625779	-1.2602149864025056
7934	0.7203549781633756	-1.2602725822678214
7935	0.7244285766375305	-1.2430234932703614
7936	0.473390889006178	-1.4393730341197235
7937	0.6122841908798867	-1.3270401528028646
7938	0.8294677270103051	-2.1380196070467936
7939	0.8307767239493009	-2.1409377975561283
7940	0.48444580448831004	-1.4444641595477912
7941	0.6778771548283377	-1.3334804177427235
7942	0.5600464863676964	-1.4116222990130136
7943	0.5599312946370648	-1.4116798948783296
7944	0.5304404662661166	-1.4225916933617981
7945	0.5304404662661166	-1.4225916933617981
7946	0.5304404662661166	-1.4225916933617981
7947	0.661188892479421	-2.1368641990819737
7948	0.8520121449583158	-2.149954168471931
7949	0.42876980134969095	-1.4323341212464304
7950	0.46626470967028516	-1.4356502468252197
7951	0.6244212104982553	-1.3183344504939167
7952	0.6244212104982553	-1.3183344504939167
7953	0.5121371984004521	-1.6542527356375094
7954	0.5121371984004521	-1.6542457543205016
7955	0.5121371984004521	-1.6542457543205016
7956	0.5121371984004521	-1.6542457543205016
7957	0.5772100542318087	-1.3942266023583862
7958	0.7389427346971151	-1.2384280413498603
7959	0.8336861878123755	-2.1470464499381086
7960	0.7286749627076325	-1.2319109819229135
7961	0.7289664326927157	-1.2316212572670826
7962	0.5603379563527795	-1.4108665714469
7963	0.555567971507079	-1.4143851552189208
7964	0.6608979984529911	-2.117374107324953
7965	0.7192414581006032	-1.2711320208737302
7966	0.7181017580990509	-1.2710848969839263
7967	0.7231195796985346	-1.2457584242082367
7968	0.6835232949585393	-1.3332517796107124
7969	0.5667660039878747	-1.4083358440315084
7970	0.48333926574254565	-1.4430382255489118
7971	0.7182029871956666	-1.2772895424747661
7972	0.5651672823930478	-1.4098193738957037
7973	0.5625492885150563	-1.4074335088082273
7974	0.7133736611553984	-1.2900025207462928
7975	0.7251843042036439	-1.2267046647642144
7976	0.7121240054109703	-1.2885189908820978
7977	0.710406601427008	-1.2915436464758039
7978	0.7104537253168118	-1.291500013244504
7979	0.6701191663032229	-1.336122846230243
7980	0.5464625887994246	-1.4209301399138996
7981	0.5430591967580356	-1.4220366786596639
7982	0.5430591967580356	-1.4220366786596639
7983	0.5430016008927198	-1.421977337465096
7984	0.5434658584737503	-1.422385744510063
7985	0.7239625737272478	-1.245292421297954
7986	0.5588247558913004	-1.4126694965642104
7987	0.48253117829887227	-1.4440766964538485
7988	0.573724631715576	-1.3939159337515312
7989	0.557138767833874	-1.4151129575170023
7990	0.5579520912653032	-1.4146469546067197
7991	0.8284502000563925	-2.1412275222119592
7992	0.845835424735508	-2.1412187955656994
7993	0.8459907590389354	-2.1415137562092865
7994	0.8284502000563925	-2.1415189921970423
7995	0.8461932172321668	-2.1421001868379563
7996	0.8287399247122235	-2.1421001868379563
7997	0.8383392355981922	-2.140065132930131
7998	0.6869039977196523	-1.3309304917055598
7999	0.5832314401511891	-1.3825102070897484
8000	0.7101448020392087	-1.291775775266319
8001	0.710101168807909	-1.291779265924823
8002	0.5482951845140186	-1.4202616788103857
8003	0.5664762793320435	-1.410545430864533
8004	0.5389873436131328	-1.4226754691658938
8005	0.4430815012160445	-1.4002200630097348
8006	0.6733427894316564	-1.327518373017911
8007	0.5096064709850603	-1.571611395555578
8008	0.48359233848408484	-1.4407692975213189
8009	0.5955115767682212	-1.3602450418220566
8010	0.5955115767682212	-1.3602450418220566
8011	0.5955115767682212	-1.3602450418220566
8012	0.7229729720413671	-1.2375833019918951
8013	0.7475821144944872	-2.1743887779998516
8014	0.7285301003797171	-1.2324345806985118
8015	0.7291112950206311	-1.2304571226560024
8016	0.7285301003797171	-1.2324345806985118
8017	1.0181081485536083	-2.771001657526081
8018	0.4667883084458835	-1.4338176511106258
8019	0.9730210579868387	-2.8309240467348022
8020	0.722988680004635	-1.2301656526709193
8021	0.7225663103256524	-1.2291777963142905
8022	0.7235838372795651	-1.2287117934040082
8023	0.7388554682345155	-2.1717707841218603
8024	1.0149089600347025	-2.384700952865168
8025	0.6934769076826629	-2.161298808609894
8026	0.7154837642210594	-1.2844663363589668
8027	0.7154837642210594	-1.2844663363589668
8028	0.46441989665092714	-1.4350498535625338
8029	0.6643019839063258	-2.1331117411901857
8030	0.6056676476855762	-1.3372276396467555
8031	1.0469060812115147	-2.469117292796378
8032	1.0469654224060825	-2.468536098155464
8033	1.0466739524209994	-2.4681276911104972
8034	1.0346887764475543	-2.833833510597877
8035	0.7235559120115331	-1.2457863494762684
8036	0.571892036000982	-1.3947222758659525
8037	0.5718798186962181	-1.3948584115476081
8038	0.8055776602090067	-2.1522527670968072
8039	0.48360106513034484	-1.4438183877245532
8040	0.8450308279503386	-2.1458823153270283
8041	0.8453292792524295	-2.1458299554494684
8042	0.8447393579652555	-2.1467549799530254
8043	0.8444478879801725	-2.1470464499381086
8044	0.5505641125416113	-1.418022421380077
8045	0.7162778890307169	-1.261311053172758
8046	0.6685396433301679	-1.3325885544949545
8047	0.6686495990730437	-1.3319183480621886
8048	0.6686495990730437	-1.3319183480621886
8049	0.6684384142335522	-1.3312149803736348
8050	0.6684384142335522	-1.3312149803736348
8051	0.7193671218067469	-1.2560558667950033
8052	0.7186253568746492	-1.2552320713880618
8053	0.6640977803838424	-2.126973418210922
8054	0.6120049381995677	-1.3267783534150654
8055	0.8191406138262547	-2.1659536017249628
8056	0.8191406138262547	-2.1656621317398796
8057	0.5293583621298801	-1.5363836699333244
8058	0.7187178593250049	-1.2748548081682343
8059	0.5717000497832626	-1.393999709555627
8060	0.5717122670880266	-1.393994473567871
8061	0.5717401923560584	-1.3939648029705871
8062	0.5713038600430599	-1.393353937732389
8063	0.5302048468170973	-1.424703541756711
8064	0.5302048468170973	-1.424703541756711
8065	0.5302048468170973	-1.424703541756711
8066	0.6899862491786742	-1.3232510429967848
8067	0.680533545949873	-1.3331697491358687
8068	0.645422757387503	-1.326567168575574
8069	0.645422757387503	-1.3264205609184065
8070	0.6842947304879208	-1.327518373017911
8071	0.5775957719964995	-1.395259837275567
8072	0.8070786433657218	-2.163583444600755
8073	0.6741910194481257	-1.3290978959909658
8074	0.6741910194481257	-1.3290978959909658
8075	0.5649630788705644	-1.4074038382109435
8076	0.9061173517701401	-3.071198288869106
8077	0.9064070764259712	-3.0697426842729425
8078	0.9064070764259712	-3.0706153488989396
8079	0.7131031351213392	-1.2879360509119315
8080	0.7125952443090088	-1.2876079290125566
8081	0.7207721118546022	-1.2724671977515059
8082	0.8505565403621526	-2.1426831268081226
8083	0.8505216337771127	-2.1427983185387545
8084	1.0268347948135799	-2.7678007236779236
8085	0.7120890988259305	-1.2888698020617486
8086	0.8071484565358017	-2.164107043376353
8087	0.7194683509033625	-1.2484479765855598
8088	0.7207860744886182	-1.2562094557691785
8089	1.0462672907052848	-2.469989957422375
8090	1.0456267548698028	-2.471298954361371
8091	0.48793646299229876	-1.4455392823670197
8092	0.8066527830282352	-2.154875996962555
8093	0.6241594111104561	-1.318276854628601
8094	0.6241594111104561	-1.318276854628601
8095	0.7300136302439123	-1.2458160200735524
8096	0.7121117881062065	-1.289007683072656
8097	0.8447393579652555	-2.1435557914341197
8098	0.8272860654453121	-2.1435557914341197
8099	0.8275775354303953	-2.1429728514639534
8100	0.8450308279503386	-2.1429728514639534
8101	0.5681046715241542	-1.4060948412719476
8102	0.5676980098084395	-1.405630583690917
8103	0.5291401959733808	-1.4246476912206474
8104	0.5291401959733808	-1.4246476912206474
8105	0.5291401959733808	-1.4246476912206474
8106	0.7270744957835538	-1.242819289747878
8107	0.7269296334556382	-1.2434598255833602
8108	0.7256206365166425	-1.2451475589700387
8109	0.6745208866767525	-1.331803156331557
8110	0.6745208866767525	-1.331803156331557
8111	0.7566874972021416	-2.1701627541043615
8112	0.5663890128694439	-1.4064439071223465
8113	0.752615062280822	-2.1715328375671774
8114	0.7198470873510453	-1.2634438455186952
8115	0.7197964728027375	-1.2639971148915774
8116	0.719642883828562	-1.2625502369416741
8117	0.719337451209463	-1.263152375533612
8118	0.5706877588171059	-2.0448940741481323
8119	0.5706877588171059	-2.0448940741481323
8120	0.4794419455228423	-1.4432703543394267
8121	0.7158764633027581	-1.2845623294678266
8122	0.7262315017548405	-1.2292353921796064
8123	0.4881336851977741	-1.442064331826299
8124	0.6698870375127076	-1.33273341682287
8125	0.6698800561956997	-1.332738652810626
8126	0.6698800561956997	-1.332738652810626
8127	0.6698573669154237	-1.332127787572428
8128	0.6698573669154237	-1.332127787572428
8129	0.6698573669154237	-1.332127787572428
8130	0.66977533644058	-1.3316635299913975
8131	0.6713792940231627	-1.333024886807953
8132	0.6713792940231627	-1.333024886807953
8133	0.6713792940231627	-1.333024886807953
8134	0.6829176657080973	-1.3332186183549244
8135	0.6813817759663423	-1.333044085429725
8136	0.6813817759663423	-1.333044085429725
8137	0.6823312350794272	-1.3333093754760281
8138	0.6820973609596599	-1.333335555414808
8139	0.8480467568977847	-2.1467322906727495
8140	0.8479385464841611	-2.1467549799530254
8141	0.715003798676761	-1.2769998178189352
8142	0.7152935233325921	-1.2781255551864714
8143	0.7145081251691946	-1.2781255551864714
8144	0.5495465855876985	-1.4190696189312737
8145	0.7234093043543658	-1.2268216018240983
8146	0.7120995708014425	-1.2880302986915393
8147	0.5403242658201606	-1.4212512804962665
8148	0.5721102021574812	-1.394910771425168
8149	0.572162562035041	-1.3948671381938682
8150	0.4823880613002087	-1.4420870211065748
8151	0.485407480906159	-1.4389768443795208
8152	0.48600438351034103	-1.4389140125264492
8153	0.4838977711031839	-1.440519715438284
8154	0.530344473157257	-1.4233823275129514
8155	0.530344473157257	-1.4233823275129514
8156	0.530344473157257	-1.4233823275129514
8157	0.530313057230721	-1.4233980354762195
8158	0.530313057230721	-1.4233980354762195
8159	0.530313057230721	-1.4233980354762195
8160	0.8231548711058416	-2.1444476546818887
8161	0.5733109886828534	-1.3950277084850515
8162	0.5729427242106825	-1.3950207271680437
8163	0.5730404626487942	-1.3950416711190676
8164	0.5602803604874637	-1.4119416942661287
8165	0.6643072198940817	-2.1341310134733504
8166	0.6640977803838424	-2.133665010563068
8167	0.5637710189914523	-1.4089170386724224
8168	0.5635092196036533	-1.4092364339255377
8169	0.8275775354303953	-2.1415189921970423
8170	0.8272860654453121	-2.1415189921970423
8171	0.8450308279503386	-2.1421001868379563
8172	0.8449575241217548	-2.14220839725158
8173	0.8448475683788791	-2.1405241545234057
8174	0.8447393579652555	-2.140354857585962
8175	0.6825336932726584	-1.3285533532643437
8176	0.6772837428826596	-1.3301014603108625
8177	0.7141311340507638	-1.286520588888564
8178	0.676868354520685	-1.3097526665618608
8179	0.676868354520685	-1.3097526665618608
8180	0.7263484388147242	-1.2237376050358242
8181	0.9442231253289323	-2.883865118935547
8182	0.5680174050615546	-1.3989983325333388
8183	0.8444478879801725	-2.150245638457014
8184	0.8249595415524038	-2.138609528333968
8185	0.8456120225912527	-2.1493729738310168
8186	0.8429940287132611	-2.1496644438161
8187	0.5480909809915353	-1.4194466100497043
8188	0.5480909809915353	-1.4194466100497043
8189	0.5947855197993915	-1.3601787193104808
8190	0.5947855197993915	-1.3601787193104808
8191	0.5947855197993915	-1.3601787193104808
8192	0.8575971985646977	-2.1610090839540628
8193	0.6764320222076864	-1.3264275422354146
8194	0.5967664685004052	-1.3606150516234794
8195	0.855050763186038	-2.1427023254298945
8196	0.5727507379929632	-1.3949160074129239
8197	0.5728118245167829	-1.3950277084850515
8198	0.5723720015452803	-1.394881100827884
8199	0.5725465344704798	-1.3947851077190245
8200	0.6687316295478873	-1.3337666517400508
8201	0.5307406628974596	-1.4242375388464288
8202	0.5307406628974596	-1.4242375388464288
8203	0.5307406628974596	-1.4242375388464288
8204	0.7169603127682467	-1.2665016623681893
8205	0.654673002423073	-2.1313960825354754
8206	0.6544984694978736	-2.1313367413409074
8207	0.6539166814450137	-2.1304640767149103
8208	0.7248928342185608	-1.2377578349170946
8209	0.7242540437123309	-1.2462226817892672
8210	0.7243692354429626	-1.2460778194613515
8211	0.5583604983102699	-1.4140657599658057
8212	0.7243989060402465	-1.2463396188491507
8213	0.7258248400391258	-1.2445646189998725
8214	0.7256206365166425	-1.244362160806641
8215	0.711919801888487	-1.2904091824620076
8216	0.5771507130372409	-1.3948671381938682
8217	0.7240498401898476	-1.2314746496099152
8218	0.7237007743394488	-1.2310976584914841
8219	0.7115131401727723	-1.2906709818498068
8220	0.7113647871863529	-1.2906936711300827
8221	0.7194823135373785	-1.2553280644969216
8222	0.7127348706491684	-1.2879709574969713
8223	0.7176566991397924	-1.2580472874715287
8224	0.7176357551887684	-1.2565794655706015
8225	0.7207633852083423	-1.2579163877776292
8226	0.7155064535013353	-1.2812462038890373
8227	0.7151783316019604	-1.2810053484522619
8228	0.714712328691678	-1.2816528656047521
8229	0.7156949490605508	-1.281014075098522
8230	0.7156949490605508	-1.281014075098522
8231	0.7156949490605508	-1.281014075098522
8232	0.723313311245506	-1.264717935872651
8233	0.722391777400453	-1.230601984983918
8234	0.8406675048203527	-2.154027766946086
8235	0.8406675048203527	-2.154027766946086
8236	0.8409572294761838	-2.1516994977239254
8237	0.8343773381961652	-2.137059675958197
8238	0.836885376331281	-2.139482192959965
8239	0.7213742504465402	-1.254856825598883
8240	0.7211997175213408	-1.224697536124421
8241	0.5660975428843609	-1.4040004461695543
8242	0.48185573587835046	-1.4454520159044197
8243	0.4817196001966949	-1.446314208554905
8244	0.5597846869798974	-1.413105828877209
8245	0.5600761569649804	-1.4135997570555234
8246	0.5601634234275801	-1.4140657599658057
8247	0.8228581651330026	-2.145590845341945
8248	0.8229227423153264	-2.145590845341945
8249	1.0291630640357403	-2.3602663433372477
8250	1.0315716184034924	-2.362695841656024
8251	0.571886800013226	-1.3962634015954636
8252	0.7123613701892416	-1.287477029318657
8253	0.9773843811168246	-2.8038714433288905
8254	0.9770929111317415	-2.8027073087178103
8255	0.5286305598317985	-1.5381586697826026
8256	0.8190184407786151	-2.1670234885564352
8257	0.8188159825853838	-2.1663899340379618
8258	0.8188508891704236	-2.166534796365877
8259	0.5408199393277269	-1.420785277585984
8260	0.5470158581723068	-1.418312146035908
8261	0.5504768460790115	-1.416858286768997
8262	0.5470158581723068	-1.418312146035908
8263	0.5504768460790115	-1.416858286768997
8264	0.5433820826696546	-1.420767824293464
8265	0.5574878336842728	-1.412524634236295
8266	0.5570515013712741	-1.412786433624094
8267	0.818704281513256	-2.16692225945982
8268	0.543263400280519	-1.4207556069887002
8269	0.543263400280519	-1.4207556069887002
8270	1.0233441363095912	-2.7678007236779236
8271	0.7223621068031691	-1.2636847009554704
8272	0.7133736611553984	-1.286888853360735
8273	0.3199764477558764	-1.1452274592933631
8274	0.8468337530676487	-2.1427354866856825
8275	0.8467761572023329	-2.1426831268081226
8276	0.9069900163961373	-3.0642169718611285
8277	0.5678428721363551	-1.4034768473939563
8278	0.5599888905023807	-1.414589358741404
8279	0.5740038843958951	-1.3955739965409257
8280	0.5741487467238106	-1.39558621384569
8281	0.5740161017006591	-1.3956577723450216
8282	0.8607387912182874	-2.1490815038459337
8283	0.6606071218798537	-2.135410339815062
8284	0.5555330649220391	-1.4164708236750538
8285	0.5560043038200776	-1.4162177509335148
8286	0.5719391598907858	-1.3945390162944933
8287	0.5720543516214174	-1.3945041097094533
8288	0.5487611874243011	-1.4195932177068717
8289	0.6056240144542764	-1.338236439954408
8290	0.6056240144542764	-1.338236439954408
8291	0.6053814136882492	-1.3381142669067685
8292	0.65989502754504	-2.1377281370617105
8293	0.559290758801583	-1.412524634236295
8294	0.5598143575771812	-1.413310032399692
8295	0.5591458964736674	-1.4120010354606967
8296	0.5711467804103804	-1.3929472760166743
8297	0.5704259594293067	-1.3914811994449992
8298	0.5714295237492034	-1.3935494146086125
8299	0.5706825228293498	-1.3919995622328416
8300	0.570984464789945	-1.3926383527390713
8301	0.836565981078166	-2.140450850694822
8302	0.8369586801598647	-2.139410634460633
8303	0.5255483083727766	-1.4696248260445413
8304	0.7208209810736581	-1.2484916098168597
8305	0.7197737835224616	-1.2759020057194308
8306	0.7297797561241449	-1.2461650859239515
8307	0.5811073744515121	-1.383571367274961
8308	0.5813639378515552	-1.383813968040988
8309	0.6736325140874874	-1.3473592759545825
8310	0.5644394800949663	-1.4043791826172374
8311	0.5500108431687291	-1.418923011274106
8312	0.8471688562840316	-2.143801882858651
8313	0.5717908069043663	-1.3939456043488152
8314	0.42862319369252344	-1.427853861056561
8315	0.5708675277300613	-2.0451331842556555
8316	0.5708675277300613	-2.0451331842556555
8317	0.8574505909075303	-2.158972284716986
8318	0.5121965395950199	-1.6529140681012298
8319	0.5115560037595379	-1.6549211967410231
8320	0.4866536459920829	-1.440809440094115
8321	0.4865838328220031	-1.4413016229431774
8322	0.7178835919425517	-1.2572182560768312
8323	0.7182989803045263	-1.2594068989588323
8324	0.7183478495235821	-1.259206186094853
8325	0.4679629150324756	-1.4360743618334544
8326	0.7219257744901706	-1.2367979038284977
8327	0.7225959809229363	-1.2366233709032983
8328	0.7223045109378532	-1.2354016404269021
8329	0.7129669994396837	-1.2906709818498068
8330	0.686982537535992	-1.3244640468269209
8331	0.5822278758312924	-1.3838279306750039
8332	0.8241095662066826	-2.139590403373589
8333	0.8240868769264067	-2.139482192959965
8334	0.826121930834232	-2.1391924683041337
8335	0.8259910311403325	-2.1393320946442937
8336	0.8795290059452585	-2.184396495930787
8337	0.7160178349721696	-1.2577278922184136
8338	0.6600253338269939	-2.137155669067057
8339	0.47696881397276636	-1.4408862345812028
8340	1.0309083932877345	-2.8236512597417422
8341	0.8456120225912527	-2.1537362969610028
8342	0.720239786432744	-1.2584696571505114
8343	0.5708971983273452	-1.399260131921138
8344	0.5709547941926609	-1.399521931308937
8345	0.7247479718906453	-1.2450602925074388
8346	0.724864908950529	-1.2454372836258696
8347	0.7810924361327783	-1.1681785389570887
8348	0.8188508891704236	-2.1663899340379618
8349	0.718979658712804	-1.2589705666458337
8350	0.7224493732657689	-1.2228073445445111
8351	0.722391777400453	-1.2237079344385402
8352	0.7190756518216638	-1.24965574442794
8353	0.7190669251754038	-1.2495108821000245
8354	0.7216639751023713	-1.2495894219163641
8355	0.8465667176920936	-2.1416272026106657
8356	0.8464846872172498	-2.1415189921970423
8357	0.680212405367506	-1.333723018508751
8358	0.7153005046496	-1.2839863708146684
8359	0.7153005046496	-1.2839863708146684
8360	0.7148868616168774	-1.2838868870473048
8361	0.7148868616168774	-1.2838868870473048
8362	0.687595148103442	-1.3273281321294434
8363	0.6872809888380831	-1.327205959081804
8364	0.8467761572023329	-2.1406463275710452
8365	0.8468546970186727	-2.140684724814589
8366	0.7232068461611344	-1.2374960355292954
8367	0.6861185995562549	-1.331831081599589
8368	0.5765398477990428	-1.3947502011339847
8369	0.9756390518648302	-2.8059082425659674
8370	0.561093683918893	-1.4109538379095
8371	0.680861667849248	-1.3296354574005802
8372	0.678083103680073	-1.3442874964710727
8373	0.8505216337771127	-2.1411315291030997
8374	0.8331032478422093	-2.1412275222119592
8375	0.8252492662082348	-2.1406463275710452
8376	0.8251532730993751	-2.1408592577397885
8377	0.7240358775558317	-1.2250902352061197
8378	0.7237583702047645	-1.2244060661393381
8379	0.6744824894332087	-1.3461288188319265
8380	0.8238390401726234	-2.146309920993767
8381	0.8237954069413236	-2.1461737853121114
8382	0.8237954069413236	-2.1473361745939394
8383	0.8239175799889632	-2.1474443850075633
8384	0.7197214236449017	-1.266527842306969
8385	0.7184351159861818	-1.2665767115260251
8386	0.8065375912976036	-2.1630650818129125
8387	0.7241074360551635	-1.2228946110071108
8388	0.7138396640656808	-1.2831084702009152
8389	0.5710577686185286	-2.0453810210094385
8390	0.4819063504266583	-1.4415459690384564
8391	0.7218332720398147	-1.2478371113473619
8392	0.9759305218499132	-2.802998778702893
8393	0.7135481940805977	-1.2833981948567463
8394	0.8480694461780607	-2.14536744319769
8395	0.7130752098533073	-1.2876829781703925
8396	0.7132061095472069	-1.2875503331472407
8397	0.7128011931607441	-1.287454340038381
8398	0.7128570436968079	-1.2874037254900732
8399	0.7286959066586565	-1.2679869375616364
8400	0.7203410155293597	-1.2615588899265413
8401	0.7200652535075446	-1.2611085949795269
8402	0.6143558967020041	-1.3220869083857045
8403	0.7190756518216638	-1.2906709818498068
8404	0.7175188181288847	-1.262579907538958
8405	0.8345588524383726	-2.1412275222119592
8406	0.7702719765468301	-2.1665353781422887
8407	0.7238177113993324	-1.2301656526709193
8408	0.7243989060402465	-1.2310976584914841
8409	0.9226979796640863	-2.2427480888127134
8410	0.7118028648286033	-1.2903795118647237
8411	0.7117155983660037	-1.2904667783273234
8412	0.7125830270042449	-1.285434994093824
8413	0.6903353150290732	-1.3240067705628984
8414	0.7134330023499661	-1.2901770536714923
8415	0.6243042734383717	-1.3185386540164001
8416	0.7158677366564982	-1.271161691471014
8417	0.7160614682034695	-1.2725579548726096
8418	0.7169376234879707	-1.2711232942274702
8419	0.7243168755654028	-1.2661264165790105
8420	0.7128221371117681	-1.290351586596692
8421	0.5721538353887811	-1.395565269894666
8422	0.5628686837681712	-1.40789951171851
8423	0.7167770531967873	-1.259459258836392
8424	0.5721398727547651	-1.3941044293107467
8425	0.5723720015452803	-1.3947798717312685
8426	0.5726739435058754	-1.3947275118537088
8427	0.7268720375903225	-1.2443324902093573
8428	0.6687752627791872	-1.3334524924746918
8429	0.6687752627791872	-1.3334524924746918
8430	0.6763447557450866	-1.3351559338246382
8431	0.674985144257783	-1.3309444543395756
8432	1.0733774899765127	-2.898119222936584
8433	0.5739515245183352	-1.3935581412548723
8434	0.5745327191592494	-1.3934412041949888
8435	0.5722271392173649	-1.3947798717312685
8436	0.6778562108773136	-1.3343618090149807
8437	0.5928796202562138	-1.360445754686036
8438	0.5928796202562138	-1.360445754686036
8439	0.5928796202562138	-1.360445754686036
8440	0.7174175890322692	-1.2646079801297754
8441	0.5125106988603789	-1.6545145350253085
8442	0.5125106988603789	-1.6545145350253085
8443	0.5125106988603789	-1.6545145350253085
8444	0.5149995383737228	-1.6558758918418643
8445	0.5149995383737228	-1.6558758918418643
8446	0.5149995383737228	-1.6558758918418643
8447	0.6872530635700511	-1.3284573601554839
8448	0.6737634137813869	-1.328448633509224
8449	0.6871448531564275	-1.328719159543283
8450	0.7136738577867414	-1.2873059870519616
8451	0.8472840480146633	-2.139185486987126
8452	0.8299040593233037	-2.1391924683041337
8453	0.7134905982152819	-1.2871070195172343
8454	0.8064677781275238	-2.1538096007895864
8455	0.7143056669759632	-1.2813771035829369
8456	0.7143056669759632	-1.2813771035829369
8457	0.7120943348136864	-1.2895068472387266
8458	0.5677852762710394	-1.403855583841639
8459	0.713171202962167	-1.2883444579568981
8460	0.8444478879801725	-2.1453011206861143
8461	0.8444478879801725	-2.1453011206861143
8462	0.5302956039382011	-1.4217225193943048
8463	0.5302956039382011	-1.4217225193943048
8464	0.5302956039382011	-1.4217225193943048
8465	0.9066985464110543	-3.0694529596171116
8466	0.7298390973187128	-1.245960882401468
8467	0.5919772850329327	-1.3620933454999185
8468	0.42862319369252344	-1.4405371687308037
8469	0.9576045647039728	-2.8518679977587347
8470	0.9576045647039728	-2.8518679977587347
8471	0.5580986989224708	-1.4145317628760883
8472	0.5581562947877866	-1.414676625204004
8473	0.5292134998019646	-1.4253231336411694
8474	0.5292134998019646	-1.425118930118686
8475	0.6717021799347818	-1.3328119566392098
8476	0.6717021799347818	-1.3328119566392098
8477	0.6725329566587309	-1.3333146114637842
8478	0.6723880943308155	-1.3337806143740667
8479	0.724835238353245	-1.2461074900586353
8480	0.5690349320154672	-1.4035937844538398
8481	0.5416629333564402	-1.4212792057642984
8482	0.7168887542689149	-1.2633129458247954
8483	0.48192903970693424	-1.4420782944603148
8484	0.5575157589523047	-1.4134548947276078
8485	0.5704311954170628	-1.3963209974607793
8486	0.5716529258934588	-1.3964379345206632
8487	0.8496838757361554	-2.1493729738310168
8488	0.8496838757361554	-2.1493729738310168
8489	0.5722358658636248	-1.3981256679073417
8490	0.5519900465404907	-1.4170031490969122
8491	0.97447491725375	-2.8061979672217987
8492	0.880897344078822	-2.2015007226003314
8493	0.6770777940309243	-1.3445527865173756
8494	0.8418019688341489	-2.1560052249885953
8495	0.9040805525330626	-3.0790522705030803
8496	0.3671003375597233	-2.739002791020017
8497	0.8395033702092726	-2.1461737853121114
8498	0.8395033702092726	-2.1461737853121114
8499	0.9026266932661515	-3.103195410045918
8500	0.9032078879070655	-3.102322745419921
8501	0.7219554450874545	-1.2305443891186019
8502	0.8480415209100287	-2.1506819707700124
8503	0.8479385464841611	-2.1508268330979283
8504	0.7196568464625779	-1.265363707695889
8505	0.7196865170598618	-1.2647615691039509
8506	0.6801635361484503	-1.3307646854266206
8507	0.6774792197588829	-1.3328067206514538
8508	0.6778649375235737	-1.3323407177411715
8509	0.6770428874458844	-1.3340127431645818
8510	0.6722711572709319	-1.3348574825225472
8511	0.428448660767324	-1.4279707981164447
8512	0.428448660767324	-1.4279707981164447
8513	0.7277726274843516	-1.2434598255833602
8514	0.5606573516058945	-1.4160728886055993
8515	0.5607166928004622	-1.4161025592028833
8516	0.8461932172321668	-2.1459835444236437
8517	0.8461932172321668	-2.1458823153270283
8518	0.9049532171590599	3.1087228677869843
8519	1.0245658667859872	-2.7445302487610834
8520	0.7247776424879292	-1.231795790192282
8521	0.5823936821102318	-1.383208338790546
8522	0.31968672310004537	-1.144644519323197
8523	0.8495966092735557	-2.1417720649385816
8524	0.8491026810952413	-2.1418104621821255
8525	0.5585053606381855	-1.412465293041727
8526	0.5646140130201657	-1.410342972671302
8527	0.7266102382025234	-1.2265004612417314
8528	0.4838838084691679	-1.4418112590847598
8529	0.7189587147617802	-1.252041609515416
8530	0.7179708584051513	-1.2500344808756227
8531	0.7182029871956666	-1.2502369390688541
8532	0.8342673824532895	-2.140065132930131
8533	0.8486890380625187	-2.148660879496203
8534	0.567261677495441	-1.4099939068209029
8535	0.655952904723438	-2.132792345937071
8536	0.657116463375865	-2.1330820705929017
8537	0.5562364326105929	-1.4149960204571188
8538	0.5466074511273401	-1.4190399483339897
8539	0.7193950470747787	-1.2586529167219707
8540	0.718979658712804	-1.2584487131994875
8541	0.7193950470747787	-1.2581205913001123
8542	0.7195207107809223	-1.258242764347752
8543	0.5467540587845077	-1.4192720771245049
8544	0.7214021757145722	-1.25460026219884
8545	0.5565558278637078	-1.4154323527701174
8546	0.5565558278637078	-1.4154323527701174
8547	0.5567024355208753	-1.4153747569048016
8548	0.7160440149109496	-1.2633513430683394
8549	0.4743804906920588	-1.4398093664327223
8550	0.5464922593967084	-1.419882942362703
8551	0.9043720225181457	-3.075851336654923
8552	0.5562364326105929	-1.414589358741404
8553	0.7149880907134931	-1.2827297337532326
8554	0.7149880907134931	-1.2827297337532326
8555	0.7174036263982532	-1.261989986251784
8556	0.5577496330720719	-1.4147638916666037
8557	0.5575157589523047	-1.4149960204571188
8558	0.43287132509187765	-1.4113604996252145
8559	0.43353978619539146	-1.40970243683582
8560	0.43353978619539146	-1.40970243683582
8561	0.7160440149109496	-1.2824330277803935
8562	0.7160440149109496	-1.2824330277803935
8563	0.6779434773399134	-1.332152222181956
8564	0.7227111726535679	-1.2275476587929277
8565	0.47894801734452797	-1.443212758474111
8566	0.846130385379095	-2.14359069801916
8567	0.6812753108819706	-1.331124223252531
8568	0.6819699519242642	-1.3317420698077373
8569	0.6819699519242642	-1.3317420698077373
8570	0.682069435691628	-1.3318991494404169
8571	1.0343990517917234	-2.362594612559408
8572	0.7653565475967974	-1.2168732250877305
8573	0.7657928799097959	-1.217018087415646
8574	0.6850417314077744	-1.3341000096271816
8575	0.720239786432744	-1.2624542438328143
8576	0.6762574892824869	-1.3384057368918516
8577	0.562345084992573	-1.410051502686219
8578	0.5449790589352295	-1.4212792057642984
8579	0.7125882629920008	-1.2904091824620076
8580	0.7123264636042017	-1.2904091824620076
8581	0.42713966382832824	-1.4277089987286453
8582	0.5263040359388901	-1.4256721994915682
8583	0.5263040359388901	-1.4256721994915682
8584	0.5263040359388901	-1.4256721994915682
8585	0.7126039709552688	-1.286826021507663
8586	0.7104938678896077	-1.2913691135506042
8587	0.7110419012747339	-1.2910113210539456
8588	0.7417649320975901	-1.2359845803970684
8589	0.6643886569569797	-2.133665010563068
8590	0.6646795509834097	-2.133665010563068
8591	0.8395033702092726	-2.1412275222119592
8592	0.8395033702092726	-2.1412275222119592
8593	0.8397948401943556	-2.1415189921970423
8594	0.8397948401943556	-2.1409377975561283
8595	0.6741718208263537	-1.3288203886398988
8596	0.6692761722745095	-1.3473365866743068
8597	0.8508480103472357	-2.144428456060117
8598	0.8508270663962118	-2.144412748096849
8599	0.8508480103472357	-2.1438455160899506
8600	0.8512354734411783	-2.144128259428774
8601	0.714071792856196	-1.2852604611686242
8602	0.714071792856196	-1.2852604611686242
8603	0.7142707603909234	-1.2855432045074473
8604	0.7160736855082335	-1.266590674160041
8605	0.5305277327287163	-1.4206770671723603
8606	0.5305277327287163	-1.4206770671723603
8607	0.5305277327287163	-1.4206770671723603
8608	0.5304631555463926	-1.4212792057642984
8609	0.5304631555463926	-1.4212792057642984
8610	0.5304631555463926	-1.4212792057642984
8611	0.807031519475918	-2.1627299785965293
8612	0.5596398246519817	-1.4134845653248918
8613	0.554025100448316	-1.4175564184697944
8614	0.5535224456237416	-1.417046782328212
8615	0.7189011188964644	-1.223418209782709
8616	0.449684081776339	-1.39864926668294
8617	0.449684081776339	-1.39864926668294
8618	0.449684081776339	-1.39864926668294
8619	0.6052505139943496	-1.3371630624644315
8620	0.723322037891766	-1.2365361044406984
8621	0.7234389749516497	-1.235810047471869
8622	0.47484649360234127	-1.4400711658205214
8623	0.5302606973531612	-1.4214834092867816
8624	0.5302606973531612	-1.4214834092867816
8625	0.5302606973531612	-1.4214834092867816
8626	0.6596524267790128	-2.1382255558985293
8627	0.6596524267790128	-2.1382255558985293
8628	0.7185956862773654	-1.276074793315378
8629	0.7117749395605715	-1.2904388530592914
8630	0.7117452689632876	-1.2905261195218911
8631	0.6854780637207729	-1.3322394886445557
8632	0.52755543701257	-1.536500606993208
8633	0.5276706287432016	-1.5364709363959241
8634	0.5352924815866609	-1.5364709363959241
8635	0.7253291665315595	-1.2243484702740224
8636	0.7251843042036439	-1.2221092128437134
8637	0.7169760207315147	-1.2555759012507046
8638	0.7170388525845864	-1.2540190675579257
8639	0.7168939902566709	-1.2536700017075268
8640	0.7183635574868501	-1.2535774992571713
8641	0.6655522156094068	-2.130174352059079
8642	0.6646795509834097	-2.1272648881960046
8643	0.6655522156094068	-2.130174352059079
8644	0.5573708966243891	-1.4159559515457156
8645	1.0250894655615856	-2.739002791020017
8646	0.606027185511487	-1.338559325866027
8647	0.6059207204271154	-1.339240004274305
8648	0.5759673798043887	-1.394600102818313
8649	0.5670278033756738	-1.4045240449451528
8650	0.567289602763473	-1.405630583690917
8651	0.5180102313334131	-1.657743394141498
8652	0.5180102313334131	-1.657743394141498
8653	0.5180102313334131	-1.657743394141498
8654	0.4310963252425994	-1.4166837538437973
8655	0.4310963252425994	-1.4166837538437973
8656	0.7267551005304388	-1.2436919543738754
8657	0.7274532322312366	-1.2428786309424458
8658	0.6816872085854413	-1.3340808110054097
8659	0.7198750126190773	-1.2565794655706015
8660	0.657116463375865	-2.1330820705929017
8661	0.7190756518216638	-1.2621872084572592
8662	0.4817894133667747	-1.443802679761285
8663	0.48185573587835046	-1.4432825716441908
8664	0.7216639751023713	-1.229060859254407
8665	0.7216936456996553	-1.2267046647642144
8666	0.721170046924057	-1.2285948563441242
8667	0.8400845648501866	-2.140354857585962
8668	0.5947733024946277	-1.3594369543783833
8669	0.721766949528239	-1.256108226672563
8670	0.55281209661818	-1.417125322144552
8671	0.5526637436317604	-1.418333089986932
8672	0.553115783908027	-1.4169804598166362
8673	0.5526236010589646	-1.4173906121908548
8674	0.8918056519037866	-2.225352392158086
8675	0.7209379181335417	-1.2234758056480248
8676	0.7209379181335417	-1.2234758056480248
8677	0.7207982917933822	-1.254891732183923
8678	0.5698500007761486	-2.044072024070443
8679	0.5700629309448919	-2.0442256130446186
8680	0.7282962262599497	-1.2454669542231536
8681	0.8418298941021809	-2.1490815038459337
8682	0.842412834072347	-2.1476276445790226
8683	0.4302236606166022	-1.4384427736284107
8684	0.7196568464625779	-1.2726364946889495
8685	0.721135140339017	-1.2580979020198364
8686	0.4770281551673342	-1.4413225668942011
8687	0.549721118512898	-1.4187781489461906
8688	0.7472330486440882	-1.2368851702910975
8689	0.6062889848992862	-1.3383271970755117
8690	0.6061755384979065	-1.3383760662945678
8691	0.6061755384979065	-1.3383760662945678
8692	0.7212276427893728	-1.2597262942119474
8693	0.8223415476744123	-2.1415189921970423
8694	0.4311835917051991	-1.4191848106619052
8695	0.4311835917051991	-1.4191848106619052
8696	0.721147357643781	-1.2564328579134338
8697	0.7243413101749306	-1.2329581794741102
8698	0.7246310348307617	-1.2325218471611117
8699	0.8383392355981922	-2.1409377975561283
8700	0.8380495109423612	-2.1406463275710452
8701	0.5735797693876605	-1.395544325943642
8702	0.5683088750466376	-1.399521931308937
8703	0.7234686455489335	-1.2365657750379824
8704	0.7235559120115331	-1.2358973139344687
8705	0.7247479718906453	-1.2338308441001073
8706	0.7163040689694968	-1.262236077676315
8707	0.7206953173675145	-1.2571257536264757
8708	1.017235483927611	-2.380337629735182
8709	0.570949558204905	-2.0457492854816097
8710	0.570949558204905	-2.0457492854816097
8711	0.5710280980212448	-1.392772743091475
8712	0.5547232321491138	-1.416514456906354
8713	1.0178184238977772	-2.3756845819493657
8714	0.6844221395233164	-1.3333495180488242
8715	0.5477419151411363	-1.4195635471095878
8716	0.5783288102823371	-1.3830128619143225
8717	0.7139932530398563	-1.2812025706577375
8718	0.7141311340507638	-1.280780200978755
8719	0.42905952600552205	-1.4285223221600747
8720	0.4297297324382878	-1.429075591532957
8721	0.5541210935571756	-1.4166052140274574
8722	0.7237583702047645	-1.233336915921793
8723	0.7170981937791542	-1.2811362481461617
8724	0.5738345874584517	-1.3940817400304708
8725	1.022181747027763	-2.764893005144101
8726	0.7142759963786793	-1.2839863708146684
8727	0.7142759963786793	-1.2839863708146684
8728	0.6574073399490025	-2.1330820705929017
8729	0.6591526692009968	-2.1330820705929017
8730	0.6597344572538565	-2.133954735218899
8731	0.6597344572538565	-2.135118869829979
8732	0.6596384641449968	-2.1342904201535218
8733	0.6597344572538565	-2.135118869829979
8734	0.5597846869798974	-1.4138912270406065
8735	0.848294593651568	-2.1434964502395517
8736	0.556206762013309	-1.413716694115407
8737	0.556206762013309	-1.413716694115407
8738	0.6738663882072546	-1.3261500348843474
8739	1.1053746111533247	-2.9466969720073424
8740	0.8304852539642178	-2.138609528333968
8741	0.7225610743378965	-1.2581432805803883
8742	0.723627470510865	-1.2578361026320375
8743	0.7118622060231713	-1.2900897872088928
8744	0.9008813640141571	-3.1171580440618727
8745	0.7151399343584165	-1.275778087342539
8746	0.7151399343584165	-1.275778087342539
8747	0.7156513158292509	-1.275748416745255
8748	0.7156513158292509	-1.275748416745255
8749	0.7159689657531139	-1.2765250882623926
8750	0.7182029871956666	-1.2484916098168597
8751	0.7195416547319463	-1.2214390064109477
8752	0.4863359960682199	-1.4408268933866348
8753	0.4863359960682199	-1.4408338747036429
8754	0.5493999779305311	-1.4194466100497043
8755	0.5486739209617014	-1.4190975441993054
8756	0.5483824509766184	-1.4192144812591891
8757	0.6894713770493359	-1.325031278833819
8758	0.6894713770493359	-1.325031278833819
8759	0.8374665709721951	-2.140065132930131
8760	0.8374665709721951	-2.140354857585962
8761	0.5465201846647404	-1.4198550170946709
8762	0.6872094303387514	-1.326232065359191
8763	0.5743232796490101	-1.3954396061885221
8764	0.7184996931685057	-1.261031800492439
8765	0.717766654882668	-1.2602149864025056
8766	0.9610952232079614	-2.858557844781629
8767	0.657116463375865	-2.134827399844896
8768	0.6573782627636642	-2.1349443369047796
8769	0.5292414250699965	-1.421366472226898
8770	0.7164227513586324	-1.26320299008192
8771	0.8505513043743965	-2.144835117775832
8772	0.8505565403621526	-2.144718180715948
8773	0.5639455519166519	-1.4085976434193075
8774	0.564207351304451	-1.4077249787933104
8775	0.564788545945365	-1.4080443740464252
8776	0.5667660039878747	-1.4057754460188328
8777	0.7144941625351786	-1.285578111092487
8778	0.5112942043717389	-1.569108593408218
8779	0.4831944034146301	-1.4439981566375086
8780	0.4806514586944744	-1.4442198134525117
8781	0.7271617622461535	-1.2456990830136687
8782	0.7270744957835538	-1.24535001716327
8783	0.8339759124682065	-2.1467549799530254
8784	0.8515251980970094	-2.146812575818341
8785	0.8241881060230222	-2.145363952539186
8786	0.8240868769264067	-2.1453011206861143
8787	0.8485214864543272	-2.1421001868379563
8788	0.8486174795631869	-2.142342787603984
8789	0.8466819094227251	-2.145931184546084
8790	0.8467761572023329	-2.1458823153270283
8791	0.8479385464841611	-2.1435557914341197
8792	0.848003123666485	-2.1436133872994354
8793	0.5824250980367678	-1.3834142876422815
8794	0.5664466087347596	-1.4037386467817552
8795	0.723322037891766	-1.2378747719769783
8796	0.7237007743394488	-1.2380789754994617
8797	0.7145151064862025	-1.2858713264068222
8798	0.5294456285924799	-1.5236724369910497
8799	0.6696531633929403	-1.3437289911104342
8800	0.6640977803838424	-2.1365727290968906
8801	0.6643886569569797	-2.1365727290968906
8802	0.6972590361717347	-1.3113234628886556
8803	0.8256419652899335	-2.1441509487090498
8804	0.8255407361933178	-2.1441369860750337
8805	0.8246384009700368	-2.1454547096602896
8806	0.8246680715673207	-2.145590845341945
8807	0.8241357461454624	-2.145615279951473
8808	0.8240868769264067	-2.145590845341945
8809	0.7109302002026062	-1.29096245183489
8810	0.557400567221673	-1.4150553616516865
8811	0.842412834072347	-2.1653724070840488
8812	0.7170545605478544	-1.278279144160647
8813	0.5673489439580408	-1.4025762574999272
8814	0.48332530310852967	-1.4436874880306536
8815	0.4826481153587559	-1.4409822276900623
8816	0.6635159923309826	-2.1357000644708934
8817	0.8240868769264067	-2.1418104621821255
8818	0.8242090499740462	-2.1417947542188576
8819	1.017235483927611	-2.366374995719228
8820	0.5715953300281429	-1.3985899254883722
8821	0.7184682772419697	-1.2603458860964054
8822	0.71903725457812	-1.26010503065963
8823	0.6739152574263104	-1.3347841786939636
8824	0.6744824894332087	-1.3349534756314068
8825	0.8068273159534347	-2.1636410404660706
8826	0.6798057436517914	-2.159844949342983
8827	0.6033027265491239	-2.1060312125162417
8828	0.6582800045749996	-2.135118869829979
8829	0.6582800045749996	-2.135118869829979
8830	0.6582800045749996	-2.134537675189065
8831	0.6603162278534239	-2.1365727290968906
8832	0.6603162278534239	-2.1362830044410597
8833	0.6599438967640958	-2.1383983434944764
8834	0.6598129970701962	-2.140450850694822
8835	0.6600974857382713	-2.1383110770318767
8836	0.6600974857382713	-2.1383110770318767
8837	0.6597554012048805	-2.1383564555924286
8838	0.6597554012048805	-2.1383564555924286
8839	0.6867870606597687	-2.161298808609894
8840	0.6600253338269939	-2.1368641990819737
8841	0.6981317007977318	-2.1653724070840488
8842	0.6600451258607115	-2.137970737827738
8843	0.8493941510803243	-2.1470464499381086
8844	0.8495006161646961	-2.1468631903666493
8845	0.8070699167194619	-2.1615606079976932
8846	0.7258527653071577	-1.2262107365859
8847	0.8505338510818766	-2.14719654825378
8848	0.8505565403621526	-2.1473361745939394
8849	0.8397948401943556	-2.1418104621821255
8850	0.8397948401943556	-2.1421001868379563
8851	0.6592405290755422	-2.1386479255775117
8852	0.6595162910973573	-2.1395764407395728
8853	0.5701257627979637	-2.0459831596013767
8854	0.5701257627979637	-2.0459831596013767
8855	0.7175484887261687	-1.2761638051072297
8856	0.8418298941021809	-2.144428456060117
8857	0.8418298941021809	-2.144428456060117
8858	0.6689550316921425	-1.334944748985147
8859	0.5976391331264023	-1.3606290142574953
8860	0.6225013483210615	-2.117084382669122
8861	0.6393717008708387	-2.128429022807085
8862	1.0195637531497714	-2.355613295551431
8863	0.6632251157578453	-2.1473361745939394
8864	0.6614797865058508	-2.1362830044410597
8865	0.6643886569569797	-2.1263922235700075
8866	0.6134832320760069	-2.107776541768236
8867	0.6626433277049854	-2.1368641990819737
8868	0.6623524511318482	-2.1368641990819737
8869	0.6335545184739416	-2.127847828166171
8870	0.8403760348352697	-2.1423916568230394
8871	0.8403760348352697	-2.1423916568230394
8872	0.8403760348352697	-2.1421001868379563
8873	0.8403760348352697	-2.1421001868379563
8874	0.8406675048203527	-2.1426831268081226
8875	0.8406675048203527	-2.1421001868379563
8876	0.8406675048203527	-2.1421001868379563
8877	0.8406675048203527	-2.1415189921970423
8878	0.46175652421238383	-1.431489381888465
8879	0.46175652421238383	-1.4314963632054731
8880	0.7251843042036439	-1.2214390064109477
8881	0.725446103591443	-1.220391808859751
8882	0.7251267083383282	-1.2214686770082315
8883	0.7222748403405693	-1.2482018851610286
8884	0.7180860501357831	-1.2735318485952225
8885	0.6849771542254505	-1.3316286234063577
8886	0.6852459349302576	-1.331220216361391
8887	0.685469337074513	-1.3303981662837017
8888	0.6846350696920597	-1.3322325073275476
8889	0.6764232955614263	-1.3339464206530063
8890	0.6763098491600467	-1.334225673333325
8891	0.6763098491600467	-1.334225673333325
8892	0.6762854145505188	-1.3326164797629865
8893	0.675011324196563	-1.3258620555577685
8894	0.9657482709937784	-2.801544919435982
8895	0.8554731328650207	-2.156965156077192
8896	0.8352185868956264	-2.1393757278755934
8897	0.8374665709721951	-2.138900998319051
8898	0.9945462036516848	-2.7730367114339063
8899	0.4854633314422228	-1.6969836317140867
8900	0.715003798676761	-1.2758356832078548
8901	0.4827929776866714	-1.4416279995133001
8902	0.48264462470025193	-1.4414639385636128
8903	0.4827877416989155	-1.4416419621473162
8904	0.5624026808578888	-1.4077249787933104
8905	0.8383392355981922	-2.1421001868379563
8906	0.8397948401943556	-2.1421001868379563
8907	0.8307994132295768	-2.1408505310935286
8908	0.8301955293083867	-2.140065132930131
8909	0.8301955293083867	-2.140065132930131
8910	0.8304852539642178	-2.1391924683041337
8911	0.5610657586508612	-1.416160155068199
8912	0.7516557129686419	-1.233947781159991
8913	0.669443723882701	-1.3436713952451185
8914	0.6588617926278594	-2.135410339815062
8915	0.8336861878123755	-2.1365744744261423
8916	0.8755740898602393	-2.161590278594977
8917	1.0210176124166828	-2.76838366364809
8918	0.8345588524383726	-2.1432643214490366
8919	0.8521081380671756	-2.1434091837769524
8920	0.7024950239277177	-2.170608394840032
8921	0.31567246582045844	-1.1733272602504718
8922	0.6724456901961313	-1.3489353082691335
8923	0.6723304984654996	-1.3487328500759022
8924	0.5707226654021458	-2.0461070779782684
8925	0.5115560037595379	-1.568208003514189
8926	0.8823512033457332	-2.226254727381367
8927	0.723322037891766	-1.2365361044406984
8928	0.8363041816903669	-2.1752614426258488
8929	0.8069913769031222	-2.1555392220783127
8930	0.7210531098641734	-1.2516401837874576
8931	0.7203410155293597	-1.2516925436650175
8932	0.5818840459686495	-1.3837197202613805
8933	0.5557617030540504	-1.414894791360503
8934	0.5560915702826773	-1.414676625204004
8935	0.8500853014641141	-2.143773957590619
8936	0.6608979984529911	-2.1368641990819737
8937	0.6608979984529911	-2.137155669067057
8938	0.8431109657731448	-2.156122162048479
8939	0.7198610499850612	-1.2573927890020309
8940	0.8499753457212386	-2.1435557914341197
8941	0.6058334539645157	-1.3383132344414959
8942	0.6724753607934152	-1.3307123255490607
8943	0.7192292407958392	-1.2760311600840781
8944	0.7211124510587411	-1.2626793913063217
8945	0.720850651670942	-1.2562007291229187
8946	0.7172727267043536	-1.2612325133564184
8947	0.7169515861219866	-1.2606513187155044
8948	0.5607742886657782	-1.4116519696102976
8949	0.5802207471914989	-1.3824019966761245
8950	0.5735064655590767	-1.3944517498318934
8951	0.48120123740885257	-1.4424064163596897
8952	0.4808958047897536	-1.4431830878768273
8953	0.5931449103025168	-1.360149048713197
8954	0.5931449103025168	-1.360149048713197
8955	0.5931449103025168	-1.360149048713197
8956	0.5933892563977962	-1.36047542528332
8957	0.5933892563977962	-1.36047542528332
8958	0.5933892563977962	-1.36047542528332
8959	0.5935201560916957	-1.3605277851608797
8960	0.5935201560916957	-1.3605277851608797
8961	0.5935201560916957	-1.3605277851608797
8962	0.5935376093842156	-1.3603305629554043
8963	0.5935376093842156	-1.3603305629554043
8964	0.5935376093842156	-1.3603305629554043
8965	0.5718798186962181	-1.3940520694331868
8966	0.5233369762104997	-1.4247122684029712
8967	0.5233369762104997	-1.4247122684029712
8968	0.5233369762104997	-1.4247122684029712
8969	0.6899146906793425	-1.3261831961401354
8970	0.6620615571054181	-2.1368641990819737
8971	0.7216936456996553	-2.1674074609918743
8972	0.5727507379929632	-1.3946838786224087
8973	0.8304852539642178	-2.1368641990819737
8974	0.7229450467733353	-1.2386601701403757
8975	0.8301955293083867	-2.138028333693054
8976	0.8304852539642178	-2.1374471390521395
8977	0.8304852539642178	-2.138609528333968
8978	0.8301955293083867	-2.138609528333968
8979	0.6606071218798537	-2.1374453937228877
8980	0.7118028648286033	-1.2895068472387266
8981	0.6594435632274267	-2.135410339815062
8982	0.7158520286932303	-1.2691371095387007
8983	0.716855593013127	-1.269007955174053
8984	0.714707092703922	-1.2645434029474516
8985	0.6858410922051877	-1.3311329498987912
8986	0.7231771755638505	-1.2353440445615864
8987	0.7271687435631614	-1.2676116917724576
8988	0.7180947767820429	-1.262867886865537
8989	0.7141747672820636	-1.2828257268620922
8990	0.7166182282348557	-1.2571606602115155
8991	0.6892008510152768	-1.3264065982843907
8992	0.6643886569569797	-2.129882882073996
8993	0.8457568849191682	-2.1429152555986377
8994	0.7243692354429626	-1.244973026044839
8995	0.7244285766375305	-1.245322091895238
8996	0.7242540437123309	-1.245292421297954
8997	0.4858473038776615	-1.4411742139077817
8998	0.5519516492969467	-1.4174988226044787
8999	0.5524019442439613	-1.41898758845643
9000	0.5723894548378003	-1.395797398685181
9001	0.572817060504539	-1.3956525363572656
9002	0.7181244473793268	-1.2689416326624772
9003	0.7195556173659622	-1.2689416326624772
9004	0.7289664326927157	-1.2313297872819995
9005	1.0193595496272883	-2.354187361552551
9006	1.0193595496272883	-2.354187361552551
9007	0.6691592352146261	-1.320137375611227
9008	0.673115896628897	-2.152863632335005
9009	0.5820899948203848	-1.3837022669688603
9010	0.5692688061352346	-1.4030125898129258
9011	0.5683368003146695	-1.4030998562755255
9012	0.5671150698382734	-1.4066184400475459
9013	0.5704032701490308	-2.045059880427072
9014	0.5710141353872289	-2.0452344133522713
9015	0.6600259272389396	-2.137736863707971
9016	0.659917716825316	-2.1380667309365977
9017	0.845809244796728	-2.145896277961044
9018	0.8459034925763358	-2.1458823153270283
9019	0.655952904723438	-2.133665010563068
9020	0.807350914729033	-2.164112279364109
9021	0.8072636482664333	-2.164047702181785
9022	0.807310772156237	-2.1636497671123305
9023	0.6686059658417438	-1.3343914796122647
9024	0.6807482214478683	-1.3330824826732688
9025	0.6807482214478683	-1.3330824826732688
9026	0.7201961532014441	-1.2490745497870257
9027	0.6807255321675924	-1.3325379399466466
9028	0.6807255321675924	-1.3325379399466466
9029	0.7205591816858589	-1.2502369390688541
9030	0.7199483164476609	-1.2490745497870257
9031	0.8514292049881497	-2.156354290838994
9032	0.5503895796164118	-1.4184587536930755
9033	0.4765045563917359	-1.4407117016560032
9034	0.7174088623860092	-1.280466041713396
9035	0.5591284431811474	-1.411802067925969
9036	0.5591458964736674	-1.411243562565331
9037	0.5591458964736674	-1.411243562565331
9038	0.5599592199050968	-1.415170553382318
9039	0.5600185610996645	-1.4154044275020854
9040	0.7198837392653371	-1.2621784818109991
9041	0.720536492405583	-1.2627073165743536
9042	0.905825881785057	3.1049407392979123
9043	0.5603082857554955	-1.4157814186205162
9044	0.8680970993446957	-2.1624332726236903
9045	0.8604473212332044	-2.1470464499381086
9046	1.0019359277046287	-2.367132468614593
9047	0.8749911498900732	-2.187770217374892
9048	0.6050410744841103	-1.3378908647625134
9049	0.6054931147603768	-1.3378332688971974
9050	0.7178835919425517	-1.2553280644969216
9051	0.8464846872172498	-2.1418104621821255
9052	0.8466679467887093	-2.142051317618901
9053	0.6744528188359248	-1.3337858503618225
9054	0.6738227549759548	-1.3325239773126307
9055	0.6744615454821847	-1.334269306564625
9056	0.6744615454821847	-1.334269306564625
9057	0.6120293728090955	-1.3281955607676847
9058	0.7661995416255106	-1.216349626312132
9059	0.716550160394028	-1.2814346994482526
9060	0.7161574613123293	-1.2811676640726977
9061	0.7161574613123293	-1.2811676640726977
9062	0.6713618407306428	-1.3377599650686136
9063	0.664249624028766	-2.1258110289290935
9064	0.7136075352751655	-1.2653933782931728
9065	0.7155553227203912	-1.2831084702009152
9066	0.7155797573299191	-1.2831171968471753
9067	0.5729915934297384	-1.3951289375816673
9068	0.7160789214959895	-1.2781709337470233
9069	0.5720543516214174	-1.394881100827884
9070	0.5721573260472852	-1.3947065679026847
9071	0.6576982339754323	-2.1357000644708934
9072	0.6574073399490025	-2.134246205203982
9073	0.8482788856883	-2.1406236382907693
9074	0.8485214864543272	-2.1406463275710452
9075	0.5304055596810767	-1.4217748792718647
9076	0.5304055596810767	-1.4217748792718647
9077	0.9887290212547877	-2.690425041949259
9078	0.7192676380393831	-1.265035585796514
9079	0.7187353126175249	-1.264461372472608
9080	0.8437707002303986	-2.1387910425761754
9081	0.8296125893382206	-2.138028333693054
9082	0.826413400819315	-2.138609528333968
9083	0.844617184917616	-2.1394245970946493
9084	1.037598240310629	-2.362011672589242
9085	0.5586798935633849	-1.4138615564433226
9086	0.5576902918775041	-1.4148511581292031
9087	0.558650222966101	-1.41400816410049
9088	0.8508392837009756	-2.147816140138238
9089	0.8508480103472357	-2.1476276445790226
9090	0.8511394803323187	-2.1470464499381086
9091	0.5631008125586865	-1.4092085086575055
9092	0.5624026808578888	-1.409964236223619
9093	0.8429940287132611	-2.1441369860750337
9094	0.8432854986983441	-2.1432643214490366
9095	0.8429940287132611	-2.1423916568230394
9096	0.570024533701348	-1.4034489221259243
9097	0.5696754678509491	-1.3966124674458624
9098	0.485091576311548	-1.4411567606152618
9099	0.5751156591294155	-1.3950416711190676
9100	0.5943945660469448	-1.3595905433525586
9101	0.7156809864265348	-1.273640059008846
9102	0.8144526594553979	-2.160740303249256
9103	0.7120367389483707	-1.2898279878210934
9104	0.5717349563683025	-1.394628028086345
9105	0.5717471736730664	-1.3942510369679142
9106	0.5718082601968862	-1.3947100585611887
9107	0.6588617926278594	-2.138609528333968
9108	0.6588617926278594	-2.138609528333968
9109	0.5600464863676964	-1.41400816410049
9110	0.5670278033756738	-1.4023423833801598
9111	0.8248565671265362	-2.1390458606469664
9112	0.7232347714291663	-1.236420912710067
9113	0.7233517084890498	-1.235750706277301
9114	0.724543768368162	-1.2334241823843928
9115	1.016073094645783	-2.379756435094268
9116	0.571267208128768	-1.3936506437052283
9117	0.5542868998361151	-1.416741349709113
9118	1.0163628193016139	-2.3753931119642826
9119	0.8351400470792867	-2.139482192959965
9120	0.5474521904853054	-1.4191568853938732
9121	0.5474521904853054	-1.4191568853938732
9122	0.578053048260522	-1.3836097645185048
9123	0.661188892479421	-2.1362830044410597
9124	0.5608318845310939	-1.4064439071223465
9125	0.4298222348886435	-1.4460262292283261
9126	0.5919668130574207	-1.3615104055297524
9127	0.5919668130574207	-1.3615104055297524
9128	0.5919196891676168	-1.3615610200780606
9129	0.4810424124469211	-1.4445618979859027
9130	0.4296180313661602	-1.4470821534257825
9131	0.7175624513601847	-1.2516925436650175
9132	0.7176217925547526	-1.2514010736799344
9133	0.5617638903516589	-1.409964236223619
9134	0.6890647153336212	-1.3278761655145699
9135	0.6643886569569797	-2.1275563581810877
9136	0.8482300164692442	-2.1473361745939394
9137	0.8484272386747195	-2.1473518825572073
9138	0.8235039369562406	-2.1453011206861143
9139	0.8233939812133648	-2.145344753917414
9140	0.5535311722700016	-1.416168881714459
9141	0.7298390973187128	-2.1700254548698656
9142	0.5305364593749763	-1.4202477161763698
9143	0.5305364593749763	-1.4202477161763698
9144	0.5305364593749763	-1.4202477161763698
9145	0.5305451860212362	-1.4200662019341623
9146	0.5305451860212362	-1.4200662019341623
9147	0.5305451860212362	-1.4200662019341623
9148	0.5304055596810767	-1.422298478047463
9149	0.5304055596810767	-1.422298478047463
9150	0.5304055596810767	-1.422298478047463
9151	0.5305853285940322	-1.4204501743696012
9152	0.5305853285940322	-1.4204501743696012
9153	0.5305853285940322	-1.4204501743696012
9154	0.5305800926062761	-1.4204065411383013
9155	0.5305800926062761	-1.4204065411383013
9156	0.5375038137489377	-1.4227051397631778
9157	0.5244138443589802	-1.4692181643288267
9158	0.5263040359388901	-1.4695969007765095
9159	1.0533062035785778	-3.01447508817929
9160	0.7270465705155219	-1.221294144083032
9161	0.6640977803838424	-2.128429022807085
9162	0.7158415567177182	-1.283457536051314
9163	0.573117257135882	-1.3959492423301048
9164	0.5694433390604339	-1.3961464645355801
9165	0.8456120225912527	-2.1743887779998516
9166	0.7169725300730106	-1.2760311600840781
9167	0.7169725300730106	-1.2760311600840781
9168	0.7164489312974124	-1.275778087342539
9169	0.7164489312974124	-1.275778087342539
9170	0.7168992262444268	-1.273633077691838
9171	0.84764882182833	-2.1423916568230394
9172	0.8475528287194704	-2.142464960651623
9173	0.6058474165985316	-1.3389083917164262
9174	0.665261321582977	-2.1304640767149103
9175	0.5718047695383822	-1.3939508403365712
9176	0.5931728355705488	-1.3605661824044237
9177	0.5931728355705488	-1.3605661824044237
9178	0.5931728355705488	-1.3605661824044237
9179	0.8767364791420675	-2.1842795588709034
9180	0.550621708406927	-1.419533876512304
9181	0.9974556675147593	-2.9749137100243344
9182	0.6835145683122793	-1.331768249746517
9183	0.6832527689244802	-1.3321173155969162
9184	0.6825633638699423	-1.3317787217220292
9185	0.6825633638699423	-1.3317787217220292
9186	0.6679951006035457	-1.3429435929470368
9187	0.569762734313549	-2.0441784891548145
9188	0.7103490055616922	-2.1691527902438685
9189	0.48205993940083386	-1.442601893235913
9190	0.4820651753885898	-1.442607129223669
9191	0.48179814001303467	-1.4444344889505072
9192	0.4817859227082707	-1.4444397249382632
9193	0.48185573587835046	-1.4445793512784226
9194	0.9014625586550712	-3.1104681970389785
9195	0.7238177113993324	-1.2343841134729894
9196	0.6122475389655948	-1.3265322619905342
9197	0.5354966851091442	-1.5360939452774933
9198	0.5298296010279187	-1.4245028288927317
9199	0.5298296010279187	-1.4245028288927317
9200	0.5298296010279187	-1.4245028288927317
9201	0.8469646527615483	-2.1433166813265965
9202	0.5719007626472419	-1.394029380152911
9203	0.8325220532012952	-2.1426831268081226
9204	0.48654019959070327	-1.446005285277302
9205	0.8255407361933178	-2.138900998319051
9206	0.8252492662082348	-2.138900998319051
9207	0.7087782092348972	-1.2923587152364853
9208	0.7087782092348972	-1.2923587152364853
9209	0.8256489466069414	-2.1388957623312947
9210	0.8255407361933178	-2.138609528333968
9211	0.8255407361933178	-2.138900998319051
9212	0.8249595415524038	-2.138900998319051
9213	0.7196568464625779	-1.257679022999358
9214	0.7197161876571456	-1.257684258987114
9215	0.7197161876571456	-1.257684258987114
9216	0.5770634465746411	-1.3950364351313116
9217	0.5771070798059411	-1.3949194980714281
9218	0.6787759993931147	-1.3339027874217064
9219	0.6787759993931147	-1.3339027874217064
9220	0.6784967467127956	-1.3345084166721481
9221	0.6788597751972104	-1.3332011650624045
9222	0.7121240054109703	-1.287848784449332
9223	0.7121240054109703	-1.2879360509119315
9224	0.7121292413987264	-1.2879011443268917
9225	0.7122810850436498	-1.287799915230276
9226	0.7120646642164025	-1.287892417680632
9227	0.5589120223539001	-1.4145020922788043
9228	0.7952098226757436	-2.1631319861009
9229	0.7267254299331549	-1.242936226807762
9230	0.7264933011426397	-1.2429658974050457
9231	0.8513419385255501	-2.1457217450358446
9232	0.8511394803323187	-2.145590845341945
9233	0.6844692634131202	-1.3307838840483923
9234	0.6840154778076017	-1.3310893166674913
9235	0.6840434030756336	-1.3314732891029302
9236	0.6838636341626781	-1.3313580973722985
9237	0.6838636341626781	-1.3313580973722985
9238	0.6795352176177323	-1.3337282544965068
9239	0.6056955729536082	-1.3384266808428755
9240	0.8066772176377631	-2.1601364193280657
9241	0.8235999300651002	-2.145795048864428
9242	0.8482300164692442	-2.1415189921970423
9243	0.8484429466379875	-2.141557389440586
9244	0.5723370949602404	-1.3949456780102079
9245	0.5725604971044959	-1.3950713417163516
9246	0.6600253338269939	-2.135410339815062
9247	0.6603162278534239	-2.1357000644708934
9248	0.8432854986983441	-2.1531551023200883
9249	0.7164576579436722	-2.1671177363360434
9250	0.5302973492674531	-1.4246808524764354
9251	0.5302973492674531	-1.4246808524764354
9252	0.5302973492674531	-1.4246808524764354
9253	0.7195329280856863	-1.2266470688988986
9254	0.7226535767882521	-1.2247551319897367
9255	0.6884154528518794	-1.3270401528028646
9256	0.8498933152463948	-2.150865230341472
9257	0.8474742889031306	-2.1467253093557415
9258	0.8473573518432469	-2.1464635099679423
9259	0.6058561432447916	-1.338566307183035
9260	0.6058561432447916	-1.338566307183035
9261	0.42876980134969095	-1.4277526319599452
9262	0.597731635576758	-1.3605504744411556
9263	0.597731635576758	-1.3605504744411556
9264	0.5441360649065161	-1.4228796726883772
9265	0.54355312493635	-1.4229093432856612
9266	0.7207825838301143	-1.2591014663397333
9267	0.937823002961869	-2.90248254606657
9268	0.9459684545809267	-2.8783394065237324
9269	0.9450957899549294	-2.877756466553566
9270	0.8956453762581741	-3.124720555710764
9271	0.9049532171590599	-3.0729436181211
9272	0.9317143505798889	-2.929535149472482
9273	0.9293878266869805	-2.930699284083562
9274	0.9311331559389748	-2.9286624848464853
9275	0.762330728450256	-2.1675825756934852
9276	0.9416051314509408	-2.9007372168145755
9277	0.9674936002457727	-2.805325302595802
9278	0.9488482478467173	-2.876302607286655
9279	0.9497505830699983	-2.8832839242946324
9280	0.9465496492218407	-2.885029253546627
9281	0.766112275162911	-1.2177458897137277
9282	0.5939128551733944	-1.3603183456506405
9283	1.022471471683594	-2.357358624803425
9284	0.4732163560809785	-1.4393154382544078
9285	0.5567303607889073	-1.4154323527701174
9286	0.3174457203404847	-1.1452553845613953
9287	0.3174457203404847	-1.1452553845613953
9288	0.3187756612305043	-1.1444123905326817
9289	0.8406675048203527	-2.1461737853121114
9290	0.8406675048203527	-2.1461737853121114
9291	0.8409572294761838	-2.1453011206861143
9292	0.6629342217314154	-2.118538241936033
9293	0.48739715625343244	-1.441401106710541
9294	0.5701118001639477	-1.4003649253376502
9295	0.8499753457212386	-2.148791779190103
9296	0.8500486495498223	-2.148652152849943
9297	0.8053158608212075	-2.147554340750439
9298	0.6122562656118549	-1.3273578027267277
9299	0.5599312946370648	-1.4122628348484958
9300	0.9980368621556734	-2.966187063764363
9301	0.5730491892950542	-1.3944604764781534
9302	0.5719967557561016	-1.3953907369694665
9303	0.72515463360636	-1.2309807214316006
9304	0.7285876962450328	-1.2340647182198745
9305	0.7283834927225495	-1.2342392511450742
9306	1.043415422707526	-2.8315052413757167
9307	0.7282962262599497	-1.2442155531494739
9308	0.8480938807875886	-2.146571720381566
9309	0.7213742504465402	-1.230238956499503
9310	0.5570218307739903	-1.4126398259669264
9311	0.5560043038200776	-1.4138615564433226
9312	0.5560043038200776	-1.4138615564433226
9313	0.720868104963462	-1.253320935857128
9314	0.7194247176720626	-1.2534378729170117
9315	0.7198470873510453	-1.252689126667906
9316	0.48628363619066006	-1.4413853987472731
9317	0.7244285766375305	-1.2346162422635047
9318	0.7131991282301989	-1.2900601166116088
9319	0.7240201695925637	-1.232376984833196
9320	0.7241947025177631	-1.2321151854453969
9321	0.8306021910241015	-2.1391139284877942
9322	0.6635158876112275	-2.1252293106894036
9323	0.7254757741887269	-1.2358676433371847
9324	0.5729619228324545	-1.3964082639233792
9325	0.7113909671251328	-1.2907495216661464
9326	0.7114363456856847	-1.2907407950198864
9327	0.7115131401727723	-1.2906709818498068
9328	0.8318448654515214	-2.136960192190833
9329	0.8325220532012952	-2.140354857585962
9330	0.8269945954602291	-2.1415189921970423
9331	0.7244565019055622	-1.240724894645485
9332	0.7244565019055622	-1.240724894645485
9333	0.8188072559391237	-2.1660984640528786
9334	0.8831941973744465	-2.2132816950512932
9335	0.5676980098084395	-1.4083358440315084
9336	0.56941366846315	-1.4011799940983316
9337	0.5696178719856333	-1.4021975210522444
9338	0.7203846487606594	-1.2551238609744384
9339	0.7255717672975867	-1.2679467949888406
9340	0.8304852539642178	-2.139482192959965
9341	0.7106631648270512	-1.2910322650049695
9342	0.5683088750466376	-1.4065905147795141
9343	0.7121816012762862	-1.290321915999408
9344	0.5579241659972713	-1.412494963639011
9345	0.5598440281744651	-1.4137463647126909
9346	0.5585926271007852	-1.4137742899807226
9347	0.5574284924897049	-1.413310032399692
9348	0.5975431400175426	-1.3605330211486357
9349	0.5975431400175426	-1.3605330211486357
9350	0.6643886569569797	-2.135118869829979
9351	0.5289796256821974	-1.4254976665663686
9352	0.7218769052711147	-1.2581781871654283
9353	0.579574975368261	-1.38203024154545
9354	0.7246607054280457	-1.233685981772192
9355	0.5747665932790166	-1.395186533446983
9356	0.574663618853149	-1.3950905403381235
9357	0.8066475470404793	-2.157736591606574
9358	0.807031519475918	-2.1585062818067033
9359	0.7204335179797153	-1.2756035544173396
9360	0.6864676654066537	-1.3299408900196792
9361	0.6861185995562549	-1.3302410866510221
9362	0.9916384851178622	-2.320706710511544
9363	0.7248928342185608	-1.2292057215823222
9364	0.5599888905023807	-1.4123501013110953
9365	0.6781424448746408	-1.3299059834346392
9366	1.0137448254236225	-2.384119758224254
9367	0.7787077345981374	-2.1653718253076373
9368	0.7788240898816023	-2.1652031101466056
9369	0.7784255730357309	-2.1631901637426445
9370	0.7784517529745109	-2.1644060764548554
9371	0.6603162278534239	-2.137155669067057
9372	0.5743669128803099	-1.3951516268619433
9373	0.5745571537687773	-1.3950503977653275
9374	0.6597344572538565	-2.1359915344559766
9375	0.8449627601095108	-2.1400127730525713
9376	0.8059546513274375	-2.161909673848092
9377	0.8061030043138571	-2.162250013052231
10935	0.8252928994395348	-2.138805005210191
10936	0.7246607054280457	-1.233685981772192
10937	0.8395033702092726	-2.1412275222119592
10938	0.5965744822826857	-1.360759913951395
10939	0.5965744822826857	-1.360759913951395
10940	0.8395033702092726	-2.1412275222119592
10941	0.7193671218067469	-1.2583823906879115
10942	0.48340384292486943	-1.4422091941542143
10943	0.8397948401943556	-2.1415189921970423
10944	0.8397948401943556	-2.1409377975561283
10945	0.5969985972909204	-1.3609117575963185
10946	0.4831891674268741	-1.4418112590847598
10947	0.7213655238002804	-1.248098910735161
10948	0.4827667977478915	-1.4423697644453979
10949	0.5704224687708027	-2.0445275550052133
10950	0.5704224687708027	-2.0445275550052133
10951	0.5702810971013912	-2.044644492065097
10952	0.4829849639043908	-1.4415197890996767
10953	0.5551979617056563	-1.4168006909036808
10954	0.7275404986938363	-1.2334817782497085
10955	0.7159637297653579	-1.2587890524036263
10956	0.8528848095843131	-2.151990967709008
10957	0.9037890825479796	-3.0892327760299634
10958	0.9040805525330626	-3.088360111403966
10959	0.8403760348352697	-2.1415189921970423
10960	0.8383392355981922	-2.140354857585962
10961	0.8382816397328765	-2.14041419878053
10962	0.8328135231863782	-2.138900998319051
10963	0.8325220532012952	-2.1391924683041337
10964	0.832906025636734	-2.1389882647816507
10965	0.8327454553455504	-2.13917152435311
10966	0.9428565325246208	-2.898148893533868
10967	0.6585708986014296	-2.133954735218899
10968	0.6602004601641391	-2.1365744744261423
10969	0.6600253338269939	-2.1362830044410597
10970	0.6600253338269939	-2.1365727290968906
10971	0.6603162278534239	-2.1368641990819737
10972	0.6603162278534239	-2.1365727290968906
10973	0.8333947178272924	-2.1464635099679423
10974	0.8509841460288913	-2.1464111500903824
10975	0.8303491182825622	-2.1367716966316177
10976	0.831940858560381	-2.1368641990819737
10977	0.7264357052773238	-1.2430234932703614
10978	0.9686577348568529	-2.8477961446138313
10979	0.9660397409788615	-2.84517815073584
10980	0.5752465588233151	-1.3948322316088284
10981	0.6606071218798537	-2.1362830044410597
10982	0.6606071218798537	-2.1362830044410597
10983	0.6638068863574125	-2.1261007535849243
10984	1.101594227993505	-2.9484423012593366
10985	1.049524075089506	-2.8303428520938883
10986	0.8345588524383726	-2.1374471390521395
10987	0.605135322263718	-1.3381439375040525
10988	0.48578272669533773	-1.6937547725978972
10989	0.4857914533415977	-1.6937408099638813
10990	0.4857914533415977	-1.6937408099638813
10991	0.4857914533415977	-1.6937408099638813
10992	0.6887732453485382	-1.3259999365686759
10993	0.5675810727485561	-1.404785844332952
10994	0.5674065398233565	-1.4050773143180348
10995	0.5676683392111557	-1.404174979094754
10996	0.5673489439580408	-1.4034192515286403
10997	0.9445145953140154	-2.8879387174097015
10998	0.7213742504465402	-1.253940527741586
10999	0.9421863260918549	-2.8984106929216673
11000	0.5754053837852465	-1.3950992669843834
11001	0.5436403913989497	-1.421425813421466
11002	0.5436403913989497	-1.421425813421466
11003	0.43034059767648586	-1.4187484783489066
11004	0.43034059767648586	-1.4187484783489066
11005	0.8074242185576167	-2.1641733658879287
11006	0.6596960600103128	-2.1378276208290745
11007	0.6596960600103128	-2.1378276208290745
11008	0.8235772407848243	-2.1414701229779864
11009	0.6759520566633879	-1.3317734857342733
11010	0.5912093401620553	-1.3614877162494765
11011	0.5706493615735619	-2.0460931153442523
11012	0.5706493615735619	-2.0460931153442523
11013	0.5704311954170628	-2.0461070779782684
11014	0.5704521393680866	-2.0460878793564965
11015	0.6809053010805478	-1.3328782791507856
11016	0.6809105370683037	-1.3328782791507856
11017	0.5428846638328362	-1.4196211429749037
11018	0.5470734540376225	-1.4178182178575935
11019	0.5137673359218148	-1.5700981950940986
11020	0.5108875426560241	-1.5698939915716157
11021	0.694059847652829	-1.2935804457128812
11022	0.8497275089674553	-2.1430688445728134
11023	0.8496838757361554	-2.1426831268081226
11024	0.7202973822980598	-1.258876318866226
11025	1.033526387165726	-2.362303142574325
11026	0.571895526659486	-1.3951079936306434
11027	0.5625772137830882	-1.4072589758830278
11028	0.7093314786077795	-1.2940447032939117
11029	0.7093314786077795	-1.2940447032939117
11030	1.0204364177757688	-2.3742289773532024
11031	0.56635934227216	-1.407840170523942
11032	0.563537144871685	-1.4076377123307107
11033	0.5655442735114786	-1.4079867781811095
11034	0.566010276421761	-1.4080740446437092
11035	0.7235838372795651	-1.2463692894464347
11036	0.9596396186117983	-2.8524491923996487
11037	0.5732830634148214	-1.3971360662214607
11038	0.8475371207562024	-2.1408854376785684
11039	0.8473573518432469	-2.1406463275710452
11040	0.6721559655403002	-1.3381823347475965
11041	0.7093314786077795	-1.2940447032939117
11042	0.7093314786077795	-1.2940447032939117
11043	0.6606071218798537	-2.134537675189065
11044	0.6606455191233976	-2.1347331520652886
11045	0.47647488579445196	-1.4410014263118343
11046	0.6056379770882923	-1.3378611941652294
11047	0.7196568464625779	-1.2602149864025056
11048	0.7203549781633756	-1.2602725822678214
11049	0.7244285766375305	-1.2430234932703614
11050	0.473390889006178	-1.4393730341197235
11051	0.6122841908798867	-1.3270401528028646
11052	0.8294677270103051	-2.1380196070467936
11053	0.8307767239493009	-2.1409377975561283
11054	0.48444580448831004	-1.4444641595477912
11055	0.6778771548283377	-1.3334804177427235
11056	0.5600464863676964	-1.4116222990130136
11057	0.5599312946370648	-1.4116798948783296
11058	0.5304404662661166	-1.4225916933617981
11059	0.5304404662661166	-1.4225916933617981
11060	0.5304404662661166	-1.4225916933617981
11061	0.661188892479421	-2.1368641990819737
11062	0.8520121449583158	-2.149954168471931
11063	0.42876980134969095	-1.4323341212464304
11064	0.46626470967028516	-1.4356502468252197
11065	0.6244212104982553	-1.3183344504939167
11066	0.6244212104982553	-1.3183344504939167
11067	0.5121371984004521	-1.6542527356375094
11068	0.5121371984004521	-1.6542457543205016
11069	0.5121371984004521	-1.6542457543205016
11070	0.5121371984004521	-1.6542457543205016
11071	0.5772100542318087	-1.3942266023583862
11072	0.7389427346971151	-1.2384280413498603
11073	0.8336861878123755	-2.1470464499381086
11074	0.7286749627076325	-1.2319109819229135
11075	0.7289664326927157	-1.2316212572670826
11076	0.5603379563527795	-1.4108665714469
11077	0.555567971507079	-1.4143851552189208
11078	0.6608979984529911	-2.117374107324953
11079	0.7192414581006032	-1.2711320208737302
11080	0.7181017580990509	-1.2710848969839263
11081	0.7231195796985346	-1.2457584242082367
11082	0.6835232949585393	-1.3332517796107124
11083	0.5667660039878747	-1.4083358440315084
11084	0.48333926574254565	-1.4430382255489118
11085	0.7182029871956666	-1.2772895424747661
11086	0.5651672823930478	-1.4098193738957037
11087	0.5625492885150563	-1.4074335088082273
11088	0.7133736611553984	-1.2900025207462928
11089	0.7251843042036439	-1.2267046647642144
11090	0.7121240054109703	-1.2885189908820978
11091	0.710406601427008	-1.2915436464758039
11092	0.7104537253168118	-1.291500013244504
11093	0.6701191663032229	-1.336122846230243
11094	0.5464625887994246	-1.4209301399138996
11095	0.5430591967580356	-1.4220366786596639
11096	0.5430591967580356	-1.4220366786596639
11097	0.5430016008927198	-1.421977337465096
11098	0.5434658584737503	-1.422385744510063
11099	0.7239625737272478	-1.245292421297954
11100	0.5588247558913004	-1.4126694965642104
11101	0.48253117829887227	-1.4440766964538485
11102	0.573724631715576	-1.3939159337515312
11103	0.557138767833874	-1.4151129575170023
11104	0.5579520912653032	-1.4146469546067197
11105	0.8284502000563925	-2.1412275222119592
11106	0.845835424735508	-2.1412187955656994
11107	0.8459907590389354	-2.1415137562092865
11108	0.8284502000563925	-2.1415189921970423
11109	0.8461932172321668	-2.1421001868379563
11110	0.8287399247122235	-2.1421001868379563
11111	0.8383392355981922	-2.140065132930131
11112	0.6869039977196523	-1.3309304917055598
11113	0.5832314401511891	-1.3825102070897484
11114	0.7101448020392087	-1.291775775266319
11115	0.710101168807909	-1.291779265924823
11116	0.5482951845140186	-1.4202616788103857
11117	0.5664762793320435	-1.410545430864533
11118	0.5389873436131328	-1.4226754691658938
11119	0.4430815012160445	-1.4002200630097348
11120	0.6733427894316564	-1.327518373017911
11121	0.5096064709850603	-1.571611395555578
11122	0.48359233848408484	-1.4407692975213189
11123	0.5955115767682212	-1.3602450418220566
11124	0.5955115767682212	-1.3602450418220566
11125	0.5955115767682212	-1.3602450418220566
11126	0.7229729720413671	-1.2375833019918951
11127	0.7475821144944872	-2.1743887779998516
11128	0.7285301003797171	-1.2324345806985118
11129	0.7291112950206311	-1.2304571226560024
11130	0.7285301003797171	-1.2324345806985118
11131	1.0181081485536083	-2.771001657526081
11132	0.4667883084458835	-1.4338176511106258
11133	0.9730210579868387	-2.8309240467348022
11134	0.722988680004635	-1.2301656526709193
11135	0.7225663103256524	-1.2291777963142905
11136	0.7235838372795651	-1.2287117934040082
11137	0.7388554682345155	-2.1717707841218603
11138	1.0149089600347025	-2.384700952865168
11139	0.6934769076826629	-2.161298808609894
11140	0.7154837642210594	-1.2844663363589668
11141	0.7154837642210594	-1.2844663363589668
11142	0.46441989665092714	-1.4350498535625338
11143	0.6643019839063258	-2.1331117411901857
11144	0.6056676476855762	-1.3372276396467555
11145	1.0469060812115147	-2.469117292796378
11146	1.0469654224060825	-2.468536098155464
11147	1.0466739524209994	-2.4681276911104972
11148	1.0346887764475543	-2.833833510597877
11149	0.7235559120115331	-1.2457863494762684
11150	0.571892036000982	-1.3947222758659525
11151	0.5718798186962181	-1.3948584115476081
11152	0.8055776602090067	-2.1522527670968072
11153	0.48360106513034484	-1.4438183877245532
11154	0.8450308279503386	-2.1458823153270283
11155	0.8453292792524295	-2.1458299554494684
11156	0.8447393579652555	-2.1467549799530254
11157	0.8444478879801725	-2.1470464499381086
11158	0.5505641125416113	-1.418022421380077
11159	0.7162778890307169	-1.261311053172758
11160	0.6685396433301679	-1.3325885544949545
11161	0.6686495990730437	-1.3319183480621886
11162	0.6686495990730437	-1.3319183480621886
11163	0.6684384142335522	-1.3312149803736348
11164	0.6684384142335522	-1.3312149803736348
11165	0.7193671218067469	-1.2560558667950033
11166	0.7186253568746492	-1.2552320713880618
11167	0.6640977803838424	-2.126973418210922
11168	0.6120049381995677	-1.3267783534150654
11169	0.8191406138262547	-2.1659536017249628
11170	0.8191406138262547	-2.1656621317398796
11171	0.5293583621298801	-1.5363836699333244
11172	0.7187178593250049	-1.2748548081682343
11173	0.5717000497832626	-1.393999709555627
11174	0.5717122670880266	-1.393994473567871
11175	0.5717401923560584	-1.3939648029705871
11176	0.5713038600430599	-1.393353937732389
11177	0.5302048468170973	-1.424703541756711
11178	0.5302048468170973	-1.424703541756711
11179	0.5302048468170973	-1.424703541756711
11180	0.6899862491786742	-1.3232510429967848
11181	0.680533545949873	-1.3331697491358687
11182	0.645422757387503	-1.326567168575574
11183	0.645422757387503	-1.3264205609184065
11184	0.6842947304879208	-1.327518373017911
11185	0.5775957719964995	-1.395259837275567
11186	0.8070786433657218	-2.163583444600755
11187	0.6741910194481257	-1.3290978959909658
11188	0.6741910194481257	-1.3290978959909658
11189	0.5649630788705644	-1.4074038382109435
11190	0.9061173517701401	-3.071198288869106
11191	0.9064070764259712	-3.0697426842729425
11192	0.9064070764259712	-3.0706153488989396
11193	0.7131031351213392	-1.2879360509119315
11194	0.7125952443090088	-1.2876079290125566
11195	0.7207721118546022	-1.2724671977515059
11196	0.8505565403621526	-2.1426831268081226
11197	0.8505216337771127	-2.1427983185387545
11198	1.0268347948135799	-2.7678007236779236
11199	0.7120890988259305	-1.2888698020617486
11200	0.8071484565358017	-2.164107043376353
11201	0.7194683509033625	-1.2484479765855598
11202	0.7207860744886182	-1.2562094557691785
11203	1.0462672907052848	-2.469989957422375
11204	1.0456267548698028	-2.471298954361371
11205	0.48793646299229876	-1.4455392823670197
11206	0.8066527830282352	-2.154875996962555
11207	0.6241594111104561	-1.318276854628601
11208	0.6241594111104561	-1.318276854628601
11209	0.7300136302439123	-1.2458160200735524
11210	0.7121117881062065	-1.289007683072656
11211	0.8447393579652555	-2.1435557914341197
11212	0.8272860654453121	-2.1435557914341197
11213	0.8275775354303953	-2.1429728514639534
11214	0.8450308279503386	-2.1429728514639534
11215	0.5681046715241542	-1.4060948412719476
11216	0.5676980098084395	-1.405630583690917
11217	0.5291401959733808	-1.4246476912206474
11218	0.5291401959733808	-1.4246476912206474
11219	0.5291401959733808	-1.4246476912206474
11220	0.7270744957835538	-1.242819289747878
11221	0.7269296334556382	-1.2434598255833602
11222	0.7256206365166425	-1.2451475589700387
11223	0.6745208866767525	-1.331803156331557
11224	0.6745208866767525	-1.331803156331557
11225	0.7566874972021416	-2.1701627541043615
11226	0.5663890128694439	-1.4064439071223465
11227	0.752615062280822	-2.1715328375671774
11228	0.7198470873510453	-1.2634438455186952
11229	0.7197964728027375	-1.2639971148915774
11230	0.719642883828562	-1.2625502369416741
11231	0.719337451209463	-1.263152375533612
11232	0.5706877588171059	-2.0448940741481323
11233	0.5706877588171059	-2.0448940741481323
11234	0.4794419455228423	-1.4432703543394267
11235	0.7158764633027581	-1.2845623294678266
11236	0.7262315017548405	-1.2292353921796064
11237	0.4881336851977741	-1.442064331826299
11238	0.6698870375127076	-1.33273341682287
11239	0.6698800561956997	-1.332738652810626
11240	0.6698800561956997	-1.332738652810626
11241	0.6698573669154237	-1.332127787572428
11242	0.6698573669154237	-1.332127787572428
11243	0.6698573669154237	-1.332127787572428
11244	0.66977533644058	-1.3316635299913975
11245	0.6713792940231627	-1.333024886807953
11246	0.6713792940231627	-1.333024886807953
11247	0.6713792940231627	-1.333024886807953
11248	0.6829176657080973	-1.3332186183549244
11249	0.6813817759663423	-1.333044085429725
11250	0.6813817759663423	-1.333044085429725
11251	0.6823312350794272	-1.3333093754760281
11252	0.6820973609596599	-1.333335555414808
11253	0.8480467568977847	-2.1467322906727495
11254	0.8479385464841611	-2.1467549799530254
11255	0.715003798676761	-1.2769998178189352
11256	0.7152935233325921	-1.2781255551864714
11257	0.7145081251691946	-1.2781255551864714
11258	0.5495465855876985	-1.4190696189312737
11259	0.7234093043543658	-1.2268216018240983
11260	0.7120995708014425	-1.2880302986915393
11261	0.5403242658201606	-1.4212512804962665
11262	0.5721102021574812	-1.394910771425168
11263	0.572162562035041	-1.3948671381938682
11264	0.4823880613002087	-1.4420870211065748
11265	0.485407480906159	-1.4389768443795208
11266	0.48600438351034103	-1.4389140125264492
11267	0.4838977711031839	-1.440519715438284
11268	0.530344473157257	-1.4233823275129514
11269	0.530344473157257	-1.4233823275129514
11270	0.530344473157257	-1.4233823275129514
11271	0.530313057230721	-1.4233980354762195
11272	0.530313057230721	-1.4233980354762195
11273	0.530313057230721	-1.4233980354762195
11274	0.8231548711058416	-2.1444476546818887
11275	0.5733109886828534	-1.3950277084850515
11276	0.5729427242106825	-1.3950207271680437
11277	0.5730404626487942	-1.3950416711190676
11278	0.5602803604874637	-1.4119416942661287
11279	0.6643072198940817	-2.1341310134733504
11280	0.6640977803838424	-2.133665010563068
11281	0.5637710189914523	-1.4089170386724224
11282	0.5635092196036533	-1.4092364339255377
11283	0.8275775354303953	-2.1415189921970423
11284	0.8272860654453121	-2.1415189921970423
11285	0.8450308279503386	-2.1421001868379563
11286	0.8449575241217548	-2.14220839725158
11287	0.8448475683788791	-2.1405241545234057
11288	0.8447393579652555	-2.140354857585962
11289	0.6825336932726584	-1.3285533532643437
11290	0.6772837428826596	-1.3301014603108625
11291	0.7141311340507638	-1.286520588888564
11292	0.676868354520685	-1.3097526665618608
11293	0.676868354520685	-1.3097526665618608
11294	0.7263484388147242	-1.2237376050358242
11295	0.9442231253289323	-2.883865118935547
11296	0.5680174050615546	-1.3989983325333388
11297	0.8444478879801725	-2.150245638457014
11298	0.8249595415524038	-2.138609528333968
11299	0.8456120225912527	-2.1493729738310168
11300	0.8429940287132611	-2.1496644438161
11301	0.5480909809915353	-1.4194466100497043
11302	0.5480909809915353	-1.4194466100497043
11303	0.5947855197993915	-1.3601787193104808
11304	0.5947855197993915	-1.3601787193104808
11305	0.5947855197993915	-1.3601787193104808
11306	0.8575971985646977	-2.1610090839540628
11307	0.6764320222076864	-1.3264275422354146
11308	0.5967664685004052	-1.3606150516234794
11309	0.855050763186038	-2.1427023254298945
11310	0.5727507379929632	-1.3949160074129239
11311	0.5728118245167829	-1.3950277084850515
11312	0.5723720015452803	-1.394881100827884
11313	0.5725465344704798	-1.3947851077190245
11314	0.6687316295478873	-1.3337666517400508
11315	0.5307406628974596	-1.4242375388464288
11316	0.5307406628974596	-1.4242375388464288
11317	0.5307406628974596	-1.4242375388464288
11318	0.7169603127682467	-1.2665016623681893
11319	0.654673002423073	-2.1313960825354754
11320	0.6544984694978736	-2.1313367413409074
11321	0.6539166814450137	-2.1304640767149103
11322	0.7248928342185608	-1.2377578349170946
11323	0.7242540437123309	-1.2462226817892672
11324	0.7243692354429626	-1.2460778194613515
11325	0.5583604983102699	-1.4140657599658057
11326	0.7243989060402465	-1.2463396188491507
11327	0.7258248400391258	-1.2445646189998725
11328	0.7256206365166425	-1.244362160806641
11329	0.711919801888487	-1.2904091824620076
11330	0.5771507130372409	-1.3948671381938682
11331	0.7240498401898476	-1.2314746496099152
11332	0.7237007743394488	-1.2310976584914841
11333	0.7115131401727723	-1.2906709818498068
11334	0.7113647871863529	-1.2906936711300827
11335	0.7194823135373785	-1.2553280644969216
11336	0.7127348706491684	-1.2879709574969713
11337	0.7176566991397924	-1.2580472874715287
11338	0.7176357551887684	-1.2565794655706015
11339	0.7207633852083423	-1.2579163877776292
11340	0.7155064535013353	-1.2812462038890373
11341	0.7151783316019604	-1.2810053484522619
11342	0.714712328691678	-1.2816528656047521
11343	0.7156949490605508	-1.281014075098522
11344	0.7156949490605508	-1.281014075098522
11345	0.7156949490605508	-1.281014075098522
11346	0.723313311245506	-1.264717935872651
11347	0.722391777400453	-1.230601984983918
11348	0.8406675048203527	-2.154027766946086
11349	0.8406675048203527	-2.154027766946086
11350	0.8409572294761838	-2.1516994977239254
11351	0.8343773381961652	-2.137059675958197
11352	0.836885376331281	-2.139482192959965
11353	0.7213742504465402	-1.254856825598883
11354	0.7211997175213408	-1.224697536124421
11355	0.5660975428843609	-1.4040004461695543
11356	0.48185573587835046	-1.4454520159044197
11357	0.4817196001966949	-1.446314208554905
11358	0.5597846869798974	-1.413105828877209
11359	0.5600761569649804	-1.4135997570555234
11360	0.5601634234275801	-1.4140657599658057
11361	0.8228581651330026	-2.145590845341945
11362	0.8229227423153264	-2.145590845341945
11363	1.0291630640357403	-2.3602663433372477
11364	1.0315716184034924	-2.362695841656024
11365	0.571886800013226	-1.3962634015954636
11366	0.7123613701892416	-1.287477029318657
11367	0.9773843811168246	-2.8038714433288905
11368	0.9770929111317415	-2.8027073087178103
11369	0.5286305598317985	-1.5381586697826026
11370	0.8190184407786151	-2.1670234885564352
11371	0.8188159825853838	-2.1663899340379618
11372	0.8188508891704236	-2.166534796365877
11373	0.5408199393277269	-1.420785277585984
11374	0.5470158581723068	-1.418312146035908
11375	0.5504768460790115	-1.416858286768997
11376	0.5470158581723068	-1.418312146035908
11377	0.5504768460790115	-1.416858286768997
11378	0.5433820826696546	-1.420767824293464
11379	0.5574878336842728	-1.412524634236295
11380	0.5570515013712741	-1.412786433624094
11381	0.818704281513256	-2.16692225945982
11382	0.543263400280519	-1.4207556069887002
11383	0.543263400280519	-1.4207556069887002
11384	1.0233441363095912	-2.7678007236779236
11385	0.7223621068031691	-1.2636847009554704
11386	0.7133736611553984	-1.286888853360735
11387	0.3199764477558764	-1.1452274592933631
11388	0.8468337530676487	-2.1427354866856825
11389	0.8467761572023329	-2.1426831268081226
11390	0.9069900163961373	-3.0642169718611285
11391	0.5678428721363551	-1.4034768473939563
11392	0.5599888905023807	-1.414589358741404
11393	0.5740038843958951	-1.3955739965409257
11394	0.5741487467238106	-1.39558621384569
11395	0.5740161017006591	-1.3956577723450216
11396	0.8607387912182874	-2.1490815038459337
11397	0.6606071218798537	-2.135410339815062
11398	0.5555330649220391	-1.4164708236750538
11399	0.5560043038200776	-1.4162177509335148
11400	0.5719391598907858	-1.3945390162944933
11401	0.5720543516214174	-1.3945041097094533
11402	0.5487611874243011	-1.4195932177068717
11403	0.6056240144542764	-1.338236439954408
11404	0.6056240144542764	-1.338236439954408
11405	0.6053814136882492	-1.3381142669067685
11406	0.65989502754504	-2.1377281370617105
11407	0.559290758801583	-1.412524634236295
11408	0.5598143575771812	-1.413310032399692
11409	0.5591458964736674	-1.4120010354606967
11410	0.5711467804103804	-1.3929472760166743
11411	0.5704259594293067	-1.3914811994449992
11412	0.5714295237492034	-1.3935494146086125
11413	0.5706825228293498	-1.3919995622328416
11414	0.570984464789945	-1.3926383527390713
11415	0.836565981078166	-2.140450850694822
11416	0.8369586801598647	-2.139410634460633
11417	0.5255483083727766	-1.4696248260445413
11418	0.7208209810736581	-1.2484916098168597
11419	0.7197737835224616	-1.2759020057194308
11420	0.7297797561241449	-1.2461650859239515
11421	0.5811073744515121	-1.383571367274961
11422	0.5813639378515552	-1.383813968040988
11423	0.6736325140874874	-1.3473592759545825
11424	0.5644394800949663	-1.4043791826172374
11425	0.5500108431687291	-1.418923011274106
11426	0.8471688562840316	-2.143801882858651
11427	0.5717908069043663	-1.3939456043488152
11428	0.42862319369252344	-1.427853861056561
11429	0.5708675277300613	-2.0451331842556555
11430	0.5708675277300613	-2.0451331842556555
11431	0.8574505909075303	-2.158972284716986
11432	0.5121965395950199	-1.6529140681012298
11433	0.5115560037595379	-1.6549211967410231
11434	0.4866536459920829	-1.440809440094115
11435	0.4865838328220031	-1.4413016229431774
11436	0.7178835919425517	-1.2572182560768312
11437	0.7182989803045263	-1.2594068989588323
11438	0.7183478495235821	-1.259206186094853
11439	0.4679629150324756	-1.4360743618334544
11440	0.7219257744901706	-1.2367979038284977
11441	0.7225959809229363	-1.2366233709032983
11442	0.7223045109378532	-1.2354016404269021
11443	0.7129669994396837	-1.2906709818498068
11444	0.686982537535992	-1.3244640468269209
11445	0.5822278758312924	-1.3838279306750039
11446	0.8241095662066826	-2.139590403373589
11447	0.8240868769264067	-2.139482192959965
11448	0.826121930834232	-2.1391924683041337
11449	0.8259910311403325	-2.1393320946442937
11450	0.8795290059452585	-2.184396495930787
11451	0.7160178349721696	-1.2577278922184136
11452	0.6600253338269939	-2.137155669067057
11453	0.47696881397276636	-1.4408862345812028
11454	1.0309083932877345	-2.8236512597417422
11455	0.8456120225912527	-2.1537362969610028
11456	0.720239786432744	-1.2584696571505114
11457	0.5708971983273452	-1.399260131921138
11458	0.5709547941926609	-1.399521931308937
11459	0.7247479718906453	-1.2450602925074388
11460	0.724864908950529	-1.2454372836258696
11461	0.7810924361327783	-1.1681785389570887
11462	0.8188508891704236	-2.1663899340379618
11463	0.718979658712804	-1.2589705666458337
11464	0.7224493732657689	-1.2228073445445111
11465	0.722391777400453	-1.2237079344385402
11466	0.7190756518216638	-1.24965574442794
11467	0.7190669251754038	-1.2495108821000245
11468	0.7216639751023713	-1.2495894219163641
11469	0.8465667176920936	-2.1416272026106657
11470	0.8464846872172498	-2.1415189921970423
11471	0.680212405367506	-1.333723018508751
11472	0.7153005046496	-1.2839863708146684
11473	0.7153005046496	-1.2839863708146684
11474	0.7148868616168774	-1.2838868870473048
11475	0.7148868616168774	-1.2838868870473048
11476	0.687595148103442	-1.3273281321294434
11477	0.6872809888380831	-1.327205959081804
11478	0.8467761572023329	-2.1406463275710452
11479	0.8468546970186727	-2.140684724814589
11480	0.7232068461611344	-1.2374960355292954
11481	0.6861185995562549	-1.331831081599589
11482	0.5765398477990428	-1.3947502011339847
11483	0.9756390518648302	-2.8059082425659674
11484	0.561093683918893	-1.4109538379095
11485	0.680861667849248	-1.3296354574005802
11486	0.678083103680073	-1.3442874964710727
11487	0.8505216337771127	-2.1411315291030997
11488	0.8331032478422093	-2.1412275222119592
11489	0.8252492662082348	-2.1406463275710452
11490	0.8251532730993751	-2.1408592577397885
11491	0.7240358775558317	-1.2250902352061197
11492	0.7237583702047645	-1.2244060661393381
11493	0.6744824894332087	-1.3461288188319265
11494	0.8238390401726234	-2.146309920993767
11495	0.8237954069413236	-2.1461737853121114
11496	0.8237954069413236	-2.1473361745939394
11497	0.8239175799889632	-2.1474443850075633
11498	0.7197214236449017	-1.266527842306969
11499	0.7184351159861818	-1.2665767115260251
11500	0.8065375912976036	-2.1630650818129125
11501	0.7241074360551635	-1.2228946110071108
11502	0.7138396640656808	-1.2831084702009152
11503	0.5710577686185286	-2.0453810210094385
11504	0.4819063504266583	-1.4415459690384564
11505	0.7218332720398147	-1.2478371113473619
11506	0.9759305218499132	-2.802998778702893
11507	0.7135481940805977	-1.2833981948567463
11508	0.8480694461780607	-2.14536744319769
11509	0.7130752098533073	-1.2876829781703925
11510	0.7132061095472069	-1.2875503331472407
11511	0.7128011931607441	-1.287454340038381
11512	0.7128570436968079	-1.2874037254900732
11513	0.7286959066586565	-1.2679869375616364
11514	0.7203410155293597	-1.2615588899265413
11515	0.7200652535075446	-1.2611085949795269
11516	0.6143558967020041	-1.3220869083857045
11517	0.7190756518216638	-1.2906709818498068
11518	0.7175188181288847	-1.262579907538958
11519	0.8345588524383726	-2.1412275222119592
11520	0.7702719765468301	-2.1665353781422887
11521	0.7238177113993324	-1.2301656526709193
11522	0.7243989060402465	-1.2310976584914841
11523	0.9226979796640863	-2.2427480888127134
11524	0.7118028648286033	-1.2903795118647237
11525	0.7117155983660037	-1.2904667783273234
11526	0.7125830270042449	-1.285434994093824
11527	0.6903353150290732	-1.3240067705628984
11528	0.7134330023499661	-1.2901770536714923
11529	0.6243042734383717	-1.3185386540164001
11530	0.7158677366564982	-1.271161691471014
11531	0.7160614682034695	-1.2725579548726096
11532	0.7169376234879707	-1.2711232942274702
11533	0.7243168755654028	-1.2661264165790105
11534	0.7128221371117681	-1.290351586596692
11535	0.5721538353887811	-1.395565269894666
11536	0.5628686837681712	-1.40789951171851
11537	0.7167770531967873	-1.259459258836392
11538	0.5721398727547651	-1.3941044293107467
11539	0.5723720015452803	-1.3947798717312685
11540	0.5726739435058754	-1.3947275118537088
11541	0.7268720375903225	-1.2443324902093573
11542	0.6687752627791872	-1.3334524924746918
11543	0.6687752627791872	-1.3334524924746918
11544	0.6763447557450866	-1.3351559338246382
11545	0.674985144257783	-1.3309444543395756
11546	1.0733774899765127	-2.898119222936584
11547	0.5739515245183352	-1.3935581412548723
11548	0.5745327191592494	-1.3934412041949888
11549	0.5722271392173649	-1.3947798717312685
11550	0.6778562108773136	-1.3343618090149807
11551	0.5928796202562138	-1.360445754686036
11552	0.5928796202562138	-1.360445754686036
11553	0.5928796202562138	-1.360445754686036
11554	0.7174175890322692	-1.2646079801297754
11555	0.5125106988603789	-1.6545145350253085
11556	0.5125106988603789	-1.6545145350253085
11557	0.5125106988603789	-1.6545145350253085
11558	0.5149995383737228	-1.6558758918418643
11559	0.5149995383737228	-1.6558758918418643
11560	0.5149995383737228	-1.6558758918418643
11561	0.6872530635700511	-1.3284573601554839
11562	0.6737634137813869	-1.328448633509224
11563	0.6871448531564275	-1.328719159543283
11564	0.7136738577867414	-1.2873059870519616
11565	0.8472840480146633	-2.139185486987126
11566	0.8299040593233037	-2.1391924683041337
11567	0.7134905982152819	-1.2871070195172343
11568	0.8064677781275238	-2.1538096007895864
11569	0.7143056669759632	-1.2813771035829369
11570	0.7143056669759632	-1.2813771035829369
11571	0.7120943348136864	-1.2895068472387266
11572	0.5677852762710394	-1.403855583841639
11573	0.713171202962167	-1.2883444579568981
11574	0.8444478879801725	-2.1453011206861143
11575	0.8444478879801725	-2.1453011206861143
11576	0.5302956039382011	-1.4217225193943048
11577	0.5302956039382011	-1.4217225193943048
11578	0.5302956039382011	-1.4217225193943048
11579	0.9066985464110543	-3.0694529596171116
11580	0.7298390973187128	-1.245960882401468
11581	0.5919772850329327	-1.3620933454999185
11582	0.42862319369252344	-1.4405371687308037
11583	0.9576045647039728	-2.8518679977587347
11584	0.9576045647039728	-2.8518679977587347
11585	0.5580986989224708	-1.4145317628760883
11586	0.5581562947877866	-1.414676625204004
11587	0.5292134998019646	-1.4253231336411694
11588	0.5292134998019646	-1.425118930118686
11589	0.6717021799347818	-1.3328119566392098
11590	0.6717021799347818	-1.3328119566392098
11591	0.6725329566587309	-1.3333146114637842
11592	0.6723880943308155	-1.3337806143740667
11593	0.724835238353245	-1.2461074900586353
11594	0.5690349320154672	-1.4035937844538398
11595	0.5416629333564402	-1.4212792057642984
11596	0.7168887542689149	-1.2633129458247954
11597	0.48192903970693424	-1.4420782944603148
11598	0.5575157589523047	-1.4134548947276078
11599	0.5704311954170628	-1.3963209974607793
11600	0.5716529258934588	-1.3964379345206632
11601	0.8496838757361554	-2.1493729738310168
11602	0.8496838757361554	-2.1493729738310168
11603	0.5722358658636248	-1.3981256679073417
11604	0.5519900465404907	-1.4170031490969122
11605	0.97447491725375	-2.8061979672217987
11606	0.880897344078822	-2.2015007226003314
11607	0.6770777940309243	-1.3445527865173756
11608	0.8418019688341489	-2.1560052249885953
11609	0.9040805525330626	-3.0790522705030803
11610	0.3671003375597233	-2.739002791020017
11611	0.8395033702092726	-2.1461737853121114
11612	0.8395033702092726	-2.1461737853121114
11613	0.9026266932661515	-3.103195410045918
11614	0.9032078879070655	-3.102322745419921
11615	0.7219554450874545	-1.2305443891186019
11616	0.8480415209100287	-2.1506819707700124
11617	0.8479385464841611	-2.1508268330979283
11618	0.7196568464625779	-1.265363707695889
11619	0.7196865170598618	-1.2647615691039509
11620	0.6801635361484503	-1.3307646854266206
11621	0.6774792197588829	-1.3328067206514538
11622	0.6778649375235737	-1.3323407177411715
11623	0.6770428874458844	-1.3340127431645818
11624	0.6722711572709319	-1.3348574825225472
11625	0.428448660767324	-1.4279707981164447
11626	0.428448660767324	-1.4279707981164447
11627	0.7277726274843516	-1.2434598255833602
11628	0.5606573516058945	-1.4160728886055993
11629	0.5607166928004622	-1.4161025592028833
11630	0.8461932172321668	-2.1459835444236437
11631	0.8461932172321668	-2.1458823153270283
11632	0.9049532171590599	3.1087228677869843
11633	1.0245658667859872	-2.7445302487610834
11634	0.7247776424879292	-1.231795790192282
11635	0.5823936821102318	-1.383208338790546
11636	0.31968672310004537	-1.144644519323197
11637	0.8495966092735557	-2.1417720649385816
11638	0.8491026810952413	-2.1418104621821255
11639	0.5585053606381855	-1.412465293041727
11640	0.5646140130201657	-1.410342972671302
11641	0.7266102382025234	-1.2265004612417314
11642	0.4838838084691679	-1.4418112590847598
11643	0.7189587147617802	-1.252041609515416
11644	0.7179708584051513	-1.2500344808756227
11645	0.7182029871956666	-1.2502369390688541
11646	0.8342673824532895	-2.140065132930131
11647	0.8486890380625187	-2.148660879496203
11648	0.567261677495441	-1.4099939068209029
11649	0.655952904723438	-2.132792345937071
11650	0.657116463375865	-2.1330820705929017
11651	0.5562364326105929	-1.4149960204571188
11652	0.5466074511273401	-1.4190399483339897
11653	0.7193950470747787	-1.2586529167219707
11654	0.718979658712804	-1.2584487131994875
11655	0.7193950470747787	-1.2581205913001123
11656	0.7195207107809223	-1.258242764347752
11657	0.5467540587845077	-1.4192720771245049
11658	0.7214021757145722	-1.25460026219884
11659	0.5565558278637078	-1.4154323527701174
11660	0.5565558278637078	-1.4154323527701174
11661	0.5567024355208753	-1.4153747569048016
11662	0.7160440149109496	-1.2633513430683394
11663	0.4743804906920588	-1.4398093664327223
11664	0.5464922593967084	-1.419882942362703
11665	0.9043720225181457	-3.075851336654923
11666	0.5562364326105929	-1.414589358741404
11667	0.7149880907134931	-1.2827297337532326
11668	0.7149880907134931	-1.2827297337532326
11669	0.7174036263982532	-1.261989986251784
11670	0.5577496330720719	-1.4147638916666037
11671	0.5575157589523047	-1.4149960204571188
11672	0.43287132509187765	-1.4113604996252145
11673	0.43353978619539146	-1.40970243683582
11674	0.43353978619539146	-1.40970243683582
11675	0.7160440149109496	-1.2824330277803935
11676	0.7160440149109496	-1.2824330277803935
11677	0.6779434773399134	-1.332152222181956
11678	0.7227111726535679	-1.2275476587929277
11679	0.47894801734452797	-1.443212758474111
11680	0.846130385379095	-2.14359069801916
11681	0.6812753108819706	-1.331124223252531
11682	0.6819699519242642	-1.3317420698077373
11683	0.6819699519242642	-1.3317420698077373
11684	0.682069435691628	-1.3318991494404169
11685	1.0343990517917234	-2.362594612559408
11686	0.7653565475967974	-1.2168732250877305
11687	0.7657928799097959	-1.217018087415646
11688	0.6850417314077744	-1.3341000096271816
11689	0.720239786432744	-1.2624542438328143
11690	0.6762574892824869	-1.3384057368918516
11691	0.562345084992573	-1.410051502686219
11692	0.5449790589352295	-1.4212792057642984
11693	0.7125882629920008	-1.2904091824620076
11694	0.7123264636042017	-1.2904091824620076
11695	0.42713966382832824	-1.4277089987286453
11696	0.5263040359388901	-1.4256721994915682
11697	0.5263040359388901	-1.4256721994915682
11698	0.5263040359388901	-1.4256721994915682
11699	0.7126039709552688	-1.286826021507663
11700	0.7104938678896077	-1.2913691135506042
11701	0.7110419012747339	-1.2910113210539456
11702	0.7417649320975901	-1.2359845803970684
11703	0.6643886569569797	-2.133665010563068
11704	0.6646795509834097	-2.133665010563068
11705	0.8395033702092726	-2.1412275222119592
11706	0.8395033702092726	-2.1412275222119592
11707	0.8397948401943556	-2.1415189921970423
11708	0.8397948401943556	-2.1409377975561283
11709	0.6741718208263537	-1.3288203886398988
11710	0.6692761722745095	-1.3473365866743068
11711	0.8508480103472357	-2.144428456060117
11712	0.8508270663962118	-2.144412748096849
11713	0.8508480103472357	-2.1438455160899506
11714	0.8512354734411783	-2.144128259428774
11715	0.714071792856196	-1.2852604611686242
11716	0.714071792856196	-1.2852604611686242
11717	0.7142707603909234	-1.2855432045074473
11718	0.7160736855082335	-1.266590674160041
11719	0.5305277327287163	-1.4206770671723603
11720	0.5305277327287163	-1.4206770671723603
11721	0.5305277327287163	-1.4206770671723603
11722	0.5304631555463926	-1.4212792057642984
11723	0.5304631555463926	-1.4212792057642984
11724	0.5304631555463926	-1.4212792057642984
11725	0.807031519475918	-2.1627299785965293
11726	0.5596398246519817	-1.4134845653248918
11727	0.554025100448316	-1.4175564184697944
11728	0.5535224456237416	-1.417046782328212
11729	0.7189011188964644	-1.223418209782709
11730	0.449684081776339	-1.39864926668294
11731	0.449684081776339	-1.39864926668294
11732	0.449684081776339	-1.39864926668294
11733	0.6052505139943496	-1.3371630624644315
11734	0.723322037891766	-1.2365361044406984
11735	0.7234389749516497	-1.235810047471869
11736	0.47484649360234127	-1.4400711658205214
11737	0.5302606973531612	-1.4214834092867816
11738	0.5302606973531612	-1.4214834092867816
11739	0.5302606973531612	-1.4214834092867816
11740	0.6596524267790128	-2.1382255558985293
11741	0.6596524267790128	-2.1382255558985293
11742	0.7185956862773654	-1.276074793315378
11743	0.7117749395605715	-1.2904388530592914
11744	0.7117452689632876	-1.2905261195218911
11745	0.6854780637207729	-1.3322394886445557
11746	0.52755543701257	-1.536500606993208
11747	0.5276706287432016	-1.5364709363959241
11748	0.5352924815866609	-1.5364709363959241
11749	0.7253291665315595	-1.2243484702740224
11750	0.7251843042036439	-1.2221092128437134
11751	0.7169760207315147	-1.2555759012507046
11752	0.7170388525845864	-1.2540190675579257
11753	0.7168939902566709	-1.2536700017075268
11754	0.7183635574868501	-1.2535774992571713
11755	0.6655522156094068	-2.130174352059079
11756	0.6646795509834097	-2.1272648881960046
11757	0.6655522156094068	-2.130174352059079
11758	0.5573708966243891	-1.4159559515457156
11759	1.0250894655615856	-2.739002791020017
11760	0.606027185511487	-1.338559325866027
11761	0.6059207204271154	-1.339240004274305
11762	0.5759673798043887	-1.394600102818313
11763	0.5670278033756738	-1.4045240449451528
11764	0.567289602763473	-1.405630583690917
11765	0.5180102313334131	-1.657743394141498
11766	0.5180102313334131	-1.657743394141498
11767	0.5180102313334131	-1.657743394141498
11768	0.4310963252425994	-1.4166837538437973
11769	0.4310963252425994	-1.4166837538437973
11770	0.7267551005304388	-1.2436919543738754
11771	0.7274532322312366	-1.2428786309424458
11772	0.6816872085854413	-1.3340808110054097
11773	0.7198750126190773	-1.2565794655706015
11774	0.657116463375865	-2.1330820705929017
11775	0.7190756518216638	-1.2621872084572592
11776	0.4817894133667747	-1.443802679761285
11777	0.48185573587835046	-1.4432825716441908
11778	0.7216639751023713	-1.229060859254407
11779	0.7216936456996553	-1.2267046647642144
11780	0.721170046924057	-1.2285948563441242
11781	0.8400845648501866	-2.140354857585962
11782	0.5947733024946277	-1.3594369543783833
11783	0.721766949528239	-1.256108226672563
11784	0.55281209661818	-1.417125322144552
11785	0.5526637436317604	-1.418333089986932
11786	0.553115783908027	-1.4169804598166362
11787	0.5526236010589646	-1.4173906121908548
11788	0.8918056519037866	-2.225352392158086
11789	0.7209379181335417	-1.2234758056480248
11790	0.7209379181335417	-1.2234758056480248
11791	0.7207982917933822	-1.254891732183923
11792	0.5698500007761486	-2.044072024070443
11793	0.5700629309448919	-2.0442256130446186
11794	0.7282962262599497	-1.2454669542231536
11795	0.8418298941021809	-2.1490815038459337
11796	0.842412834072347	-2.1476276445790226
11797	0.4302236606166022	-1.4384427736284107
11798	0.7196568464625779	-1.2726364946889495
11799	0.721135140339017	-1.2580979020198364
11800	0.4770281551673342	-1.4413225668942011
11801	0.549721118512898	-1.4187781489461906
11802	0.7472330486440882	-1.2368851702910975
11803	0.6062889848992862	-1.3383271970755117
11804	0.6061755384979065	-1.3383760662945678
11805	0.6061755384979065	-1.3383760662945678
11806	0.7212276427893728	-1.2597262942119474
11807	0.8223415476744123	-2.1415189921970423
11808	0.4311835917051991	-1.4191848106619052
11809	0.4311835917051991	-1.4191848106619052
11810	0.721147357643781	-1.2564328579134338
11811	0.7243413101749306	-1.2329581794741102
11812	0.7246310348307617	-1.2325218471611117
11813	0.8383392355981922	-2.1409377975561283
11814	0.8380495109423612	-2.1406463275710452
11815	0.5735797693876605	-1.395544325943642
11816	0.5683088750466376	-1.399521931308937
11817	0.7234686455489335	-1.2365657750379824
11818	0.7235559120115331	-1.2358973139344687
11819	0.7247479718906453	-1.2338308441001073
11820	0.7163040689694968	-1.262236077676315
11821	0.7206953173675145	-1.2571257536264757
11822	1.017235483927611	-2.380337629735182
11823	0.570949558204905	-2.0457492854816097
11824	0.570949558204905	-2.0457492854816097
11825	0.5710280980212448	-1.392772743091475
11826	0.5547232321491138	-1.416514456906354
11827	1.0178184238977772	-2.3756845819493657
11828	0.6844221395233164	-1.3333495180488242
11829	0.5477419151411363	-1.4195635471095878
11830	0.5783288102823371	-1.3830128619143225
11831	0.7139932530398563	-1.2812025706577375
11832	0.7141311340507638	-1.280780200978755
11833	0.42905952600552205	-1.4285223221600747
11834	0.4297297324382878	-1.429075591532957
11835	0.5541210935571756	-1.4166052140274574
11836	0.7237583702047645	-1.233336915921793
11837	0.7170981937791542	-1.2811362481461617
11838	0.5738345874584517	-1.3940817400304708
11839	1.022181747027763	-2.764893005144101
11840	0.7142759963786793	-1.2839863708146684
11841	0.7142759963786793	-1.2839863708146684
11842	0.6574073399490025	-2.1330820705929017
11843	0.6591526692009968	-2.1330820705929017
11844	0.6597344572538565	-2.133954735218899
11845	0.6597344572538565	-2.135118869829979
11846	0.6596384641449968	-2.1342904201535218
11847	0.6597344572538565	-2.135118869829979
11848	0.5597846869798974	-1.4138912270406065
11849	0.848294593651568	-2.1434964502395517
11850	0.556206762013309	-1.413716694115407
11851	0.556206762013309	-1.413716694115407
11852	0.6738663882072546	-1.3261500348843474
11853	1.1053746111533247	-2.9466969720073424
11854	0.8304852539642178	-2.138609528333968
11855	0.7225610743378965	-1.2581432805803883
11856	0.723627470510865	-1.2578361026320375
11857	0.7118622060231713	-1.2900897872088928
11858	0.9008813640141571	-3.1171580440618727
11859	0.7151399343584165	-1.275778087342539
11860	0.7151399343584165	-1.275778087342539
11861	0.7156513158292509	-1.275748416745255
11862	0.7156513158292509	-1.275748416745255
11863	0.7159689657531139	-1.2765250882623926
11864	0.7182029871956666	-1.2484916098168597
11865	0.7195416547319463	-1.2214390064109477
11866	0.4863359960682199	-1.4408268933866348
11867	0.4863359960682199	-1.4408338747036429
11868	0.5493999779305311	-1.4194466100497043
11869	0.5486739209617014	-1.4190975441993054
11870	0.5483824509766184	-1.4192144812591891
11871	0.6894713770493359	-1.325031278833819
11872	0.6894713770493359	-1.325031278833819
11873	0.8374665709721951	-2.140065132930131
11874	0.8374665709721951	-2.140354857585962
11875	0.5465201846647404	-1.4198550170946709
11876	0.6872094303387514	-1.326232065359191
11877	0.5743232796490101	-1.3954396061885221
11878	0.7184996931685057	-1.261031800492439
11879	0.717766654882668	-1.2602149864025056
11880	0.9610952232079614	-2.858557844781629
11881	0.657116463375865	-2.134827399844896
11882	0.6573782627636642	-2.1349443369047796
11883	0.5292414250699965	-1.421366472226898
11884	0.7164227513586324	-1.26320299008192
11885	0.8505513043743965	-2.144835117775832
11886	0.8505565403621526	-2.144718180715948
11887	0.5639455519166519	-1.4085976434193075
11888	0.564207351304451	-1.4077249787933104
11889	0.564788545945365	-1.4080443740464252
11890	0.5667660039878747	-1.4057754460188328
11891	0.7144941625351786	-1.285578111092487
11892	0.5112942043717389	-1.569108593408218
11893	0.4831944034146301	-1.4439981566375086
11894	0.4806514586944744	-1.4442198134525117
11895	0.7271617622461535	-1.2456990830136687
11896	0.7270744957835538	-1.24535001716327
11897	0.8339759124682065	-2.1467549799530254
11898	0.8515251980970094	-2.146812575818341
11899	0.8241881060230222	-2.145363952539186
11900	0.8240868769264067	-2.1453011206861143
11901	0.8485214864543272	-2.1421001868379563
11902	0.8486174795631869	-2.142342787603984
11903	0.8466819094227251	-2.145931184546084
11904	0.8467761572023329	-2.1458823153270283
11905	0.8479385464841611	-2.1435557914341197
11906	0.848003123666485	-2.1436133872994354
11907	0.5824250980367678	-1.3834142876422815
11908	0.5664466087347596	-1.4037386467817552
11909	0.723322037891766	-1.2378747719769783
11910	0.7237007743394488	-1.2380789754994617
11911	0.7145151064862025	-1.2858713264068222
11912	0.5294456285924799	-1.5236724369910497
11913	0.6696531633929403	-1.3437289911104342
11914	0.6640977803838424	-2.1365727290968906
11915	0.6643886569569797	-2.1365727290968906
11916	0.6972590361717347	-1.3113234628886556
11917	0.8256419652899335	-2.1441509487090498
11918	0.8255407361933178	-2.1441369860750337
11919	0.8246384009700368	-2.1454547096602896
11920	0.8246680715673207	-2.145590845341945
11921	0.8241357461454624	-2.145615279951473
11922	0.8240868769264067	-2.145590845341945
11923	0.7109302002026062	-1.29096245183489
11924	0.557400567221673	-1.4150553616516865
11925	0.842412834072347	-2.1653724070840488
11926	0.7170545605478544	-1.278279144160647
11927	0.5673489439580408	-1.4025762574999272
11928	0.48332530310852967	-1.4436874880306536
11929	0.4826481153587559	-1.4409822276900623
11930	0.6635159923309826	-2.1357000644708934
11931	0.8240868769264067	-2.1418104621821255
11932	0.8242090499740462	-2.1417947542188576
11933	1.017235483927611	-2.366374995719228
11934	0.5715953300281429	-1.3985899254883722
11935	0.7184682772419697	-1.2603458860964054
11936	0.71903725457812	-1.26010503065963
11937	0.6739152574263104	-1.3347841786939636
11938	0.6744824894332087	-1.3349534756314068
11939	0.8068273159534347	-2.1636410404660706
11940	0.6798057436517914	-2.159844949342983
11941	0.6033027265491239	-2.1060312125162417
11942	0.6582800045749996	-2.135118869829979
11943	0.6582800045749996	-2.135118869829979
11944	0.6582800045749996	-2.134537675189065
11945	0.6603162278534239	-2.1365727290968906
11946	0.6603162278534239	-2.1362830044410597
11947	0.6599438967640958	-2.1383983434944764
11948	0.6598129970701962	-2.140450850694822
11949	0.6600974857382713	-2.1383110770318767
11950	0.6600974857382713	-2.1383110770318767
11951	0.6597554012048805	-2.1383564555924286
11952	0.6597554012048805	-2.1383564555924286
11953	0.6867870606597687	-2.161298808609894
11954	0.6600253338269939	-2.1368641990819737
11955	0.6981317007977318	-2.1653724070840488
11956	0.6600451258607115	-2.137970737827738
11957	0.8493941510803243	-2.1470464499381086
11958	0.8495006161646961	-2.1468631903666493
11959	0.8070699167194619	-2.1615606079976932
11960	0.7258527653071577	-1.2262107365859
11961	0.8505338510818766	-2.14719654825378
11962	0.8505565403621526	-2.1473361745939394
11963	0.8397948401943556	-2.1418104621821255
11964	0.8397948401943556	-2.1421001868379563
11965	0.6592405290755422	-2.1386479255775117
11966	0.6595162910973573	-2.1395764407395728
11967	0.5701257627979637	-2.0459831596013767
11968	0.5701257627979637	-2.0459831596013767
11969	0.7175484887261687	-1.2761638051072297
11970	0.8418298941021809	-2.144428456060117
11971	0.8418298941021809	-2.144428456060117
11972	0.6689550316921425	-1.334944748985147
11973	0.5976391331264023	-1.3606290142574953
11974	0.6225013483210615	-2.117084382669122
11975	0.6393717008708387	-2.128429022807085
11976	1.0195637531497714	-2.355613295551431
11977	0.6632251157578453	-2.1473361745939394
11978	0.6614797865058508	-2.1362830044410597
11979	0.6643886569569797	-2.1263922235700075
11980	0.6134832320760069	-2.107776541768236
11981	0.6626433277049854	-2.1368641990819737
11982	0.6623524511318482	-2.1368641990819737
11983	0.6335545184739416	-2.127847828166171
11984	0.8403760348352697	-2.1423916568230394
11985	0.8403760348352697	-2.1423916568230394
11986	0.8403760348352697	-2.1421001868379563
11987	0.8403760348352697	-2.1421001868379563
11988	0.8406675048203527	-2.1426831268081226
11989	0.8406675048203527	-2.1421001868379563
11990	0.8406675048203527	-2.1421001868379563
11991	0.8406675048203527	-2.1415189921970423
11992	0.46175652421238383	-1.431489381888465
11993	0.46175652421238383	-1.4314963632054731
11994	0.7251843042036439	-1.2214390064109477
11995	0.725446103591443	-1.220391808859751
11996	0.7251267083383282	-1.2214686770082315
11997	0.7222748403405693	-1.2482018851610286
11998	0.7180860501357831	-1.2735318485952225
11999	0.6849771542254505	-1.3316286234063577
12000	0.6852459349302576	-1.331220216361391
12001	0.685469337074513	-1.3303981662837017
12002	0.6846350696920597	-1.3322325073275476
12003	0.6764232955614263	-1.3339464206530063
12004	0.6763098491600467	-1.334225673333325
12005	0.6763098491600467	-1.334225673333325
12006	0.6762854145505188	-1.3326164797629865
12007	0.675011324196563	-1.3258620555577685
12008	0.9657482709937784	-2.801544919435982
12009	0.8554731328650207	-2.156965156077192
12010	0.8352185868956264	-2.1393757278755934
12011	0.8374665709721951	-2.138900998319051
12012	0.9945462036516848	-2.7730367114339063
12013	0.4854633314422228	-1.6969836317140867
12014	0.715003798676761	-1.2758356832078548
12015	0.4827929776866714	-1.4416279995133001
12016	0.48264462470025193	-1.4414639385636128
12017	0.4827877416989155	-1.4416419621473162
12018	0.5624026808578888	-1.4077249787933104
12019	0.8383392355981922	-2.1421001868379563
12020	0.8397948401943556	-2.1421001868379563
12021	0.8307994132295768	-2.1408505310935286
12022	0.8301955293083867	-2.140065132930131
12023	0.8301955293083867	-2.140065132930131
12024	0.8304852539642178	-2.1391924683041337
12025	0.5610657586508612	-1.416160155068199
12026	0.7516557129686419	-1.233947781159991
12027	0.669443723882701	-1.3436713952451185
12028	0.6588617926278594	-2.135410339815062
12029	0.8336861878123755	-2.1365744744261423
12030	0.8755740898602393	-2.161590278594977
12031	1.0210176124166828	-2.76838366364809
12032	0.8345588524383726	-2.1432643214490366
12033	0.8521081380671756	-2.1434091837769524
12034	0.7024950239277177	-2.170608394840032
12035	0.31567246582045844	-1.1733272602504718
12036	0.6724456901961313	-1.3489353082691335
12037	0.6723304984654996	-1.3487328500759022
12038	0.5707226654021458	-2.0461070779782684
12039	0.5115560037595379	-1.568208003514189
12040	0.8823512033457332	-2.226254727381367
12041	0.723322037891766	-1.2365361044406984
12042	0.8363041816903669	-2.1752614426258488
12043	0.8069913769031222	-2.1555392220783127
12044	0.7210531098641734	-1.2516401837874576
12045	0.7203410155293597	-1.2516925436650175
12046	0.5818840459686495	-1.3837197202613805
12047	0.5557617030540504	-1.414894791360503
12048	0.5560915702826773	-1.414676625204004
12049	0.8500853014641141	-2.143773957590619
12050	0.6608979984529911	-2.1368641990819737
12051	0.6608979984529911	-2.137155669067057
12052	0.8431109657731448	-2.156122162048479
12053	0.7198610499850612	-1.2573927890020309
12054	0.8499753457212386	-2.1435557914341197
12055	0.6058334539645157	-1.3383132344414959
12056	0.6724753607934152	-1.3307123255490607
12057	0.7192292407958392	-1.2760311600840781
12058	0.7211124510587411	-1.2626793913063217
12059	0.720850651670942	-1.2562007291229187
12060	0.7172727267043536	-1.2612325133564184
12061	0.7169515861219866	-1.2606513187155044
12062	0.5607742886657782	-1.4116519696102976
12063	0.5802207471914989	-1.3824019966761245
12064	0.5735064655590767	-1.3944517498318934
12065	0.48120123740885257	-1.4424064163596897
12066	0.4808958047897536	-1.4431830878768273
12067	0.5931449103025168	-1.360149048713197
12068	0.5931449103025168	-1.360149048713197
12069	0.5931449103025168	-1.360149048713197
12070	0.5933892563977962	-1.36047542528332
12071	0.5933892563977962	-1.36047542528332
12072	0.5933892563977962	-1.36047542528332
12073	0.5935201560916957	-1.3605277851608797
12074	0.5935201560916957	-1.3605277851608797
12075	0.5935201560916957	-1.3605277851608797
12076	0.5935376093842156	-1.3603305629554043
12077	0.5935376093842156	-1.3603305629554043
12078	0.5935376093842156	-1.3603305629554043
12079	0.5718798186962181	-1.3940520694331868
12080	0.5233369762104997	-1.4247122684029712
12081	0.5233369762104997	-1.4247122684029712
12082	0.5233369762104997	-1.4247122684029712
12083	0.6899146906793425	-1.3261831961401354
12084	0.6620615571054181	-2.1368641990819737
12085	0.7216936456996553	-2.1674074609918743
12086	0.5727507379929632	-1.3946838786224087
12087	0.8304852539642178	-2.1368641990819737
12088	0.7229450467733353	-1.2386601701403757
12089	0.8301955293083867	-2.138028333693054
12090	0.8304852539642178	-2.1374471390521395
12091	0.8304852539642178	-2.138609528333968
12092	0.8301955293083867	-2.138609528333968
12093	0.6606071218798537	-2.1374453937228877
12094	0.7118028648286033	-1.2895068472387266
12095	0.6594435632274267	-2.135410339815062
12096	0.7158520286932303	-1.2691371095387007
12097	0.716855593013127	-1.269007955174053
12098	0.714707092703922	-1.2645434029474516
12099	0.6858410922051877	-1.3311329498987912
12100	0.7231771755638505	-1.2353440445615864
12101	0.7271687435631614	-1.2676116917724576
12102	0.7180947767820429	-1.262867886865537
12103	0.7141747672820636	-1.2828257268620922
12104	0.7166182282348557	-1.2571606602115155
12105	0.6892008510152768	-1.3264065982843907
12106	0.6643886569569797	-2.129882882073996
12107	0.8457568849191682	-2.1429152555986377
12108	0.7243692354429626	-1.244973026044839
12109	0.7244285766375305	-1.245322091895238
12110	0.7242540437123309	-1.245292421297954
12111	0.4858473038776615	-1.4411742139077817
12112	0.5519516492969467	-1.4174988226044787
12113	0.5524019442439613	-1.41898758845643
12114	0.5723894548378003	-1.395797398685181
12115	0.572817060504539	-1.3956525363572656
12116	0.7181244473793268	-1.2689416326624772
12117	0.7195556173659622	-1.2689416326624772
12118	0.7289664326927157	-1.2313297872819995
12119	1.0193595496272883	-2.354187361552551
12120	1.0193595496272883	-2.354187361552551
12121	0.6691592352146261	-1.320137375611227
12122	0.673115896628897	-2.152863632335005
12123	0.5820899948203848	-1.3837022669688603
12124	0.5692688061352346	-1.4030125898129258
12125	0.5683368003146695	-1.4030998562755255
12126	0.5671150698382734	-1.4066184400475459
12127	0.5704032701490308	-2.045059880427072
12128	0.5710141353872289	-2.0452344133522713
12129	0.6600259272389396	-2.137736863707971
12130	0.659917716825316	-2.1380667309365977
12131	0.845809244796728	-2.145896277961044
12132	0.8459034925763358	-2.1458823153270283
12133	0.655952904723438	-2.133665010563068
12134	0.807350914729033	-2.164112279364109
12135	0.8072636482664333	-2.164047702181785
12136	0.807310772156237	-2.1636497671123305
12137	0.6686059658417438	-1.3343914796122647
12138	0.6807482214478683	-1.3330824826732688
12139	0.6807482214478683	-1.3330824826732688
12140	0.7201961532014441	-1.2490745497870257
12141	0.6807255321675924	-1.3325379399466466
12142	0.6807255321675924	-1.3325379399466466
12143	0.7205591816858589	-1.2502369390688541
12144	0.7199483164476609	-1.2490745497870257
12145	0.8514292049881497	-2.156354290838994
12146	0.5503895796164118	-1.4184587536930755
12147	0.4765045563917359	-1.4407117016560032
12148	0.7174088623860092	-1.280466041713396
12149	0.5591284431811474	-1.411802067925969
12150	0.5591458964736674	-1.411243562565331
12151	0.5591458964736674	-1.411243562565331
12152	0.5599592199050968	-1.415170553382318
12153	0.5600185610996645	-1.4154044275020854
12154	0.7198837392653371	-1.2621784818109991
12155	0.720536492405583	-1.2627073165743536
12156	0.905825881785057	3.1049407392979123
12157	0.5603082857554955	-1.4157814186205162
12158	0.8680970993446957	-2.1624332726236903
12159	0.8604473212332044	-2.1470464499381086
12160	1.0019359277046287	-2.367132468614593
12161	0.8749911498900732	-2.187770217374892
12162	0.6050410744841103	-1.3378908647625134
12163	0.6054931147603768	-1.3378332688971974
12164	0.7178835919425517	-1.2553280644969216
12165	0.8464846872172498	-2.1418104621821255
12166	0.8466679467887093	-2.142051317618901
12167	0.6744528188359248	-1.3337858503618225
12168	0.6738227549759548	-1.3325239773126307
12169	0.6744615454821847	-1.334269306564625
12170	0.6744615454821847	-1.334269306564625
12171	0.6120293728090955	-1.3281955607676847
12172	0.7661995416255106	-1.216349626312132
12173	0.716550160394028	-1.2814346994482526
12174	0.7161574613123293	-1.2811676640726977
12175	0.7161574613123293	-1.2811676640726977
12176	0.6713618407306428	-1.3377599650686136
12177	0.664249624028766	-2.1258110289290935
12178	0.7136075352751655	-1.2653933782931728
12179	0.7155553227203912	-1.2831084702009152
12180	0.7155797573299191	-1.2831171968471753
12181	0.5729915934297384	-1.3951289375816673
12182	0.7160789214959895	-1.2781709337470233
12183	0.5720543516214174	-1.394881100827884
12184	0.5721573260472852	-1.3947065679026847
12185	0.6576982339754323	-2.1357000644708934
12186	0.6574073399490025	-2.134246205203982
12187	0.8482788856883	-2.1406236382907693
12188	0.8485214864543272	-2.1406463275710452
12189	0.5304055596810767	-1.4217748792718647
12190	0.5304055596810767	-1.4217748792718647
12191	0.9887290212547877	-2.690425041949259
12192	0.7192676380393831	-1.265035585796514
12193	0.7187353126175249	-1.264461372472608
12194	0.8437707002303986	-2.1387910425761754
12195	0.8296125893382206	-2.138028333693054
12196	0.826413400819315	-2.138609528333968
12197	0.844617184917616	-2.1394245970946493
12198	1.037598240310629	-2.362011672589242
12199	0.5586798935633849	-1.4138615564433226
12200	0.5576902918775041	-1.4148511581292031
12201	0.558650222966101	-1.41400816410049
12202	0.8508392837009756	-2.147816140138238
12203	0.8508480103472357	-2.1476276445790226
12204	0.8511394803323187	-2.1470464499381086
12205	0.5631008125586865	-1.4092085086575055
12206	0.5624026808578888	-1.409964236223619
12207	0.8429940287132611	-2.1441369860750337
12208	0.8432854986983441	-2.1432643214490366
12209	0.8429940287132611	-2.1423916568230394
12210	0.570024533701348	-1.4034489221259243
12211	0.5696754678509491	-1.3966124674458624
12212	0.485091576311548	-1.4411567606152618
12213	0.5751156591294155	-1.3950416711190676
12214	0.5943945660469448	-1.3595905433525586
12215	0.7156809864265348	-1.273640059008846
12216	0.8144526594553979	-2.160740303249256
12217	0.7120367389483707	-1.2898279878210934
12218	0.5717349563683025	-1.394628028086345
12219	0.5717471736730664	-1.3942510369679142
12220	0.5718082601968862	-1.3947100585611887
12221	0.6588617926278594	-2.138609528333968
12222	0.6588617926278594	-2.138609528333968
12223	0.5600464863676964	-1.41400816410049
12224	0.5670278033756738	-1.4023423833801598
12225	0.8248565671265362	-2.1390458606469664
12226	0.7232347714291663	-1.236420912710067
12227	0.7233517084890498	-1.235750706277301
12228	0.724543768368162	-1.2334241823843928
12229	1.016073094645783	-2.379756435094268
12230	0.571267208128768	-1.3936506437052283
12231	0.5542868998361151	-1.416741349709113
12232	1.0163628193016139	-2.3753931119642826
12233	0.8351400470792867	-2.139482192959965
12234	0.5474521904853054	-1.4191568853938732
12235	0.5474521904853054	-1.4191568853938732
12236	0.578053048260522	-1.3836097645185048
12237	0.661188892479421	-2.1362830044410597
12238	0.5608318845310939	-1.4064439071223465
12239	0.4298222348886435	-1.4460262292283261
12240	0.5919668130574207	-1.3615104055297524
12241	0.5919668130574207	-1.3615104055297524
12242	0.5919196891676168	-1.3615610200780606
12243	0.4810424124469211	-1.4445618979859027
12244	0.4296180313661602	-1.4470821534257825
12245	0.7175624513601847	-1.2516925436650175
12246	0.7176217925547526	-1.2514010736799344
12247	0.5617638903516589	-1.409964236223619
12248	0.6890647153336212	-1.3278761655145699
12249	0.6643886569569797	-2.1275563581810877
12250	0.8482300164692442	-2.1473361745939394
12251	0.8484272386747195	-2.1473518825572073
12252	0.8235039369562406	-2.1453011206861143
12253	0.8233939812133648	-2.145344753917414
12254	0.5535311722700016	-1.416168881714459
12255	0.7298390973187128	-2.1700254548698656
12256	0.5305364593749763	-1.4202477161763698
12257	0.5305364593749763	-1.4202477161763698
12258	0.5305364593749763	-1.4202477161763698
12259	0.5305451860212362	-1.4200662019341623
12260	0.5305451860212362	-1.4200662019341623
12261	0.5305451860212362	-1.4200662019341623
12262	0.5304055596810767	-1.422298478047463
12263	0.5304055596810767	-1.422298478047463
12264	0.5304055596810767	-1.422298478047463
12265	0.5305853285940322	-1.4204501743696012
12266	0.5305853285940322	-1.4204501743696012
12267	0.5305853285940322	-1.4204501743696012
12268	0.5305800926062761	-1.4204065411383013
12269	0.5305800926062761	-1.4204065411383013
12270	0.5375038137489377	-1.4227051397631778
12271	0.5244138443589802	-1.4692181643288267
12272	0.5263040359388901	-1.4695969007765095
12273	1.0533062035785778	-3.01447508817929
12274	0.7270465705155219	-1.221294144083032
12275	0.6640977803838424	-2.128429022807085
12276	0.7158415567177182	-1.283457536051314
12277	0.573117257135882	-1.3959492423301048
12278	0.5694433390604339	-1.3961464645355801
12279	0.8456120225912527	-2.1743887779998516
12280	0.7169725300730106	-1.2760311600840781
12281	0.7169725300730106	-1.2760311600840781
12282	0.7164489312974124	-1.275778087342539
12283	0.7164489312974124	-1.275778087342539
12284	0.7168992262444268	-1.273633077691838
12285	0.84764882182833	-2.1423916568230394
12286	0.8475528287194704	-2.142464960651623
12287	0.6058474165985316	-1.3389083917164262
12288	0.665261321582977	-2.1304640767149103
12289	0.5718047695383822	-1.3939508403365712
12290	0.5931728355705488	-1.3605661824044237
12291	0.5931728355705488	-1.3605661824044237
12292	0.5931728355705488	-1.3605661824044237
12293	0.8767364791420675	-2.1842795588709034
12294	0.550621708406927	-1.419533876512304
12295	0.9974556675147593	-2.9749137100243344
12296	0.6835145683122793	-1.331768249746517
12297	0.6832527689244802	-1.3321173155969162
12298	0.6825633638699423	-1.3317787217220292
12299	0.6825633638699423	-1.3317787217220292
12300	0.6679951006035457	-1.3429435929470368
12301	0.569762734313549	-2.0441784891548145
12302	0.7103490055616922	-2.1691527902438685
12303	0.48205993940083386	-1.442601893235913
12304	0.4820651753885898	-1.442607129223669
12305	0.48179814001303467	-1.4444344889505072
12306	0.4817859227082707	-1.4444397249382632
12307	0.48185573587835046	-1.4445793512784226
12308	0.9014625586550712	-3.1104681970389785
12309	0.7238177113993324	-1.2343841134729894
12310	0.6122475389655948	-1.3265322619905342
12311	0.5354966851091442	-1.5360939452774933
12312	0.5298296010279187	-1.4245028288927317
12313	0.5298296010279187	-1.4245028288927317
12314	0.5298296010279187	-1.4245028288927317
12315	0.8469646527615483	-2.1433166813265965
12316	0.5719007626472419	-1.394029380152911
12317	0.8325220532012952	-2.1426831268081226
12318	0.48654019959070327	-1.446005285277302
12319	0.8255407361933178	-2.138900998319051
12320	0.8252492662082348	-2.138900998319051
12321	0.7087782092348972	-1.2923587152364853
12322	0.7087782092348972	-1.2923587152364853
12323	0.8256489466069414	-2.1388957623312947
12324	0.8255407361933178	-2.138609528333968
12325	0.8255407361933178	-2.138900998319051
12326	0.8249595415524038	-2.138900998319051
12327	0.7196568464625779	-1.257679022999358
12328	0.7197161876571456	-1.257684258987114
12329	0.7197161876571456	-1.257684258987114
12330	0.5770634465746411	-1.3950364351313116
12331	0.5771070798059411	-1.3949194980714281
12332	0.6787759993931147	-1.3339027874217064
12333	0.6787759993931147	-1.3339027874217064
12334	0.6784967467127956	-1.3345084166721481
12335	0.6788597751972104	-1.3332011650624045
12336	0.7121240054109703	-1.287848784449332
12337	0.7121240054109703	-1.2879360509119315
12338	0.7121292413987264	-1.2879011443268917
12339	0.7122810850436498	-1.287799915230276
12340	0.7120646642164025	-1.287892417680632
12341	0.5589120223539001	-1.4145020922788043
12342	0.7952098226757436	-2.1631319861009
12343	0.7267254299331549	-1.242936226807762
12344	0.7264933011426397	-1.2429658974050457
12345	0.8513419385255501	-2.1457217450358446
12346	0.8511394803323187	-2.145590845341945
12347	0.6844692634131202	-1.3307838840483923
12348	0.6840154778076017	-1.3310893166674913
12349	0.6840434030756336	-1.3314732891029302
12350	0.6838636341626781	-1.3313580973722985
12351	0.6838636341626781	-1.3313580973722985
12352	0.6795352176177323	-1.3337282544965068
12353	0.6056955729536082	-1.3384266808428755
12354	0.8066772176377631	-2.1601364193280657
12355	0.8235999300651002	-2.145795048864428
12356	0.8482300164692442	-2.1415189921970423
12357	0.8484429466379875	-2.141557389440586
12358	0.5723370949602404	-1.3949456780102079
12359	0.5725604971044959	-1.3950713417163516
12360	0.6600253338269939	-2.135410339815062
12361	0.6603162278534239	-2.1357000644708934
12362	0.8432854986983441	-2.1531551023200883
12363	0.7164576579436722	-2.1671177363360434
12364	0.5302973492674531	-1.4246808524764354
12365	0.5302973492674531	-1.4246808524764354
12366	0.5302973492674531	-1.4246808524764354
12367	0.7195329280856863	-1.2266470688988986
12368	0.7226535767882521	-1.2247551319897367
12369	0.6884154528518794	-1.3270401528028646
12370	0.8498933152463948	-2.150865230341472
12371	0.8474742889031306	-2.1467253093557415
12372	0.8473573518432469	-2.1464635099679423
12373	0.6058561432447916	-1.338566307183035
12374	0.6058561432447916	-1.338566307183035
12375	0.42876980134969095	-1.4277526319599452
12376	0.597731635576758	-1.3605504744411556
12377	0.597731635576758	-1.3605504744411556
12378	0.5441360649065161	-1.4228796726883772
12379	0.54355312493635	-1.4229093432856612
12380	0.7207825838301143	-1.2591014663397333
12381	0.937823002961869	-2.90248254606657
12382	0.9459684545809267	-2.8783394065237324
12383	0.9450957899549294	-2.877756466553566
12384	0.8956453762581741	-3.124720555710764
12385	0.9049532171590599	-3.0729436181211
12386	0.9317143505798889	-2.929535149472482
12387	0.9293878266869805	-2.930699284083562
12388	0.9311331559389748	-2.9286624848464853
12389	0.762330728450256	-2.1675825756934852
12390	0.9416051314509408	-2.9007372168145755
12391	0.9674936002457727	-2.805325302595802
12392	0.9488482478467173	-2.876302607286655
12393	0.9497505830699983	-2.8832839242946324
12394	0.9465496492218407	-2.885029253546627
12395	0.766112275162911	-1.2177458897137277
12396	0.5939128551733944	-1.3603183456506405
12397	1.022471471683594	-2.357358624803425
12398	0.4732163560809785	-1.4393154382544078
12399	0.5567303607889073	-1.4154323527701174
12400	0.3174457203404847	-1.1452553845613953
12401	0.3174457203404847	-1.1452553845613953
12402	0.3187756612305043	-1.1444123905326817
12403	0.8406675048203527	-2.1461737853121114
12404	0.8406675048203527	-2.1461737853121114
12405	0.8409572294761838	-2.1453011206861143
12406	0.6629342217314154	-2.118538241936033
12407	0.48739715625343244	-1.441401106710541
12408	0.5701118001639477	-1.4003649253376502
12409	0.8499753457212386	-2.148791779190103
12410	0.8500486495498223	-2.148652152849943
12411	0.8053158608212075	-2.147554340750439
12412	0.6122562656118549	-1.3273578027267277
12413	0.5599312946370648	-1.4122628348484958
12414	0.9980368621556734	-2.966187063764363
12415	0.5730491892950542	-1.3944604764781534
12416	0.5719967557561016	-1.3953907369694665
12417	0.72515463360636	-1.2309807214316006
12418	0.7285876962450328	-1.2340647182198745
12419	0.7283834927225495	-1.2342392511450742
12420	1.043415422707526	-2.8315052413757167
12421	0.7282962262599497	-1.2442155531494739
12422	0.8480938807875886	-2.146571720381566
12423	0.7213742504465402	-1.230238956499503
12424	0.5570218307739903	-1.4126398259669264
12425	0.5560043038200776	-1.4138615564433226
12426	0.5560043038200776	-1.4138615564433226
12427	0.720868104963462	-1.253320935857128
12428	0.7194247176720626	-1.2534378729170117
12429	0.7198470873510453	-1.252689126667906
12430	0.48628363619066006	-1.4413853987472731
12431	0.7244285766375305	-1.2346162422635047
12432	0.7131991282301989	-1.2900601166116088
12433	0.7240201695925637	-1.232376984833196
12434	0.7241947025177631	-1.2321151854453969
12435	0.8306021910241015	-2.1391139284877942
12436	0.6635158876112275	-2.1252293106894036
12437	0.7254757741887269	-1.2358676433371847
12438	0.5729619228324545	-1.3964082639233792
12439	0.7113909671251328	-1.2907495216661464
12440	0.7114363456856847	-1.2907407950198864
12441	0.7115131401727723	-1.2906709818498068
12442	0.8318448654515214	-2.136960192190833
12443	0.8325220532012952	-2.140354857585962
12444	0.8269945954602291	-2.1415189921970423
12445	0.7244565019055622	-1.240724894645485
12446	0.7244565019055622	-1.240724894645485
12447	0.8188072559391237	-2.1660984640528786
12448	0.8831941973744465	-2.2132816950512932
12449	0.5676980098084395	-1.4083358440315084
12450	0.56941366846315	-1.4011799940983316
12451	0.5696178719856333	-1.4021975210522444
12452	0.7203846487606594	-1.2551238609744384
12453	0.7255717672975867	-1.2679467949888406
12454	0.8304852539642178	-2.139482192959965
12455	0.7106631648270512	-1.2910322650049695
12456	0.5683088750466376	-1.4065905147795141
12457	0.7121816012762862	-1.290321915999408
12458	0.5579241659972713	-1.412494963639011
12459	0.5598440281744651	-1.4137463647126909
12460	0.5585926271007852	-1.4137742899807226
12461	0.5574284924897049	-1.413310032399692
12462	0.5975431400175426	-1.3605330211486357
12463	0.5975431400175426	-1.3605330211486357
12464	0.6643886569569797	-2.135118869829979
12465	0.5289796256821974	-1.4254976665663686
12466	0.7218769052711147	-1.2581781871654283
12467	0.579574975368261	-1.38203024154545
12468	0.7246607054280457	-1.233685981772192
12469	0.5747665932790166	-1.395186533446983
12470	0.574663618853149	-1.3950905403381235
12471	0.8066475470404793	-2.157736591606574
12472	0.807031519475918	-2.1585062818067033
12473	0.7204335179797153	-1.2756035544173396
12474	0.6864676654066537	-1.3299408900196792
12475	0.6861185995562549	-1.3302410866510221
12476	0.9916384851178622	-2.320706710511544
12477	0.7248928342185608	-1.2292057215823222
12478	0.5599888905023807	-1.4123501013110953
12479	0.6781424448746408	-1.3299059834346392
12480	1.0137448254236225	-2.384119758224254
12481	0.7787077345981374	-2.1653718253076373
12482	0.7788240898816023	-2.1652031101466056
12483	0.7784255730357309	-2.1631901637426445
12484	0.7784517529745109	-2.1644060764548554
12485	0.6603162278534239	-2.137155669067057
12486	0.5743669128803099	-1.3951516268619433
12487	0.5745571537687773	-1.3950503977653275
12488	0.6597344572538565	-2.1359915344559766
12489	0.8449627601095108	-2.1400127730525713
12490	0.8059546513274375	-2.161909673848092
12491	0.8061030043138571	-2.162250013052231
12492	0.8252928994395348	-2.138805005210191
12493	0.7246607054280457	-1.233685981772192
12494	0.8395033702092726	-2.1412275222119592
12495	0.5965744822826857	-1.360759913951395
12496	0.5965744822826857	-1.360759913951395
12497	0.8395033702092726	-2.1412275222119592
12498	0.7193671218067469	-1.2583823906879115
12499	0.48340384292486943	-1.4422091941542143
12500	0.8397948401943556	-2.1415189921970423
12501	0.8397948401943556	-2.1409377975561283
12502	0.5969985972909204	-1.3609117575963185
12503	0.4831891674268741	-1.4418112590847598
12504	0.7213655238002804	-1.248098910735161
12505	0.4827667977478915	-1.4423697644453979
12506	0.5704224687708027	-2.0445275550052133
12507	0.5704224687708027	-2.0445275550052133
12508	0.5702810971013912	-2.044644492065097
12509	0.4829849639043908	-1.4415197890996767
12510	0.5551979617056563	-1.4168006909036808
12511	0.7275404986938363	-1.2334817782497085
12512	0.7159637297653579	-1.2587890524036263
12513	0.8528848095843131	-2.151990967709008
12514	0.9037890825479796	-3.0892327760299634
12515	0.9040805525330626	-3.088360111403966
12516	0.8403760348352697	-2.1415189921970423
12517	0.8383392355981922	-2.140354857585962
12518	0.8382816397328765	-2.14041419878053
12519	0.8328135231863782	-2.138900998319051
12520	0.8325220532012952	-2.1391924683041337
12521	0.832906025636734	-2.1389882647816507
12522	0.8327454553455504	-2.13917152435311
12523	0.9428565325246208	-2.898148893533868
12524	0.6585708986014296	-2.133954735218899
12525	0.6602004601641391	-2.1365744744261423
12526	0.6600253338269939	-2.1362830044410597
12527	0.6600253338269939	-2.1365727290968906
12528	0.6603162278534239	-2.1368641990819737
12529	0.6603162278534239	-2.1365727290968906
12530	0.8333947178272924	-2.1464635099679423
12531	0.8509841460288913	-2.1464111500903824
12532	0.8303491182825622	-2.1367716966316177
12533	0.831940858560381	-2.1368641990819737
12534	0.7264357052773238	-1.2430234932703614
12535	0.9686577348568529	-2.8477961446138313
12536	0.9660397409788615	-2.84517815073584
12537	0.5752465588233151	-1.3948322316088284
12538	0.6606071218798537	-2.1362830044410597
12539	0.6606071218798537	-2.1362830044410597
12540	0.6638068863574125	-2.1261007535849243
12541	1.101594227993505	-2.9484423012593366
12542	1.049524075089506	-2.8303428520938883
12543	0.8345588524383726	-2.1374471390521395
12544	0.605135322263718	-1.3381439375040525
12545	0.48578272669533773	-1.6937547725978972
12546	0.4857914533415977	-1.6937408099638813
12547	0.4857914533415977	-1.6937408099638813
12548	0.4857914533415977	-1.6937408099638813
12549	0.6887732453485382	-1.3259999365686759
12550	0.5675810727485561	-1.404785844332952
12551	0.5674065398233565	-1.4050773143180348
12552	0.5676683392111557	-1.404174979094754
12553	0.5673489439580408	-1.4034192515286403
12554	0.9445145953140154	-2.8879387174097015
12555	0.7213742504465402	-1.253940527741586
12556	0.9421863260918549	-2.8984106929216673
12557	0.5754053837852465	-1.3950992669843834
12558	0.5436403913989497	-1.421425813421466
12559	0.5436403913989497	-1.421425813421466
12560	0.43034059767648586	-1.4187484783489066
12561	0.43034059767648586	-1.4187484783489066
12562	0.8074242185576167	-2.1641733658879287
12563	0.6596960600103128	-2.1378276208290745
12564	0.6596960600103128	-2.1378276208290745
12565	0.8235772407848243	-2.1414701229779864
12566	0.6759520566633879	-1.3317734857342733
12567	0.5912093401620553	-1.3614877162494765
12568	0.5706493615735619	-2.0460931153442523
12569	0.5706493615735619	-2.0460931153442523
12570	0.5704311954170628	-2.0461070779782684
12571	0.5704521393680866	-2.0460878793564965
12572	0.6809053010805478	-1.3328782791507856
12573	0.6809105370683037	-1.3328782791507856
12574	0.5428846638328362	-1.4196211429749037
12575	0.5470734540376225	-1.4178182178575935
12576	0.5137673359218148	-1.5700981950940986
12577	0.5108875426560241	-1.5698939915716157
12578	0.694059847652829	-1.2935804457128812
12579	0.8497275089674553	-2.1430688445728134
12580	0.8496838757361554	-2.1426831268081226
12581	0.7202973822980598	-1.258876318866226
12582	1.033526387165726	-2.362303142574325
12583	0.571895526659486	-1.3951079936306434
12584	0.5625772137830882	-1.4072589758830278
12585	0.7093314786077795	-1.2940447032939117
12586	0.7093314786077795	-1.2940447032939117
12587	1.0204364177757688	-2.3742289773532024
12588	0.56635934227216	-1.407840170523942
12589	0.563537144871685	-1.4076377123307107
12590	0.5655442735114786	-1.4079867781811095
12591	0.566010276421761	-1.4080740446437092
12592	0.7235838372795651	-1.2463692894464347
12593	0.9596396186117983	-2.8524491923996487
12594	0.5732830634148214	-1.3971360662214607
12595	0.8475371207562024	-2.1408854376785684
12596	0.8473573518432469	-2.1406463275710452
12597	0.6721559655403002	-1.3381823347475965
12598	0.7093314786077795	-1.2940447032939117
12599	0.7093314786077795	-1.2940447032939117
12600	0.6606071218798537	-2.134537675189065
12601	0.6606455191233976	-2.1347331520652886
12602	0.47647488579445196	-1.4410014263118343
12603	0.6056379770882923	-1.3378611941652294
12604	0.7196568464625779	-1.2602149864025056
12605	0.7203549781633756	-1.2602725822678214
12606	0.7244285766375305	-1.2430234932703614
12607	0.473390889006178	-1.4393730341197235
12608	0.6122841908798867	-1.3270401528028646
12609	0.8294677270103051	-2.1380196070467936
12610	0.8307767239493009	-2.1409377975561283
12611	0.48444580448831004	-1.4444641595477912
12612	0.6778771548283377	-1.3334804177427235
12613	0.5600464863676964	-1.4116222990130136
12614	0.5599312946370648	-1.4116798948783296
12615	0.5304404662661166	-1.4225916933617981
12616	0.5304404662661166	-1.4225916933617981
12617	0.5304404662661166	-1.4225916933617981
12618	0.661188892479421	-2.1368641990819737
12619	0.8520121449583158	-2.149954168471931
12620	0.42876980134969095	-1.4323341212464304
12621	0.46626470967028516	-1.4356502468252197
12622	0.6244212104982553	-1.3183344504939167
12623	0.6244212104982553	-1.3183344504939167
12624	0.5121371984004521	-1.6542527356375094
12625	0.5121371984004521	-1.6542457543205016
12626	0.5121371984004521	-1.6542457543205016
12627	0.5121371984004521	-1.6542457543205016
12628	0.5772100542318087	-1.3942266023583862
12629	0.7389427346971151	-1.2384280413498603
12630	0.8336861878123755	-2.1470464499381086
12631	0.7286749627076325	-1.2319109819229135
12632	0.7289664326927157	-1.2316212572670826
12633	0.5603379563527795	-1.4108665714469
12634	0.555567971507079	-1.4143851552189208
12635	0.6608979984529911	-2.117374107324953
12636	0.7192414581006032	-1.2711320208737302
12637	0.7181017580990509	-1.2710848969839263
12638	0.7231195796985346	-1.2457584242082367
12639	0.6835232949585393	-1.3332517796107124
12640	0.5667660039878747	-1.4083358440315084
12641	0.48333926574254565	-1.4430382255489118
12642	0.7182029871956666	-1.2772895424747661
12643	0.5651672823930478	-1.4098193738957037
12644	0.5625492885150563	-1.4074335088082273
12645	0.7133736611553984	-1.2900025207462928
12646	0.7251843042036439	-1.2267046647642144
12647	0.7121240054109703	-1.2885189908820978
12648	0.710406601427008	-1.2915436464758039
12649	0.7104537253168118	-1.291500013244504
12650	0.6701191663032229	-1.336122846230243
12651	0.5464625887994246	-1.4209301399138996
12652	0.5430591967580356	-1.4220366786596639
12653	0.5430591967580356	-1.4220366786596639
12654	0.5430016008927198	-1.421977337465096
12655	0.5434658584737503	-1.422385744510063
12656	0.7239625737272478	-1.245292421297954
12657	0.5588247558913004	-1.4126694965642104
12658	0.48253117829887227	-1.4440766964538485
12659	0.573724631715576	-1.3939159337515312
12660	0.557138767833874	-1.4151129575170023
12661	0.5579520912653032	-1.4146469546067197
12662	0.8284502000563925	-2.1412275222119592
12663	0.845835424735508	-2.1412187955656994
12664	0.8459907590389354	-2.1415137562092865
12665	0.8284502000563925	-2.1415189921970423
12666	0.8461932172321668	-2.1421001868379563
12667	0.8287399247122235	-2.1421001868379563
12668	0.8383392355981922	-2.140065132930131
12669	0.6869039977196523	-1.3309304917055598
12670	0.5832314401511891	-1.3825102070897484
12671	0.7101448020392087	-1.291775775266319
12672	0.710101168807909	-1.291779265924823
12673	0.5482951845140186	-1.4202616788103857
12674	0.5664762793320435	-1.410545430864533
12675	0.5389873436131328	-1.4226754691658938
12676	0.4430815012160445	-1.4002200630097348
12677	0.6733427894316564	-1.327518373017911
12678	0.5096064709850603	-1.571611395555578
12679	0.48359233848408484	-1.4407692975213189
12680	0.5955115767682212	-1.3602450418220566
12681	0.5955115767682212	-1.3602450418220566
12682	0.5955115767682212	-1.3602450418220566
12683	0.7229729720413671	-1.2375833019918951
12684	0.7475821144944872	-2.1743887779998516
12685	0.7285301003797171	-1.2324345806985118
12686	0.7291112950206311	-1.2304571226560024
12687	0.7285301003797171	-1.2324345806985118
12688	1.0181081485536083	-2.771001657526081
12689	0.4667883084458835	-1.4338176511106258
12690	0.9730210579868387	-2.8309240467348022
12691	0.722988680004635	-1.2301656526709193
12692	0.7225663103256524	-1.2291777963142905
12693	0.7235838372795651	-1.2287117934040082
12694	0.7388554682345155	-2.1717707841218603
12695	1.0149089600347025	-2.384700952865168
12696	0.6934769076826629	-2.161298808609894
12697	0.7154837642210594	-1.2844663363589668
12698	0.7154837642210594	-1.2844663363589668
12699	0.46441989665092714	-1.4350498535625338
12700	0.6643019839063258	-2.1331117411901857
12701	0.6056676476855762	-1.3372276396467555
12702	1.0469060812115147	-2.469117292796378
12703	1.0469654224060825	-2.468536098155464
12704	1.0466739524209994	-2.4681276911104972
12705	1.0346887764475543	-2.833833510597877
12706	0.7235559120115331	-1.2457863494762684
12707	0.571892036000982	-1.3947222758659525
12708	0.5718798186962181	-1.3948584115476081
12709	0.8055776602090067	-2.1522527670968072
12710	0.48360106513034484	-1.4438183877245532
12711	0.8450308279503386	-2.1458823153270283
12712	0.8453292792524295	-2.1458299554494684
12713	0.8447393579652555	-2.1467549799530254
12714	0.8444478879801725	-2.1470464499381086
12715	0.5505641125416113	-1.418022421380077
12716	0.7162778890307169	-1.261311053172758
12717	0.6685396433301679	-1.3325885544949545
12718	0.6686495990730437	-1.3319183480621886
12719	0.6686495990730437	-1.3319183480621886
12720	0.6684384142335522	-1.3312149803736348
12721	0.6684384142335522	-1.3312149803736348
12722	0.7193671218067469	-1.2560558667950033
12723	0.7186253568746492	-1.2552320713880618
12724	0.6640977803838424	-2.126973418210922
12725	0.6120049381995677	-1.3267783534150654
12726	0.8191406138262547	-2.1659536017249628
12727	0.8191406138262547	-2.1656621317398796
12728	0.5293583621298801	-1.5363836699333244
12729	0.7187178593250049	-1.2748548081682343
12730	0.5717000497832626	-1.393999709555627
12731	0.5717122670880266	-1.393994473567871
12732	0.5717401923560584	-1.3939648029705871
12733	0.5713038600430599	-1.393353937732389
12734	0.5302048468170973	-1.424703541756711
12735	0.5302048468170973	-1.424703541756711
12736	0.5302048468170973	-1.424703541756711
12737	0.6899862491786742	-1.3232510429967848
12738	0.680533545949873	-1.3331697491358687
12739	0.645422757387503	-1.326567168575574
12740	0.645422757387503	-1.3264205609184065
12741	0.6842947304879208	-1.327518373017911
12742	0.5775957719964995	-1.395259837275567
12743	0.8070786433657218	-2.163583444600755
12744	0.6741910194481257	-1.3290978959909658
12745	0.6741910194481257	-1.3290978959909658
12746	0.5649630788705644	-1.4074038382109435
12747	0.9061173517701401	-3.071198288869106
12748	0.9064070764259712	-3.0697426842729425
12749	0.9064070764259712	-3.0706153488989396
12750	0.7131031351213392	-1.2879360509119315
12751	0.7125952443090088	-1.2876079290125566
12752	0.7207721118546022	-1.2724671977515059
12753	0.8505565403621526	-2.1426831268081226
12754	0.8505216337771127	-2.1427983185387545
12755	1.0268347948135799	-2.7678007236779236
12756	0.7120890988259305	-1.2888698020617486
12757	0.8071484565358017	-2.164107043376353
12758	0.7194683509033625	-1.2484479765855598
12759	0.7207860744886182	-1.2562094557691785
12760	1.0462672907052848	-2.469989957422375
12761	1.0456267548698028	-2.471298954361371
12762	0.48793646299229876	-1.4455392823670197
12763	0.8066527830282352	-2.154875996962555
12764	0.6241594111104561	-1.318276854628601
12765	0.6241594111104561	-1.318276854628601
12766	0.7300136302439123	-1.2458160200735524
12767	0.7121117881062065	-1.289007683072656
12768	0.8447393579652555	-2.1435557914341197
12769	0.8272860654453121	-2.1435557914341197
12770	0.8275775354303953	-2.1429728514639534
12771	0.8450308279503386	-2.1429728514639534
12772	0.5681046715241542	-1.4060948412719476
12773	0.5676980098084395	-1.405630583690917
12774	0.5291401959733808	-1.4246476912206474
12775	0.5291401959733808	-1.4246476912206474
12776	0.5291401959733808	-1.4246476912206474
12777	0.7270744957835538	-1.242819289747878
12778	0.7269296334556382	-1.2434598255833602
12779	0.7256206365166425	-1.2451475589700387
12780	0.6745208866767525	-1.331803156331557
12781	0.6745208866767525	-1.331803156331557
12782	0.7566874972021416	-2.1701627541043615
12783	0.5663890128694439	-1.4064439071223465
12784	0.752615062280822	-2.1715328375671774
12785	0.7198470873510453	-1.2634438455186952
12786	0.7197964728027375	-1.2639971148915774
12787	0.719642883828562	-1.2625502369416741
12788	0.719337451209463	-1.263152375533612
12789	0.5706877588171059	-2.0448940741481323
12790	0.5706877588171059	-2.0448940741481323
12791	0.4794419455228423	-1.4432703543394267
12792	0.7158764633027581	-1.2845623294678266
12793	0.7262315017548405	-1.2292353921796064
12794	0.4881336851977741	-1.442064331826299
12795	0.6698870375127076	-1.33273341682287
12796	0.6698800561956997	-1.332738652810626
12797	0.6698800561956997	-1.332738652810626
12798	0.6698573669154237	-1.332127787572428
12799	0.6698573669154237	-1.332127787572428
12800	0.6698573669154237	-1.332127787572428
12801	0.66977533644058	-1.3316635299913975
12802	0.6713792940231627	-1.333024886807953
12803	0.6713792940231627	-1.333024886807953
12804	0.6713792940231627	-1.333024886807953
12805	0.6829176657080973	-1.3332186183549244
12806	0.6813817759663423	-1.333044085429725
12807	0.6813817759663423	-1.333044085429725
12808	0.6823312350794272	-1.3333093754760281
12809	0.6820973609596599	-1.333335555414808
12810	0.8480467568977847	-2.1467322906727495
12811	0.8479385464841611	-2.1467549799530254
12812	0.715003798676761	-1.2769998178189352
12813	0.7152935233325921	-1.2781255551864714
12814	0.7145081251691946	-1.2781255551864714
12815	0.5495465855876985	-1.4190696189312737
12816	0.7234093043543658	-1.2268216018240983
12817	0.7120995708014425	-1.2880302986915393
12818	0.5403242658201606	-1.4212512804962665
12819	0.5721102021574812	-1.394910771425168
12820	0.572162562035041	-1.3948671381938682
12821	0.4823880613002087	-1.4420870211065748
12822	0.485407480906159	-1.4389768443795208
12823	0.48600438351034103	-1.4389140125264492
12824	0.4838977711031839	-1.440519715438284
12825	0.530344473157257	-1.4233823275129514
12826	0.530344473157257	-1.4233823275129514
12827	0.530344473157257	-1.4233823275129514
12828	0.530313057230721	-1.4233980354762195
12829	0.530313057230721	-1.4233980354762195
12830	0.530313057230721	-1.4233980354762195
12831	0.8231548711058416	-2.1444476546818887
12832	0.5733109886828534	-1.3950277084850515
12833	0.5729427242106825	-1.3950207271680437
12834	0.5730404626487942	-1.3950416711190676
12835	0.5602803604874637	-1.4119416942661287
12836	0.6643072198940817	-2.1341310134733504
12837	0.6640977803838424	-2.133665010563068
12838	0.5637710189914523	-1.4089170386724224
12839	0.5635092196036533	-1.4092364339255377
12840	0.8275775354303953	-2.1415189921970423
12841	0.8272860654453121	-2.1415189921970423
12842	0.8450308279503386	-2.1421001868379563
12843	0.8449575241217548	-2.14220839725158
12844	0.8448475683788791	-2.1405241545234057
12845	0.8447393579652555	-2.140354857585962
12846	0.6825336932726584	-1.3285533532643437
12847	0.6772837428826596	-1.3301014603108625
12848	0.7141311340507638	-1.286520588888564
12849	0.676868354520685	-1.3097526665618608
12850	0.676868354520685	-1.3097526665618608
12851	0.7263484388147242	-1.2237376050358242
12852	0.9442231253289323	-2.883865118935547
12853	0.5680174050615546	-1.3989983325333388
12854	0.8444478879801725	-2.150245638457014
12855	0.8249595415524038	-2.138609528333968
12856	0.8456120225912527	-2.1493729738310168
12857	0.8429940287132611	-2.1496644438161
12858	0.5480909809915353	-1.4194466100497043
12859	0.5480909809915353	-1.4194466100497043
12860	0.5947855197993915	-1.3601787193104808
12861	0.5947855197993915	-1.3601787193104808
12862	0.5947855197993915	-1.3601787193104808
12863	0.8575971985646977	-2.1610090839540628
12864	0.6764320222076864	-1.3264275422354146
12865	0.5967664685004052	-1.3606150516234794
12866	0.855050763186038	-2.1427023254298945
12867	0.5727507379929632	-1.3949160074129239
12868	0.5728118245167829	-1.3950277084850515
12869	0.5723720015452803	-1.394881100827884
12870	0.5725465344704798	-1.3947851077190245
12871	0.6687316295478873	-1.3337666517400508
12872	0.5307406628974596	-1.4242375388464288
12873	0.5307406628974596	-1.4242375388464288
12874	0.5307406628974596	-1.4242375388464288
12875	0.7169603127682467	-1.2665016623681893
12876	0.654673002423073	-2.1313960825354754
12877	0.6544984694978736	-2.1313367413409074
12878	0.6539166814450137	-2.1304640767149103
12879	0.7248928342185608	-1.2377578349170946
12880	0.7242540437123309	-1.2462226817892672
12881	0.7243692354429626	-1.2460778194613515
12882	0.5583604983102699	-1.4140657599658057
12883	0.7243989060402465	-1.2463396188491507
12884	0.7258248400391258	-1.2445646189998725
12885	0.7256206365166425	-1.244362160806641
12886	0.711919801888487	-1.2904091824620076
12887	0.5771507130372409	-1.3948671381938682
12888	0.7240498401898476	-1.2314746496099152
12889	0.7237007743394488	-1.2310976584914841
12890	0.7115131401727723	-1.2906709818498068
12891	0.7113647871863529	-1.2906936711300827
12892	0.7194823135373785	-1.2553280644969216
12893	0.7127348706491684	-1.2879709574969713
12894	0.7176566991397924	-1.2580472874715287
12895	0.7176357551887684	-1.2565794655706015
12896	0.7207633852083423	-1.2579163877776292
12897	0.7155064535013353	-1.2812462038890373
12898	0.7151783316019604	-1.2810053484522619
12899	0.714712328691678	-1.2816528656047521
12900	0.7156949490605508	-1.281014075098522
12901	0.7156949490605508	-1.281014075098522
12902	0.7156949490605508	-1.281014075098522
12903	0.723313311245506	-1.264717935872651
12904	0.722391777400453	-1.230601984983918
12905	0.8406675048203527	-2.154027766946086
12906	0.8406675048203527	-2.154027766946086
12907	0.8409572294761838	-2.1516994977239254
12908	0.8343773381961652	-2.137059675958197
12909	0.836885376331281	-2.139482192959965
12910	0.7213742504465402	-1.254856825598883
12911	0.7211997175213408	-1.224697536124421
12912	0.5660975428843609	-1.4040004461695543
12913	0.48185573587835046	-1.4454520159044197
12914	0.4817196001966949	-1.446314208554905
12915	0.5597846869798974	-1.413105828877209
12916	0.5600761569649804	-1.4135997570555234
12917	0.5601634234275801	-1.4140657599658057
12918	0.8228581651330026	-2.145590845341945
12919	0.8229227423153264	-2.145590845341945
12920	1.0291630640357403	-2.3602663433372477
12921	1.0315716184034924	-2.362695841656024
12922	0.571886800013226	-1.3962634015954636
12923	0.7123613701892416	-1.287477029318657
12924	0.9773843811168246	-2.8038714433288905
12925	0.9770929111317415	-2.8027073087178103
12926	0.5286305598317985	-1.5381586697826026
12927	0.8190184407786151	-2.1670234885564352
12928	0.8188159825853838	-2.1663899340379618
12929	0.8188508891704236	-2.166534796365877
12930	0.5408199393277269	-1.420785277585984
12931	0.5470158581723068	-1.418312146035908
12932	0.5504768460790115	-1.416858286768997
12933	0.5470158581723068	-1.418312146035908
12934	0.5504768460790115	-1.416858286768997
12935	0.5433820826696546	-1.420767824293464
12936	0.5574878336842728	-1.412524634236295
12937	0.5570515013712741	-1.412786433624094
12938	0.818704281513256	-2.16692225945982
12939	0.543263400280519	-1.4207556069887002
12940	0.543263400280519	-1.4207556069887002
12941	1.0233441363095912	-2.7678007236779236
12942	0.7223621068031691	-1.2636847009554704
12943	0.7133736611553984	-1.286888853360735
12944	0.3199764477558764	-1.1452274592933631
12945	0.8468337530676487	-2.1427354866856825
12946	0.8467761572023329	-2.1426831268081226
12947	0.9069900163961373	-3.0642169718611285
12948	0.5678428721363551	-1.4034768473939563
12949	0.5599888905023807	-1.414589358741404
12950	0.5740038843958951	-1.3955739965409257
12951	0.5741487467238106	-1.39558621384569
12952	0.5740161017006591	-1.3956577723450216
12953	0.8607387912182874	-2.1490815038459337
12954	0.6606071218798537	-2.135410339815062
12955	0.5555330649220391	-1.4164708236750538
12956	0.5560043038200776	-1.4162177509335148
12957	0.5719391598907858	-1.3945390162944933
12958	0.5720543516214174	-1.3945041097094533
12959	0.5487611874243011	-1.4195932177068717
12960	0.6056240144542764	-1.338236439954408
12961	0.6056240144542764	-1.338236439954408
12962	0.6053814136882492	-1.3381142669067685
12963	0.65989502754504	-2.1377281370617105
12964	0.559290758801583	-1.412524634236295
12965	0.5598143575771812	-1.413310032399692
12966	0.5591458964736674	-1.4120010354606967
12967	0.5711467804103804	-1.3929472760166743
12968	0.5704259594293067	-1.3914811994449992
12969	0.5714295237492034	-1.3935494146086125
12970	0.5706825228293498	-1.3919995622328416
12971	0.570984464789945	-1.3926383527390713
12972	0.836565981078166	-2.140450850694822
12973	0.8369586801598647	-2.139410634460633
12974	0.5255483083727766	-1.4696248260445413
12975	0.7208209810736581	-1.2484916098168597
12976	0.7197737835224616	-1.2759020057194308
12977	0.7297797561241449	-1.2461650859239515
12978	0.5811073744515121	-1.383571367274961
12979	0.5813639378515552	-1.383813968040988
12980	0.6736325140874874	-1.3473592759545825
12981	0.5644394800949663	-1.4043791826172374
12982	0.5500108431687291	-1.418923011274106
12983	0.8471688562840316	-2.143801882858651
12984	0.5717908069043663	-1.3939456043488152
12985	0.42862319369252344	-1.427853861056561
12986	0.5708675277300613	-2.0451331842556555
12987	0.5708675277300613	-2.0451331842556555
12988	0.8574505909075303	-2.158972284716986
12989	0.5121965395950199	-1.6529140681012298
12990	0.5115560037595379	-1.6549211967410231
12991	0.4866536459920829	-1.440809440094115
12992	0.4865838328220031	-1.4413016229431774
12993	0.7178835919425517	-1.2572182560768312
12994	0.7182989803045263	-1.2594068989588323
12995	0.7183478495235821	-1.259206186094853
12996	0.4679629150324756	-1.4360743618334544
12997	0.7219257744901706	-1.2367979038284977
12998	0.7225959809229363	-1.2366233709032983
12999	0.7223045109378532	-1.2354016404269021
13000	0.7129669994396837	-1.2906709818498068
13001	0.686982537535992	-1.3244640468269209
13002	0.5822278758312924	-1.3838279306750039
13003	0.8241095662066826	-2.139590403373589
13004	0.8240868769264067	-2.139482192959965
13005	0.826121930834232	-2.1391924683041337
13006	0.8259910311403325	-2.1393320946442937
13007	0.8795290059452585	-2.184396495930787
13008	0.7160178349721696	-1.2577278922184136
13009	0.6600253338269939	-2.137155669067057
13010	0.47696881397276636	-1.4408862345812028
13011	1.0309083932877345	-2.8236512597417422
13012	0.8456120225912527	-2.1537362969610028
13013	0.720239786432744	-1.2584696571505114
13014	0.5708971983273452	-1.399260131921138
13015	0.5709547941926609	-1.399521931308937
13016	0.7247479718906453	-1.2450602925074388
13017	0.724864908950529	-1.2454372836258696
13018	0.7810924361327783	-1.1681785389570887
13019	0.8188508891704236	-2.1663899340379618
13020	0.718979658712804	-1.2589705666458337
13021	0.7224493732657689	-1.2228073445445111
13022	0.722391777400453	-1.2237079344385402
13023	0.7190756518216638	-1.24965574442794
13024	0.7190669251754038	-1.2495108821000245
13025	0.7216639751023713	-1.2495894219163641
13026	0.8465667176920936	-2.1416272026106657
13027	0.8464846872172498	-2.1415189921970423
13028	0.680212405367506	-1.333723018508751
13029	0.7153005046496	-1.2839863708146684
13030	0.7153005046496	-1.2839863708146684
13031	0.7148868616168774	-1.2838868870473048
13032	0.7148868616168774	-1.2838868870473048
13033	0.687595148103442	-1.3273281321294434
13034	0.6872809888380831	-1.327205959081804
13035	0.8467761572023329	-2.1406463275710452
13036	0.8468546970186727	-2.140684724814589
13037	0.7232068461611344	-1.2374960355292954
13038	0.6861185995562549	-1.331831081599589
13039	0.5765398477990428	-1.3947502011339847
13040	0.9756390518648302	-2.8059082425659674
13041	0.561093683918893	-1.4109538379095
13042	0.680861667849248	-1.3296354574005802
13043	0.678083103680073	-1.3442874964710727
13044	0.8505216337771127	-2.1411315291030997
13045	0.8331032478422093	-2.1412275222119592
13046	0.8252492662082348	-2.1406463275710452
13047	0.8251532730993751	-2.1408592577397885
13048	0.7240358775558317	-1.2250902352061197
13049	0.7237583702047645	-1.2244060661393381
13050	0.6744824894332087	-1.3461288188319265
13051	0.8238390401726234	-2.146309920993767
13052	0.8237954069413236	-2.1461737853121114
13053	0.8237954069413236	-2.1473361745939394
13054	0.8239175799889632	-2.1474443850075633
13055	0.7197214236449017	-1.266527842306969
13056	0.7184351159861818	-1.2665767115260251
13057	0.8065375912976036	-2.1630650818129125
13058	0.7241074360551635	-1.2228946110071108
13059	0.7138396640656808	-1.2831084702009152
13060	0.5710577686185286	-2.0453810210094385
13061	0.4819063504266583	-1.4415459690384564
13062	0.7218332720398147	-1.2478371113473619
13063	0.9759305218499132	-2.802998778702893
13064	0.7135481940805977	-1.2833981948567463
13065	0.8480694461780607	-2.14536744319769
13066	0.7130752098533073	-1.2876829781703925
13067	0.7132061095472069	-1.2875503331472407
13068	0.7128011931607441	-1.287454340038381
13069	0.7128570436968079	-1.2874037254900732
13070	0.7286959066586565	-1.2679869375616364
13071	0.7203410155293597	-1.2615588899265413
13072	0.7200652535075446	-1.2611085949795269
13073	0.6143558967020041	-1.3220869083857045
13074	0.7190756518216638	-1.2906709818498068
13075	0.7175188181288847	-1.262579907538958
13076	0.8345588524383726	-2.1412275222119592
13077	0.7702719765468301	-2.1665353781422887
13078	0.7238177113993324	-1.2301656526709193
13079	0.7243989060402465	-1.2310976584914841
13080	0.9226979796640863	-2.2427480888127134
13081	0.7118028648286033	-1.2903795118647237
13082	0.7117155983660037	-1.2904667783273234
13083	0.7125830270042449	-1.285434994093824
13084	0.6903353150290732	-1.3240067705628984
13085	0.7134330023499661	-1.2901770536714923
13086	0.6243042734383717	-1.3185386540164001
13087	0.7158677366564982	-1.271161691471014
13088	0.7160614682034695	-1.2725579548726096
13089	0.7169376234879707	-1.2711232942274702
13090	0.7243168755654028	-1.2661264165790105
13091	0.7128221371117681	-1.290351586596692
13092	0.5721538353887811	-1.395565269894666
13093	0.5628686837681712	-1.40789951171851
13094	0.7167770531967873	-1.259459258836392
13095	0.5721398727547651	-1.3941044293107467
13096	0.5723720015452803	-1.3947798717312685
13097	0.5726739435058754	-1.3947275118537088
13098	0.7268720375903225	-1.2443324902093573
13099	0.6687752627791872	-1.3334524924746918
13100	0.6687752627791872	-1.3334524924746918
13101	0.6763447557450866	-1.3351559338246382
13102	0.674985144257783	-1.3309444543395756
13103	1.0733774899765127	-2.898119222936584
13104	0.5739515245183352	-1.3935581412548723
13105	0.5745327191592494	-1.3934412041949888
13106	0.5722271392173649	-1.3947798717312685
13107	0.6778562108773136	-1.3343618090149807
13108	0.5928796202562138	-1.360445754686036
13109	0.5928796202562138	-1.360445754686036
13110	0.5928796202562138	-1.360445754686036
13111	0.7174175890322692	-1.2646079801297754
13112	0.5125106988603789	-1.6545145350253085
13113	0.5125106988603789	-1.6545145350253085
13114	0.5125106988603789	-1.6545145350253085
13115	0.5149995383737228	-1.6558758918418643
13116	0.5149995383737228	-1.6558758918418643
13117	0.5149995383737228	-1.6558758918418643
13118	0.6872530635700511	-1.3284573601554839
13119	0.6737634137813869	-1.328448633509224
13120	0.6871448531564275	-1.328719159543283
13121	0.7136738577867414	-1.2873059870519616
13122	0.8472840480146633	-2.139185486987126
13123	0.8299040593233037	-2.1391924683041337
13124	0.7134905982152819	-1.2871070195172343
13125	0.8064677781275238	-2.1538096007895864
13126	0.7143056669759632	-1.2813771035829369
13127	0.7143056669759632	-1.2813771035829369
13128	0.7120943348136864	-1.2895068472387266
13129	0.5677852762710394	-1.403855583841639
13130	0.713171202962167	-1.2883444579568981
13131	0.8444478879801725	-2.1453011206861143
13132	0.8444478879801725	-2.1453011206861143
13133	0.5302956039382011	-1.4217225193943048
13134	0.5302956039382011	-1.4217225193943048
13135	0.5302956039382011	-1.4217225193943048
13136	0.9066985464110543	-3.0694529596171116
13137	0.7298390973187128	-1.245960882401468
13138	0.5919772850329327	-1.3620933454999185
13139	0.42862319369252344	-1.4405371687308037
13140	0.9576045647039728	-2.8518679977587347
13141	0.9576045647039728	-2.8518679977587347
13142	0.5580986989224708	-1.4145317628760883
13143	0.5581562947877866	-1.414676625204004
13144	0.5292134998019646	-1.4253231336411694
13145	0.5292134998019646	-1.425118930118686
13146	0.6717021799347818	-1.3328119566392098
13147	0.6717021799347818	-1.3328119566392098
13148	0.6725329566587309	-1.3333146114637842
13149	0.6723880943308155	-1.3337806143740667
13150	0.724835238353245	-1.2461074900586353
13151	0.5690349320154672	-1.4035937844538398
13152	0.5416629333564402	-1.4212792057642984
13153	0.7168887542689149	-1.2633129458247954
13154	0.48192903970693424	-1.4420782944603148
13155	0.5575157589523047	-1.4134548947276078
13156	0.5704311954170628	-1.3963209974607793
13157	0.5716529258934588	-1.3964379345206632
13158	0.8496838757361554	-2.1493729738310168
13159	0.8496838757361554	-2.1493729738310168
13160	0.5722358658636248	-1.3981256679073417
13161	0.5519900465404907	-1.4170031490969122
13162	0.97447491725375	-2.8061979672217987
13163	0.880897344078822	-2.2015007226003314
13164	0.6770777940309243	-1.3445527865173756
13165	0.8418019688341489	-2.1560052249885953
13166	0.9040805525330626	-3.0790522705030803
13167	0.3671003375597233	-2.739002791020017
13168	0.8395033702092726	-2.1461737853121114
13169	0.8395033702092726	-2.1461737853121114
13170	0.9026266932661515	-3.103195410045918
13171	0.9032078879070655	-3.102322745419921
13172	0.7219554450874545	-1.2305443891186019
13173	0.8480415209100287	-2.1506819707700124
13174	0.8479385464841611	-2.1508268330979283
13175	0.7196568464625779	-1.265363707695889
13176	0.7196865170598618	-1.2647615691039509
13177	0.6801635361484503	-1.3307646854266206
13178	0.6774792197588829	-1.3328067206514538
13179	0.6778649375235737	-1.3323407177411715
13180	0.6770428874458844	-1.3340127431645818
13181	0.6722711572709319	-1.3348574825225472
13182	0.428448660767324	-1.4279707981164447
13183	0.428448660767324	-1.4279707981164447
13184	0.7277726274843516	-1.2434598255833602
13185	0.5606573516058945	-1.4160728886055993
13186	0.5607166928004622	-1.4161025592028833
13187	0.8461932172321668	-2.1459835444236437
13188	0.8461932172321668	-2.1458823153270283
13189	0.9049532171590599	3.1087228677869843
13190	1.0245658667859872	-2.7445302487610834
13191	0.7247776424879292	-1.231795790192282
13192	0.5823936821102318	-1.383208338790546
13193	0.31968672310004537	-1.144644519323197
13194	0.8495966092735557	-2.1417720649385816
13195	0.8491026810952413	-2.1418104621821255
13196	0.5585053606381855	-1.412465293041727
13197	0.5646140130201657	-1.410342972671302
13198	0.7266102382025234	-1.2265004612417314
13199	0.4838838084691679	-1.4418112590847598
13200	0.7189587147617802	-1.252041609515416
13201	0.7179708584051513	-1.2500344808756227
13202	0.7182029871956666	-1.2502369390688541
13203	0.8342673824532895	-2.140065132930131
13204	0.8486890380625187	-2.148660879496203
13205	0.567261677495441	-1.4099939068209029
13206	0.655952904723438	-2.132792345937071
13207	0.657116463375865	-2.1330820705929017
13208	0.5562364326105929	-1.4149960204571188
13209	0.5466074511273401	-1.4190399483339897
13210	0.7193950470747787	-1.2586529167219707
13211	0.718979658712804	-1.2584487131994875
13212	0.7193950470747787	-1.2581205913001123
13213	0.7195207107809223	-1.258242764347752
13214	0.5467540587845077	-1.4192720771245049
13215	0.7214021757145722	-1.25460026219884
13216	0.5565558278637078	-1.4154323527701174
13217	0.5565558278637078	-1.4154323527701174
13218	0.5567024355208753	-1.4153747569048016
13219	0.7160440149109496	-1.2633513430683394
13220	0.4743804906920588	-1.4398093664327223
13221	0.5464922593967084	-1.419882942362703
13222	0.9043720225181457	-3.075851336654923
13223	0.5562364326105929	-1.414589358741404
13224	0.7149880907134931	-1.2827297337532326
13225	0.7149880907134931	-1.2827297337532326
13226	0.7174036263982532	-1.261989986251784
13227	0.5577496330720719	-1.4147638916666037
13228	0.5575157589523047	-1.4149960204571188
13229	0.43287132509187765	-1.4113604996252145
13230	0.43353978619539146	-1.40970243683582
13231	0.43353978619539146	-1.40970243683582
13232	0.7160440149109496	-1.2824330277803935
13233	0.7160440149109496	-1.2824330277803935
13234	0.6779434773399134	-1.332152222181956
13235	0.7227111726535679	-1.2275476587929277
13236	0.47894801734452797	-1.443212758474111
13237	0.846130385379095	-2.14359069801916
13238	0.6812753108819706	-1.331124223252531
13239	0.6819699519242642	-1.3317420698077373
13240	0.6819699519242642	-1.3317420698077373
13241	0.682069435691628	-1.3318991494404169
13242	1.0343990517917234	-2.362594612559408
13243	0.7653565475967974	-1.2168732250877305
13244	0.7657928799097959	-1.217018087415646
13245	0.6850417314077744	-1.3341000096271816
13246	0.720239786432744	-1.2624542438328143
13247	0.6762574892824869	-1.3384057368918516
13248	0.562345084992573	-1.410051502686219
13249	0.5449790589352295	-1.4212792057642984
13250	0.7125882629920008	-1.2904091824620076
13251	0.7123264636042017	-1.2904091824620076
13252	0.42713966382832824	-1.4277089987286453
13253	0.5263040359388901	-1.4256721994915682
13254	0.5263040359388901	-1.4256721994915682
13255	0.5263040359388901	-1.4256721994915682
13256	0.7126039709552688	-1.286826021507663
13257	0.7104938678896077	-1.2913691135506042
13258	0.7110419012747339	-1.2910113210539456
13259	0.7417649320975901	-1.2359845803970684
13260	0.6643886569569797	-2.133665010563068
13261	0.6646795509834097	-2.133665010563068
13262	0.8395033702092726	-2.1412275222119592
13263	0.8395033702092726	-2.1412275222119592
13264	0.8397948401943556	-2.1415189921970423
13265	0.8397948401943556	-2.1409377975561283
13266	0.6741718208263537	-1.3288203886398988
13267	0.6692761722745095	-1.3473365866743068
13268	0.8508480103472357	-2.144428456060117
13269	0.8508270663962118	-2.144412748096849
13270	0.8508480103472357	-2.1438455160899506
13271	0.8512354734411783	-2.144128259428774
13272	0.714071792856196	-1.2852604611686242
13273	0.714071792856196	-1.2852604611686242
13274	0.7142707603909234	-1.2855432045074473
13275	0.7160736855082335	-1.266590674160041
13276	0.5305277327287163	-1.4206770671723603
13277	0.5305277327287163	-1.4206770671723603
13278	0.5305277327287163	-1.4206770671723603
13279	0.5304631555463926	-1.4212792057642984
13280	0.5304631555463926	-1.4212792057642984
13281	0.5304631555463926	-1.4212792057642984
13282	0.807031519475918	-2.1627299785965293
13283	0.5596398246519817	-1.4134845653248918
13284	0.554025100448316	-1.4175564184697944
13285	0.5535224456237416	-1.417046782328212
13286	0.7189011188964644	-1.223418209782709
13287	0.449684081776339	-1.39864926668294
13288	0.449684081776339	-1.39864926668294
13289	0.449684081776339	-1.39864926668294
13290	0.6052505139943496	-1.3371630624644315
13291	0.723322037891766	-1.2365361044406984
13292	0.7234389749516497	-1.235810047471869
13293	0.47484649360234127	-1.4400711658205214
13294	0.5302606973531612	-1.4214834092867816
13295	0.5302606973531612	-1.4214834092867816
13296	0.5302606973531612	-1.4214834092867816
13297	0.6596524267790128	-2.1382255558985293
13298	0.6596524267790128	-2.1382255558985293
13299	0.7185956862773654	-1.276074793315378
13300	0.7117749395605715	-1.2904388530592914
13301	0.7117452689632876	-1.2905261195218911
13302	0.6854780637207729	-1.3322394886445557
13303	0.52755543701257	-1.536500606993208
13304	0.5276706287432016	-1.5364709363959241
13305	0.5352924815866609	-1.5364709363959241
13306	0.7253291665315595	-1.2243484702740224
13307	0.7251843042036439	-1.2221092128437134
13308	0.7169760207315147	-1.2555759012507046
13309	0.7170388525845864	-1.2540190675579257
13310	0.7168939902566709	-1.2536700017075268
13311	0.7183635574868501	-1.2535774992571713
13312	0.6655522156094068	-2.130174352059079
13313	0.6646795509834097	-2.1272648881960046
13314	0.6655522156094068	-2.130174352059079
13315	0.5573708966243891	-1.4159559515457156
13316	1.0250894655615856	-2.739002791020017
13317	0.606027185511487	-1.338559325866027
13318	0.6059207204271154	-1.339240004274305
13319	0.5759673798043887	-1.394600102818313
13320	0.5670278033756738	-1.4045240449451528
13321	0.567289602763473	-1.405630583690917
13322	0.5180102313334131	-1.657743394141498
13323	0.5180102313334131	-1.657743394141498
13324	0.5180102313334131	-1.657743394141498
13325	0.4310963252425994	-1.4166837538437973
13326	0.4310963252425994	-1.4166837538437973
13327	0.7267551005304388	-1.2436919543738754
13328	0.7274532322312366	-1.2428786309424458
13329	0.6816872085854413	-1.3340808110054097
13330	0.7198750126190773	-1.2565794655706015
13331	0.657116463375865	-2.1330820705929017
13332	0.7190756518216638	-1.2621872084572592
13333	0.4817894133667747	-1.443802679761285
13334	0.48185573587835046	-1.4432825716441908
13335	0.7216639751023713	-1.229060859254407
13336	0.7216936456996553	-1.2267046647642144
13337	0.721170046924057	-1.2285948563441242
13338	0.8400845648501866	-2.140354857585962
13339	0.5947733024946277	-1.3594369543783833
13340	0.721766949528239	-1.256108226672563
13341	0.55281209661818	-1.417125322144552
13342	0.5526637436317604	-1.418333089986932
13343	0.553115783908027	-1.4169804598166362
13344	0.5526236010589646	-1.4173906121908548
13345	0.8918056519037866	-2.225352392158086
13346	0.7209379181335417	-1.2234758056480248
13347	0.7209379181335417	-1.2234758056480248
13348	0.7207982917933822	-1.254891732183923
13349	0.5698500007761486	-2.044072024070443
13350	0.5700629309448919	-2.0442256130446186
13351	0.7282962262599497	-1.2454669542231536
13352	0.8418298941021809	-2.1490815038459337
13353	0.842412834072347	-2.1476276445790226
13354	0.4302236606166022	-1.4384427736284107
13355	0.7196568464625779	-1.2726364946889495
13356	0.721135140339017	-1.2580979020198364
13357	0.4770281551673342	-1.4413225668942011
13358	0.549721118512898	-1.4187781489461906
13359	0.7472330486440882	-1.2368851702910975
13360	0.6062889848992862	-1.3383271970755117
13361	0.6061755384979065	-1.3383760662945678
13362	0.6061755384979065	-1.3383760662945678
13363	0.7212276427893728	-1.2597262942119474
13364	0.8223415476744123	-2.1415189921970423
13365	0.4311835917051991	-1.4191848106619052
13366	0.4311835917051991	-1.4191848106619052
13367	0.721147357643781	-1.2564328579134338
13368	0.7243413101749306	-1.2329581794741102
13369	0.7246310348307617	-1.2325218471611117
13370	0.8383392355981922	-2.1409377975561283
13371	0.8380495109423612	-2.1406463275710452
13372	0.5735797693876605	-1.395544325943642
13373	0.5683088750466376	-1.399521931308937
13374	0.7234686455489335	-1.2365657750379824
13375	0.7235559120115331	-1.2358973139344687
13376	0.7247479718906453	-1.2338308441001073
13377	0.7163040689694968	-1.262236077676315
13378	0.7206953173675145	-1.2571257536264757
13379	1.017235483927611	-2.380337629735182
13380	0.570949558204905	-2.0457492854816097
13381	0.570949558204905	-2.0457492854816097
13382	0.5710280980212448	-1.392772743091475
13383	0.5547232321491138	-1.416514456906354
13384	1.0178184238977772	-2.3756845819493657
13385	0.6844221395233164	-1.3333495180488242
13386	0.5477419151411363	-1.4195635471095878
13387	0.5783288102823371	-1.3830128619143225
13388	0.7139932530398563	-1.2812025706577375
13389	0.7141311340507638	-1.280780200978755
13390	0.42905952600552205	-1.4285223221600747
13391	0.4297297324382878	-1.429075591532957
13392	0.5541210935571756	-1.4166052140274574
13393	0.7237583702047645	-1.233336915921793
13394	0.7170981937791542	-1.2811362481461617
13395	0.5738345874584517	-1.3940817400304708
13396	1.022181747027763	-2.764893005144101
13397	0.7142759963786793	-1.2839863708146684
13398	0.7142759963786793	-1.2839863708146684
13399	0.6574073399490025	-2.1330820705929017
13400	0.6591526692009968	-2.1330820705929017
13401	0.6597344572538565	-2.133954735218899
13402	0.6597344572538565	-2.135118869829979
13403	0.6596384641449968	-2.1342904201535218
13404	0.6597344572538565	-2.135118869829979
13405	0.5597846869798974	-1.4138912270406065
13406	0.848294593651568	-2.1434964502395517
13407	0.556206762013309	-1.413716694115407
13408	0.556206762013309	-1.413716694115407
13409	0.6738663882072546	-1.3261500348843474
13410	1.1053746111533247	-2.9466969720073424
13411	0.8304852539642178	-2.138609528333968
13412	0.7225610743378965	-1.2581432805803883
13413	0.723627470510865	-1.2578361026320375
13414	0.7118622060231713	-1.2900897872088928
13415	0.9008813640141571	-3.1171580440618727
13416	0.7151399343584165	-1.275778087342539
13417	0.7151399343584165	-1.275778087342539
13418	0.7156513158292509	-1.275748416745255
13419	0.7156513158292509	-1.275748416745255
13420	0.7159689657531139	-1.2765250882623926
13421	0.7182029871956666	-1.2484916098168597
13422	0.7195416547319463	-1.2214390064109477
13423	0.4863359960682199	-1.4408268933866348
13424	0.4863359960682199	-1.4408338747036429
13425	0.5493999779305311	-1.4194466100497043
13426	0.5486739209617014	-1.4190975441993054
13427	0.5483824509766184	-1.4192144812591891
13428	0.6894713770493359	-1.325031278833819
13429	0.6894713770493359	-1.325031278833819
13430	0.8374665709721951	-2.140065132930131
13431	0.8374665709721951	-2.140354857585962
13432	0.5465201846647404	-1.4198550170946709
13433	0.6872094303387514	-1.326232065359191
13434	0.5743232796490101	-1.3954396061885221
13435	0.7184996931685057	-1.261031800492439
13436	0.717766654882668	-1.2602149864025056
13437	0.9610952232079614	-2.858557844781629
13438	0.657116463375865	-2.134827399844896
13439	0.6573782627636642	-2.1349443369047796
13440	0.5292414250699965	-1.421366472226898
13441	0.7164227513586324	-1.26320299008192
13442	0.8505513043743965	-2.144835117775832
13443	0.8505565403621526	-2.144718180715948
13444	0.5639455519166519	-1.4085976434193075
13445	0.564207351304451	-1.4077249787933104
13446	0.564788545945365	-1.4080443740464252
13447	0.5667660039878747	-1.4057754460188328
13448	0.7144941625351786	-1.285578111092487
13449	0.5112942043717389	-1.569108593408218
13450	0.4831944034146301	-1.4439981566375086
13451	0.4806514586944744	-1.4442198134525117
13452	0.7271617622461535	-1.2456990830136687
13453	0.7270744957835538	-1.24535001716327
13454	0.8339759124682065	-2.1467549799530254
13455	0.8515251980970094	-2.146812575818341
13456	0.8241881060230222	-2.145363952539186
13457	0.8240868769264067	-2.1453011206861143
13458	0.8485214864543272	-2.1421001868379563
13459	0.8486174795631869	-2.142342787603984
13460	0.8466819094227251	-2.145931184546084
13461	0.8467761572023329	-2.1458823153270283
13462	0.8479385464841611	-2.1435557914341197
13463	0.848003123666485	-2.1436133872994354
13464	0.5824250980367678	-1.3834142876422815
13465	0.5664466087347596	-1.4037386467817552
13466	0.723322037891766	-1.2378747719769783
13467	0.7237007743394488	-1.2380789754994617
13468	0.7145151064862025	-1.2858713264068222
13469	0.5294456285924799	-1.5236724369910497
13470	0.6696531633929403	-1.3437289911104342
13471	0.6640977803838424	-2.1365727290968906
13472	0.6643886569569797	-2.1365727290968906
13473	0.6972590361717347	-1.3113234628886556
13474	0.8256419652899335	-2.1441509487090498
13475	0.8255407361933178	-2.1441369860750337
13476	0.8246384009700368	-2.1454547096602896
13477	0.8246680715673207	-2.145590845341945
13478	0.8241357461454624	-2.145615279951473
13479	0.8240868769264067	-2.145590845341945
13480	0.7109302002026062	-1.29096245183489
13481	0.557400567221673	-1.4150553616516865
13482	0.842412834072347	-2.1653724070840488
13483	0.7170545605478544	-1.278279144160647
13484	0.5673489439580408	-1.4025762574999272
13485	0.48332530310852967	-1.4436874880306536
13486	0.4826481153587559	-1.4409822276900623
13487	0.6635159923309826	-2.1357000644708934
13488	0.8240868769264067	-2.1418104621821255
13489	0.8242090499740462	-2.1417947542188576
13490	1.017235483927611	-2.366374995719228
13491	0.5715953300281429	-1.3985899254883722
13492	0.7184682772419697	-1.2603458860964054
13493	0.71903725457812	-1.26010503065963
13494	0.6739152574263104	-1.3347841786939636
13495	0.6744824894332087	-1.3349534756314068
13496	0.8068273159534347	-2.1636410404660706
13497	0.6798057436517914	-2.159844949342983
13498	0.6033027265491239	-2.1060312125162417
13499	0.6582800045749996	-2.135118869829979
13500	0.6582800045749996	-2.135118869829979
13501	0.6582800045749996	-2.134537675189065
13502	0.6603162278534239	-2.1365727290968906
13503	0.6603162278534239	-2.1362830044410597
13504	0.6599438967640958	-2.1383983434944764
13505	0.6598129970701962	-2.140450850694822
13506	0.6600974857382713	-2.1383110770318767
13507	0.6600974857382713	-2.1383110770318767
13508	0.6597554012048805	-2.1383564555924286
13509	0.6597554012048805	-2.1383564555924286
13510	0.6867870606597687	-2.161298808609894
13511	0.6600253338269939	-2.1368641990819737
13512	0.6981317007977318	-2.1653724070840488
13513	0.6600451258607115	-2.137970737827738
13514	0.8493941510803243	-2.1470464499381086
13515	0.8495006161646961	-2.1468631903666493
13516	0.8070699167194619	-2.1615606079976932
13517	0.7258527653071577	-1.2262107365859
13518	0.8505338510818766	-2.14719654825378
13519	0.8505565403621526	-2.1473361745939394
13520	0.8397948401943556	-2.1418104621821255
13521	0.8397948401943556	-2.1421001868379563
13522	0.6592405290755422	-2.1386479255775117
13523	0.6595162910973573	-2.1395764407395728
13524	0.5701257627979637	-2.0459831596013767
13525	0.5701257627979637	-2.0459831596013767
13526	0.7175484887261687	-1.2761638051072297
13527	0.8418298941021809	-2.144428456060117
13528	0.8418298941021809	-2.144428456060117
13529	0.6689550316921425	-1.334944748985147
13530	0.5976391331264023	-1.3606290142574953
13531	0.6225013483210615	-2.117084382669122
13532	0.6393717008708387	-2.128429022807085
13533	1.0195637531497714	-2.355613295551431
13534	0.6632251157578453	-2.1473361745939394
13535	0.6614797865058508	-2.1362830044410597
13536	0.6643886569569797	-2.1263922235700075
13537	0.6134832320760069	-2.107776541768236
13538	0.6626433277049854	-2.1368641990819737
13539	0.6623524511318482	-2.1368641990819737
13540	0.6335545184739416	-2.127847828166171
13541	0.8403760348352697	-2.1423916568230394
13542	0.8403760348352697	-2.1423916568230394
13543	0.8403760348352697	-2.1421001868379563
13544	0.8403760348352697	-2.1421001868379563
13545	0.8406675048203527	-2.1426831268081226
13546	0.8406675048203527	-2.1421001868379563
13547	0.8406675048203527	-2.1421001868379563
13548	0.8406675048203527	-2.1415189921970423
13549	0.46175652421238383	-1.431489381888465
13550	0.46175652421238383	-1.4314963632054731
13551	0.7251843042036439	-1.2214390064109477
13552	0.725446103591443	-1.220391808859751
13553	0.7251267083383282	-1.2214686770082315
13554	0.7222748403405693	-1.2482018851610286
13555	0.7180860501357831	-1.2735318485952225
13556	0.6849771542254505	-1.3316286234063577
13557	0.6852459349302576	-1.331220216361391
13558	0.685469337074513	-1.3303981662837017
13559	0.6846350696920597	-1.3322325073275476
13560	0.6764232955614263	-1.3339464206530063
13561	0.6763098491600467	-1.334225673333325
13562	0.6763098491600467	-1.334225673333325
13563	0.6762854145505188	-1.3326164797629865
13564	0.675011324196563	-1.3258620555577685
13565	0.9657482709937784	-2.801544919435982
13566	0.8554731328650207	-2.156965156077192
13567	0.8352185868956264	-2.1393757278755934
13568	0.8374665709721951	-2.138900998319051
13569	0.9945462036516848	-2.7730367114339063
13570	0.4854633314422228	-1.6969836317140867
13571	0.715003798676761	-1.2758356832078548
13572	0.4827929776866714	-1.4416279995133001
13573	0.48264462470025193	-1.4414639385636128
13574	0.4827877416989155	-1.4416419621473162
13575	0.5624026808578888	-1.4077249787933104
13576	0.8383392355981922	-2.1421001868379563
13577	0.8397948401943556	-2.1421001868379563
13578	0.8307994132295768	-2.1408505310935286
13579	0.8301955293083867	-2.140065132930131
13580	0.8301955293083867	-2.140065132930131
13581	0.8304852539642178	-2.1391924683041337
13582	0.5610657586508612	-1.416160155068199
13583	0.7516557129686419	-1.233947781159991
13584	0.669443723882701	-1.3436713952451185
13585	0.6588617926278594	-2.135410339815062
13586	0.8336861878123755	-2.1365744744261423
13587	0.8755740898602393	-2.161590278594977
13588	1.0210176124166828	-2.76838366364809
13589	0.8345588524383726	-2.1432643214490366
13590	0.8521081380671756	-2.1434091837769524
13591	0.7024950239277177	-2.170608394840032
13592	0.31567246582045844	-1.1733272602504718
13593	0.6724456901961313	-1.3489353082691335
13594	0.6723304984654996	-1.3487328500759022
13595	0.5707226654021458	-2.0461070779782684
13596	0.5115560037595379	-1.568208003514189
13597	0.8823512033457332	-2.226254727381367
13598	0.723322037891766	-1.2365361044406984
13599	0.8363041816903669	-2.1752614426258488
13600	0.8069913769031222	-2.1555392220783127
13601	0.7210531098641734	-1.2516401837874576
13602	0.7203410155293597	-1.2516925436650175
13603	0.5818840459686495	-1.3837197202613805
13604	0.5557617030540504	-1.414894791360503
13605	0.5560915702826773	-1.414676625204004
13606	0.8500853014641141	-2.143773957590619
13607	0.6608979984529911	-2.1368641990819737
13608	0.6608979984529911	-2.137155669067057
13609	0.8431109657731448	-2.156122162048479
13610	0.7198610499850612	-1.2573927890020309
13611	0.8499753457212386	-2.1435557914341197
13612	0.6058334539645157	-1.3383132344414959
13613	0.6724753607934152	-1.3307123255490607
13614	0.7192292407958392	-1.2760311600840781
13615	0.7211124510587411	-1.2626793913063217
13616	0.720850651670942	-1.2562007291229187
13617	0.7172727267043536	-1.2612325133564184
13618	0.7169515861219866	-1.2606513187155044
13619	0.5607742886657782	-1.4116519696102976
13620	0.5802207471914989	-1.3824019966761245
13621	0.5735064655590767	-1.3944517498318934
13622	0.48120123740885257	-1.4424064163596897
13623	0.4808958047897536	-1.4431830878768273
13624	0.5931449103025168	-1.360149048713197
13625	0.5931449103025168	-1.360149048713197
13626	0.5931449103025168	-1.360149048713197
13627	0.5933892563977962	-1.36047542528332
13628	0.5933892563977962	-1.36047542528332
13629	0.5933892563977962	-1.36047542528332
13630	0.5935201560916957	-1.3605277851608797
13631	0.5935201560916957	-1.3605277851608797
13632	0.5935201560916957	-1.3605277851608797
13633	0.5935376093842156	-1.3603305629554043
13634	0.5935376093842156	-1.3603305629554043
13635	0.5935376093842156	-1.3603305629554043
13636	0.5718798186962181	-1.3940520694331868
13637	0.5233369762104997	-1.4247122684029712
13638	0.5233369762104997	-1.4247122684029712
13639	0.5233369762104997	-1.4247122684029712
13640	0.6899146906793425	-1.3261831961401354
13641	0.6620615571054181	-2.1368641990819737
13642	0.7216936456996553	-2.1674074609918743
13643	0.5727507379929632	-1.3946838786224087
13644	0.8304852539642178	-2.1368641990819737
13645	0.7229450467733353	-1.2386601701403757
13646	0.8301955293083867	-2.138028333693054
13647	0.8304852539642178	-2.1374471390521395
13648	0.8304852539642178	-2.138609528333968
13649	0.8301955293083867	-2.138609528333968
13650	0.6606071218798537	-2.1374453937228877
13651	0.7118028648286033	-1.2895068472387266
13652	0.6594435632274267	-2.135410339815062
13653	0.7158520286932303	-1.2691371095387007
13654	0.716855593013127	-1.269007955174053
13655	0.714707092703922	-1.2645434029474516
13656	0.6858410922051877	-1.3311329498987912
13657	0.7231771755638505	-1.2353440445615864
13658	0.7271687435631614	-1.2676116917724576
13659	0.7180947767820429	-1.262867886865537
13660	0.7141747672820636	-1.2828257268620922
13661	0.7166182282348557	-1.2571606602115155
13662	0.6892008510152768	-1.3264065982843907
13663	0.6643886569569797	-2.129882882073996
13664	0.8457568849191682	-2.1429152555986377
13665	0.7243692354429626	-1.244973026044839
13666	0.7244285766375305	-1.245322091895238
13667	0.7242540437123309	-1.245292421297954
13668	0.4858473038776615	-1.4411742139077817
13669	0.5519516492969467	-1.4174988226044787
13670	0.5524019442439613	-1.41898758845643
13671	0.5723894548378003	-1.395797398685181
13672	0.572817060504539	-1.3956525363572656
13673	0.7181244473793268	-1.2689416326624772
13674	0.7195556173659622	-1.2689416326624772
13675	0.7289664326927157	-1.2313297872819995
13676	1.0193595496272883	-2.354187361552551
13677	1.0193595496272883	-2.354187361552551
13678	0.6691592352146261	-1.320137375611227
13679	0.673115896628897	-2.152863632335005
13680	0.5820899948203848	-1.3837022669688603
13681	0.5692688061352346	-1.4030125898129258
13682	0.5683368003146695	-1.4030998562755255
13683	0.5671150698382734	-1.4066184400475459
13684	0.5704032701490308	-2.045059880427072
13685	0.5710141353872289	-2.0452344133522713
13686	0.6600259272389396	-2.137736863707971
13687	0.659917716825316	-2.1380667309365977
13688	0.845809244796728	-2.145896277961044
13689	0.8459034925763358	-2.1458823153270283
13690	0.655952904723438	-2.133665010563068
13691	0.807350914729033	-2.164112279364109
13692	0.8072636482664333	-2.164047702181785
13693	0.807310772156237	-2.1636497671123305
13694	0.6686059658417438	-1.3343914796122647
13695	0.6807482214478683	-1.3330824826732688
13696	0.6807482214478683	-1.3330824826732688
13697	0.7201961532014441	-1.2490745497870257
13698	0.6807255321675924	-1.3325379399466466
13699	0.6807255321675924	-1.3325379399466466
13700	0.7205591816858589	-1.2502369390688541
13701	0.7199483164476609	-1.2490745497870257
13702	0.8514292049881497	-2.156354290838994
13703	0.5503895796164118	-1.4184587536930755
13704	0.4765045563917359	-1.4407117016560032
13705	0.7174088623860092	-1.280466041713396
13706	0.5591284431811474	-1.411802067925969
13707	0.5591458964736674	-1.411243562565331
13708	0.5591458964736674	-1.411243562565331
13709	0.5599592199050968	-1.415170553382318
13710	0.5600185610996645	-1.4154044275020854
13711	0.7198837392653371	-1.2621784818109991
13712	0.720536492405583	-1.2627073165743536
13713	0.905825881785057	3.1049407392979123
13714	0.5603082857554955	-1.4157814186205162
13715	0.8680970993446957	-2.1624332726236903
13716	0.8604473212332044	-2.1470464499381086
13717	1.0019359277046287	-2.367132468614593
13718	0.8749911498900732	-2.187770217374892
13719	0.6050410744841103	-1.3378908647625134
13720	0.6054931147603768	-1.3378332688971974
13721	0.7178835919425517	-1.2553280644969216
13722	0.8464846872172498	-2.1418104621821255
13723	0.8466679467887093	-2.142051317618901
13724	0.6744528188359248	-1.3337858503618225
13725	0.6738227549759548	-1.3325239773126307
13726	0.6744615454821847	-1.334269306564625
13727	0.6744615454821847	-1.334269306564625
13728	0.6120293728090955	-1.3281955607676847
13729	0.7661995416255106	-1.216349626312132
13730	0.716550160394028	-1.2814346994482526
13731	0.7161574613123293	-1.2811676640726977
13732	0.7161574613123293	-1.2811676640726977
13733	0.6713618407306428	-1.3377599650686136
13734	0.664249624028766	-2.1258110289290935
13735	0.7136075352751655	-1.2653933782931728
13736	0.7155553227203912	-1.2831084702009152
13737	0.7155797573299191	-1.2831171968471753
13738	0.5729915934297384	-1.3951289375816673
13739	0.7160789214959895	-1.2781709337470233
13740	0.5720543516214174	-1.394881100827884
13741	0.5721573260472852	-1.3947065679026847
13742	0.6576982339754323	-2.1357000644708934
13743	0.6574073399490025	-2.134246205203982
13744	0.8482788856883	-2.1406236382907693
13745	0.8485214864543272	-2.1406463275710452
13746	0.5304055596810767	-1.4217748792718647
13747	0.5304055596810767	-1.4217748792718647
13748	0.9887290212547877	-2.690425041949259
13749	0.7192676380393831	-1.265035585796514
13750	0.7187353126175249	-1.264461372472608
13751	0.8437707002303986	-2.1387910425761754
13752	0.8296125893382206	-2.138028333693054
13753	0.826413400819315	-2.138609528333968
13754	0.844617184917616	-2.1394245970946493
13755	1.037598240310629	-2.362011672589242
13756	0.5586798935633849	-1.4138615564433226
13757	0.5576902918775041	-1.4148511581292031
13758	0.558650222966101	-1.41400816410049
13759	0.8508392837009756	-2.147816140138238
13760	0.8508480103472357	-2.1476276445790226
13761	0.8511394803323187	-2.1470464499381086
13762	0.5631008125586865	-1.4092085086575055
13763	0.5624026808578888	-1.409964236223619
13764	0.8429940287132611	-2.1441369860750337
13765	0.8432854986983441	-2.1432643214490366
13766	0.8429940287132611	-2.1423916568230394
13767	0.570024533701348	-1.4034489221259243
13768	0.5696754678509491	-1.3966124674458624
13769	0.485091576311548	-1.4411567606152618
13770	0.5751156591294155	-1.3950416711190676
13771	0.5943945660469448	-1.3595905433525586
13772	0.7156809864265348	-1.273640059008846
13773	0.8144526594553979	-2.160740303249256
13774	0.7120367389483707	-1.2898279878210934
13775	0.5717349563683025	-1.394628028086345
13776	0.5717471736730664	-1.3942510369679142
13777	0.5718082601968862	-1.3947100585611887
13778	0.6588617926278594	-2.138609528333968
13779	0.6588617926278594	-2.138609528333968
13780	0.5600464863676964	-1.41400816410049
13781	0.5670278033756738	-1.4023423833801598
13782	0.8248565671265362	-2.1390458606469664
13783	0.7232347714291663	-1.236420912710067
13784	0.7233517084890498	-1.235750706277301
13785	0.724543768368162	-1.2334241823843928
13786	1.016073094645783	-2.379756435094268
13787	0.571267208128768	-1.3936506437052283
13788	0.5542868998361151	-1.416741349709113
13789	1.0163628193016139	-2.3753931119642826
13790	0.8351400470792867	-2.139482192959965
13791	0.5474521904853054	-1.4191568853938732
13792	0.5474521904853054	-1.4191568853938732
13793	0.578053048260522	-1.3836097645185048
13794	0.661188892479421	-2.1362830044410597
13795	0.5608318845310939	-1.4064439071223465
13796	0.4298222348886435	-1.4460262292283261
13797	0.5919668130574207	-1.3615104055297524
13798	0.5919668130574207	-1.3615104055297524
13799	0.5919196891676168	-1.3615610200780606
13800	0.4810424124469211	-1.4445618979859027
13801	0.4296180313661602	-1.4470821534257825
13802	0.7175624513601847	-1.2516925436650175
13803	0.7176217925547526	-1.2514010736799344
13804	0.5617638903516589	-1.409964236223619
13805	0.6890647153336212	-1.3278761655145699
13806	0.6643886569569797	-2.1275563581810877
13807	0.8482300164692442	-2.1473361745939394
13808	0.8484272386747195	-2.1473518825572073
13809	0.8235039369562406	-2.1453011206861143
13810	0.8233939812133648	-2.145344753917414
13811	0.5535311722700016	-1.416168881714459
13812	0.7298390973187128	-2.1700254548698656
13813	0.5305364593749763	-1.4202477161763698
13814	0.5305364593749763	-1.4202477161763698
13815	0.5305364593749763	-1.4202477161763698
13816	0.5305451860212362	-1.4200662019341623
13817	0.5305451860212362	-1.4200662019341623
13818	0.5305451860212362	-1.4200662019341623
13819	0.5304055596810767	-1.422298478047463
13820	0.5304055596810767	-1.422298478047463
13821	0.5304055596810767	-1.422298478047463
13822	0.5305853285940322	-1.4204501743696012
13823	0.5305853285940322	-1.4204501743696012
13824	0.5305853285940322	-1.4204501743696012
13825	0.5305800926062761	-1.4204065411383013
13826	0.5305800926062761	-1.4204065411383013
13827	0.5375038137489377	-1.4227051397631778
13828	0.5244138443589802	-1.4692181643288267
13829	0.5263040359388901	-1.4695969007765095
13830	1.0533062035785778	-3.01447508817929
13831	0.7270465705155219	-1.221294144083032
13832	0.6640977803838424	-2.128429022807085
13833	0.7158415567177182	-1.283457536051314
13834	0.573117257135882	-1.3959492423301048
13835	0.5694433390604339	-1.3961464645355801
13836	0.8456120225912527	-2.1743887779998516
13837	0.7169725300730106	-1.2760311600840781
13838	0.7169725300730106	-1.2760311600840781
13839	0.7164489312974124	-1.275778087342539
13840	0.7164489312974124	-1.275778087342539
13841	0.7168992262444268	-1.273633077691838
13842	0.84764882182833	-2.1423916568230394
13843	0.8475528287194704	-2.142464960651623
13844	0.6058474165985316	-1.3389083917164262
13845	0.665261321582977	-2.1304640767149103
13846	0.5718047695383822	-1.3939508403365712
13847	0.5931728355705488	-1.3605661824044237
13848	0.5931728355705488	-1.3605661824044237
13849	0.5931728355705488	-1.3605661824044237
13850	0.8767364791420675	-2.1842795588709034
13851	0.550621708406927	-1.419533876512304
13852	0.9974556675147593	-2.9749137100243344
13853	0.6835145683122793	-1.331768249746517
13854	0.6832527689244802	-1.3321173155969162
13855	0.6825633638699423	-1.3317787217220292
13856	0.6825633638699423	-1.3317787217220292
13857	0.6679951006035457	-1.3429435929470368
13858	0.569762734313549	-2.0441784891548145
13859	0.7103490055616922	-2.1691527902438685
13860	0.48205993940083386	-1.442601893235913
13861	0.4820651753885898	-1.442607129223669
13862	0.48179814001303467	-1.4444344889505072
13863	0.4817859227082707	-1.4444397249382632
13864	0.48185573587835046	-1.4445793512784226
13865	0.9014625586550712	-3.1104681970389785
13866	0.7238177113993324	-1.2343841134729894
13867	0.6122475389655948	-1.3265322619905342
13868	0.5354966851091442	-1.5360939452774933
13869	0.5298296010279187	-1.4245028288927317
13870	0.5298296010279187	-1.4245028288927317
13871	0.5298296010279187	-1.4245028288927317
13872	0.8469646527615483	-2.1433166813265965
13873	0.5719007626472419	-1.394029380152911
13874	0.8325220532012952	-2.1426831268081226
13875	0.48654019959070327	-1.446005285277302
13876	0.8255407361933178	-2.138900998319051
13877	0.8252492662082348	-2.138900998319051
13878	0.7087782092348972	-1.2923587152364853
13879	0.7087782092348972	-1.2923587152364853
13880	0.8256489466069414	-2.1388957623312947
13881	0.8255407361933178	-2.138609528333968
13882	0.8255407361933178	-2.138900998319051
13883	0.8249595415524038	-2.138900998319051
13884	0.7196568464625779	-1.257679022999358
13885	0.7197161876571456	-1.257684258987114
13886	0.7197161876571456	-1.257684258987114
13887	0.5770634465746411	-1.3950364351313116
13888	0.5771070798059411	-1.3949194980714281
13889	0.6787759993931147	-1.3339027874217064
13890	0.6787759993931147	-1.3339027874217064
13891	0.6784967467127956	-1.3345084166721481
13892	0.6788597751972104	-1.3332011650624045
13893	0.7121240054109703	-1.287848784449332
13894	0.7121240054109703	-1.2879360509119315
13895	0.7121292413987264	-1.2879011443268917
13896	0.7122810850436498	-1.287799915230276
13897	0.7120646642164025	-1.287892417680632
13898	0.5589120223539001	-1.4145020922788043
13899	0.7952098226757436	-2.1631319861009
13900	0.7267254299331549	-1.242936226807762
13901	0.7264933011426397	-1.2429658974050457
13902	0.8513419385255501	-2.1457217450358446
13903	0.8511394803323187	-2.145590845341945
13904	0.6844692634131202	-1.3307838840483923
13905	0.6840154778076017	-1.3310893166674913
13906	0.6840434030756336	-1.3314732891029302
13907	0.6838636341626781	-1.3313580973722985
13908	0.6838636341626781	-1.3313580973722985
13909	0.6795352176177323	-1.3337282544965068
13910	0.6056955729536082	-1.3384266808428755
13911	0.8066772176377631	-2.1601364193280657
13912	0.8235999300651002	-2.145795048864428
13913	0.8482300164692442	-2.1415189921970423
13914	0.8484429466379875	-2.141557389440586
13915	0.5723370949602404	-1.3949456780102079
13916	0.5725604971044959	-1.3950713417163516
13917	0.6600253338269939	-2.135410339815062
13918	0.6603162278534239	-2.1357000644708934
13919	0.8432854986983441	-2.1531551023200883
13920	0.7164576579436722	-2.1671177363360434
13921	0.5302973492674531	-1.4246808524764354
13922	0.5302973492674531	-1.4246808524764354
13923	0.5302973492674531	-1.4246808524764354
13924	0.7195329280856863	-1.2266470688988986
13925	0.7226535767882521	-1.2247551319897367
13926	0.6884154528518794	-1.3270401528028646
13927	0.8498933152463948	-2.150865230341472
13928	0.8474742889031306	-2.1467253093557415
13929	0.8473573518432469	-2.1464635099679423
13930	0.6058561432447916	-1.338566307183035
13931	0.6058561432447916	-1.338566307183035
13932	0.42876980134969095	-1.4277526319599452
13933	0.597731635576758	-1.3605504744411556
13934	0.597731635576758	-1.3605504744411556
13935	0.5441360649065161	-1.4228796726883772
13936	0.54355312493635	-1.4229093432856612
13937	0.7207825838301143	-1.2591014663397333
13938	0.937823002961869	-2.90248254606657
13939	0.9459684545809267	-2.8783394065237324
13940	0.9450957899549294	-2.877756466553566
13941	0.8956453762581741	-3.124720555710764
13942	0.9049532171590599	-3.0729436181211
13943	0.9317143505798889	-2.929535149472482
13944	0.9293878266869805	-2.930699284083562
13945	0.9311331559389748	-2.9286624848464853
13946	0.762330728450256	-2.1675825756934852
13947	0.9416051314509408	-2.9007372168145755
13948	0.9674936002457727	-2.805325302595802
13949	0.9488482478467173	-2.876302607286655
13950	0.9497505830699983	-2.8832839242946324
13951	0.9465496492218407	-2.885029253546627
13952	0.766112275162911	-1.2177458897137277
13953	0.5939128551733944	-1.3603183456506405
13954	1.022471471683594	-2.357358624803425
13955	0.4732163560809785	-1.4393154382544078
13956	0.5567303607889073	-1.4154323527701174
13957	0.3174457203404847	-1.1452553845613953
13958	0.3174457203404847	-1.1452553845613953
13959	0.3187756612305043	-1.1444123905326817
13960	0.8406675048203527	-2.1461737853121114
13961	0.8406675048203527	-2.1461737853121114
13962	0.8409572294761838	-2.1453011206861143
13963	0.6629342217314154	-2.118538241936033
13964	0.48739715625343244	-1.441401106710541
13965	0.5701118001639477	-1.4003649253376502
13966	0.8499753457212386	-2.148791779190103
13967	0.8500486495498223	-2.148652152849943
13968	0.8053158608212075	-2.147554340750439
13969	0.6122562656118549	-1.3273578027267277
13970	0.5599312946370648	-1.4122628348484958
13971	0.9980368621556734	-2.966187063764363
13972	0.5730491892950542	-1.3944604764781534
13973	0.5719967557561016	-1.3953907369694665
13974	0.72515463360636	-1.2309807214316006
13975	0.7285876962450328	-1.2340647182198745
13976	0.7283834927225495	-1.2342392511450742
13977	1.043415422707526	-2.8315052413757167
13978	0.7282962262599497	-1.2442155531494739
13979	0.8480938807875886	-2.146571720381566
13980	0.7213742504465402	-1.230238956499503
13981	0.5570218307739903	-1.4126398259669264
13982	0.5560043038200776	-1.4138615564433226
13983	0.5560043038200776	-1.4138615564433226
13984	0.720868104963462	-1.253320935857128
13985	0.7194247176720626	-1.2534378729170117
13986	0.7198470873510453	-1.252689126667906
13987	0.48628363619066006	-1.4413853987472731
13988	0.7244285766375305	-1.2346162422635047
13989	0.7131991282301989	-1.2900601166116088
13990	0.7240201695925637	-1.232376984833196
13991	0.7241947025177631	-1.2321151854453969
13992	0.8306021910241015	-2.1391139284877942
13993	0.6635158876112275	-2.1252293106894036
13994	0.7254757741887269	-1.2358676433371847
13995	0.5729619228324545	-1.3964082639233792
13996	0.7113909671251328	-1.2907495216661464
13997	0.7114363456856847	-1.2907407950198864
13998	0.7115131401727723	-1.2906709818498068
13999	0.8318448654515214	-2.136960192190833
14000	0.8325220532012952	-2.140354857585962
14001	0.8269945954602291	-2.1415189921970423
14002	0.7244565019055622	-1.240724894645485
14003	0.7244565019055622	-1.240724894645485
14004	0.8188072559391237	-2.1660984640528786
14005	0.8831941973744465	-2.2132816950512932
14006	0.5676980098084395	-1.4083358440315084
14007	0.56941366846315	-1.4011799940983316
14008	0.5696178719856333	-1.4021975210522444
14009	0.7203846487606594	-1.2551238609744384
14010	0.7255717672975867	-1.2679467949888406
14011	0.8304852539642178	-2.139482192959965
14012	0.7106631648270512	-1.2910322650049695
14013	0.5683088750466376	-1.4065905147795141
14014	0.7121816012762862	-1.290321915999408
14015	0.5579241659972713	-1.412494963639011
14016	0.5598440281744651	-1.4137463647126909
14017	0.5585926271007852	-1.4137742899807226
14018	0.5574284924897049	-1.413310032399692
14019	0.5975431400175426	-1.3605330211486357
14020	0.5975431400175426	-1.3605330211486357
14021	0.6643886569569797	-2.135118869829979
14022	0.5289796256821974	-1.4254976665663686
14023	0.7218769052711147	-1.2581781871654283
14024	0.579574975368261	-1.38203024154545
14025	0.7246607054280457	-1.233685981772192
14026	0.5747665932790166	-1.395186533446983
14027	0.574663618853149	-1.3950905403381235
14028	0.8066475470404793	-2.157736591606574
14029	0.807031519475918	-2.1585062818067033
14030	0.7204335179797153	-1.2756035544173396
14031	0.6864676654066537	-1.3299408900196792
14032	0.6861185995562549	-1.3302410866510221
14033	0.9916384851178622	-2.320706710511544
14034	0.7248928342185608	-1.2292057215823222
14035	0.5599888905023807	-1.4123501013110953
14036	0.6781424448746408	-1.3299059834346392
14037	1.0137448254236225	-2.384119758224254
14038	0.7787077345981374	-2.1653718253076373
14039	0.7788240898816023	-2.1652031101466056
14040	0.7784255730357309	-2.1631901637426445
14041	0.7784517529745109	-2.1644060764548554
14042	0.6603162278534239	-2.137155669067057
14043	0.5743669128803099	-1.3951516268619433
14044	0.5745571537687773	-1.3950503977653275
14045	0.6597344572538565	-2.1359915344559766
14046	0.8449627601095108	-2.1400127730525713
14047	0.8059546513274375	-2.161909673848092
14048	0.8061030043138571	-2.162250013052231
14050	0.7471149596668983	-1.2358575378808156
\.


--
-- TOC entry 3499 (class 0 OID 26518)
-- Dependencies: 218
-- Data for Name: privileges; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.privileges (id, name) FROM stdin;
1	Administrator
2	Create Spot
4	Add Fish
6	Add Gear Combo
7	Access Stats
8	Create Outing
9	Create Group
10	Protect Spot
11	View Spots
12	Join Group
\.


--
-- TOC entry 3501 (class 0 OID 26529)
-- Dependencies: 220
-- Data for Name: ranks; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.ranks (id, name, rank_number, description) FROM stdin;
1	Bait Fish	1	absolute beginner (may get eaten out there)
2	Cut Bait	-1	bad luck
3	Old Stinky Chum	-5	Maybe fishing is not your thing
4	Snapper Bluefish	2	Beginner, but hungry
\.


--
-- TOC entry 3510 (class 0 OID 26654)
-- Dependencies: 229
-- Data for Name: user_accounts; Type: TABLE DATA; Schema: public; Owner: fishing_stories
--

COPY public.user_accounts (id, username, password, account_type_id, angler_id, email) FROM stdin;
4	admin	pbkdf2:sha256:260000$G3yOuBZ2Z4xRVGeX$381e8a5e59a2902a29e1756f50b1cb72142d2c6b5c966d3517462846954b321d	1	\N	\N
\.


--
-- TOC entry 3543 (class 0 OID 0)
-- Dependencies: 209
-- Name: account_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: fishing_stories
--

SELECT pg_catalog.setval('public.account_types_id_seq', 5, true);


--
-- TOC entry 3544 (class 0 OID 0)
-- Dependencies: 222
-- Name: anglers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: fishing_stories
--

SELECT pg_catalog.setval('public.anglers_id_seq', 2, true);


--
-- TOC entry 3545 (class 0 OID 0)
-- Dependencies: 211
-- Name: baits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: fishing_stories
--

SELECT pg_catalog.setval('public.baits_id_seq', 3, true);


--
-- TOC entry 3546 (class 0 OID 0)
-- Dependencies: 235
-- Name: current_stations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: fishing_stories
--

SELECT pg_catalog.setval('public.current_stations_id_seq', 12457, true);


--
-- TOC entry 3547 (class 0 OID 0)
-- Dependencies: 233
-- Name: data_urls_id_seq; Type: SEQUENCE SET; Schema: public; Owner: fishing_stories
--

SELECT pg_catalog.setval('public.data_urls_id_seq', 15606, true);


--
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 224
-- Name: fishes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: fishing_stories
--

SELECT pg_catalog.setval('public.fishes_id_seq', 5, true);


--
-- TOC entry 3549 (class 0 OID 0)
-- Dependencies: 226
-- Name: fishing_conditions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: fishing_stories
--

SELECT pg_catalog.setval('public.fishing_conditions_id_seq', 1, false);


--
-- TOC entry 3550 (class 0 OID 0)
-- Dependencies: 213
-- Name: fishing_gear_id_seq; Type: SEQUENCE SET; Schema: public; Owner: fishing_stories
--

SELECT pg_catalog.setval('public.fishing_gear_id_seq', 2, true);


--
-- TOC entry 3551 (class 0 OID 0)
-- Dependencies: 215
-- Name: fishing_outings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: fishing_stories
--

SELECT pg_catalog.setval('public.fishing_outings_id_seq', 1, false);


--
-- TOC entry 3552 (class 0 OID 0)
-- Dependencies: 231
-- Name: fishing_spots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: fishing_stories
--

SELECT pg_catalog.setval('public.fishing_spots_id_seq', 7, true);


--
-- TOC entry 3553 (class 0 OID 0)
-- Dependencies: 237
-- Name: global_positions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: fishing_stories
--

SELECT pg_catalog.setval('public.global_positions_id_seq', 14050, true);


--
-- TOC entry 3554 (class 0 OID 0)
-- Dependencies: 217
-- Name: privileges_id_seq; Type: SEQUENCE SET; Schema: public; Owner: fishing_stories
--

SELECT pg_catalog.setval('public.privileges_id_seq', 12, true);


--
-- TOC entry 3555 (class 0 OID 0)
-- Dependencies: 219
-- Name: ranks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: fishing_stories
--

SELECT pg_catalog.setval('public.ranks_id_seq', 4, true);


--
-- TOC entry 3556 (class 0 OID 0)
-- Dependencies: 228
-- Name: user_accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: fishing_stories
--

SELECT pg_catalog.setval('public.user_accounts_id_seq', 4, true);


--
-- TOC entry 3294 (class 2606 OID 26545)
-- Name: account_privileges account_privileges_pkey; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.account_privileges
    ADD CONSTRAINT account_privileges_pkey PRIMARY KEY (account_type_id, privilege_id);


--
-- TOC entry 3272 (class 2606 OID 26476)
-- Name: account_types account_types_name_key; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.account_types
    ADD CONSTRAINT account_types_name_key UNIQUE (name);


--
-- TOC entry 3274 (class 2606 OID 26474)
-- Name: account_types account_types_pkey; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.account_types
    ADD CONSTRAINT account_types_pkey PRIMARY KEY (id);


--
-- TOC entry 3308 (class 2606 OID 26677)
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- TOC entry 3320 (class 2606 OID 27495)
-- Name: angler_baits angler_baits_pkey; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.angler_baits
    ADD CONSTRAINT angler_baits_pkey PRIMARY KEY (angler_id, bait_id);


--
-- TOC entry 3322 (class 2606 OID 27510)
-- Name: angler_fishing_spots angler_fishing_spots_pkey; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.angler_fishing_spots
    ADD CONSTRAINT angler_fishing_spots_pkey PRIMARY KEY (angler_id, fishing_spot_id);


--
-- TOC entry 3324 (class 2606 OID 27525)
-- Name: angler_gear angler_gear_pkey; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.angler_gear
    ADD CONSTRAINT angler_gear_pkey PRIMARY KEY (angler_id, fishing_gear_id);


--
-- TOC entry 3326 (class 2606 OID 27572)
-- Name: angler_outings angler_outings_pkey; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.angler_outings
    ADD CONSTRAINT angler_outings_pkey PRIMARY KEY (angler_id, fishing_outing_id);


--
-- TOC entry 3296 (class 2606 OID 26564)
-- Name: anglers anglers_name_key; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.anglers
    ADD CONSTRAINT anglers_name_key UNIQUE (name);


--
-- TOC entry 3298 (class 2606 OID 26562)
-- Name: anglers anglers_pkey; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.anglers
    ADD CONSTRAINT anglers_pkey PRIMARY KEY (id);


--
-- TOC entry 3276 (class 2606 OID 26487)
-- Name: baits baits_name_size_color_key; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.baits
    ADD CONSTRAINT baits_name_size_color_key UNIQUE (name, size, color);


--
-- TOC entry 3278 (class 2606 OID 26485)
-- Name: baits baits_pkey; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.baits
    ADD CONSTRAINT baits_pkey PRIMARY KEY (id);


--
-- TOC entry 3314 (class 2606 OID 26918)
-- Name: current_stations current_stations_name_key; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.current_stations
    ADD CONSTRAINT current_stations_name_key UNIQUE (name);


--
-- TOC entry 3316 (class 2606 OID 26916)
-- Name: current_stations current_stations_pkey; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.current_stations
    ADD CONSTRAINT current_stations_pkey PRIMARY KEY (id);


--
-- TOC entry 3312 (class 2606 OID 26843)
-- Name: data_urls data_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.data_urls
    ADD CONSTRAINT data_urls_pkey PRIMARY KEY (id);


--
-- TOC entry 3300 (class 2606 OID 26593)
-- Name: fishes fishes_pkey; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.fishes
    ADD CONSTRAINT fishes_pkey PRIMARY KEY (id);


--
-- TOC entry 3302 (class 2606 OID 26617)
-- Name: fishing_conditions fishing_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.fishing_conditions
    ADD CONSTRAINT fishing_conditions_pkey PRIMARY KEY (id);


--
-- TOC entry 3280 (class 2606 OID 26496)
-- Name: fishing_gear fishing_gear_pkey; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.fishing_gear
    ADD CONSTRAINT fishing_gear_pkey PRIMARY KEY (id);


--
-- TOC entry 3282 (class 2606 OID 26505)
-- Name: fishing_outings fishing_outings_pkey; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.fishing_outings
    ADD CONSTRAINT fishing_outings_pkey PRIMARY KEY (id);


--
-- TOC entry 3310 (class 2606 OID 26831)
-- Name: fishing_spots fishing_spots_pkey; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.fishing_spots
    ADD CONSTRAINT fishing_spots_pkey PRIMARY KEY (id);


--
-- TOC entry 3318 (class 2606 OID 26977)
-- Name: global_positions global_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.global_positions
    ADD CONSTRAINT global_positions_pkey PRIMARY KEY (id);


--
-- TOC entry 3284 (class 2606 OID 26527)
-- Name: privileges privileges_name_key; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.privileges
    ADD CONSTRAINT privileges_name_key UNIQUE (name);


--
-- TOC entry 3286 (class 2606 OID 26525)
-- Name: privileges privileges_pkey; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.privileges
    ADD CONSTRAINT privileges_pkey PRIMARY KEY (id);


--
-- TOC entry 3288 (class 2606 OID 26538)
-- Name: ranks ranks_name_key; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.ranks
    ADD CONSTRAINT ranks_name_key UNIQUE (name);


--
-- TOC entry 3290 (class 2606 OID 26536)
-- Name: ranks ranks_pkey; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.ranks
    ADD CONSTRAINT ranks_pkey PRIMARY KEY (id);


--
-- TOC entry 3292 (class 2606 OID 26540)
-- Name: ranks ranks_rank_number_key; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.ranks
    ADD CONSTRAINT ranks_rank_number_key UNIQUE (rank_number);


--
-- TOC entry 3304 (class 2606 OID 26659)
-- Name: user_accounts user_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.user_accounts
    ADD CONSTRAINT user_accounts_pkey PRIMARY KEY (id);


--
-- TOC entry 3306 (class 2606 OID 26661)
-- Name: user_accounts user_accounts_username_key; Type: CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.user_accounts
    ADD CONSTRAINT user_accounts_username_key UNIQUE (username);


--
-- TOC entry 3350 (class 2620 OID 27618)
-- Name: fishing_spots set_nearest_curr; Type: TRIGGER; Schema: public; Owner: fishing_stories
--

CREATE TRIGGER set_nearest_curr BEFORE INSERT ON public.fishing_spots FOR EACH ROW EXECUTE FUNCTION public.find_nearest_curr();


--
-- TOC entry 3329 (class 2606 OID 26546)
-- Name: account_privileges account_privileges_account_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.account_privileges
    ADD CONSTRAINT account_privileges_account_type_id_fkey FOREIGN KEY (account_type_id) REFERENCES public.account_types(id) ON DELETE CASCADE;


--
-- TOC entry 3330 (class 2606 OID 26551)
-- Name: account_privileges account_privileges_privilege_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.account_privileges
    ADD CONSTRAINT account_privileges_privilege_id_fkey FOREIGN KEY (privilege_id) REFERENCES public.privileges(id) ON DELETE CASCADE;


--
-- TOC entry 3342 (class 2606 OID 27795)
-- Name: angler_baits angler_baits_angler_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.angler_baits
    ADD CONSTRAINT angler_baits_angler_id_fkey FOREIGN KEY (angler_id) REFERENCES public.anglers(id) ON DELETE CASCADE;


--
-- TOC entry 3343 (class 2606 OID 27800)
-- Name: angler_baits angler_baits_bait_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.angler_baits
    ADD CONSTRAINT angler_baits_bait_id_fkey FOREIGN KEY (bait_id) REFERENCES public.baits(id) ON DELETE CASCADE;


--
-- TOC entry 3344 (class 2606 OID 27805)
-- Name: angler_fishing_spots angler_fishing_Spots_angler_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.angler_fishing_spots
    ADD CONSTRAINT "angler_fishing_Spots_angler_id_fkey" FOREIGN KEY (angler_id) REFERENCES public.anglers(id) ON DELETE CASCADE;


--
-- TOC entry 3345 (class 2606 OID 27810)
-- Name: angler_fishing_spots angler_fishing_spots_fishing_spot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.angler_fishing_spots
    ADD CONSTRAINT angler_fishing_spots_fishing_spot_id_fkey FOREIGN KEY (fishing_spot_id) REFERENCES public.fishing_spots(id) ON DELETE CASCADE;


--
-- TOC entry 3346 (class 2606 OID 27815)
-- Name: angler_gear angler_gear_angler_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.angler_gear
    ADD CONSTRAINT angler_gear_angler_id_fkey FOREIGN KEY (angler_id) REFERENCES public.anglers(id) ON DELETE CASCADE;


--
-- TOC entry 3347 (class 2606 OID 27820)
-- Name: angler_gear angler_gear_fishing_gear_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.angler_gear
    ADD CONSTRAINT angler_gear_fishing_gear_id_fkey FOREIGN KEY (fishing_gear_id) REFERENCES public.fishing_gear(id) ON DELETE CASCADE;


--
-- TOC entry 3349 (class 2606 OID 27830)
-- Name: angler_outings angler_outings_angler_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.angler_outings
    ADD CONSTRAINT angler_outings_angler_id_fkey FOREIGN KEY (angler_id) REFERENCES public.anglers(id) ON DELETE CASCADE;


--
-- TOC entry 3348 (class 2606 OID 27825)
-- Name: angler_outings angler_outings_fishing_outing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.angler_outings
    ADD CONSTRAINT angler_outings_fishing_outing_id_fkey FOREIGN KEY (fishing_outing_id) REFERENCES public.fishing_outings(id) ON DELETE CASCADE;


--
-- TOC entry 3331 (class 2606 OID 26565)
-- Name: anglers anglers_rank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.anglers
    ADD CONSTRAINT anglers_rank_id_fkey FOREIGN KEY (rank_id) REFERENCES public.ranks(id) ON DELETE CASCADE;


--
-- TOC entry 3341 (class 2606 OID 26980)
-- Name: current_stations current_stations_global_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.current_stations
    ADD CONSTRAINT current_stations_global_position_id_fkey FOREIGN KEY (global_position_id) REFERENCES public.global_positions(id);


--
-- TOC entry 3340 (class 2606 OID 26985)
-- Name: data_urls data_urls_global_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.data_urls
    ADD CONSTRAINT data_urls_global_position_id_fkey FOREIGN KEY (global_position_id) REFERENCES public.global_positions(id);


--
-- TOC entry 3332 (class 2606 OID 27774)
-- Name: fishes fishes_angler_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.fishes
    ADD CONSTRAINT fishes_angler_id_fkey FOREIGN KEY (angler_id) REFERENCES public.anglers(id);


--
-- TOC entry 3335 (class 2606 OID 27789)
-- Name: fishes fishes_bait_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.fishes
    ADD CONSTRAINT fishes_bait_id_fkey FOREIGN KEY (bait_id) REFERENCES public.baits(id);


--
-- TOC entry 3334 (class 2606 OID 27784)
-- Name: fishes fishes_fishing_spot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.fishes
    ADD CONSTRAINT fishes_fishing_spot_id_fkey FOREIGN KEY (fishing_spot_id) REFERENCES public.fishing_spots(id);


--
-- TOC entry 3333 (class 2606 OID 27779)
-- Name: fishes fishes_gear_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.fishes
    ADD CONSTRAINT fishes_gear_id_fkey FOREIGN KEY (gear_id) REFERENCES public.fishing_gear(id);


--
-- TOC entry 3327 (class 2606 OID 27583)
-- Name: fishing_outings fishing_outings_fishing_conditions_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.fishing_outings
    ADD CONSTRAINT fishing_outings_fishing_conditions_id_fkey FOREIGN KEY (fishing_conditions_id) REFERENCES public.fishing_conditions(id);


--
-- TOC entry 3328 (class 2606 OID 27588)
-- Name: fishing_outings fishing_outings_fishing_spot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.fishing_outings
    ADD CONSTRAINT fishing_outings_fishing_spot_id_fkey FOREIGN KEY (fishing_spot_id) REFERENCES public.fishing_spots(id);


--
-- TOC entry 3339 (class 2606 OID 27603)
-- Name: fishing_spots fishing_spots_current_url_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.fishing_spots
    ADD CONSTRAINT fishing_spots_current_url_id_fkey FOREIGN KEY (current_url_id) REFERENCES public.data_urls(id);


--
-- TOC entry 3338 (class 2606 OID 26990)
-- Name: fishing_spots fishing_spots_global_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.fishing_spots
    ADD CONSTRAINT fishing_spots_global_position_id_fkey FOREIGN KEY (global_position_id) REFERENCES public.global_positions(id);


--
-- TOC entry 3336 (class 2606 OID 26662)
-- Name: user_accounts user_accounts_account_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.user_accounts
    ADD CONSTRAINT user_accounts_account_type_id_fkey FOREIGN KEY (account_type_id) REFERENCES public.account_types(id) ON DELETE CASCADE;


--
-- TOC entry 3337 (class 2606 OID 26667)
-- Name: user_accounts user_accounts_angler_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fishing_stories
--

ALTER TABLE ONLY public.user_accounts
    ADD CONSTRAINT user_accounts_angler_id_fkey FOREIGN KEY (angler_id) REFERENCES public.anglers(id) ON DELETE CASCADE;


-- Completed on 2022-06-28 05:25:01 UTC

--
-- PostgreSQL database dump complete
--

