CREATE TABLE users (id INTEGER PRIMARY KEY, username TEXT,
    pass_hash TEXT);

CREATE TABLE games (id INTEGER PRIMARY KEY, name TEXT,
    owner_id INTEGER REFERENCES users(id), ctime TEXT, mtime TEXT);

CREATE TABLE periods (id INTEGER PRIMARY KEY,
    game_id INTEGER REFERENCES games(id) ON DELETE CASCADE,
    content TEXT, next INTEGER, previous INTEGER, tone TEXT,
    ctime TEXT, mtime TEXT);

CREATE TABLE events (id INTEGER PRIMARY KEY,
    period_id INTEGER REFERENCES periods(id) ON DELETE CASCADE,
    content TEXT, next INTEGER, previous INTEGER, tone TEXT,
    ctime TEXT, mtime TEXT);

CREATE TABLE scenes (id INTEGER PRIMARY KEY,
    event_id INTEGER REFERENCES events(id) ON DELETE CASCADE,
    question TEXT, setting TEXT, answer TEXT,
    next INTEGER, previous INTEGER, tone TEXT,
    ctime TEXT, mtime TEXT);

CREATE TABLE players (user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    game_id INTEGER REFERENCES games(id) ON DELETE CASCADE,
    UNIQUE (user_id, game_id));

CREATE INDEX period_gameid ON periods (game_id);

CREATE INDEX event_periodid ON events (period_id);

CREATE INDEX scene_eventid ON scenes (event_id);

CREATE OR REPLACE FUNCTION game_insert() RETURNS trigger AS $$
    BEGIN
        UPDATE games SET ctime = now() WHERE id = NEW.id;
        UPDATE games SET mtime = now() WHERE id = NEW.id;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER game_insert AFTER INSERT ON games
    FOR EACH ROW EXECUTE PROCEDURE game_insert();

CREATE OR REPLACE FUNCTION period_insert() RETURNS trigger AS $$
    BEGIN
        UPDATE periods SET next = NEW.id WHERE next = NEW.next AND NOT id = NEW.id;
        UPDATE periods SET previous = NEW.previous WHERE previous = NEW.previous
            AND NOT id = NEW.id;
        UPDATE periods SET ctime = now() WHERE id = NEW.id;
        UPDATE periods SET mtime = now() WHERE id = NEW.id;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER period_insert AFTER INSERT ON periods
    FOR EACH ROW EXECUTE PROCEDURE period_insert();


CREATE OR REPLACE FUNCTION event_insert() RETURNS trigger AS $$
    BEGIN
        UPDATE events SET next = NEW.id WHERE next = NEW.next AND NOT id = NEW.id;
        UPDATE events SET previous = NEW.previous WHERE previous = NEW.previous
            AND NOT id = NEW.id;
        UPDATE events SET ctime = now() WHERE id = NEW.id;
        UPDATE events SET mtime = now() WHERE id = NEW.id;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER event_insert AFTER INSERT ON events


CREATE OR REPLACE FUNCTION scene_insert() RETURNS trigger AS $$
    BEGIN
        UPDATE scenes SET next = NEW.id WHERE next = NEW.next AND NOT id = NEW.id;
        UPDATE scenes SET previous = NEW.previous WHERE previous = NEW.previous
            AND NOT id = NEW.id;
        UPDATE scenes SET ctime = now() WHERE id = NEW.id;
        UPDATE scenes SET mtime = now() WHERE id = NEW.id;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER scene_insert AFTER INSERT ON scenes
    FOR EACH ROW EXECUTE PROCEDURE scene_insert();

CREATE OR REPLACE FUNCTION game_update() RETURNS trigger AS $$
    BEGIN
        UPDATE games SET mtime = now() WHERE id = NEW.id;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER game_update AFTER UPDATE ON games
    FOR EACH ROW EXECUTE PROCEDURE game_update();


CREATE OR REPLACE FUNCTION period_update() RETURNS trigger AS $$
    BEGIN
        UPDATE games SET mtime = now() WHERE id = NEW.game_id;
        UPDATE periods SET mtime = now() WHERE id = NEW.id;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER period_update AFTER UPDATE ON periods
    FOR EACH ROW EXECUTE PROCEDURE period_update();

CREATE OR REPLACE FUNCTION event_update() RETURNS trigger AS $$
    BEGIN
        UPDATE periods SET mtime = now() WHERE id = NEW.period_id;
        UPDATE events SET mtime = now() WHERE id = NEW.id;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER event_update AFTER UPDATE ON events
    FOR EACH ROW EXECUTE PROCEDURE event_update();

CREATE OR REPLACE FUNCTION scene_update() RETURNS trigger AS $$
    BEGIN
        UPDATE events SET mtime = now() WHERE id = NEW.event_id;
        UPDATE scenes SET mtime = now() WHERE id = NEW.id;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER scene_update AFTER UPDATE ON scenes
    FOR EACH ROW EXECUTE PROCEDURE scene_update();

CREATE OR REPLACE FUNCTION period_delete() RETURNS trigger AS $$
    BEGIN
        UPDATE games SET mtime = now() WHERE id = NEW.game_id;
        UPDATE periods SET next = old.next WHERE next = old.id;
        UPDATE periods SET previous = old.previous WHERE previous = old.id;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER period_delete AFTER DELETE ON periods
    FOR EACH ROW EXECUTE PROCEDURE period_delete();


CREATE OR REPLACE FUNCTION event_delete() RETURNS trigger AS $$
    BEGIN
        UPDATE periods SET mtime = now() WHERE id = NEW.period_id;
        UPDATE events SET next = old.next WHERE next = old.id;
        UPDATE events SET previous = old.previous WHERE previous = old.id;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER event_delete AFTER DELETE ON events
    FOR EACH ROW EXECUTE PROCEDURE event_delete();

CREATE OR REPLACE FUNCTION scene_delete() RETURNS trigger AS $$
    BEGIN
        UPDATE events SET mtime = now() WHERE id = NEW.event_id;
        UPDATE scenes SET next = old.next WHERE next = old.id;
        UPDATE scenes SET previous = old.previous WHERE previous = old.id;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER scene_delete AFTER DELETE ON scenes
    FOR EACH ROW EXECUTE PROCEDURE scene_delete();
