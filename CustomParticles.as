#include 'CPEmbed.as';

const float PI = 3.1415926535897932384626433832795;
const float MAX_RAND = 1073741824;
const float FRAME = 1.0 / 60.0;

class Particle {
	float x = 0;
	float y = 0;
	float xvel = 0;
	float yvel = 0;
	float friction = 0;
	float xgravity = 0;
	float ygravity = 0;
	float xscale = 0;
	float yscale = 0;
	float rotation = 0;
	float rotation_speed = 0;

	string s_name_base = "";
	string s_name = "";
	int s_frame = 0;
	int s_palette = 0;
	string embed = "";

	float fade_in = 0.2; // percentage of life, not seconds
	float fade_out = 0.2;
	int life = 120;

	int age;

	bool animate = false;
	int anim_frames;
	bool anim_loop;
	int anim_rate;

	int anim_timer;
	int anim_current_frame;

	uint alpha = 0;
	bool alive = true;
	bool stay_alive = false;

	Particle() {}

	void set_embed(string em, string sn, int sf, int sp, bool an, int af, bool al, int ar) {
		s_name_base = sn;
		s_name = sn;
		s_frame = sf;
		s_palette = sp;
		animate = an;
		anim_frames = af;
		anim_loop = al;
		anim_rate = ar;
	}

	void set_sprite(string sn, int sf, int sp) {
		s_name_base = sn;
		s_name = sn;
		s_frame = sf;
		s_palette = sp;
		animate = false;
	}

	void reset(float px, float py, float pxv, float pyv, float pf, float pxg, float pyg, float pr, float prs, int pl, float pxs, float pys, float fi, float fo) {
		x = px;
		y = py;
		xvel = pxv;
		yvel = pyv;
		friction = pf;
		xgravity = pxg;
		ygravity = pyg;
		xscale = pxs;
		yscale = pys;

		rotation = pr;
		rotation_speed = prs;
		life = pl;

		fade_in = fi;
		fade_out = fo;
		age = 0;
		alive = true;
		alpha = 0;
		anim_timer = 0;
		anim_current_frame = 0;
	}

	bool step() {
		if (!alive)
			return true;

		// age
		age++;
		if (age >= life) {
			alive = false;
			return true;
		}

		// accelerate
		xvel += xgravity;
		yvel += ygravity;

		if (friction != 0) {
			float vel_angle = atan2(yvel, xvel);
			if (xvel != 0) {
				float xf = friction * cos(vel_angle);
				if (abs(xvel) < abs(xf))
					xvel = 0;
				else
					xvel -= xf;
			}
			if (yvel != 0) {
				float yf = friction * sin(vel_angle);
				if (abs(yvel) < abs(yf))
					yvel = 0;
				else
					yvel -= yf;
			}
		}

		// move
		x += xvel;
		y += yvel;
		rotation += rotation_speed;

		// animate
		if (animate) {
			if (anim_loop) {
				anim_timer++;
				if (anim_timer >= anim_rate) {
					anim_timer = 0;
					anim_current_frame++;
					if (anim_current_frame >= anim_frames)
						anim_current_frame = 0;
					s_name = s_name_base + "_" + anim_current_frame;
				}
			} else {
				anim_current_frame = anim_frames * age / life;
				s_name = s_name_base + "_" + anim_current_frame;
			}
		}

		// alpha
		float l = float(age) / life;
		float a = 1;
		if (fade_in > 0 && l < fade_in)
			a = l / fade_in;
		else if (fade_out > 0 && 1 - l < fade_out)
			a = (1 - l) / fade_out;
		alpha = uint(0xFF * a);

		return false;
	}
}

class Spawn : trigger_base {
	script@ s;
	scripttrigger@ self;
	scene@ g;

	array<Particle> particles(0);

	[text] int layer = 20;
	[text] int sublayer = 20;
	[text] float w = 200;
	[text] float h = 200;

	[text] uint max_particles = 10;
	[text] uint min_particles = 0;
	[text] float spawn_rate = 0.2; // seconds per particle spawn, only used if min < max
	[text] float spawn_chance = 1; // likelihood out of 1 that a particle is created when able, checked each frame

	[text] float vel_min = 0.1;
	[text] float vel_range = 0.2;
	[angle] float direction = 0;
	[text] float angle_range = 0; // applies to either side of direction
	[text] float friction = 0;
	[text] float gravity = 0;
	[angle] float gravity_direction = 180;

	[text] float life_min = 2; // seconds
	[text] float life_range = 0.5;

	[text] bool rotate = true; // also applies random initial rotation
	[text] float rotate_spd = 0;
	[text] float rotate_spd_range = 0.2; // applies to either side of rotate_spd
	[text] float x_scale = 1;
	[text] float x_scale_range = 0;
	[text] float y_scale = 1;
	[text] float y_scale_range = 0;
	[text] bool flip_x = true;
	[text] bool flip_y = true;
	[text] float fade_in = 0.2; // percentage of life, not seconds, 0 = no fade
	[text] float fade_out = 0.2;

	[color, alpha] uint color = 0xFFFFFFFF;
	[text] bool use_embed = false;
	[text] string sprite_name = "foliage_25"; // also used for embed sprite_name
	[text] string sprite_set = "props2";
	[text] int sprite_frame = 0;
	[text] int sprite_palette = 0;

	bool active;
	float spawn_timer;
	bool spawn_queued;

	void editor_init(script@ s, scripttrigger@ self) {
		init(s, self);
	}

	void init(script@ s, scripttrigger@ self) {
		@this.s = @s;
		@this.self = @self;
		@g = get_scene();

		if (!use_embed)
			s.sprite_handler.add_sprite_set(sprite_set);

		active = true;
		spawn_timer = spawn_rate;
		spawn_queued = false;

		particles.resize(0);
		for (uint i = 0; i < min_particles; i++) {
			add_particle();
		}
	}

	void add_particle() {
		Particle@ p = Particle();
		reset_particle(p);
		particles.insertLast(p);

		spawn_timer = 0;
		spawn_queued = false;
	}

	void reset_particle(Particle@ p) {
		float px, py, pxv, pyv, pxg, pyg, pr, prs, pxs, pys;
		int pi, pl;

		if (use_embed) {
			dictionary ed = dictionary(s.embed_info[sprite_name]);
			pi = int((rand() / MAX_RAND) * int(ed["sprites"]));
			bool an = bool(ed["animate"]);
			int af = an ? int(ed["anim_frames"]) : 1;
			bool al = an ? bool(ed["anim_loop"]) : true;
			int ar =  an ? int(ed["anim_rate"]) : 1;

			p.set_embed(sprite_name, sprite_name + pi, 0, 0, an, af, al, ar);
		} else {
			p.set_sprite(sprite_name, sprite_frame, sprite_palette);
		}

		px = self.x() + (rand() / MAX_RAND) * w - w / 2;
		py = self.y() + (rand() / MAX_RAND) * h - h / 2;

		float v = vel_min + (rand() / MAX_RAND) * vel_range;
		float a = (direction + (rand() / MAX_RAND) * angle_range - angle_range / 2) / 180 * PI - PI / 2;
		pxv = v * cos(a);
		pyv = v * sin(a);

		float ga = gravity_direction / 180 * PI - PI / 2;
		pxg = gravity * cos(ga);
		pyg = gravity * sin(ga);

		pr = rotate ? ((rand() / MAX_RAND) * 360) : 0;
		prs = rotate ? (rotate_spd + (rand() / MAX_RAND) * rotate_spd_range - rotate_spd_range / 2) : 0;

		pl = int(60 * life_min + (rand() / MAX_RAND) * 60 * life_range);

		pxs = (x_scale + (rand() / MAX_RAND) * x_scale_range) * (flip_x && rand() / MAX_RAND < 0.5 ? 1 : -1);
		pys = (y_scale + (rand() / MAX_RAND) * y_scale_range) * (flip_y && rand() / MAX_RAND < 0.5 ? 1 : -1);

		p.reset(px, py, pxv, pyv, friction, pxg, pyg, pr, prs, pl, pxs, pys, fade_in, fade_out);
	}

	void editor_step() {
		step();
	}

	void step() {
		if (!active)
			return;

		if (s.debug_show_particle_count)
			s.p += particles.length();

		if (particles.length() <= max_particles) {
			spawn_timer += FRAME;
			if (spawn_timer > spawn_rate) {
				if ((rand() / MAX_RAND) < spawn_chance) {
					if (particles.length() >= max_particles)
						spawn_queued = true;
					else
						add_particle();
				}
			}
		} else if (min_particles == max_particles || particles.length() < min_particles) {
			spawn_queued = true;
		}

		for (uint i = 0; i < particles.length(); i++) {
			Particle@ p = particles[i];
			if (p.step() && spawn_queued) {
				reset_particle(p);
				spawn_timer = 0;
				spawn_queued = false;
			}
		}
	}

	void draw(float sf) {
		if (!active || !g.layer_visible(layer))
			return;

		for (uint i = 0; i < particles.length(); i++) {
			Particle@ p = particles[i];
			if (p.alive) {
				uint a = uint((float(color >> 24) / 0xFF) * (float(p.alpha) / 0xFF) * 0xFF) << 24;
				uint c = a | (color % (1 << 24));
				s.sprite_handler.draw_world(layer, sublayer, p.s_name, p.s_frame, p.s_palette, p.x, p.y, p.rotation, p.xscale, p.yscale, c);
			}
		}
	}

	void editor_draw(float sf) {
		draw(sf);
		g.draw_rectangle_world(layer, sublayer, self.x() - w / 2 , self.y() - h / 2, self.x() + w / 2, self.y() + h / 2, 0, 0x33FFCCCC);
	}
}


class script {
	scene@ g;

	[text] bool debug_show_particle_count = false;
	int p;
	textfield@ debug_particles;

	EmbedData@ ed;
	dictionary embed_info;
	sprites@ sprite_handler;

	script() {
		@g = get_scene();

		srand(get_time_us());

		@ed = EmbedData();
		embed_info = ed.get_info();

		@sprite_handler = create_sprites();
		sprite_handler.add_sprite_set("script");

		p = 0;
		@debug_particles = @create_textfield();
		debug_particles.set_font("Caracteres", 36);
	}

	void build_sprites(message@ msg) {
		array<string> build_list = ed.get_build_list();
		for (uint s = 0; s < build_list.length(); s++) {
			string s_set = build_list[s];
			dictionary s_info = dictionary(embed_info[s_set]);
			for (int i = 0; i < int(s_info["sprites"]); i++) {
				string s_name = s_set + i;
				for (int f = 0; f < int(s_info["anim_frames"]); f++) {
					if (bool(s_info["animate"]))
						s_name = s_set + i + "_" + f;
					msg.set_string(s_name, s_name);
					msg.set_int(s_name + "|offsetx", int(s_info["offsetx"]));
					msg.set_int(s_name + "|offsety", int(s_info["offsety"]));
				}
			}
		}
	}

	void step(int e) {
		if (debug_show_particle_count) {
			debug_particles.text("P: " + p);
			p = 0;
		}
	}

	void draw(float sf) {
		if (debug_show_particle_count)
			debug_particles.draw_hud(0, 0, 0, 400, 1, 1, 0);
	}
}
