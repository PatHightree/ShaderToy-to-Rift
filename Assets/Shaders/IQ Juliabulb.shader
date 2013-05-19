// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Unity note: This shader only works when Unity is running in OpenGL!
// To do this, start the editor with -force-opengl on the command line.
 
Shader "ShaderToy/IQ Juliabulb"
{    
    Properties
    {
    
    }
    SubShader
    {
        Tags { "Queue" = "Geometry" }
        Pass
            {            
                GLSLPROGRAM
                
                uniform vec2 iMouse;
                
                uniform vec3 iCamRight;
                uniform vec3 iCamUp;
                uniform vec3 iCamForward;
                uniform vec3 iCamPos;
                
                #ifdef VERTEX  
                void main()
                {          
                    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
                }
                #endif  
 
                #ifdef FRAGMENT
                #include "UnityCG.glslinc"
 
bool isphere( in vec4 sph, in vec3 ro, in vec3 rd, out vec2 t )
{
    vec3 oc = ro - sph.xyz;
	float b = dot(oc,rd);
	float c = dot(oc,oc) - sph.w*sph.w;

    float h = b*b - c;
    if( h<0.0 )
        return false;

    float g = sqrt( h );
    t.x = - b - g;
    t.y = - b + g;

    return true;
}

const int NumIte = 7;
const float Bailout = 1000.0;

bool iterate( in vec3 p, in vec3 CC, out float resPot, out vec4 resColor )
{
    vec3 zz = p;
	vec4 trap = vec4(abs(zz.xyz),dot(zz,zz));
	float dz = 1.0;

	for( int i=0; i<NumIte; i++ )
    {
        float m = dot(zz,zz);
		if( m > Bailout )
        {
		    resColor = trap;
			resPot = 0.25*log(m)*sqrt(m)/dz;
            return false;
        }

		dz = 8.0*pow(m,3.5)*dz;

        float x = zz.x; float x2 = x*x; float x4 = x2*x2;
        float y = zz.y; float y2 = y*y; float y4 = y2*y2;
        float z = zz.z; float z2 = z*z; float z4 = z2*z2;

        float k3 = x2 + z2;
        float k2 = inversesqrt( k3*k3*k3*k3*k3*k3*k3 );
        float k1 = x4 + y4 + z4 - 6.0*y2*z2 - 6.0*x2*y2 + 2.0*z2*x2;
        float k4 = x2 - y2 + z2;

        zz.x = CC.x +  64.0*x*y*z*(x2-z2)*k4*(x4-6.0*x2*z2+z4)*k1*k2;
        zz.y = CC.y + -16.0*y2*k3*k4*k4 + k1*k1;
        zz.z = CC.z +  -8.0*y*k4*(x4*x4 - 28.0*x4*x2*z2 + 70.0*x4*z4 - 28.0*x2*z2*z4 + z4*z4)*k1*k2;

        trap = min( trap, vec4(abs(zz.xyz),dot(zz,zz)) );

    }

    resColor = trap;
    resPot = 0.0;
    return true;
}

bool ifractal( in vec3 ro, in vec3 rd, out float rest, in float maxt, out vec3 resnor, out vec4 rescol, float fov, vec3 ccc )
{
    vec4 sph = vec4( 0.0, 0.0, 0.0, 1.25 );
    vec2 dis;

    if( !isphere(sph,ro,rd,dis) )
        return false;

    // early skip
    if( dis.y<0.001 ) return false;
    // clip to near!
    if( dis.x<0.001 )dis.x = 0.001;

    if( dis.y>maxt) dis.y = maxt;

    float dt;
	vec3 gra;
	vec4 color;

	float fovfactor = 1.0/sqrt(1.0+fov*fov);

	float t = dis.x;
	for( int i=0; i<80; i++  )
    { 
        vec3 p = ro + rd*t;

float Surface = clamp( 0.002*t*fovfactor, 0.000001, 0.005 );


		float eps = Surface*0.1;
		vec4 col2;
		if( iterate(p,ccc,dt,color) ) { rest = t; resnor=vec3(0.0,0.0,0.0); rescol = color; return true; }

		//gra = vec3( pot2-pot1, pot3-pot1, pot4-pot1 );
//dt = 0.01;
		if( dt<Surface )
        {
		    rescol = color;

			vec4 tmp;
			float eps = Surface*0.75;
			float p2; iterate( p+vec3(eps,0.0,0.0), ccc, p2, tmp );
			float p3; iterate( p+vec3(0.0,eps,0.0), ccc, p3, tmp );
			float p4; iterate( p+vec3(0.0,0.0,eps), ccc, p4, tmp );
			resnor = normalize( vec3( p2-dt, p3-dt, p4-dt ) );
            rest = t;
            return true;
        }

        t+=dt;
    }

    return false;
}


void main(void)
{
    vec2 xy = -1.0 + 2.0*gl_FragCoord.xy / _ScreenParams.xy;

	vec2 s = xy*vec2(1.75,1.0);

    float time = _Time.y*.15;

	vec3 light1 = vec3(  0.577, 0.577, -0.577 );
	vec3 light2 = vec3( -0.707, 0.000,  0.707 );


	float r = 1.3+0.1*cos(.29*time);
	/*
	vec3 campos = vec3( r*cos(.33*time), 0.8*r*sin(.37*time), r*sin(.31*time) );
	vec3 camtar = vec3(0.0,0.1,0.0);

	float roll = 0.5*cos(0.1*time);
	vec3 cw = normalize(camtar-campos);
	vec3 cp = vec3(sin(roll), cos(roll),0.0);
	vec3 cu = normalize(cross(cw,cp));
	vec3 cv = normalize(cross(cu,cw));
	*/
	
	// camera navigation
	vec3 ro = iCamPos;
	vec3 cu = iCamRight;
	vec3 cv = iCamUp;
	vec3 cw = iCamForward;

	float fov = 1.5;
	vec3 rd = normalize( s.x*cu + s.y*cv + fov*cw );


	vec3 cc = vec3( 0.9*cos(3.9+1.2*time)-.3, 0.8*cos(2.5+1.1*time), 0.8*cos(3.4+1.3*time) );
	if( length(cc)<0.50 ) cc=0.50*normalize(cc);
	if( length(cc)>0.95 ) cc=0.95*normalize(cc);

	vec3 nor, rgb;
	vec4 col;
    float t;
    if( !ifractal(iCamPos,rd,t,1e20,nor,col,fov,cc) )
    {
     	rgb = 1.3*vec3(1.0,.98,0.9)*(0.7+0.3*rd.y);

		rgb += vec3(0.8,0.7,0.5)*pow( clamp(dot(rd,light1),0.0,1.0), 32.0 );
	}
	else
	{
		vec3 xyz = iCamPos + t*rd;

		float dif1 = clamp( dot( light1, nor ), 0.0, 1.0 );
		float dif2 = clamp( 0.5 + 0.5*dot( light2, nor ), 0.0, 1.0 );
		float ao = clamp(1.5*col.w-0.9,0.0,1.0);
		float lt1;
		vec3 ln;
		vec4 lc;
		if( dif1>0.001 ) if( ifractal(xyz,light1,lt1,1e20,ln,lc,fov,cc) ) dif1 = 0.0;

		rgb = vec3(1.0,1.0,1.0)*0.3;

		rgb = mix( rgb, vec3(1.0,0.1,0.0), sqrt(col.x) );
		rgb = mix( rgb, vec3(1.0,0.5,0.2), sqrt(col.y) );
		rgb = mix( rgb, vec3(1.0,1.0,1.0), col.z );

		vec3 brdf  = 1.5*vec3(0.17,0.19,0.20)*(0.6+0.4*nor.y)*(0.1+0.9*ao);
		     brdf += 1.9*vec3(1.00,0.90,0.60)*dif1*(0.5+0.5*ao);
		     brdf += 1.1*vec3(0.14,0.14,0.14)*dif2*ao;

		rgb *= brdf;

	}

	rgb = sqrt(rgb);

	vec2 uv = xy*0.5+0.5;
	//rgb *= 0.7 + 0.3*pow(16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y),0.25);
	gl_FragColor=vec4(rgb,1.0);
}
                #endif                          
                ENDGLSL        
            }
     }
    FallBack "Diffuse"
}