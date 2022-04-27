project(
    'com.github.zenitsudev.manager',
    'vala', 'c',
    version: '0.1'
)

granite_dep = dependency('granite-7')
adwaita_dep = dependency('libadwaita-1')
gtk_dep = dependency('gtk4')
posix_dep = meson.get_compiler('vala').find_library('posix')


dependencies = [
    granite_dep,
    adwaita_dep,
    gtk_dep,
    posix_dep,
    meson.get_compiler ('c').find_library ('m', required : false),
]

# subdir('po')
subdir('src')
# subdir('data')

# meson.add_install_script('meson/post_install.py')
