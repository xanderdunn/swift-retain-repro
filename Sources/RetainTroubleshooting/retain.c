#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>

#if DEBUG

extern void *(*_swift_retain)(void *);

static void *(*_old_swift_retain)(void*);

size_t swift_retainCount(void *);

const char *swift_getTypeName(void *classObject, _Bool qualified);

static void *swift_retain_hook(void *object) {
  if (swift_retainCount(object) > 21000) {
      void *isa = *(void**)object;
      const char *className = swift_getTypeName(isa, 1);

      time_t mytime = time(NULL);
      char * time_str = ctime(&mytime);
      time_str[strlen(time_str)-1] = '\0';
      fprintf(stderr, "%s: %s at %p has %zu retains!\n", time_str, className, object, swift_retainCount(object));
      if (swift_retainCount(object) > 1000000) {
          abort();
      }
  }
  return _old_swift_retain(object);
}

__attribute__((constructor))
static void hook_swift_retain() {
  _old_swift_retain = _swift_retain;
  _swift_retain = swift_retain_hook;
}

#endif
