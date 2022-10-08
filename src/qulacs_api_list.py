"""

This is a python script to show API for each submodules of qulacs

"""
import importlib
import inspect

import qulacs


def print_qulacs_api(pymod):
    if isinstance(pymod, str):
        pymod = importlib.import_module(f"{pymod}")

    modulename = pymod.__name__.split(".")[-1]
    classes = []
    functions = []
    for attr in sorted(pymod.__dir__()):
        if inspect.ismodule(getattr(pymod, attr)):
            continue
        if attr.startswith("_"):
            continue
        if attr[0].isupper():
            classes.append(attr)
        else:
            functions.append(attr)

    print(f"const {modulename}_classes = [")
    for c in classes:
        print("    " + ":" + c + ",")
    print("]")
    print()
    print(f"const {modulename}_functions = [")
    for c in functions:
        print("    " + ":" + c + ",")
    print("]")


def print_all():
    for attr_str in sorted(qulacs.__dir__()):
        attr = getattr(qulacs, attr_str)
        if inspect.ismodule(attr):
            module_name = attr.__name__.split(".")[-1]
            module_name = attr.__name__
            print(f"# --- {module_name} ---")
            print_qulacs_api(module_name)
            print()