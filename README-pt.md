Olá!

Neste repositório, estão os arquivos do Trabalho de Conclusão de Curso (TCC) que apresentamos para concluir o curso de Engenharia de Computação, em 2013. O resumo do projeto está no final deste arquivo.

A monografia pode ser encontrada em: <http://repositorio.roca.utfpr.edu.br/jspui/handle/1/954>.

Há pequenas diferenças entre o firmware que colocamos neste repositório e o apresentado na época: a versão do repositório usa o FreeRTOS em lugar do µC/OS-II como sistema operacional. Nós mudamos o sistema operacional para evitar problemas com a licença.

Os arquivos estão organizados da seguinte forma:

./Driver - Projetos do Eclipse com o driver e interfaces gráficas para PC e Android.
./HexapodHW - Projeto Quartus com o hardware reconfigurável e com o firmware.
./PCI - Arquivos da placa de circuito impresso (PCI) em formato Eagle.

Att.

Felipe Michels Fontoura, Leandro Piekarski do Nascimento, Lucas Longen Gioppo

--------------------------------------------------

FONTOURA, Felipe Michels; GIOPPO, Lucas Longen; DO NASCIMENTO, Leandro Piekarski. Robô Hexápode Controlado por FPGA. 2013. Monografia (Graduação) – Curso de Engenharia de Computação, UTFPR, Curitiba, Brasil.

Robôs hexápodes são comumente utilizados como ferramenta de estudo de robótica, logo é de interesse acadêmico a elaboração de um robô hexápode com especificação aberta. O objetivo geral do projeto descrito é desenvolver um robô hexápode controlado por uma FPGA, recebendo comandos de um computador. O desenvolvimento segue o processo de desenvolvimento em espiral, em três etapas: projeto, construção e testes. Foram necessários diversos estudos para sua concretização, especialmente o da cinemática inversa. O projeto constitui-se de seis partes: mecânica do robô, eletrônica dos motores, hardware de controle robô, firmware, driver de comunicação e software de interface gráfica. A estrutura mecânica é a MSR-H01, desenvolvida pela Micromagic Systems, com três motores por pata. Utilizaram-se seis motores Corona DS329MG nos ombros, e doze BMS-620MG nas demais articulações, todos alimentados por uma fonte ATX (140W em regime na linha de 5V), isolada do restante do hardware por acoplamento ótico. O hardware de controle do robô engloba a FPGA e seus periféricos: os optoacopladores dos motores, o magnetômetro (HMC5883), o acelerômetro (ADXL345) e o módulo XBee. A FPGA gera os sinais de controle para os motores e para os demais dispositivos e embarca um processador NIOS II, com arquitetura RISC de 32 bits de até 250 DMIPS. O firmware, desenvolvido em linguagem C++, é responsável pela leitura dos sensores, por enviar sinais de controle para os motores e por comunicar-se com o driver, desenvolvido em Java, através do módulo XBee. O software de interface gráfica permite ao usuário enviar comandos de movimentação para o robô através do driver e apresenta leituras dos sensores. O resultado final foi um robô capaz de movimentar-se usando cinemática e diversas tecnologias acopladas. Tecnologicamente, o projeto se destaca pela extensibilidade, pois a FPGA permite reprogramação do hardware e o software é modular. Socioeconômicamente, a flexibilidade do robô permite utilização em atividades de ensino e pesquisa. Além disso, sua documentação e sua especificação são abertas, de forma que é possível replicá-lo sem grande esforço.

Palavras-chave: Robô Hexápode. Servomotor. Lógica Reconfigurável. Orientado a objetos. Desenvolvimento em Espiral. 