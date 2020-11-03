#!/usr/bin/env bash


# Mono repositories
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/ubuntu stable-"`lsb_release -cs`" main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
sudo apt-get update

# Mono for boogie, python3 for solc-verify
sudo apt-get install -y \
	mono-complete \
	python3 \
	python3-pip

# PSUtil for timeout kill
sudo pip3 install psutil

# CVC4 1.7
wget https://github.com/CVC4/CVC4/releases/download/1.7/cvc4-1.7-x86_64-linux-opt -O cvc4
sudo install cvc4 /usr/bin/cvc4

# Yices2 2.6.1
pushd .
wget http://yices.csl.sri.com/releases/2.6.1/yices-2.6.1-x86_64-pc-linux-gnu-static-gmp.tar.gz
tar xzvf yices*
rm yices*.tar.gz
cd yices*
sudo ./install-yices
popd

# Boogie with Yices2 support
pushd .
git clone https://github.com/dddejan/boogie.git
cd boogie
mozroots --import --sync
wget https://nuget.org/nuget.exe
mono ./nuget.exe restore Source/Boogie.sln
msbuild Source/Boogie.sln
popd

dotnet build Sources\VeriSol.sln

dotnet tool install --global SolToBoogieTest --version 0.1.1-alpha --add-source %VERISOL_PATH%/nupkg/

VeriSolRegressionRunner %VERISOL_PATH%/Test/
