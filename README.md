# DevOps-Netology

ДЗ по блоку "Инструменты Git":

1. полный хэш и комментарий коммита, хэш которого начинается на aefea:
# git show aefea ИЛИ git show aefea --stat
aefead2207ef7e2aa5dc81a34aedf0cad4c32545
Update CHANGELOG.md

2. какому тегу соответствует коммит 85024d3:
# git show 85924d3 ИЛИ git show 85924d3 --stat
tag: v0.12.23

3. кол-во родителей у коммита b8d720 и их хэши:
# git log --pretty=%P -n 1 b8d720
56cd7859e05c36c06b56d013b55a252d0bb7e158
9ea88f22fc6269854151c571162c5bcf958bee2b

4. хэши и комментарии всех коммитов, которые были сделаны между тегами v0.12.23 и v0.12.24:
# git log --pretty=format:"%H %s" v0.12.23..v0.12.24
33ff1c03bb960b332be3af2e333462dde88b279e v0.12.24
b14b74c4939dcab573326f4e3ee2a62e23e12f89 [Website] vmc provider links
3f235065b9347a758efadc92295b540ee0a5e26e Update CHANGELOG.md
6ae64e247b332925b872447e9ce869657281c2bf registry: Fix panic when server is unreachable
5c619ca1baf2e21a155fcdb4c264cc9e24a2a353 website: Remove links to the getting started guide's old location
06275647e2b53d97d4f0a19a0fec11f6d69820b5 Update CHANGELOG.md
d5f9411f5108260320064349b757f55c09bc4b80 command: Fix bug when using terraform login on Windows
4b6d06cc5dcb78af637bbb19c198faff37a066ed Update CHANGELOG.md
dd01a35078f040ca984cdd349f18d0b67e486c35 Update CHANGELOG.md
225466bc3e5f35baa5d07197bbc079345b77525e Cleanup after v0.12.23 release

5. коммит, в котором была создана функция func providerSource:
# git log -S "func providerSource(" --pretty=format:"%h, %an, %s"
8c928e835, Martin Atkins, main: Consult local directories as potential mirrors of providers

6. все коммиты, где была изменена функция globalPluginDirs:
# сначала узнаём, в каком файле эта функция была импортирована изначально через git grep -p "globalPluginDirs"
plugins.go=import ( ...

# затем по этому файлу ищем все изменения по ней через git log -L :globalPluginDirs:plugins.go -s
78b12205587fe839f10d946ea3fdc06719decb05
52dbf94834cb970b510f2fba853a5b49ad9b1a46
41ab0aef7a0fe030e84018973a64135b11abcd70
66ebff90cdfaa6938f26f908c7ebad8d547fea17
8364383c359a6b738a436d1b7745ccdce178df47

7. узнаём автора функции synchromizedWriters:
# git log -SsynchronizedWriters --oneline --pretty=format:"%h %ad %an"
# получаем 3 результата, по первому по дате определяем автора:
Martin Atkins