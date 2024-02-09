shader_type sky;

uniform sampler2D noise1;
uniform sampler2D noise2;

void sky() {
	COLOR = vec3( (textureLod(noise1,SCREEN_UV,1.0).x*.5) ,0, textureLod(noise2,SCREEN_UV,1.0).z*.5 )*EYEDIR;
}
