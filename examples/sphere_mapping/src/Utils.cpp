/*
  Parallel Computation of Spherical Parameterizations for Mesh Analysis
  Copyright (C) 2011 Athanasiadis Theodoros and Fudos Ioannis

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/

#include "Utils.h"
#include <fstream>
#include <iostream>

bool loadTextFile(const std::string &strFile, std::string &strText)
{
    std::ifstream fin(strFile.c_str());
    
    if( fin == NULL ) {
        std::cerr << "Failed to open : " << strFile << std::endl;
        return false;
    }

    strText = std::string( (std::istreambuf_iterator<char>(fin)),
                 std::istreambuf_iterator<char>());
    return true;
}