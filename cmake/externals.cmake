# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

include(ExternalProject)
string(REPLACE ")$" "|INSTALL_ARGS)$" _ep_keywords_ExternalProject_Add ${_ep_keywords_ExternalProject_Add})

get_filename_component(GIT_PATH ${GIT_EXECUTABLE} PATH)
find_program(PATCH_EXECUTABLE patch HINTS "${GIT_PATH}" "${GIT_PATH}/../bin")
if (NOT PATCH_EXECUTABLE)
   message(FATAL_ERROR "patch not found")
endif()

set(EP_BASE "${CMAKE_BINARY_DIR}/ep_base")
set_property(DIRECTORY PROPERTY EP_BASE ${EP_BASE})
set(SANDBOX_CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${EP_BASE} -DEP_BASE=${EP_BASE} -DLUA_SANDBOX_INCLUDE=${CMAKE_SOURCE_DIR}/include -DUSE_RPATH=false --no-warn-unused-cli)
set(LUA_INCLUDE_DIR "${EP_BASE}/include/${PROJECT_NAME}")

if (LUA_JIT)
    message(FATAL_ERROR, "LuaJIT support has not been added back in yet, issue #66")
    set(LUA_PROJECT "luajit-2_0_2")
    if(MSVC)
        externalproject_add(
            ${LUA_PROJECT}
            BUILD_IN_SOURCE 1
            URL http://luajit.org/download/LuaJIT-2.0.2.tar.gz
            URL_MD5 112dfb82548b03377fbefbba2e0e3a5b
            PATCH_COMMAND ${PATCH_EXECUTABLE} -p1 < ${CMAKE_CURRENT_LIST_DIR}/luajit-2_0_2.patch
            CONFIGURE_COMMAND ""
            BUILD_COMMAND ${CMAKE_COMMAND} -E chdir src msvcbuild.bat
            INSTALL_COMMAND ${CMAKE_COMMAND} -E copy src/lua.dll ${EP_BASE}/lib/lua.dll
            COMMAND ${CMAKE_COMMAND} -E copy src/lua.lib ${EP_BASE}/lib/lua.lib
            COMMAND ${CMAKE_COMMAND} -E copy src/lauxlib.h "${LUA_INCLUDE_DIR}/lauxlib.h"
            COMMAND ${CMAKE_COMMAND} -E copy src/luaconf.h "${LUA_INCLUDE_DIR}/luaconf.h"
            COMMAND ${CMAKE_COMMAND} -E copy src/lua.h "${LUA_INCLUDE_DIR}/lua.h"
            COMMAND ${CMAKE_COMMAND} -E copy src/luajit.h "${LUA_INCLUDE_DIR}/luajit.h"
            COMMAND ${CMAKE_COMMAND} -E copy src/lualib.h "${LUA_INCLUDE_DIR}/lualib.h"
        )
    elseif(UNIX)
        externalproject_add(
            ${LUA_PROJECT}
            BUILD_IN_SOURCE 1
            URL http://luajit.org/download/LuaJIT-2.0.2.tar.gz
            URL_MD5 112dfb82548b03377fbefbba2e0e3a5b
            PATCH_COMMAND ${PATCH_EXECUTABLE} -p1 < ${CMAKE_CURRENT_LIST_DIR}/luajit-2_0_2.patch
            CONFIGURE_COMMAND ""
            BUILD_COMMAND make
            INSTALL_COMMAND ${CMAKE_COMMAND} -E copy src/libluajit.a ${EP_BASE}/lib/liblua.a
            COMMAND ${CMAKE_COMMAND} -E copy src/lauxlib.h "${LUA_INCLUDE_DIR}/lauxlib.h"
            COMMAND ${CMAKE_COMMAND} -E copy src/luaconf.h "${LUA_INCLUDE_DIR}/luaconf.h"
            COMMAND ${CMAKE_COMMAND} -E copy src/lua.h "${LUA_INCLUDE_DIR}/lua.h"
            COMMAND ${CMAKE_COMMAND} -E copy src/luajit.h "${LUA_INCLUDE_DIR}/luajit.h"
            COMMAND ${CMAKE_COMMAND} -E copy src/lualib.h "${LUA_INCLUDE_DIR}/lualib.h"
        )
    else()
        message(FATAL_ERROR "Cannot use LuaJIT with ${CMAKE_GENERATOR}")
    endif()
else()
    set(LUA_PROJECT "lua-5_1_5")
    externalproject_add(
        ${LUA_PROJECT}
        GIT_REPOSITORY https://github.com/trink/lua.git
        GIT_TAG 477c0b5ae0932953ee41ab7cd24098c23e3e33c3
        CMAKE_ARGS ${SANDBOX_CMAKE_ARGS}
        INSTALL_DIR ${EP_BASE}
        INSTALL_ARGS "install/strip"
    )
endif()

externalproject_add(
    lua_lpeg
    GIT_REPOSITORY https://github.com/LuaDist/lpeg.git
    GIT_TAG baf0dc90b9278360be719dbfb8e56d34ce3c61bd
    UPDATE_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_DIR}/FindLua.cmake <SOURCE_DIR>/cmake
    CMAKE_ARGS ${SANDBOX_CMAKE_ARGS}
    INSTALL_DIR ${EP_BASE}
    INSTALL_ARGS "install/strip"
)
add_dependencies(lua_lpeg ${LUA_PROJECT})

externalproject_add(
    lua_cjson
    GIT_REPOSITORY https://github.com/trink/lua-cjson.git
    GIT_TAG 3c8321cbfc6bea944974e046da82deca38e66587
    CMAKE_ARGS ${SANDBOX_CMAKE_ARGS}
    INSTALL_DIR ${EP_BASE}
    INSTALL_ARGS "install/strip"
)
add_dependencies(lua_cjson ${LUA_PROJECT})

externalproject_add(
    lua_struct
    GIT_REPOSITORY https://github.com/trink/struct.git
    GIT_TAG 5cf31819bee0d829d058cb5219e95ef0b1dd43a8
    UPDATE_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_DIR}/FindLua.cmake <SOURCE_DIR>/cmake
    CMAKE_ARGS ${SANDBOX_CMAKE_ARGS}
    INSTALL_DIR ${EP_BASE}
    INSTALL_ARGS "install/strip"
)
add_dependencies(lua_struct ${LUA_PROJECT})

externalproject_add(
    lua_bloom_filter
    GIT_REPOSITORY https://github.com/mozilla-services/lua_bloom_filter.git
    GIT_TAG 1afb5fe85adec5750238c5ebd7d6d95e7993f122
    CMAKE_ARGS ${SANDBOX_CMAKE_ARGS}
    INSTALL_DIR ${EP_BASE}
    INSTALL_ARGS "install/strip"
)

externalproject_add(
    lua_circular_buffer
    GIT_REPOSITORY https://github.com/mozilla-services/lua_circular_buffer.git
    GIT_TAG e87bcc0a3ae29c5a7acaabbb7b1f2b56700769c6
    CMAKE_ARGS ${SANDBOX_CMAKE_ARGS}
    INSTALL_DIR ${EP_BASE}
    INSTALL_ARGS "install/strip"
)

externalproject_add(
    lua_hyperloglog
    GIT_REPOSITORY https://github.com/mozilla-services/lua_hyperloglog.git
    GIT_TAG 5deeaf7c24088dada8d80529951502aa4a55c8ab
    CMAKE_ARGS ${SANDBOX_CMAKE_ARGS}
    INSTALL_DIR ${EP_BASE}
    INSTALL_ARGS "install/strip"
)

externalproject_add(
    lua_cuckoo_filter
    GIT_REPOSITORY https://github.com/mozilla-services/lua_cuckoo_filter.git
    GIT_TAG cfb311a433ed7e4c8224ca99ab58b54302037b6d
    CMAKE_ARGS ${SANDBOX_CMAKE_ARGS}
    INSTALL_DIR ${EP_BASE}
    INSTALL_ARGS "install/strip"
)

externalproject_add(
    lua_tdigest
    GIT_REPOSITORY https://github.com/vitillo/lua_tdigest.git
    GIT_TAG 60c717714aa69930bbf78cce3120d30b6a5aef15
    CMAKE_ARGS ${SANDBOX_CMAKE_ARGS}
    INSTALL_DIR ${EP_BASE}
    INSTALL_ARGS "install/strip"
)
