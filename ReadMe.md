_Jan Haller's lib has been archived. This is a copy kept alive against the still developing SFML (v3)._

## Porting to SFML 3:

+ The lib compiles cleanly against the master (pre-3.0) branch of [SFML](https://github.com/SFML/SFML/),
  e.g. with a script like this on Windows:

    ~~~~
    set SFML=C:/SW/devel/lib/sfml/master
    set THOR=.
    set INCLUDE=%THOR%/include;%THOR%/extlibs/aurora/include;%SFML%/include;%INCLUDE%
    md out
    cl -W4 -DSFML_STATIC -O2 -std:c++20 -MD -EHsc -Foout/ -c src/*.cpp
    lib -out:out/thor.lib out/*.obj
    ~~~~

+ All the examples compile cleanly, and run. (But not all run correctly yet!)


### TODO:

- Makefile for GCC!

_The original (upstream) README:_

-------------------------------------------------------------------------------------------------    
    
![Thor C++ Library](http://www.bromeon.ch/libraries/thor/thor.png)

# Thor C++ Library

Thor is an open-source and cross-platform C++ library. It extends the multimedia library SFML with higher-level features such as:

* Animations
* Particle systems
* Resource management
* Time measurement utilities
* Event handling and callbacks
* Delaunay triangulation
* Color gradients
* Vector algebra
* ...

For a full list of features as well as tutorials and API documentation, visit the [project homepage](http://www.bromeon.ch/libraries/thor).

Thor uses the build system CMake and can be compiled for Visual C++, g++ and Clang compilers, as long as they provide at least partial C++11 support. Besides SFML, the library depends on my other project Aurora, which is shipped with Thor.


## Development status

I am no longer actively developing Thor. The library has reached a state where I'm relatively happy with it, and it's well usable for SFML 2.
Improvements are of course always possible, some of them simply because tooling has moved on (e.g. CMake).

There's a chance I will update Thor for SFML 3 once it becomes more stable, but only if there is significant interest and I find the time to work on it.


## License

Both Thor and Aurora are licensed under [zlib/libpng](http://opensource.org/licenses/zlib-license.php), which is very permissive. You can use the code in free and commercial products, open- or closed-source.
I would appreciate if you left a short note that you used one my libraries, but it's not required.


## Author and contact

Thor has been developed by Jan Haller since 2011.

* E-mail: bromeon@gmail.com
* Project homepage: http://www.bromeon.ch/libraries/thor
* GitHub repository: https://github.com/Bromeon/Thor
