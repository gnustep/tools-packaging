import argparse

desc = 'Builds the GNUstep Objective-C 2.0 Toolchain for dpkg-based Distributions.'

def main():
    parser = argparse.ArgumentParser(description=desc)
    _ = parser.parse_args()

    print("python main function")


if __name__ == '__main__':
    main()