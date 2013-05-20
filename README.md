ShaderToy-to-Rift
=================
My excuse for getting an Oculus Rift was that I wanted to fly through 3D fractals.   
When I found www.shadertoy.com, I concluded that it probably contained some of the fastest fractal code out there.   
So I deceided that getting that code to run under Unity3D would be my quickest way to flying through it.   

As starter I've chosen [Apollonian](https://www.shadertoy.com/view/4ds3zn) because its a very fast fractal.   
![Apollonian](https://github.com/PatHightree/ShaderToy-to-Rift/blob/master/README.md/Apollonian.PNG)   
Later on I'd love to have a go at the [juliabulb](https://www.shadertoy.com/view/MdfGRr) and [mandelbulb](https://www.shadertoy.com/view/4ss3Dn) shaders, but they are pretty expensive.

Caveat
======
The shader code is GLSL, so it only runs in OpenGL mode.   
Therefore you have to run Unity with the **-forceopengl** option!

Credits
=======
All fractal shader code is by the awesome hackers at ShaderToy.com, I just massaged it into Unity3D.   
The Oculus Rift handling code was based on the Oculus Unity integration package.
