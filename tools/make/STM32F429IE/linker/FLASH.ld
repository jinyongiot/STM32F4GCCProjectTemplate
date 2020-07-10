SEARCH_DIR("./tools/make/STM3F429IE/linker")

/* include the common STMxxx sub-script */
INCLUDE "COMMON.ld"

/* include the memory spaces definitions sub-script */
INCLUDE "DEF.ld"

/* include the sections management sub-script for FLASH mode */
INCLUDE "sections_FLASH.ld"
