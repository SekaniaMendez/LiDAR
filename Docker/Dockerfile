###############################################################################
# Imagen base
# - Usamos Ubuntu 24.04 (Noble), que es el target oficial de ROS 2 Jazzy.
# - Es multi-arch, así que en Apple Silicon se resolverá a linux/arm64.
###############################################################################
FROM ubuntu:24.04
SHELL ["/bin/bash", "-lc"]
###############################################################################
# Variables de entorno globales
# - DEBIAN_FRONTEND: evita prompts interactivos en apt.
# - Locale a en_US.UTF-8 para evitar warnings con tools que esperan UTF-8.
###############################################################################
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

###############################################################################
# Paquetes base útiles:
# - locales: generar UTF-8
# - curl, gnupg, lsb-release: para agregar repos y claves de ROS 2
# - sudo, git, build-essential: tooling general para dev
###############################################################################
RUN apt-get update && apt-get install -y \
    locales curl gnupg lsb-release sudo git build-essential \
    # Genera locales en_US
    && locale-gen en_US en_US.UTF-8 \
    # Limpieza de caché de apt para achicar la imagen final
    && rm -rf /var/lib/apt/lists/*

###############################################################################
# Clave y repositorio oficial de ROS 2
# - Añadimos la key en /usr/share/keyrings (método moderno con signed-by)
# - Creamos /etc/apt/sources.list.d/ros2.list apuntando a packages.ros.org
# - $UBUNTU_CODENAME se expande a "noble" dentro del contenedor
###############################################################################
RUN set -euo pipefail; \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
      | tee /usr/share/keyrings/ros-archive-keyring.gpg >/dev/null && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
    http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
      > /etc/apt/sources.list.d/ros2.list

###############################################################################
# Instalación de ROS 2 Jazzy (metapaquete 'desktop') + herramientas:
# - ros-jazzy-desktop: rviz2, rqt, demos, etc. (si solo quieres minimal, usa 'ros-jazzy-ros-base')
# - python3-rosdep, python3-colcon-common-extensions: build & deps
# - rosdep init/update: prepara la base de datos de dependencias
# Nota: 'rosdep update' puede fallar en redes corporativas; por eso el "|| true".
###############################################################################
RUN apt-get update && apt-get install -y \
      ros-jazzy-desktop \
      python3-rosdep python3-colcon-common-extensions \
    && rosdep init \
    && rosdep update || true \
    && rm -rf /var/lib/apt/lists/*

###############################################################################
# (Opcional) Usuario no-root para desarrollo más cómodo:
# - Crea 'dev' con shell bash, homedir, y sudo sin password.
# - Esto evita usar root para compilar/workspace y mejora seguridad.
###############################################################################
RUN useradd -ms /bin/bash dev \
 && usermod -aG sudo dev \
 && echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-dev-nopasswd

###############################################################################
# Ajustes de shell y directorio de trabajo
# - SHELL /bin/bash -lc: asegura que los RUN siguientes usen bash login-like.
# - WORKDIR /work: donde montarás tu workspace con -v ~/ros2_ws:/work
###############################################################################
SHELL ["/bin/bash", "-lc"]
WORKDIR /ros2_ws
USER dev

###############################################################################
# Auto-source de ROS 2:
# - Añade 'source /opt/ros/jazzy/setup.bash' al ~/.bashrc del usuario 'dev'
#   para que las nuevas sesiones ya tengan el entorno de ROS 2.
###############################################################################
RUN echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc

###############################################################################
# (Opcional) Dependencias gráficas ligeras para RViz2 vía X11/VNC:
# - No agregamos nada aquí por defecto para mantener la imagen liviana.
# - Si vas a usar RViz2 con XQuartz, exporta DISPLAY desde 'container run'.
# - Si prefieres VNC, puedes instalar un escritorio y un server VNC aquí.
###############################################################################

# Fin del Dockerfile