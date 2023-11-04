include $(GNUSTEP_MAKEFILES)/common.make

export messages := yes

TOOL_NAME = tool
tool_OBJC_FILES = common.m

APP_NAME = app
app_OBJC_FILES = common.m
app_CPPFLAGS = -DAPP

LIBRARY_NAME = Foo
Foo_OBJC_FILES = Foo.m
Foo_HEADER_FILES = Foo.h

FRAMEWORK_NAME = FooKit
FooKit_OBJC_FILES = Foo.m
FooKit_HEADER_FILES = Foo.h

DOCUMENT_NAME = manual
manual_TEXI_FILES = manual.texi

include $(GNUSTEP_MAKEFILES)/tool.make
include $(GNUSTEP_MAKEFILES)/application.make
include $(GNUSTEP_MAKEFILES)/library.make
include $(GNUSTEP_MAKEFILES)/framework.make
include $(GNUSTEP_MAKEFILES)/documentation.make
