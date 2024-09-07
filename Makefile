# Variables
FLUTTER = flutter
APP_NAME = podcast_client

# Flutter commands
run:
	$(FLUTTER) run

build-apk:
	$(FLUTTER) build apk

build-ios:
	$(FLUTTER) build ios

test:
	$(FLUTTER) test

clean:
	$(FLUTTER) clean

get-packages:
	$(FLUTTER) pub get

format:
	$(FLUTTER) format .

lint:
	$(FLUTTER) analyze

# Install dependencies
install-deps: get-packages

# Run tests and lint checks
ci-check: lint test

# Clean, fetch dependencies, run tests, and lint
all: clean install-deps ci-check