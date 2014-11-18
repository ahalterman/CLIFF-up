sudo apt-get update
echo "Installing basic packages..."
sudo apt-get install git <<-EOF
yes
EOF
sudo apt-get install curl <<-EOF
yes
EOF
sudo apt-get install vim <<-EOF
yes
EOF
sudo apt-get install unzip htop <<-EOF
yes
EOF
echo "Installing Java and JDK"
sudo apt-get install openjdk-7-jre <<-EOF
yes
EOF
sudo apt-get install openjdk-7-jdk <<-EOF
yes
EOF

echo "Configuring Java and things"

set JRE_HOME=/usr/lib/jvm/java-7-openjdk-amd64

cd
sudo wget https://raw.githubusercontent.com/ahalterman/CLIFF-up/master/bashrc
sudo rm ~/.bashrc
sudo mv bashrc ~/.bashrc
. ~/.bashrc

cd /usr/lib/jvm/ 
sudo chmod +x /usr/lib/jvm/java-7-openjdk-amd64

cd /usr/lib/jvm/java-7-openjdk-amd64
sudo chmod 777 -R *

echo "Install Maven"
# Why does stupid Maven install Java 6?
sudo apt-get install maven <<-EOF
yes
EOF

# tell it again that we do indeed want Java 7
set JRE_HOME=/usr/lib/jvm/java-7-openjdk-amd64

sudo update-alternatives --config java  <<-EOF
2
EOF

echo "Download Tomcat"
cd
sudo wget http://download.nextag.com/apache/tomcat/tomcat-7/v7.0.57/bin/apache-tomcat-7.0.57.tar.gz
sudo tar -xvzf apache-tomcat-7.0.57.tar.gz
#sudo rm apache-tomcat-7.0.57.tar.gz

# get tomcat users set up correctly
cd
cd /home/vagrant/apache-tomcat-7.0.57/conf
sudo rm tomcat-users.xml
sudo wget https://raw.githubusercontent.com/ahalterman/CLIFF-up/master/tomcat-users.xml

echo "Boot Tomcat"
$CATALINA_HOME/bin/startup.sh

echo "Downloading CLAVIN..."
cd
sudo git clone https://github.com/Berico-Technologies/CLAVIN.git
cd CLAVIN
echo "Downloading placenames file from Geonames..."
sudo wget http://download.geonames.org/export/dump/allCountries.zip
sudo unzip allCountries.zip
sudo rm allCountries.zip

echo "Compiling CLAVIN"
sudo mvn compile

echo "Building Lucene index of placenames--this is the slow one"
MAVEN_OPTS="-Xmx4g" mvn exec:java -Dexec.mainClass="com.bericotech.clavin.index.IndexDirectoryBuilder"

sudo mkdir /etc/cliff2
sudo ln -s /home/vagrant/CLAVIN/IndexDirectory /etc/cliff2/IndexDirectory

cd ~/.m2/
sudo rm settings.xml
sudo wget https://raw.githubusercontent.com/ahalterman/CLIFF-up/master/settings.xml

echo "Download CLIFF"
cd
sudo git clone https://github.com/c4fcm/CLIFF
cd CLIFF
sudo rm pom.xml 
sudo wget https://raw.githubusercontent.com/ahalterman/CLIFF-up/master/pom.xml

sudo mvn tomcat7:deploy -DskipTests

echo "Move files around and redeploy"
sudo mv /home/vagrant/CLIFF/target/CLIFF-2.0.0.war /home/vagrant/apache-tomcat-7.0.57/webapps/
$CATALINA_HOME/bin/shutdown.sh
$CATALINA_HOME/bin/startup.sh

