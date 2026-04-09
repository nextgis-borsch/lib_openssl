# Resolve gost-engine sources: prefer git submodule at engines/gost, else clone tag v3.0.3.
if(BUILD_ENGINES AND NOT OPENSSL_NO_GOSTENG)
    set(GOST_ENGINE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/engines/gost" CACHE PATH
        "Path to gost-engine sources (git submodule https://github.com/gost-engine/engine)")

    if(NOT EXISTS "${GOST_ENGINE_SOURCE_DIR}/gost_eng.c")
        find_program(GOST_GIT NAMES git git.exe)
        if(GOST_GIT AND EXISTS "${CMAKE_SOURCE_DIR}/.git")
            execute_process(
                COMMAND ${GOST_GIT} submodule update --init --recursive "${GOST_ENGINE_SOURCE_DIR}"
                WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
                RESULT_VARIABLE _gost_subm_ec
                ERROR_QUIET
                OUTPUT_QUIET
            )
        endif()
    endif()

    if(NOT EXISTS "${GOST_ENGINE_SOURCE_DIR}/gost_eng.c")
        if(GOST_GIT)
            message(STATUS "gost-engine: cloning v3.0.3 into ${GOST_ENGINE_SOURCE_DIR}")
            execute_process(
                COMMAND ${GOST_GIT} clone --depth 1 --branch v3.0.3
                        https://github.com/gost-engine/engine.git
                        "${GOST_ENGINE_SOURCE_DIR}"
                WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
                RESULT_VARIABLE _gost_clone_ec
            )
        endif()
    endif()

    if(NOT EXISTS "${GOST_ENGINE_SOURCE_DIR}/gost_eng.c")
        message(FATAL_ERROR
            "gost-engine sources not found (expected gost_eng.c under engines/gost).\n"
            "Initialize the submodule:\n"
            "  git submodule update --init engines/gost\n"
            "Or add it:\n"
            "  git submodule add https://github.com/gost-engine/engine.git engines/gost\n"
            "  cd engines/gost && git checkout v3.0.3\n")
    endif()
endif()
