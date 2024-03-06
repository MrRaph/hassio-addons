## 0.6.2

- Update woob dependencies install method

## 0.6.1

- Remove support for i386 architecture

## 0.6.0

- Bump Kresus to 0.19.0

## 0.5.1

- Fix AppArmor profile

## 0.5.0

- Attempt using `alpine:edge` as base image

## 0.4.2

- Fix AppArmor profile

## 0.4.1

- Reinstall py3-lxml by default

## 0.4.0

- Remove python dependencies from Dockerfile to prevent
  incompatibility with woob requirements

## 0.3.0

- Use `s6-setuidgid` instead of `su-exec`
- Set AppArmor in complain mode
