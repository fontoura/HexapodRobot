Greetings!

This repo contains files of the Capstone Project we presented in order to get our Computer Engineering degrees, back in 2013. The project was published in Portuguese language only, but the university demanded we include an 'abstract' section written in Engish. The abstract section as published is at the end of this file. If you are an English speaker and gets interested in this project, feel free to contact us!

Our monograph (in Portuguese) can be found at: <http://repositorio.roca.utfpr.edu.br/jspui/handle/1/954>.

There is a small difference between the firmware version in this repo and the one we presented back in 2013: the version in this repo uses FreeRTOS instead of µC/OS-II for RTOS. We changed the operating system in order to avoid licensing problems.

The files are organized as follows:

./Driver - Eclipse projects with the driger and the UI's for PC and Android.

./HexapodHW - Quartus project with the reconfigurable hardware and firmware.

./PCI - Printed circuit board (in Portuguese: 'placa de circuito impresso'/'PCI') for Eagle.

Best regards.

Felipe Michels Fontoura, Leandro Piekarski do Nascimento, Lucas Longen Gioppo

--------------------------------------------------

FONTOURA, Felipe Michels; GIOPPO, Lucas Longen; DO NASCIMENTO, Leandro Piekarski. Robô Hexápode Controlado por FPGA (Hexapod Robot Controlled by FPGA). 2013. Monograph (Undergraduate) – Computer Engineering Course, UTFPR, Curitiba, Brazil.

Hexapod robots are commonly used as platform for studies on robotics, hence it is of academic interest to develop such kind of robot with open specifications. The main goal ot this project is the development of a hexapod robot controlled by FPGA, receiving highlevel commands from a computer. The development follows a spiral model in three stages: project, development and tests. Many studies were necessary in order to make the project possible, especially those regarding inverse kinematics. The project itself is divided in six parts: robot mechanics, motor electronics, robot control hardware, firmware, driver and user interface software. The robot is based on a MSR-H01 mechanical structure developed by Micromagic Systems which requires three motors per leg. There are six Corona DS329MG motors on the shoulders, and twelve BMS-620MG on other joints, all supplied by an ATX power source (140W at 5V) and optically isolated from remaining hardware. The robot control hardware includes the FPGA and its peripherals such as optocouplers, magnetometer (HMC5883), accelerometer (ADXL345) and the XBee device. The FPGA generates the control signals for the servos and other devices while embedding a NIOS II processor with 32-bit RISC architecture, capable of performances up to 250 DMIPS. The firmware was developed in C++ and is responsible for reading the sensors, sending control signals to the servos and connecting to the driver, developed in Java, through the XBee channel. The user interface software allows the user to send commands to the robot through the driver and displays readings from the sensors. The result was a robot capable of moving using a combination of inverse kinematics and other technologies. Technologically, the project has the quality of being extensible, as the FPGA allows hardware reprogramming and the software is split into individual modules. Socioeconomically, the flexibility of the robot allows using it for both teaching and research. It is also remarkable that its specification is open and so more robots like this one can be made with little effort.

Keywords: Hexapod Robot. Servomotor, Reconfigurable Logic. Object-Oriented. Spiral Method
