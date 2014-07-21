// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//
// I can't recall where I learnt about this fractal.
//
// Coloring and fake occlusions are done by orbit trapping, as usual (unless somebody has invented
// something new in the last 4 years that i'm unaware of, that is)

// Unity note: This shader only works when Unity is running in OpenGL!
// To do this, start the editor with -force-opengl on the command line.
 
Shader "ShaderToy/IQ Appolonian"
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
                
				uniform vec2 iViewportOffset;
				uniform vec2 iViewportScale;
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
 
vec4 orb; 
float ss;
float map( vec3 p )
{
	float scale = 1.0;

	orb = vec4(1000.0); 
	
	for( int i=0; i<8;i++ )
	{
		p = -1.0 + 2.0*fract(0.5*p+0.5);

		float r2 = dot(p,p);
		
        orb = min( orb, vec4(abs(p),r2) );
		
		float k = max(ss/r2,0.1);
		p     *= k;
		scale *= k;
	}
	
	return 0.25*abs(p.y)/scale;
}

float trace( in vec3 ro, in vec3 rd )
{
	float maxd = 100.0;
	float precis = 0.001;
    float h=precis*2.0;
    float t = 0.0;
    for( int i=0; i<200; i++ )
    {
        if( abs(h)<precis||t>maxd ) continue;//break;
        t += h;
	    h = map( ro+rd*t );
    }

    if( t>maxd ) t=-1.0;
    return t;
}

vec3 calcNormal( in vec3 pos )
{
	vec3  eps = vec3(.0001,0.0,0.0);
	vec3 nor;
	nor.x = map(pos+eps.xyy) - map(pos-eps.xyy);
	nor.y = map(pos+eps.yxy) - map(pos-eps.yxy);
	nor.z = map(pos+eps.yyx) - map(pos-eps.yyx);
	return normalize(nor);
}

void main(void)
{
	vec2 p;
	p = iViewportOffset + iViewportScale * gl_FragCoord.xy / _ScreenParams.xy;
    p.x *= _ScreenParams.x/_ScreenParams.y;

	//ss = 1.1 + 0.5*smoothstep( -0.3, 0.3, cos(0.1*_Time.y) );
    ss = 1.1 + 0.5*smoothstep( -0.3, 0.3, cos(0.1*0) );
	
	// camera navigation
	vec3 ro = iCamPos;
	vec3 cu = iCamRight;
	vec3 cv = iCamUp;
	vec3 cw = iCamForward;
	
	vec3 rd = normalize( p.x*cu + p.y*cv + 2.0*cw );


    // trace	
	vec3 col = vec3(0.0);
	float t = trace( ro, rd );
	if( t>0.0 )
	{
		vec4 tra = orb;
		vec3 pos = ro + t*rd;
		vec3 nor = calcNormal( pos );
		
		// lighting
        vec3  light1 = vec3(  0.577, 0.577, -0.577 );
        vec3  light2 = vec3( -0.707, 0.000,  0.707 );
		float key = clamp( dot( light1, nor ), 0.0, 1.0 );
		float bac = clamp( 0.2 + 0.8*dot( light2, nor ), 0.0, 1.0 );
		float amb = (0.7+0.3*nor.y);
		float ao = pow( clamp(tra.w*2.0,0.0,1.0), 1.2 );

		vec3 brdf  = 1.0*vec3(0.40,0.40,0.40)*amb*ao;
			 brdf += 1.0*vec3(1.00,1.00,1.00)*key*ao;
			 brdf += 1.0*vec3(0.40,0.40,0.40)*bac*ao;

        // material		
		vec3 rgb = vec3(1.0);
		rgb = mix( rgb, vec3(1.0,0.80,0.2), clamp(6.0*tra.y,0.0,1.0) );
		rgb = mix( rgb, vec3(1.0,0.55,0.0), pow(clamp(1.0-2.0*tra.z,0.0,1.0),8.0) );

		// color
		col = rgb*brdf*exp(-0.2*t);
	}

	col = sqrt(col);
	
	col = mix( col, smoothstep( 0.0, 1.0, col ), 0.25 );
	
	gl_FragColor=vec4(col,1.0);
}

                #endif                          
                ENDGLSL        
            }
     }
    FallBack "Diffuse"
}