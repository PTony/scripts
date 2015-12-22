#!/bin/bash
echo "$0"

# list interface with HWaddress
interfaces=(`ifconfig -a | grep 'Ethernet.*HWaddr' | cut -d ' ' -f 1`)
mac_addresses=(`ifconfig -a | grep 'Ethernet.*HWaddr' | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'`)
echo -e "There are ${#interfaces[@]} interface(s) you can change MAC address"
for i in ${!interfaces[@]}
do
    echo -e '\t' $(($i+1))")" ${interfaces[$i]} "\t("${mac_addresses[$i]}")"
done

echo -e "\n Select the number of the interface to change"
PS3="Your choice: "
select i in ${interfaces[*]} QUIT
do
    if [ $REPLY -ge 1 -a $REPLY -le ${#interfaces[@]} ]; then
        itf_num=$(( $REPLY -1 ))
        echo -e '\t' ${interfaces[$itf_num]} "  ("${mac_addresses[$itf_num]}")"
        break
    elif [ $REPLY -eq $(( ${#interfaces[@]} +1 )) ]; then
        echo "exit"
        exit 0
    else
        echo "error"
    fi
done

# get the OUI from a list of legit OUIs
OUI_ARRAY=(
    00-00-00   # XEROX CORPORATION
    00-00-01   # XEROX CORPORATION
    00-00-02   # XEROX CORPORATION
    00-00-03   # XEROX CORPORATION
    00-00-04   # XEROX CORPORATION
    00-00-05   # XEROX CORPORATION
    00-00-06   # XEROX CORPORATION
    00-00-07   # XEROX CORPORATION
    00-00-08   # XEROX CORPORATION
    00-00-09   # XEROX CORPORATION
    00-00-0A   # OMRON TATEISI ELECTRONICS CO.
    00-00-0B   # MATRIX CORPORATION
    00-00-0C   # Cisco Systems, Inc
    00-00-0D   # FIBRONICS LTD.
    00-00-0E   # FUJITSU LIMITED
    00-00-0F   # NEXT, INC.
    00-00-10   # SYTEK INC.
    00-00-11   # NORMEREL SYSTEMES
    00-00-12   # INFORMATION TECHNOLOGY LIMITED
    00-00-13   # CAMEX
    00-00-14   # NETRONIX
    00-00-15   # DATAPOINT CORPORATION
    00-00-16   # DU PONT PIXEL SYSTEMS     .
    00-00-17   # Oracle
    00-00-18   # WEBSTER COMPUTER CORPORATION
    00-00-19   # APPLIED DYNAMICS INTERNATIONAL
    00-00-1A   # ADVANCED MICRO DEVICES
    00-00-1B   # NOVELL INC.
    00-00-1C   # BELL TECHNOLOGIES
    00-00-1D   # Cabletron Systems, Inc.
    00-00-1E   # TELSIST INDUSTRIA ELECTRONICA
    00-00-1F   # Telco Systems, Inc.
    00-00-20   # DATAINDUSTRIER DIAB AB
    00-00-21   # SUREMAN COMP. & COMMUN. CORP.
    00-00-22   # VISUAL TECHNOLOGY INC.
    00-00-23   # ABB INDUSTRIAL SYSTEMS AB
    00-00-24   # CONNECT AS
    00-00-25   # RAMTEK CORP.
    00-00-26   # SHA-KEN CO., LTD.
    00-00-27   # JAPAN RADIO COMPANY
    00-00-28   # PRODIGY SYSTEMS CORPORATION
    00-00-29   # IMC NETWORKS CORP.
    00-00-2A   # TRW - SEDD/INP
    00-00-2B   # CRISP AUTOMATION, INC
    00-00-2C   # AUTOTOTE LIMITED
    00-00-2D   # CHROMATICS INC
    00-00-2E   # SOCIETE EVIRA
    00-00-2F   # TIMEPLEX INC.
    00-00-30   # VG LABORATORY SYSTEMS LTD
    00-00-31   # QPSX COMMUNICATIONS PTY LTD
    00-00-32   # Marconi plc
    00-00-33   # EGAN MACHINERY COMPANY
    00-00-34   # NETWORK RESOURCES CORPORATION
    00-00-35   # SPECTRAGRAPHICS CORPORATION
    00-00-36   # ATARI CORPORATION
    00-00-37   # OXFORD METRICS LIMITED
    00-00-38   # CSS LABS
    00-00-39   # TOSHIBA CORPORATION
    00-00-3A   # CHYRON CORPORATION
    00-00-3B   # i Controls, Inc.
    00-00-3C   # AUSPEX SYSTEMS INC.
    00-00-3D   # UNISYS
    00-00-3E   # SIMPACT
    00-00-3F   # SYNTREX, INC.
    00-00-40   # APPLICON, INC.
    00-00-41   # ICE CORPORATION
    00-00-42   # METIER MANAGEMENT SYSTEMS LTD.
    00-00-43   # MICRO TECHNOLOGY
    00-00-44   # CASTELLE CORPORATION
    00-00-45   # FORD AEROSPACE & COMM. CORP.
    00-00-46   # OLIVETTI NORTH AMERICA
    00-00-47   # NICOLET INSTRUMENTS CORP.
    00-00-48   # SEIKO EPSON CORPORATION
    00-00-49   # APRICOT COMPUTERS, LTD
    00-00-4A   # ADC CODENOLL TECHNOLOGY CORP.
    00-00-4B   # ICL DATA OY
    00-00-4C   # NEC CORPORATION
    00-00-4D   # DCI CORPORATION
    00-00-4E   # AMPEX CORPORATION
    00-00-4F   # LOGICRAFT, INC.
    00-00-50   # RADISYS CORPORATION
    00-00-51   # HOB ELECTRONIC GMBH & CO. KG
    00-00-52   # Intrusion.com, Inc.
    00-00-53   # COMPUCORP
    00-00-54   # Schneider Electric
    00-00-55   # COMMISSARIAT A L`ENERGIE ATOM.
    00-00-56   # DR. B. STRUCK
    00-00-57   # SCITEX CORPORATION LTD.
    00-00-58   # RACORE COMPUTER PRODUCTS INC.
    00-00-59   # Hellige GMBH
    00-00-5A   # SysKonnect GmbH
    00-00-5B   # ELTEC ELEKTRONIK AG
    00-00-5C   # TELEMATICS INTERNATIONAL INC.
    00-00-5D   # CS TELECOM
    00-00-5E   # ICANN, IANA Department
    00-00-5F   # Sumitomo Electric Industries,Ltd
    00-00-60   # KONTRON ELEKTRONIK GMBH
    00-00-61   # GATEWAY COMMUNICATIONS
    00-00-62   # BULL HN INFORMATION SYSTEMS
    00-00-63   # BARCO CONTROL ROOMS GMBH
    00-00-64   # Yokogawa Electric Corporation
    00-00-65   # Network General Corporation
    00-00-66   # TALARIS SYSTEMS, INC.
    00-00-67   # SOFT * RITE, INC.
    00-00-68   # ROSEMOUNT CONTROLS
    00-00-69   # CONCORD COMMUNICATIONS INC
    00-00-6A   # COMPUTER CONSOLES INC.
    00-00-6B   # SILICON GRAPHICS INC./MIPS
    00-00-6C   # Private
    00-00-6D   # CRAY COMMUNICATIONS, LTD.
    00-00-6E   # Artisoft Inc.
    00-00-6F   # Madge Ltd.
    00-00-70   # HCL LIMITED
    00-00-71   # ADRA SYSTEMS INC.
    00-00-72   # MINIWARE TECHNOLOGY
    00-00-73   # SIECOR CORPORATION
    00-00-74   # RICOH COMPANY LTD.
    00-00-75   # Nortel Networks
    00-00-76   # ABEKAS VIDEO SYSTEM
    00-00-77   # INTERPHASE CORPORATION
    00-00-78   # LABTAM LIMITED
    00-00-79   # NETWORTH INCORPORATED
    00-00-7A   # DANA COMPUTER INC.
    00-00-7B   # RESEARCH MACHINES
    00-00-7C   # AMPERE INCORPORATED
    00-00-7D   # Oracle Corporation
    00-00-7E   # CLUSTRIX CORPORATION
    00-00-7F   # LINOTYPE-HELL AG
    00-00-80   # CRAY COMMUNICATIONS A/S
    00-00-81   # Bay Networks
    00-00-82   # LECTRA SYSTEMES SA
    00-00-83   # TADPOLE TECHNOLOGY PLC
    00-00-84   # SUPERNET
    00-00-85   # CANON INC.
    00-00-86   # MEGAHERTZ CORPORATION
    00-00-87   # HITACHI, LTD.
    00-00-88   # Brocade Communications Systems, Inc.
    00-00-89   # CAYMAN SYSTEMS INC.
    00-00-8A   # DATAHOUSE INFORMATION SYSTEMS
    00-00-8B   # INFOTRON
    00-00-8C   # Alloy Computer Products (Australia) Pty Ltd
    00-00-8D   # Cryptek Inc.
    00-00-8E   # SOLBOURNE COMPUTER, INC.
    00-00-8F   # Raytheon
    00-00-90   # MICROCOM
    00-00-91   # ANRITSU CORPORATION
    00-00-92   # COGENT DATA TECHNOLOGIES
    00-00-93   # PROTEON INC.
    00-00-94   # ASANTE TECHNOLOGIES
    00-00-95   # SONY TEKTRONIX CORP.
    00-00-96   # MARCONI ELECTRONICS LTD.
    00-00-97   # EMC Corporation
    00-00-98   # CROSSCOMM CORPORATION
    00-00-99   # MTX, INC.
    00-00-9A   # RC COMPUTER A/S
    00-00-9B   # INFORMATION INTERNATIONAL, INC
    00-00-9C   # ROLM MIL-SPEC COMPUTERS
    00-00-9D   # LOCUS COMPUTING CORPORATION
    00-00-9E   # MARLI S.A.
    00-00-9F   # AMERISTAR TECHNOLOGIES INC.
    00-00-A0   # SANYO Electric Co., Ltd.
    00-00-A1   # MARQUETTE ELECTRIC CO.
    00-00-A2   # Bay Networks
    00-00-A3   # NETWORK APPLICATION TECHNOLOGY
    00-00-A4   # ACORN COMPUTERS LIMITED
    00-00-A5   # Tattile SRL
    00-00-A6   # NETWORK GENERAL CORPORATION
    00-00-A7   # NETWORK COMPUTING DEVICES INC.
    00-00-A8   # STRATUS COMPUTER INC.
    00-00-A9   # NETWORK SYSTEMS CORP.
    00-00-AA   # XEROX CORPORATION
    00-00-AB   # LOGIC MODELING CORPORATION
    00-00-AC   # CONWARE COMPUTER CONSULTING
    00-00-AD   # BRUKER INSTRUMENTS INC.
    00-00-AE   # DASSAULT ELECTRONIQUE
    00-00-AF   # Canberra Industries, Inc.
    00-00-B0   # RND-RAD NETWORK DEVICES
    00-00-B1   # Alpha Micro
    00-00-B2   # TELEVIDEO SYSTEMS, INC.
    00-00-B3   # CIMLINC INCORPORATED
    00-00-B4   # EDIMAX COMPUTER COMPANY
    00-00-B5   # DATABILITY SOFTWARE SYS. INC.
    00-00-B6   # MICRO-MATIC RESEARCH
    00-00-B7   # DOVE COMPUTER CORPORATION
    00-00-B8   # SEIKOSHA CO., LTD.
    00-00-B9   # MCDONNELL DOUGLAS COMPUTER SYS
    00-00-BA   # SIIG, INC.
    00-00-BB   # TRI-DATA
    00-00-BC   # Rockwell Automation
    00-00-BD   # MITSUBISHI CABLE COMPANY
    00-00-BE   # THE NTI GROUP
    00-00-BF   # SYMMETRIC COMPUTER SYSTEMS
    00-00-C0   # WESTERN DIGITAL CORPORATION
    00-00-C1   # Madge Ltd.
    00-00-C2   # INFORMATION PRESENTATION TECH.
    00-00-C3   # HARRIS CORP COMPUTER SYS DIV
    00-00-C4   # WATERS DIV. OF MILLIPORE
    00-00-C5   # ARRIS Group, Inc.
    00-00-C6   # EON SYSTEMS
    00-00-C7   # ARIX CORPORATION
    00-00-C8   # ALTOS COMPUTER SYSTEMS
    00-00-C9   # Emulex Corporation
    00-00-CA   # ARRIS Group, Inc.
    00-00-CB   # COMPU-SHACK ELECTRONIC GMBH
    00-00-CC   # DENSAN CO., LTD.
    00-00-CD   # Allied Telesis Labs Ltd
    00-00-CE   # MEGADATA CORP.
    00-00-CF   # HAYES MICROCOMPUTER PRODUCTS
    00-00-D0   # DEVELCON ELECTRONICS LTD.
    00-00-D1   # ADAPTEC INCORPORATED
    00-00-D2   # SBE, INC.
    00-00-D3   # WANG LABORATORIES INC.
    00-00-D4   # PURE DATA LTD.
    00-00-D5   # MICROGNOSIS INTERNATIONAL
    00-00-D6   # PUNCH LINE HOLDING
    00-00-D7   # DARTMOUTH COLLEGE
    00-00-D8   # NOVELL, INC.
    00-00-D9   # NIPPON TELEGRAPH & TELEPHONE
    00-00-DA   # ATEX
    00-00-DB   # British Telecommunications plc
    00-00-DC   # HAYES MICROCOMPUTER PRODUCTS
    00-00-DD   # TCL INCORPORATED
    00-00-DE   # CETIA
    00-00-DF   # BELL & HOWELL PUB SYS DIV
    00-00-E0   # QUADRAM CORP.
    00-00-E1   # GRID SYSTEMS
    00-00-E2   # ACER TECHNOLOGIES CORP.
    00-00-E3   # INTEGRATED MICRO PRODUCTS LTD
    00-00-E4   # IN2 GROUPE INTERTECHNIQUE
    00-00-E5   # SIGMEX LTD.
    00-00-E6   # APTOR PRODUITS DE COMM INDUST
    00-00-E7   # Star Gate Technologies
    00-00-E8   # ACCTON TECHNOLOGY CORP.
    00-00-E9   # ISICAD, INC.
    00-00-EA   # UPNOD AB
    00-00-EB   # MATSUSHITA COMM. IND. CO. LTD.
    00-00-EC   # MICROPROCESS
    00-00-ED   # APRIL
    00-00-EE   # NETWORK DESIGNERS, LTD.
    00-00-EF   # KTI
    00-00-F0   # SAMSUNG ELECTRONICS CO., LTD.
    00-00-F1   # MAGNA COMPUTER CORPORATION
    00-00-F2   # SPIDER COMMUNICATIONS
    00-00-F3   # GANDALF DATA LIMITED
    00-00-F4   # Allied Telesis, Inc.
    00-00-F5   # DIAMOND SALES LIMITED
    00-00-F6   # APPLIED MICROSYSTEMS CORP.
    00-00-F7   # YOUTH KEEP ENTERPRISE CO LTD
    00-00-F8   # DIGITAL EQUIPMENT CORPORATION
    00-00-F9   # QUOTRON SYSTEMS INC.
    00-00-FA   # MICROSAGE COMPUTER SYSTEMS INC
    00-00-FB   # RECHNER ZUR KOMMUNIKATION
    00-00-FC   # MEIKO
    00-00-FD   # HIGH LEVEL HARDWARE
    00-00-FE   # ANNAPOLIS MICRO SYSTEMS
    00-00-FF   # CAMTEC ELECTRONICS LTD.
    00-01-00   # EQUIP'TRANS
    00-01-01   # Private
    00-01-02   # 3COM CORPORATION
    00-01-03   # 3COM CORPORATION
    00-01-04   # DVICO Co., Ltd.
    00-01-05   # Beckhoff Automation GmbH
    00-01-06   # Tews Datentechnik GmbH
    00-01-07   # Leiser GmbH
    00-01-08   # AVLAB Technology, Inc.
    00-01-09   # Nagano Japan Radio Co., Ltd.
    00-01-0A   # CIS TECHNOLOGY INC.
    00-01-0B   # Space CyberLink, Inc.
    00-01-0C   # System Talks Inc.
    00-01-0D   # CORECO, INC.
    00-01-0E   # Bri-Link Technologies Co., Ltd
    00-01-0F   # Brocade Communications Systems, Inc.
    00-01-10   # Gotham Networks
    00-01-11   # iDigm Inc.
    00-01-12   # Shark Multimedia Inc.
    00-01-13   # OLYMPUS CORPORATION
    00-01-14   # KANDA TSUSHIN KOGYO CO., LTD.
    00-01-15   # EXTRATECH CORPORATION
    00-01-16   # Netspect Technologies, Inc.
    00-01-17   # Canal +
    00-01-18   # EZ Digital Co., Ltd.
    00-01-19   # RTUnet (Australia)
    00-01-1A   # Hoffmann und Burmeister GbR
    00-01-1B   # Unizone Technologies, Inc.
    00-01-1C   # Universal Talkware Corporation
    00-01-1D   # Centillium Communications
    00-01-1E   # Precidia Technologies, Inc.
    00-01-1F   # RC Networks, Inc.
    00-01-20   # OSCILLOQUARTZ S.A.
    00-01-21   # Watchguard Technologies, Inc.
    00-01-22   # Trend Communications, Ltd.
    00-01-23   # DIGITAL ELECTRONICS CORP.
    00-01-24   # Acer Incorporated
    00-01-25   # YAESU MUSEN CO., LTD.
    00-01-26   # PAC Labs
    00-01-27   # OPEN Networks Pty Ltd
    00-01-28   # EnjoyWeb, Inc.
    00-01-29   # DFI Inc.
    00-01-2A   # Telematica Sistems Inteligente
    00-01-2B   # TELENET Co., Ltd.
    00-01-2C   # Aravox Technologies, Inc.
    00-01-2D   # Komodo Technology
    00-01-2E   # PC Partner Ltd.
    00-01-2F   # Twinhead International Corp
    00-01-30   # Extreme Networks
    00-01-31   # Bosch Security Systems, Inc.
    00-01-32   # Dranetz - BMI
    00-01-33   # KYOWA Electronic Instruments C
    00-01-34   # Selectron Systems AG
    00-01-35   # KDC Corp.
    00-01-36   # CyberTAN Technology Inc.
    00-01-37   # IT Farm Corporation
    00-01-38   # XAVi Technologies Corp.
    00-01-39   # Point Multimedia Systems
    00-01-3A   # SHELCAD COMMUNICATIONS, LTD.
    00-01-3B   # BNA SYSTEMS
    00-01-3C   # TIW SYSTEMS
    00-01-3D   # RiscStation Ltd.
    00-01-3E   # Ascom Tateco AB
    00-01-3F   # Neighbor World Co., Ltd.
    00-01-40   # Sendtek Corporation
    00-01-41   # CABLE PRINT
    00-01-42   # Cisco Systems, Inc
    00-01-43   # Cisco Systems, Inc
    00-01-44   # EMC Corporation
    00-01-45   # WINSYSTEMS, INC.
    00-01-46   # Tesco Controls, Inc.
    00-01-47   # Zhone Technologies
    00-01-48   # X-traWeb Inc.
    00-01-49   # T.D.T. Transfer Data Test GmbH
    00-01-4A   # Sony Corporation
    00-01-4B   # Ennovate Networks, Inc.
    00-01-4C   # Berkeley Process Control
    00-01-4D   # Shin Kin Enterprises Co., Ltd
    00-01-4E   # WIN Enterprises, Inc.
    00-01-4F   # ADTRAN INC
    00-01-50   # GILAT COMMUNICATIONS, LTD.
    00-01-51   # Ensemble Communications
    00-01-52   # CHROMATEK INC.
    00-01-53   # ARCHTEK TELECOM CORPORATION
    00-01-54   # G3M Corporation
    00-01-55   # Promise Technology, Inc.
    00-01-56   # FIREWIREDIRECT.COM, INC.
    00-01-57   # SYSWAVE CO., LTD
    00-01-58   # Electro Industries/Gauge Tech
    00-01-59   # S1 Corporation
    00-01-5A   # Digital Video Broadcasting
    00-01-5B   # ITALTEL S.p.A/RF-UP-I
    00-01-5C   # CADANT INC.
    00-01-5D   # Oracle Corporation
    00-01-5E   # BEST TECHNOLOGY CO., LTD.
    00-01-5F   # DIGITAL DESIGN GmbH
    00-01-60   # ELMEX Co., LTD.
    00-01-61   # Meta Machine Technology
    00-01-62   # Cygnet Technologies, Inc.
    00-01-63   # Cisco Systems, Inc
    00-01-64   # Cisco Systems, Inc
    00-01-65   # AirSwitch Corporation
    00-01-66   # TC GROUP A/S
    00-01-67   # HIOKI E.E. CORPORATION
    00-01-68   # VITANA CORPORATION
    00-01-69   # Celestix Networks Pte Ltd.
    00-01-6A   # ALITEC
    00-01-6B   # LightChip, Inc.
    00-01-6C   # FOXCONN
    00-01-6D   # CarrierComm Inc.
    00-01-6E   # Conklin Corporation
    00-01-6F   # Inkel Corp.
    00-01-70   # ESE Embedded System Engineer'g
    00-01-71   # Allied Data Technologies
    00-01-72   # TechnoLand Co., LTD.
    00-01-73   # AMCC
    00-01-74   # CyberOptics Corporation
    00-01-75   # Radiant Communications Corp.
    00-01-76   # Orient Silver Enterprises
    00-01-77   # EDSL
    00-01-78   # MARGI Systems, Inc.
    00-01-79   # WIRELESS TECHNOLOGY, INC.
    00-01-7A   # Chengdu Maipu Electric Industrial Co., Ltd.
    00-01-7B   # Heidelberger Druckmaschinen AG
    00-01-7C   # AG-E GmbH
    00-01-7D   # ThermoQuest
    00-01-7E   # ADTEK System Science Co., Ltd.
    00-01-7F   # Experience Music Project
    00-01-80   # AOpen, Inc.
    00-01-81   # Nortel Networks
    00-01-82   # DICA TECHNOLOGIES AG
    00-01-83   # ANITE TELECOMS
    00-01-84   # SIEB & MEYER AG
    00-01-85   # Hitachi Aloka Medical, Ltd.
    00-01-86   # Uwe Disch
    00-01-87   # I2SE GmbH
    00-01-88   # LXCO Technologies ag
    00-01-89   # Refraction Technology, Inc.
    00-01-8A   # ROI COMPUTER AG
    00-01-8B   # NetLinks Co., Ltd.
    00-01-8C   # Mega Vision
    00-01-8D   # AudeSi Technologies
    00-01-8E   # Logitec Corporation
    00-01-8F   # Kenetec, Inc.
    00-01-90   # SMK-M
    00-01-91   # SYRED Data Systems
    00-01-92   # Texas Digital Systems
    00-01-93   # Hanbyul Telecom Co., Ltd.
    00-01-94   # Capital Equipment Corporation
    00-01-95   # Sena Technologies, Inc.
    00-01-96   # Cisco Systems, Inc
    00-01-97   # Cisco Systems, Inc
    00-01-98   # Darim Vision
    00-01-99   # HeiSei Electronics
    00-01-9A   # LEUNIG GmbH
    00-01-9B   # Kyoto Microcomputer Co., Ltd.
    00-01-9C   # JDS Uniphase Inc.
    00-01-9D   # E-Control Systems, Inc.
    00-01-9E   # ESS Technology, Inc.
    00-01-9F   # ReadyNet
    00-01-A0   # Infinilink Corporation
    00-01-A1   # Mag-Tek, Inc.
    00-01-A2   # Logical Co., Ltd.
    00-01-A3   # GENESYS LOGIC, INC.
    00-01-A4   # Microlink Corporation
    00-01-A5   # Nextcomm, Inc.
    00-01-A6   # Scientific-Atlanta Arcodan A/S
    00-01-A7   # UNEX TECHNOLOGY CORPORATION
    00-01-A8   # Welltech Computer Co., Ltd.
    00-01-A9   # BMW AG
    00-01-AA   # Airspan Communications, Ltd.
    00-01-AB   # Main Street Networks
    00-01-AC   # Sitara Networks, Inc.
    00-01-AD   # Coach Master International  d.b.a. CMI Worldwide, Inc.
    00-01-AE   # Trex Enterprises
    00-01-AF   # Artesyn Embedded Technologies
    00-01-B0   # Fulltek Technology Co., Ltd.
    00-01-B1   # General Bandwidth
    00-01-B2   # Digital Processing Systems, Inc.
    00-01-B3   # Precision Electronic Manufacturing
    00-01-B4   # Wayport, Inc.
    00-01-B5   # Turin Networks, Inc.
    00-01-B6   # SAEJIN T&M Co., Ltd.
    00-01-B7   # Centos, Inc.
    00-01-B8   # Netsensity, Inc.
    00-01-B9   # SKF Condition Monitoring
    00-01-BA   # IC-Net, Inc.
    00-01-BB   # Frequentis
    00-01-BC   # Brains Corporation
    00-01-BD   # Peterson Electro-Musical Products, Inc.
    00-01-BE   # Gigalink Co., Ltd.
    00-01-BF   # Teleforce Co., Ltd.
    00-01-C0   # CompuLab, Ltd.
    00-01-C1   # Vitesse Semiconductor Corporation
    00-01-C2   # ARK Research Corp.
    00-01-C3   # Acromag, Inc.
    00-01-C4   # NeoWave, Inc.
    00-01-C5   # Simpler Networks
    00-01-C6   # Quarry Technologies
    00-01-C7   # Cisco Systems, Inc
    00-01-C8   # CONRAD CORP.
    00-01-C8   # THOMAS CONRAD CORP.
    00-01-C9   # Cisco Systems, Inc
    00-01-CA   # Geocast Network Systems, Inc.
    00-01-CB   # EVR
    00-01-CC   # Japan Total Design Communication Co., Ltd.
    00-01-CD   # ARtem
    00-01-CE   # Custom Micro Products, Ltd.
    00-01-CF   # Alpha Data Parallel Systems, Ltd.
    00-01-D0   # VitalPoint, Inc.
    00-01-D1   # CoNet Communications, Inc.
    00-01-D2   # inXtron, Inc.
    00-01-D3   # PAXCOMM, Inc.
    00-01-D4   # Leisure Time, Inc.
    00-01-D5   # HAEDONG INFO & COMM CO., LTD
    00-01-D6   # manroland AG
    00-01-D7   # F5 Networks, Inc.
    00-01-D8   # Teltronics, Inc.
    00-01-D9   # Sigma, Inc.
    00-01-DA   # WINCOMM Corporation
    00-01-DB   # Freecom Technologies GmbH
    00-01-DC   # Activetelco
    00-01-DD   # Avail Networks
    00-01-DE   # Trango Systems, Inc.
    00-01-DF   # ISDN Communications, Ltd.
    00-01-E0   # Fast Systems, Inc.
    00-01-E1   # Kinpo Electronics, Inc.
    00-01-E2   # Ando Electric Corporation
    00-01-E3   # Siemens AG
    00-01-E4   # Sitera, Inc.
    00-01-E5   # Supernet, Inc.
    00-01-E6   # Hewlett Packard
    00-01-E7   # Hewlett Packard
    00-01-E8   # Force10 Networks, Inc.
    00-01-E9   # Litton Marine Systems B.V.
    00-01-EA   # Cirilium Corp.
    00-01-EB   # C-COM Corporation
    00-01-EC   # Ericsson Group
    00-01-ED   # SETA Corp.
    00-01-EE   # Comtrol Europe, Ltd.
    00-01-EF   # Camtel Technology Corp.
    00-01-F0   # Tridium, Inc.
    00-01-F1   # Innovative Concepts, Inc.
    00-01-F2   # Mark of the Unicorn, Inc.
    00-01-F3   # QPS, Inc.
    00-01-F4   # Enterasys Networks
    00-01-F5   # ERIM S.A.
    00-01-F6   # Association of Musical Electronics Industry
    00-01-F7   # Image Display Systems, Inc.
    00-01-F8   # TEXIO TECHNOLOGY CORPORATION
    00-01-F9   # TeraGlobal Communications Corp.
    00-01-FA   # HOROSCAS
    00-01-FB   # DoTop Technology, Inc.
    00-01-FC   # Keyence Corporation
    00-01-FD   # Digital Voice Systems, Inc.
    00-01-FE   # DIGITAL EQUIPMENT CORPORATION
    00-01-FF   # Data Direct Networks, Inc.
    00-02-00   # Net & Sys Co., Ltd.
    00-02-01   # IFM Electronic gmbh
    00-02-02   # Amino Communications, Ltd.
    00-02-03   # Woonsang Telecom, Inc.
    00-02-04   # Bodmann Industries Elektronik GmbH
    00-02-05   # Hitachi Denshi, Ltd.
    00-02-06   # Telital R&D Denmark A/S
    00-02-07   # VisionGlobal Network Corp.
    00-02-08   # Unify Networks, Inc.
    00-02-09   # Shenzhen SED Information Technology Co., Ltd.
    00-02-0A   # Gefran Spa
    00-02-0B   # Native Networks, Inc.
    00-02-0C   # Metro-Optix
    00-02-0D   # Micronpc.com
    00-02-0E   # ECI Telecom, Ltd
    00-02-0F   # AATR
    00-02-10   # Fenecom
    00-02-11   # Nature Worldwide Technology Corp.
    00-02-12   # SierraCom
    00-02-13   # S.D.E.L.
    00-02-14   # DTVRO
    00-02-15   # Cotas Computer Technology A/B
    00-02-16   # Cisco Systems, Inc
    00-02-17   # Cisco Systems, Inc
    00-02-18   # Advanced Scientific Corp
    00-02-19   # Paralon Technologies
    00-02-1A   # Zuma Networks
    00-02-1B   # Kollmorgen-Servotronix
    00-02-1C   # Network Elements, Inc.
    00-02-1D   # Data General Communication Ltd.
    00-02-1E   # SIMTEL S.R.L.
    00-02-1F   # Aculab PLC
    00-02-20   # CANON FINETECH INC.
    00-02-21   # DSP Application, Ltd.
    00-02-22   # Chromisys, Inc.
    00-02-23   # ClickTV
    00-02-24   # C-COR
    00-02-25   # One Stop Systems
    00-02-26   # XESystems, Inc.
    00-02-27   # ESD Electronic System Design GmbH
    00-02-28   # Necsom, Ltd.
    00-02-29   # Adtec Corporation
    00-02-2A   # Asound Electronic
    00-02-2B   # SAXA, Inc.
    00-02-2C   # ABB Bomem, Inc.
    00-02-2D   # Agere Systems
    00-02-2E   # TEAC Corp. R& D
    00-02-2F   # P-Cube, Ltd.
    00-02-30   # Intersoft Electronics
    00-02-31   # Ingersoll-Rand
    00-02-32   # Avision, Inc.
    00-02-33   # Mantra Communications, Inc.
    00-02-34   # Imperial Technology, Inc.
    00-02-35   # Paragon Networks International
    00-02-36   # INIT GmbH
    00-02-37   # Cosmo Research Corp.
    00-02-38   # Serome Technology, Inc.
    00-02-39   # Visicom
    00-02-3A   # ZSK Stickmaschinen GmbH
    00-02-3B   # Ericsson
    00-02-3C   # Creative Technology, Ltd.
    00-02-3D   # Cisco Systems, Inc
    00-02-3E   # Selta Telematica S.p.a
    00-02-3F   # COMPAL ELECTRONICS, INC.
    00-02-40   # Seedek Co., Ltd.
    00-02-41   # Amer.com
    00-02-42   # Videoframe Systems
    00-02-43   # Raysis Co., Ltd.
    00-02-44   # SURECOM Technology Co.
    00-02-45   # Lampus Co, Ltd.
    00-02-46   # All-Win Tech Co., Ltd.
    00-02-47   # Great Dragon Information Technology (Group) Co., Ltd.
    00-02-48   # Pilz GmbH & Co.
    00-02-49   # Aviv Infocom Co, Ltd.
    00-02-4A   # Cisco Systems, Inc
    00-02-4B   # Cisco Systems, Inc
    00-02-4C   # SiByte, Inc.
    00-02-4D   # Mannesman Dematic Colby Pty. Ltd.
    00-02-4E   # Datacard Group
    00-02-4F   # IPM Datacom S.R.L.
    00-02-50   # Geyser Networks, Inc.
    00-02-51   # Soma Networks, Inc.
    00-02-52   # Carrier Corporation
    00-02-53   # Televideo, Inc.
    00-02-54   # WorldGate
    00-02-55   # IBM Corp
    00-02-56   # Alpha Processor, Inc.
    00-02-57   # Microcom Corp.
    00-02-58   # Flying Packets Communications
    00-02-59   # Tsann Kuen China (Shanghai)Enterprise Co., Ltd. IT Group
    00-02-5A   # Catena Networks
    00-02-5B   # Cambridge Silicon Radio
    00-02-5C   # SCI Systems (Kunshan) Co., Ltd.
    00-02-5D   # Calix Networks
    00-02-5E   # High Technology Ltd
    00-02-5F   # Nortel Networks
    00-02-60   # Accordion Networks, Inc.
    00-02-61   # Tilgin AB
    00-02-62   # Soyo Group Soyo Com Tech Co., Ltd
    00-02-63   # UPS Manufacturing SRL
    00-02-64   # AudioRamp.com
    00-02-65   # Virditech Co. Ltd.
    00-02-66   # Thermalogic Corporation
    00-02-67   # NODE RUNNER, INC.
    00-02-68   # Harris Government Communications
    00-02-69   # Nadatel Co., Ltd
    00-02-6A   # Cocess Telecom Co., Ltd.
    00-02-6B   # BCM Computers Co., Ltd.
    00-02-6C   # Philips CFT
    00-02-6D   # Adept Telecom
    00-02-6E   # NeGeN Access, Inc.
    00-02-6F   # Senao International Co., Ltd.
    00-02-70   # Crewave Co., Ltd.
    00-02-71   # Zhone Technologies
    00-02-72   # CC&C Technologies, Inc.
    00-02-73   # Coriolis Networks
    00-02-74   # Tommy Technologies Corp.
    00-02-75   # SMART Technologies, Inc.
    00-02-76   # Primax Electronics Ltd.
    00-02-77   # Cash Systemes Industrie
    00-02-78   # Samsung Electro-Mechanics Co., Ltd.
    00-02-79   # Control Applications, Ltd.
    00-02-7A   # IOI Technology Corporation
    00-02-7B   # Amplify Net, Inc.
    00-02-7C   # Trilithic, Inc.
    00-02-7D   # Cisco Systems, Inc
    00-02-7E   # Cisco Systems, Inc
    00-02-7F   # ask-technologies.com
    00-02-80   # Mu Net, Inc.
    00-02-81   # Madge Ltd.
    00-02-82   # ViaClix, Inc.
    00-02-83   # Spectrum Controls, Inc.
    00-02-84   # AREVA T&D
    00-02-85   # Riverstone Networks
    00-02-86   # Occam Networks
    00-02-87   # Adapcom
    00-02-88   # GLOBAL VILLAGE COMMUNICATION
    00-02-89   # DNE Technologies
    00-02-8A   # Ambit Microsystems Corporation
    00-02-8B   # VDSL Systems OY
    00-02-8C   # Micrel-Synergy Semiconductor
    00-02-8D   # Movita Technologies, Inc.
    00-02-8E   # Rapid 5 Networks, Inc.
    00-02-8F   # Globetek, Inc.
    00-02-90   # Woorigisool, Inc.
    00-02-91   # Open Network Co., Ltd.
    00-02-92   # Logic Innovations, Inc.
    00-02-93   # Solid Data Systems
    00-02-94   # Tokyo Sokushin Co., Ltd.
    00-02-95   # IP.Access Limited
    00-02-96   # Lectron Co,. Ltd.
    00-02-97   # C-COR.net
    00-02-98   # Broadframe Corporation
    00-02-99   # Apex, Inc.
    00-02-9A   # Storage Apps
    00-02-9B   # Kreatel Communications AB
    00-02-9C   # 3COM
    00-02-9D   # Merix Corp.
    00-02-9E   # Information Equipment Co., Ltd.
    00-02-9F   # L-3 Communication Aviation Recorders
    00-02-A0   # Flatstack Ltd.
    00-02-A1   # World Wide Packets
    00-02-A2   # Hilscher GmbH
    00-02-A3   # ABB Switzerland Ltd, Power Systems
    00-02-A4   # AddPac Technology Co., Ltd.
    00-02-A5   # Hewlett Packard
    00-02-A6   # Effinet Systems Co., Ltd.
    00-02-A7   # Vivace Networks
    00-02-A8   # Air Link Technology
    00-02-A9   # RACOM, s.r.o.
    00-02-AA   # PLcom Co., Ltd.
    00-02-AB   # CTC Union Technologies Co., Ltd.
    00-02-AC   # 3PAR data
    00-02-AD   # HOYA Corporation
    00-02-AE   # Scannex Electronics Ltd.
    00-02-AF   # TeleCruz Technology, Inc.
    00-02-B0   # Hokubu Communication & Industrial Co., Ltd.
    00-02-B1   # Anritsu, Ltd.
    00-02-B2   # Cablevision
    00-02-B3   # Intel Corporation
    00-02-B4   # DAPHNE
    00-02-B5   # Avnet, Inc.
    00-02-B6   # Acrosser Technology Co., Ltd.
    00-02-B7   # Watanabe Electric Industry Co., Ltd.
    00-02-B8   # WHI KONSULT AB
    00-02-B9   # Cisco Systems, Inc
    00-02-BA   # Cisco Systems, Inc
    00-02-BB   # Continuous Computing Corp
    00-02-BC   # LVL 7 Systems, Inc.
    00-02-BD   # Bionet Co., Ltd.
    00-02-BE   # Totsu Engineering, Inc.
    00-02-BF   # dotRocket, Inc.
    00-02-C0   # Bencent Tzeng Industry Co., Ltd.
    00-02-C1   # Innovative Electronic Designs, Inc.
    00-02-C2   # Net Vision Telecom
    00-02-C3   # Arelnet Ltd.
    00-02-C4   # Vector International BVBA
    00-02-C5   # Evertz Microsystems Ltd.
    00-02-C6   # Data Track Technology PLC
    00-02-C7   # ALPS ELECTRIC CO.,LTD.
    00-02-C8   # Technocom Communications Technology (pte) Ltd
    00-02-C9   # Mellanox Technologies
    00-02-CA   # EndPoints, Inc.
    00-02-CB   # TriState Ltd.
    00-02-CC   # M.C.C.I
    00-02-CD   # TeleDream, Inc.
    00-02-CE   # FoxJet, Inc.
    00-02-CF   # ZyGate Communications, Inc.
    00-02-D0   # Comdial Corporation
    00-02-D1   # Vivotek, Inc.
    00-02-D2   # Workstation AG
    00-02-D3   # NetBotz, Inc.
    00-02-D4   # PDA Peripherals, Inc.
    00-02-D5   # ACR
    00-02-D6   # NICE Systems
    00-02-D7   # EMPEG Ltd
    00-02-D8   # BRECIS Communications Corporation
    00-02-D9   # Reliable Controls
    00-02-DA   # ExiO Communications, Inc.
    00-02-DB   # NETSEC
    00-02-DC   # Fujitsu General Limited
    00-02-DD   # Bromax Communications, Ltd.
    00-02-DE   # Astrodesign, Inc.
    00-02-DF   # Net Com Systems, Inc.
    00-02-E0   # ETAS GmbH
    00-02-E1   # Integrated Network Corporation
    00-02-E2   # NDC Infared Engineering
    00-02-E3   # LITE-ON Communications, Inc.
    00-02-E4   # JC HYUN Systems, Inc.
    00-02-E5   # Timeware Ltd.
    00-02-E6   # Gould Instrument Systems, Inc.
    00-02-E7   # CAB GmbH & Co KG
    00-02-E8   # E.D.&A.
    00-02-E9   # CS Systemes De Securite - C3S
    00-02-EA   # Focus Enhancements
    00-02-EB   # Pico Communications
    00-02-EC   # Maschoff Design Engineering
    00-02-ED   # DXO Telecom Co., Ltd.
    00-02-EE   # Nokia Danmark A/S
    00-02-EF   # CCC Network Systems Group Ltd.
    00-02-F0   # AME Optimedia Technology Co., Ltd.
    00-02-F1   # Pinetron Co., Ltd.
    00-02-F2   # eDevice, Inc.
    00-02-F3   # Media Serve Co., Ltd.
    00-02-F4   # PCTEL, Inc.
    00-02-F5   # VIVE Synergies, Inc.
    00-02-F6   # Equipe Communications
    00-02-F7   # ARM
    00-02-F8   # SEAKR Engineering, Inc.
    00-02-F9   # MIMOS Berhad
    00-02-FA   # DX Antenna Co., Ltd.
    00-02-FB   # Baumuller Aulugen-Systemtechnik GmbH
    00-02-FC   # Cisco Systems, Inc
    00-02-FD   # Cisco Systems, Inc
    00-02-FE   # Viditec, Inc.
    00-02-FF   # Handan BroadInfoCom
    00-03-00   # Barracuda Networks, Inc.
    00-03-01   # EXFO
    00-03-02   # Charles Industries, Ltd.
    00-03-03   # JAMA Electronics Co., Ltd.
    00-03-04   # Pacific Broadband Communications
    00-03-05   # MSC Vertriebs GmbH
    00-03-06   # Fusion In Tech Co., Ltd.
    00-03-07   # Secure Works, Inc.
    00-03-08   # AM Communications, Inc.
    00-03-09   # Texcel Technology PLC
    00-03-0A   # Argus Technologies
    00-03-0B   # Hunter Technology, Inc.
    00-03-0C   # Telesoft Technologies Ltd.
    00-03-0D   # Uniwill Computer Corp.
    00-03-0E   # Core Communications Co., Ltd.
    00-03-0F   # Digital China (Shanghai) Networks Ltd.
    00-03-10   # E-Globaledge Corporation
    00-03-11   # Micro Technology Co., Ltd.
    00-03-12   # TR-Systemtechnik GmbH
    00-03-13   # Access Media SPA
    00-03-14   # Teleware Network Systems
    00-03-15   # Cidco Incorporated
    00-03-16   # Nobell Communications, Inc.
    00-03-17   # Merlin Systems, Inc.
    00-03-18   # Cyras Systems, Inc.
    00-03-19   # Infineon AG
    00-03-1A   # Beijing Broad Telecom Ltd., China
    00-03-1B   # Cellvision Systems, Inc.
    00-03-1C   # Svenska Hardvarufabriken AB
    00-03-1D   # Taiwan Commate Computer, Inc.
    00-03-1E   # Optranet, Inc.
    00-03-1F   # Condev Ltd.
    00-03-20   # Xpeed, Inc.
    00-03-21   # Reco Research Co., Ltd.
    00-03-22   # IDIS Co., Ltd.
    00-03-23   # Cornet Technology, Inc.
    00-03-24   # SANYO Consumer Electronics Co., Ltd.
    00-03-25   # Arima Computer Corp.
    00-03-26   # Iwasaki Information Systems Co., Ltd.
    00-03-27   # ACT'L
    00-03-28   # Mace Group, Inc.
    00-03-29   # F3, Inc.
    00-03-2A   # UniData Communication Systems, Inc.
    00-03-2B   # GAI Datenfunksysteme GmbH
    00-03-2C   # ABB Switzerland Ltd
    00-03-2D   # IBASE Technology, Inc.
    00-03-2E   # Scope Information Management, Ltd.
    00-03-2F   # Global Sun Technology, Inc.
    00-03-30   # Imagenics, Co., Ltd.
    00-03-31   # Cisco Systems, Inc
    00-03-32   # Cisco Systems, Inc
    00-03-33   # Digitel Co., Ltd.
    00-03-34   # Newport Electronics
    00-03-35   # Mirae Technology
    00-03-36   # Zetes Technologies
    00-03-37   # Vaone, Inc.
    00-03-38   # Oak Technology
    00-03-39   # Eurologic Systems, Ltd.
    00-03-3A   # Silicon Wave, Inc.
    00-03-3B   # TAMI Tech Co., Ltd.
    00-03-3C   # Daiden Co., Ltd.
    00-03-3D   # ILSHin Lab
    00-03-3E   # Tateyama System Laboratory Co., Ltd.
    00-03-3F   # BigBand Networks, Ltd.
    00-03-40   # Floware Wireless Systems, Ltd.
    00-03-41   # Axon Digital Design
    00-03-42   # Nortel Networks
    00-03-43   # Martin Professional A/S
    00-03-44   # Tietech.Co., Ltd.
    00-03-45   # Routrek Networks Corporation
    00-03-46   # Hitachi Kokusai Electric, Inc.
    00-03-47   # Intel Corporation
    00-03-48   # Norscan Instruments, Ltd.
    00-03-49   # Vidicode Datacommunicatie B.V.
    00-03-4A   # RIAS Corporation
    00-03-4B   # Nortel Networks
    00-03-4C   # Shanghai DigiVision Technology Co., Ltd.
    00-03-4D   # Chiaro Networks, Ltd.
    00-03-4E   # Pos Data Company, Ltd.
    00-03-4F   # Sur-Gard Security
    00-03-50   # BTICINO SPA
    00-03-51   # Diebold, Inc.
    00-03-52   # Colubris Networks
    00-03-53   # Mitac, Inc.
    00-03-54   # Fiber Logic Communications
    00-03-55   # TeraBeam Internet Systems
    00-03-56   # Wincor Nixdorf International GmbH
    00-03-57   # Intervoice-Brite, Inc.
    00-03-58   # Hanyang Digitech Co., Ltd.
    00-03-59   # DigitalSis
    00-03-5A   # Photron Limited
    00-03-5B   # BridgeWave Communications
    00-03-5C   # Saint Song Corp.
    00-03-5D   # Bosung Hi-Net Co., Ltd.
    00-03-5E   # Metropolitan Area Networks, Inc.
    00-03-5F   # Prüftechnik Condition Monitoring GmbH & Co. KG
    00-03-60   # PAC Interactive Technology, Inc.
    00-03-61   # Widcomm, Inc.
    00-03-62   # Vodtel Communications, Inc.
    00-03-63   # Miraesys Co., Ltd.
    00-03-64   # Scenix Semiconductor, Inc.
    00-03-65   # Kira Information & Communications, Ltd.
    00-03-66   # ASM Pacific Technology
    00-03-67   # Jasmine Networks, Inc.
    00-03-68   # Embedone Co., Ltd.
    00-03-69   # Nippon Antenna Co., Ltd.
    00-03-6A   # Mainnet, Ltd.
    00-03-6B   # Cisco Systems, Inc
    00-03-6C   # Cisco Systems, Inc
    00-03-6D   # Runtop, Inc.
    00-03-6E   # Nicon Systems (Pty) Limited
    00-03-6F   # Telsey SPA
    00-03-70   # NXTV, Inc.
    00-03-71   # Acomz Networks Corp.
    00-03-72   # ULAN
    00-03-73   # Aselsan A.S
    00-03-74   # Control Microsystems
    00-03-75   # NetMedia, Inc.
    00-03-76   # Graphtec Technology, Inc.
    00-03-77   # Gigabit Wireless
    00-03-78   # HUMAX Co., Ltd.
    00-03-79   # Proscend Communications, Inc.
    00-03-7A   # Taiyo Yuden Co., Ltd.
    00-03-7B   # IDEC IZUMI Corporation
    00-03-7C   # Coax Media
    00-03-7D   # Stellcom
    00-03-7E   # PORTech Communications, Inc.
    00-03-7F   # Atheros Communications, Inc.
    00-03-80   # SSH Communications Security Corp.
    00-03-81   # Ingenico International
    00-03-82   # A-One Co., Ltd.
    00-03-83   # Metera Networks, Inc.
    00-03-84   # AETA
    00-03-85   # Actelis Networks, Inc.
    00-03-86   # Ho Net, Inc.
    00-03-87   # Blaze Network Products
    00-03-88   # Fastfame Technology Co., Ltd.
    00-03-89   # PLANTRONICS, INC.
    00-03-8A   # America Online, Inc.
    00-03-8B   # PLUS-ONE I&T, Inc.
    00-03-8C   # Total Impact
    00-03-8D   # PCS Revenue Control Systems, Inc.
    00-03-8E   # Atoga Systems, Inc.
    00-03-8F   # Weinschel Corporation
    00-03-90   # Digital Video Communications, Inc.
    00-03-91   # Advanced Digital Broadcast, Ltd.
    00-03-92   # Hyundai Teletek Co., Ltd.
    00-03-93   # Apple, Inc.
    00-03-94   # Connect One
    00-03-95   # California Amplifier
    00-03-96   # EZ Cast Co., Ltd.
    00-03-97   # Watchfront Limited
    00-03-98   # WISI
    00-03-99   # Dongju Informations & Communications Co., Ltd.
    00-03-9A   # SiConnect
    00-03-9B   # NetChip Technology, Inc.
    00-03-9C   # OptiMight Communications, Inc.
    00-03-9D   # Qisda Corporation
    00-03-9E   # Tera System Co., Ltd.
    00-03-9F   # Cisco Systems, Inc
    00-03-A0   # Cisco Systems, Inc
    00-03-A1   # HIPER Information & Communication, Inc.
    00-03-A2   # Catapult Communications
    00-03-A3   # MAVIX, Ltd.
    00-03-A4   # Imation Corp.
    00-03-A5   # Medea Corporation
    00-03-A6   # Traxit Technology, Inc.
    00-03-A7   # Unixtar Technology, Inc.
    00-03-A8   # IDOT Computers, Inc.
    00-03-A9   # AXCENT Media AG
    00-03-AA   # Watlow
    00-03-AB   # Bridge Information Systems
    00-03-AC   # Fronius Schweissmaschinen
    00-03-AD   # Emerson Energy Systems AB
    00-03-AE   # Allied Advanced Manufacturing Pte, Ltd.
    00-03-AF   # Paragea Communications
    00-03-B0   # Xsense Technology Corp.
    00-03-B1   # Hospira Inc.
    00-03-B2   # Radware
    00-03-B3   # IA Link Systems Co., Ltd.
    00-03-B4   # Macrotek International Corp.
    00-03-B5   # Entra Technology Co.
    00-03-B6   # QSI Corporation
    00-03-B7   # ZACCESS Systems
    00-03-B8   # NetKit Solutions, LLC
    00-03-B9   # Hualong Telecom Co., Ltd.
    00-03-BA   # Oracle Corporation
    00-03-BB   # Signal Communications Limited
    00-03-BC   # COT GmbH
    00-03-BD   # OmniCluster Technologies, Inc.
    00-03-BE   # Netility
    00-03-BF   # Centerpoint Broadband Technologies, Inc.
    00-03-C0   # RFTNC Co., Ltd.
    00-03-C1   # Packet Dynamics Ltd
    00-03-C2   # Solphone K.K.
    00-03-C3   # Micronik Multimedia
    00-03-C4   # Tomra Systems ASA
    00-03-C5   # Mobotix AG
    00-03-C6   # ICUE Systems, Inc.
    00-03-C7   # hopf Elektronik GmbH
    00-03-C8   # CML Emergency Services
    00-03-C9   # TECOM Co., Ltd.
    00-03-CA   # MTS Systems Corp.
    00-03-CB   # Nippon Systems Development Co., Ltd.
    00-03-CC   # Momentum Computer, Inc.
    00-03-CD   # Clovertech, Inc.
    00-03-CE   # ETEN Technologies, Inc.
    00-03-CF   # Muxcom, Inc.
    00-03-D0   # KOANKEISO Co., Ltd.
    00-03-D1   # Takaya Corporation
    00-03-D2   # Crossbeam Systems, Inc.
    00-03-D3   # Internet Energy Systems, Inc.
    00-03-D4   # Alloptic, Inc.
    00-03-D5   # Advanced Communications Co., Ltd.
    00-03-D6   # RADVision, Ltd.
    00-03-D7   # NextNet Wireless, Inc.
    00-03-D8   # iMPath Networks, Inc.
    00-03-D9   # Secheron SA
    00-03-DA   # Takamisawa Cybernetics Co., Ltd.
    00-03-DB   # Apogee Electronics Corp.
    00-03-DC   # Lexar Media, Inc.
    00-03-DD   # Comark Interactive Solutions
    00-03-DE   # OTC Wireless
    00-03-DF   # Desana Systems
    00-03-E0   # ARRIS Group, Inc.
    00-03-E1   # Winmate Communication, Inc.
    00-03-E2   # Comspace Corporation
    00-03-E3   # Cisco Systems, Inc
    00-03-E4   # Cisco Systems, Inc
    00-03-E5   # Hermstedt SG
    00-03-E6   # Entone, Inc.
    00-03-E7   # Logostek Co. Ltd.
    00-03-E8   # Wavelength Digital Limited
    00-03-E9   # Akara Canada, Inc.
    00-03-EA   # Mega System Technologies, Inc.
    00-03-EB   # Atrica
    00-03-EC   # ICG Research, Inc.
    00-03-ED   # Shinkawa Electric Co., Ltd.
    00-03-EE   # MKNet Corporation
    00-03-EF   # Oneline AG
    00-03-F0   # Redfern Broadband Networks
    00-03-F1   # Cicada Semiconductor, Inc.
    00-03-F2   # Seneca Networks
    00-03-F3   # Dazzle Multimedia, Inc.
    00-03-F4   # NetBurner
    00-03-F5   # Chip2Chip
    00-03-F6   # Allegro Networks, Inc.
    00-03-F7   # Plast-Control GmbH
    00-03-F8   # SanCastle Technologies, Inc.
    00-03-F9   # Pleiades Communications, Inc.
    00-03-FA   # TiMetra Networks
    00-03-FB   # ENEGATE Co.,Ltd.
    00-03-FC   # Intertex Data AB
    00-03-FD   # Cisco Systems, Inc
    00-03-FE   # Cisco Systems, Inc
    00-03-FF   # Microsoft Corporation
    00-04-00   # LEXMARK INTERNATIONAL, INC.
    00-04-01   # Osaki Electric Co., Ltd.
    00-04-02   # Nexsan Technologies, Ltd.
    00-04-03   # Nexsi Corporation
    00-04-04   # Makino Milling Machine Co., Ltd.
    00-04-05   # ACN Technologies
    00-04-06   # Fa. Metabox AG
    00-04-07   # Topcon Positioning Systems, Inc.
    00-04-08   # Sanko Electronics Co., Ltd.
    00-04-09   # Cratos Networks
    00-04-0A   # Sage Systems
    00-04-0B   # 3COM EUROPE LTD.
    00-04-0C   # Kanno Works, Ltd.
    00-04-0D   # Avaya Inc
    00-04-0E   # AVM GmbH
    00-04-0F   # Asus Network Technologies, Inc.
    00-04-10   # Spinnaker Networks, Inc.
    00-04-11   # Inkra Networks, Inc.
    00-04-12   # WaveSmith Networks, Inc.
    00-04-13   # SNOM Technology AG
    00-04-14   # Umezawa Musen Denki Co., Ltd.
    00-04-15   # Rasteme Systems Co., Ltd.
    00-04-16   # Parks S/A Comunicacoes Digitais
    00-04-17   # ELAU AG
    00-04-18   # Teltronic S.A.U.
    00-04-19   # Fibercycle Networks, Inc.
    00-04-1A   # Ines Test and Measurement GmbH & CoKG
    00-04-1B   # Bridgeworks Ltd.
    00-04-1C   # ipDialog, Inc.
    00-04-1D   # Corega of America
    00-04-1E   # Shikoku Instrumentation Co., Ltd.
    00-04-1F   # Sony Computer Entertainment Inc.
    00-04-20   # Slim Devices, Inc.
    00-04-21   # Ocular Networks
    00-04-22   # Gordon Kapes, Inc.
    00-04-23   # Intel Corporation
    00-04-24   # TMC s.r.l.
    00-04-25   # Atmel Corporation
    00-04-26   # Autosys
    00-04-27   # Cisco Systems, Inc
    00-04-28   # Cisco Systems, Inc
    00-04-29   # Pixord Corporation
    00-04-2A   # Wireless Networks, Inc.
    00-04-2B   # IT Access Co., Ltd.
    00-04-2C   # Minet, Inc.
    00-04-2D   # Sarian Systems, Ltd.
    00-04-2E   # Netous Technologies, Ltd.
    00-04-2F   # International Communications Products, Inc.
    00-04-30   # Netgem
    00-04-31   # GlobalStreams, Inc.
    00-04-32   # Voyetra Turtle Beach, Inc.
    00-04-33   # Cyberboard A/S
    00-04-34   # Accelent Systems, Inc.
    00-04-35   # Comptek International, Inc.
    00-04-36   # ELANsat Technologies, Inc.
    00-04-37   # Powin Information Technology, Inc.
    00-04-38   # Nortel Networks
    00-04-39   # Rosco Entertainment Technology, Inc.
    00-04-3A   # Intelligent Telecommunications, Inc.
    00-04-3B   # Lava Computer Mfg., Inc.
    00-04-3C   # SONOS Co., Ltd.
    00-04-3D   # INDEL AG
    00-04-3E   # Telencomm
    00-04-3F   # ESTeem Wireless Modems, Inc
    00-04-40   # cyberPIXIE, Inc.
    00-04-41   # Half Dome Systems, Inc.
    00-04-42   # NACT
    00-04-43   # Agilent Technologies, Inc.
    00-04-44   # Western Multiplex Corporation
    00-04-45   # LMS Skalar Instruments GmbH
    00-04-46   # CYZENTECH Co., Ltd.
    00-04-47   # Acrowave Systems Co., Ltd.
    00-04-48   # Polaroid Corporation
    00-04-49   # Mapletree Networks
    00-04-4A   # iPolicy Networks, Inc.
    00-04-4B   # NVIDIA
    00-04-4C   # JENOPTIK
    00-04-4D   # Cisco Systems, Inc
    00-04-4E   # Cisco Systems, Inc
    00-04-4F   # Schubert System Elektronik Gmbh
    00-04-50   # DMD Computers SRL
    00-04-51   # Medrad, Inc.
    00-04-52   # RocketLogix, Inc.
    00-04-53   # YottaYotta, Inc.
    00-04-54   # Quadriga UK
    00-04-55   # ANTARA.net
    00-04-56   # Cambium Networks Limited
    00-04-57   # Universal Access Technology, Inc.
    00-04-58   # Fusion X Co., Ltd.
    00-04-59   # Veristar Corporation
    00-04-5A   # The Linksys Group, Inc.
    00-04-5B   # Techsan Electronics Co., Ltd.
    00-04-5C   # Mobiwave Pte Ltd
    00-04-5D   # BEKA Elektronik
    00-04-5E   # PolyTrax Information Technology AG
    00-04-5F   # Avalue Technology, Inc.
    00-04-60   # Knilink Technology, Inc.
    00-04-61   # EPOX Computer Co., Ltd.
    00-04-62   # DAKOS Data & Communication Co., Ltd.
    00-04-63   # Bosch Security Systems
    00-04-64   # Pulse-Link Inc
    00-04-65   # i.s.t isdn-support technik GmbH
    00-04-66   # ARMITEL Co.
    00-04-67   # Wuhan Research Institute of MII
    00-04-68   # Vivity, Inc.
    00-04-69   # Innocom, Inc.
    00-04-6A   # Navini Networks
    00-04-6B   # Palm Wireless, Inc.
    00-04-6C   # Cyber Technology Co., Ltd.
    00-04-6D   # Cisco Systems, Inc
    00-04-6E   # Cisco Systems, Inc
    00-04-6F   # Digitel S/A Industria Eletronica
    00-04-70   # ipUnplugged AB
    00-04-71   # IPrad
    00-04-72   # Telelynx, Inc.
    00-04-73   # Photonex Corporation
    00-04-74   # LEGRAND
    00-04-75   # 3 Com Corporation
    00-04-76   # 3 Com Corporation
    00-04-77   # Scalant Systems, Inc.
    00-04-78   # G. Star Technology Corporation
    00-04-79   # Radius Co., Ltd.
    00-04-7A   # AXXESSIT ASA
    00-04-7B   # Schlumberger
    00-04-7C   # Skidata AG
    00-04-7D   # Pelco
    00-04-7E   # Siqura B.V.
    00-04-7F   # Chr. Mayr GmbH & Co. KG
    00-04-80   # Brocade Communications Systems, Inc.
    00-04-81   # Econolite Control Products, Inc.
    00-04-82   # Medialogic Corp.
    00-04-83   # Deltron Technology, Inc.
    00-04-84   # Amann GmbH
    00-04-85   # PicoLight
    00-04-86   # ITTC, University of Kansas
    00-04-87   # Cogency Semiconductor, Inc.
    00-04-88   # Eurotherm Controls
    00-04-89   # YAFO Networks, Inc.
    00-04-8A   # Temia Vertriebs GmbH
    00-04-8B   # Poscon Corporation
    00-04-8C   # Nayna Networks, Inc.
    00-04-8D   # Teo Technologies, Inc
    00-04-8E   # Ohm Tech Labs, Inc.
    00-04-8F   # TD Systems Corporation
    00-04-90   # Optical Access
    00-04-91   # Technovision, Inc.
    00-04-92   # Hive Internet, Ltd.
    00-04-93   # Tsinghua Unisplendour Co., Ltd.
    00-04-94   # Breezecom, Ltd.
    00-04-95   # Tejas Networks India Limited
    00-04-96   # Extreme Networks
    00-04-97   # MacroSystem Digital Video AG
    00-04-98   # Mahi Networks
    00-04-99   # Chino Corporation
    00-04-9A   # Cisco Systems, Inc
    00-04-9B   # Cisco Systems, Inc
    00-04-9C   # Surgient Networks, Inc.
    00-04-9D   # Ipanema Technologies
    00-04-9E   # Wirelink Co., Ltd.
    00-04-9F   # Freescale Semiconductor
    00-04-A0   # Verity Instruments, Inc.
    00-04-A1   # Pathway Connectivity
    00-04-A2   # L.S.I. Japan Co., Ltd.
    00-04-A3   # Microchip Technology, Inc.
    00-04-A4   # NetEnabled, Inc.
    00-04-A5   # Barco Projection Systems NV
    00-04-A6   # SAF Tehnika Ltd.
    00-04-A7   # FabiaTech Corporation
    00-04-A8   # Broadmax Technologies, Inc.
    00-04-A9   # SandStream Technologies, Inc.
    00-04-AA   # Jetstream Communications
    00-04-AB   # Comverse Network Systems, Inc.
    00-04-AC   # IBM Corp
    00-04-AD   # Malibu Networks
    00-04-AE   # Sullair Corporation
    00-04-AF   # Digital Fountain, Inc.
    00-04-B0   # ELESIGN Co., Ltd.
    00-04-B1   # Signal Technology, Inc.
    00-04-B2   # ESSEGI SRL
    00-04-B3   # Videotek, Inc.
    00-04-B4   # CIAC
    00-04-B5   # Equitrac Corporation
    00-04-B6   # Stratex Networks, Inc.
    00-04-B7   # AMB i.t. Holding
    00-04-B8   # Kumahira Co., Ltd.
    00-04-B9   # S.I. Soubou, Inc.
    00-04-BA   # KDD Media Will Corporation
    00-04-BB   # Bardac Corporation
    00-04-BC   # Giantec, Inc.
    00-04-BD   # ARRIS Group, Inc.
    00-04-BE   # OptXCon, Inc.
    00-04-BF   # VersaLogic Corp.
    00-04-C0   # Cisco Systems, Inc
    00-04-C1   # Cisco Systems, Inc
    00-04-C2   # Magnipix, Inc.
    00-04-C3   # CASTOR Informatique
    00-04-C4   # Allen & Heath Limited
    00-04-C5   # ASE Technologies, USA
    00-04-C6   # Yamaha Motor Co., Ltd.
    00-04-C7   # NetMount
    00-04-C8   # LIBA Maschinenfabrik GmbH
    00-04-C9   # Micro Electron Co., Ltd.
    00-04-CA   # FreeMs Corp.
    00-04-CB   # Tdsoft Communication, Ltd.
    00-04-CC   # Peek Traffic B.V.
    00-04-CD   # Extenway Solutions Inc
    00-04-CE   # Patria Ailon
    00-04-CF   # Seagate Technology
    00-04-D0   # Softlink s.r.o.
    00-04-D1   # Drew Technologies, Inc.
    00-04-D2   # Adcon Telemetry GmbH
    00-04-D3   # Toyokeiki Co., Ltd.
    00-04-D4   # Proview Electronics Co., Ltd.
    00-04-D5   # Hitachi Information & Communication Engineering, Ltd.
    00-04-D6   # Takagi Industrial Co., Ltd.
    00-04-D7   # Omitec Instrumentation Ltd.
    00-04-D8   # IPWireless, Inc.
    00-04-D9   # Titan Electronics, Inc.
    00-04-DA   # Relax Technology, Inc.
    00-04-DB   # Tellus Group Corp.
    00-04-DC   # Nortel Networks
    00-04-DD   # Cisco Systems, Inc
    00-04-DE   # Cisco Systems, Inc
    00-04-DF   # Teracom Telematica Ltda.
    00-04-E0   # Procket Networks
    00-04-E1   # Infinior Microsystems
    00-04-E2   # SMC Networks, Inc.
    00-04-E3   # Accton Technology Corp
    00-04-E4   # Daeryung Ind., Inc.
    00-04-E5   # Glonet Systems, Inc.
    00-04-E6   # Banyan Network Private Limited
    00-04-E7   # Lightpointe Communications, Inc
    00-04-E8   # IER, Inc.
    00-04-E9   # Infiniswitch Corporation
    00-04-EA   # Hewlett Packard
    00-04-EB   # Paxonet Communications, Inc.
    00-04-EC   # Memobox SA
    00-04-ED   # Billion Electric Co., Ltd.
    00-04-EE   # Lincoln Electric Company
    00-04-EF   # Polestar Corp.
    00-04-F0   # International Computers, Ltd
    00-04-F1   # WhereNet
    00-04-F2   # Polycom
    00-04-F3   # FS FORTH-SYSTEME GmbH
    00-04-F4   # Infinite Electronics Inc.
    00-04-F5   # SnowShore Networks, Inc.
    00-04-F6   # Amphus
    00-04-F7   # Omega Band, Inc.
    00-04-F8   # QUALICABLE TV Industria E Com., Ltda
    00-04-F9   # Xtera Communications, Inc.
    00-04-FA   # NBS Technologies Inc.
    00-04-FB   # Commtech, Inc.
    00-04-FC   # Stratus Computer (DE), Inc.
    00-04-FD   # Japan Control Engineering Co., Ltd.
    00-04-FE   # Pelago Networks
    00-04-FF   # Acronet Co., Ltd.
    00-05-00   # Cisco Systems, Inc
    00-05-01   # Cisco Systems, Inc
    00-05-02   # Apple, Inc.
    00-05-03   # ICONAG
    00-05-04   # Naray Information & Communication Enterprise
    00-05-05   # Systems Integration Solutions, Inc.
    00-05-06   # Reddo Networks AB
    00-05-07   # Fine Appliance Corp.
    00-05-08   # Inetcam, Inc.
    00-05-09   # AVOC Nishimura Ltd.
    00-05-0A   # ICS Spa
    00-05-0B   # SICOM Systems, Inc.
    00-05-0C   # Network Photonics, Inc.
    00-05-0D   # Midstream Technologies, Inc.
    00-05-0E   # 3ware, Inc.
    00-05-0F   # Tanaka S/S Ltd.
    00-05-10   # Infinite Shanghai Communication Terminals Ltd.
    00-05-11   # Complementary Technologies Ltd
    00-05-12   # Zebra Technologies Inc
    00-05-13   # VTLinx Multimedia Systems, Inc.
    00-05-14   # KDT Systems Co., Ltd.
    00-05-15   # Nuark Co., Ltd.
    00-05-16   # SMART Modular Technologies
    00-05-17   # Shellcomm, Inc.
    00-05-18   # Jupiters Technology
    00-05-19   # Siemens Building Technologies AG,
    00-05-1A   # 3COM EUROPE LTD.
    00-05-1B   # Magic Control Technology Corporation
    00-05-1C   # Xnet Technology Corp.
    00-05-1D   # Airocon, Inc.
    00-05-1E   # Brocade Communications Systems, Inc.
    00-05-1F   # Taijin Media Co., Ltd.
    00-05-20   # Smartronix, Inc.
    00-05-21   # Control Microsystems
    00-05-22   # LEA*D Corporation, Inc.
    00-05-23   # AVL List GmbH
    00-05-24   # BTL System (HK) Limited
    00-05-25   # Puretek Industrial Co., Ltd.
    00-05-26   # IPAS GmbH
    00-05-27   # SJ Tek Co. Ltd
    00-05-28   # New Focus, Inc.
    00-05-29   # Shanghai Broadan Communication Technology Co., Ltd
    00-05-2A   # Ikegami Tsushinki Co., Ltd.
    00-05-2B   # HORIBA, Ltd.
    00-05-2C   # Supreme Magic Corporation
    00-05-2D   # Zoltrix International Limited
    00-05-2E   # Cinta Networks
    00-05-2F   # Leviton Network Solutions
    00-05-30   # Andiamo Systems, Inc.
    00-05-31   # Cisco Systems, Inc
    00-05-32   # Cisco Systems, Inc
    00-05-33   # Brocade Communications Systems, Inc.
    00-05-34   # Northstar Engineering Ltd.
    00-05-35   # Chip PC Ltd.
    00-05-36   # Danam Communications, Inc.
    00-05-37   # Nets Technology Co., Ltd.
    00-05-38   # Merilus, Inc.
    00-05-39   # A Brand New World in Sweden AB
    00-05-3A   # Willowglen Services Pte Ltd
    00-05-3B   # Harbour Networks Ltd., Co. Beijing
    00-05-3C   # XIRCOM
    00-05-3D   # Agere Systems
    00-05-3E   # KID Systeme GmbH
    00-05-3F   # VisionTek, Inc.
    00-05-40   # FAST Corporation
    00-05-41   # Advanced Systems Co., Ltd.
    00-05-42   # Otari, Inc.
    00-05-43   # IQ Wireless GmbH
    00-05-44   # Valley Technologies, Inc.
    00-05-45   # Internet Photonics
    00-05-46   # KDDI Network & Solultions Inc.
    00-05-47   # Starent Networks
    00-05-48   # Disco Corporation
    00-05-49   # Salira Optical Network Systems
    00-05-4A   # Ario Data Networks, Inc.
    00-05-4B   # Eaton Automation AG
    00-05-4C   # RF Innovations Pty Ltd
    00-05-4D   # Brans Technologies, Inc.
    00-05-4E   # Philips
    00-05-4F   # Private
    00-05-50   # Vcomms Connect Limited
    00-05-51   # F & S Elektronik Systeme GmbH
    00-05-52   # Xycotec Computer GmbH
    00-05-53   # DVC Company, Inc.
    00-05-54   # Rangestar Wireless
    00-05-55   # Japan Cash Machine Co., Ltd.
    00-05-56   # 360 Systems
    00-05-57   # Agile TV Corporation
    00-05-58   # Synchronous, Inc.
    00-05-59   # Intracom S.A.
    00-05-5A   # Power Dsine Ltd.
    00-05-5B   # Charles Industries, Ltd.
    00-05-5C   # Kowa Company, Ltd.
    00-05-5D   # D-LINK SYSTEMS, INC.
    00-05-5E   # Cisco Systems, Inc
    00-05-5F   # Cisco Systems, Inc
    00-05-60   # LEADER COMM.CO., LTD
    00-05-61   # nac Image Technology, Inc.
    00-05-62   # Digital View Limited
    00-05-63   # J-Works, Inc.
    00-05-64   # Tsinghua Bitway Co., Ltd.
    00-05-65   # Tailyn Communication Company Ltd.
    00-05-66   # Secui.com Corporation
    00-05-67   # Etymonic Design, Inc.
    00-05-68   # Piltofish Networks AB
    00-05-69   # VMware, Inc.
    00-05-6A   # Heuft Systemtechnik GmbH
    00-05-6B   # C.P. Technology Co., Ltd.
    00-05-6C   # Hung Chang Co., Ltd.
    00-05-6D   # Pacific Corporation
    00-05-6E   # National Enhance Technology, Inc.
    00-05-6F   # Innomedia Technologies Pvt. Ltd.
    00-05-70   # Baydel Ltd.
    00-05-71   # Seiwa Electronics Co.
    00-05-72   # Deonet Co., Ltd.
    00-05-73   # Cisco Systems, Inc
    00-05-74   # Cisco Systems, Inc
    00-05-75   # CDS-Electronics BV
    00-05-76   # NSM Technology Ltd.
    00-05-77   # SM Information & Communication
    00-05-78   # Private
    00-05-79   # Universal Control Solution Corp.
    00-05-7A   # Overture Networks
    00-05-7B   # Chung Nam Electronic Co., Ltd.
    00-05-7C   # RCO Security AB
    00-05-7D   # Sun Communications, Inc.
    00-05-7E   # Eckelmann Steuerungstechnik GmbH
    00-05-7F   # Acqis Technology
    00-05-80   # FibroLAN Ltd.
    00-05-81   # Snell
    00-05-82   # ClearCube Technology
    00-05-83   # ImageCom Limited
    00-05-84   # AbsoluteValue Systems, Inc.
    00-05-85   # Juniper Networks
    00-05-86   # Lucent Technologies
    00-05-87   # Locus, Incorporated
    00-05-88   # Sensoria Corp.
    00-05-89   # National Datacomputer
    00-05-8A   # Netcom Co., Ltd.
    00-05-8B   # IPmental, Inc.
    00-05-8C   # Opentech Inc.
    00-05-8D   # Lynx Photonic Networks, Inc.
    00-05-8E   # Flextronics International GmbH & Co. Nfg. KG
    00-05-8F   # CLCsoft co.
    00-05-90   # Swissvoice Ltd.
    00-05-91   # Active Silicon Ltd
    00-05-92   # Pultek Corp.
    00-05-93   # Grammar Engine Inc.
    00-05-94   # HMS Technology Center Ravensburg GmbH
    00-05-95   # Alesis Corporation
    00-05-96   # Genotech Co., Ltd.
    00-05-97   # Eagle Traffic Control Systems
    00-05-98   # CRONOS S.r.l.
    00-05-99   # DRS Test and Energy Management or DRS-TEM
    00-05-9A   # Cisco Systems, Inc
    00-05-9B   # Cisco Systems, Inc
    00-05-9C   # Kleinknecht GmbH, Ing. Büro
    00-05-9D   # Daniel Computing Systems, Inc.
    00-05-9E   # Zinwell Corporation
    00-05-9F   # Yotta Networks, Inc.
    00-05-A0   # MOBILINE Kft.
    00-05-A1   # Zenocom
    00-05-A2   # CELOX Networks
    00-05-A3   # QEI, Inc.
    00-05-A4   # Lucid Voice Ltd.
    00-05-A5   # KOTT
    00-05-A6   # Extron Electronics
    00-05-A7   # Hyperchip, Inc.
    00-05-A8   # WYLE ELECTRONICS
    00-05-A9   # Princeton Networks, Inc.
    00-05-AA   # Moore Industries International Inc.
    00-05-AB   # Cyber Fone, Inc.
    00-05-AC   # Northern Digital, Inc.
    00-05-AD   # Topspin Communications, Inc.
    00-05-AE   # Mediaport USA
    00-05-AF   # InnoScan Computing A/S
    00-05-B0   # Korea Computer Technology Co., Ltd.
    00-05-B1   # ASB Technology BV
    00-05-B2   # Medison Co., Ltd.
    00-05-B3   # Asahi-Engineering Co., Ltd.
    00-05-B4   # Aceex Corporation
    00-05-B5   # Broadcom Technologies
    00-05-B6   # INSYS Microelectronics GmbH
    00-05-B7   # Arbor Technology Corp.
    00-05-B8   # Electronic Design Associates, Inc.
    00-05-B9   # Airvana, Inc.
    00-05-BA   # Area Netwoeks, Inc.
    00-05-BB   # Myspace AB
    00-05-BC   # Resource Data Management Ltd
    00-05-BD   # ROAX BV
    00-05-BE   # Kongsberg Seatex AS
    00-05-BF   # JustEzy Technology, Inc.
    00-05-C0   # Digital Network Alacarte Co., Ltd.
    00-05-C1   # A-Kyung Motion, Inc.
    00-05-C2   # Soronti, Inc.
    00-05-C3   # Pacific Instruments, Inc.
    00-05-C4   # Telect, Inc.
    00-05-C5   # Flaga HF
    00-05-C6   # Triz Communications
    00-05-C7   # I/F-COM A/S
    00-05-C8   # VERYTECH
    00-05-C9   # LG Innotek Co., Ltd.
    00-05-CA   # Hitron Technology, Inc.
    00-05-CB   # ROIS Technologies, Inc.
    00-05-CC   # Sumtel Communications, Inc.
    00-05-CD   # Denon, Ltd.
    00-05-CE   # Prolink Microsystems Corporation
    00-05-CF   # Thunder River Technologies, Inc.
    00-05-D0   # Solinet Systems
    00-05-D1   # Metavector Technologies
    00-05-D2   # DAP Technologies
    00-05-D3   # eProduction Solutions, Inc.
    00-05-D4   # FutureSmart Networks, Inc.
    00-05-D5   # Speedcom Wireless
    00-05-D6   # L-3 Linkabit
    00-05-D7   # Vista Imaging, Inc.
    00-05-D8   # Arescom, Inc.
    00-05-D9   # Techno Valley, Inc.
    00-05-DA   # Apex Automationstechnik
    00-05-DB   # PSI Nentec GmbH
    00-05-DC   # Cisco Systems, Inc
    00-05-DD   # Cisco Systems, Inc
    00-05-DE   # Gi Fone Korea, Inc.
    00-05-DF   # Electronic Innovation, Inc.
    00-05-E0   # Empirix Corp.
    00-05-E1   # Trellis Photonics, Ltd.
    00-05-E2   # Creativ Network Technologies
    00-05-E3   # LightSand Communications, Inc.
    00-05-E4   # Red Lion Controls Inc.
    00-05-E5   # Renishaw PLC
    00-05-E6   # Egenera, Inc.
    00-05-E7   # Netrake an AudioCodes Company
    00-05-E8   # TurboWave, Inc.
    00-05-E9   # Unicess Network, Inc.
    00-05-EA   # Rednix
    00-05-EB   # Blue Ridge Networks, Inc.
    00-05-EC   # Mosaic Systems Inc.
    00-05-ED   # Technikum Joanneum GmbH
    00-05-EE   # Siemens AB, Infrastructure & Cities, Building Technologies Division, IC BT SSP SP BA PR
    00-05-EF   # ADOIR Digital Technology
    00-05-F0   # SATEC
    00-05-F1   # Vrcom, Inc.
    00-05-F2   # Power R, Inc.
    00-05-F3   # Webyn
    00-05-F4   # System Base Co., Ltd.
    00-05-F5   # Geospace Technologies
    00-05-F6   # Young Chang Co. Ltd.
    00-05-F7   # Analog Devices, Inc.
    00-05-F8   # Real Time Access, Inc.
    00-05-F9   # TOA Corporation
    00-05-FA   # IPOptical, Inc.
    00-05-FB   # ShareGate, Inc.
    00-05-FC   # Schenck Pegasus Corp.
    00-05-FD   # PacketLight Networks Ltd.
    00-05-FE   # Traficon N.V.
    00-05-FF   # SNS Solutions, Inc.
    00-06-00   # Toshiba Teli Corporation
    00-06-01   # Otanikeiki Co., Ltd.
    00-06-02   # Cirkitech Electronics Co.
    00-06-03   # Baker Hughes Inc.
    00-06-04   # @Track Communications, Inc.
    00-06-05   # Inncom International, Inc.
    00-06-06   # RapidWAN, Inc.
    00-06-07   # Omni Directional Control Technology Inc.
    00-06-08   # At-Sky SAS
    00-06-09   # Crossport Systems
    00-06-0A   # Blue2space
    00-06-0B   # Artesyn Embedded Technologies
    00-06-0C   # Melco Industries, Inc.
    00-06-0D   # Wave7 Optics
    00-06-0E   # IGYS Systems, Inc.
    00-06-0F   # Narad Networks Inc
    00-06-10   # Abeona Networks Inc
    00-06-11   # Zeus Wireless, Inc.
    00-06-12   # Accusys, Inc.
    00-06-13   # Kawasaki Microelectronics Incorporated
    00-06-14   # Prism Holdings
    00-06-15   # Kimoto Electric Co., Ltd.
    00-06-16   # Tel Net Co., Ltd.
    00-06-17   # Redswitch Inc.
    00-06-18   # DigiPower Manufacturing Inc.
    00-06-19   # Connection Technology Systems
    00-06-1A   # Zetari Inc.
    00-06-1B   # Notebook Development Lab.  Lenovo Japan Ltd.
    00-06-1C   # Hoshino Metal Industries, Ltd.
    00-06-1D   # MIP Telecom, Inc.
    00-06-1E   # Maxan Systems
    00-06-1F   # Vision Components GmbH
    00-06-20   # Serial System Ltd.
    00-06-21   # Hinox, Co., Ltd.
    00-06-22   # Chung Fu Chen Yeh Enterprise Corp.
    00-06-23   # MGE UPS Systems France
    00-06-24   # Gentner Communications Corp.
    00-06-25   # The Linksys Group, Inc.
    00-06-26   # MWE GmbH
    00-06-27   # Uniwide Technologies, Inc.
    00-06-28   # Cisco Systems, Inc
    00-06-29   # IBM Corp
    00-06-2A   # Cisco Systems, Inc
    00-06-2B   # INTRASERVER TECHNOLOGY
    00-06-2C   # Bivio Networks
    00-06-2D   # TouchStar Technologies, L.L.C.
    00-06-2E   # Aristos Logic Corp.
    00-06-2F   # Pivotech Systems Inc.
    00-06-30   # Adtranz Sweden
    00-06-31   # Calix
    00-06-32   # Mesco Engineering GmbH
    00-06-33   # Cross Match Technologies GmbH
    00-06-34   # GTE Airfone Inc.
    00-06-35   # PacketAir Networks, Inc.
    00-06-36   # Jedai Broadband Networks
    00-06-37   # Toptrend-Meta Information (ShenZhen) Inc.
    00-06-38   # Sungjin C&C Co., Ltd.
    00-06-39   # Newtec
    00-06-3A   # Dura Micro, Inc.
    00-06-3B   # Arcturus Networks Inc.
    00-06-3C   # Intrinsyc Software International Inc.
    00-06-3D   # Microwave Data Systems Inc.
    00-06-3E   # Opthos Inc.
    00-06-3F   # Everex Communications Inc.
    00-06-40   # White Rock Networks
    00-06-41   # ITCN
    00-06-42   # Genetel Systems Inc.
    00-06-43   # SONO Computer Co., Ltd.
    00-06-44   # neix,Inc
    00-06-45   # Meisei Electric Co. Ltd.
    00-06-46   # ShenZhen XunBao Network Technology Co Ltd
    00-06-47   # Etrali S.A.
    00-06-48   # Seedsware, Inc.
    00-06-49   # 3M Deutschland GmbH
    00-06-4A   # Honeywell Co., Ltd. (KOREA)
    00-06-4B   # Alexon Co., Ltd.
    00-06-4C   # Invicta Networks, Inc.
    00-06-4D   # Sencore
    00-06-4E   # Broad Net Technology Inc.
    00-06-4F   # PRO-NETS Technology Corporation
    00-06-50   # Tiburon Networks, Inc.
    00-06-51   # Aspen Networks Inc.
    00-06-52   # Cisco Systems, Inc
    00-06-53   # Cisco Systems, Inc
    00-06-54   # Winpresa Building Automation Technologies GmbH
    00-06-55   # Yipee, Inc.
    00-06-56   # Tactel AB
    00-06-57   # Market Central, Inc.
    00-06-58   # Helmut Fischer GmbH Institut für Elektronik und Messtechnik
    00-06-59   # EAL (Apeldoorn) B.V.
    00-06-5A   # Strix Systems
    00-06-5B   # Dell Inc.
    00-06-5C   # Malachite Technologies, Inc.
    00-06-5D   # Heidelberg Web Systems
    00-06-5E   # Photuris, Inc.
    00-06-5F   # ECI Telecom - NGTS Ltd.
    00-06-60   # NADEX Co., Ltd.
    00-06-61   # NIA Home Technologies Corp.
    00-06-62   # MBM Technology Ltd.
    00-06-63   # Human Technology Co., Ltd.
    00-06-64   # Fostex Corporation
    00-06-65   # Sunny Giken, Inc.
    00-06-66   # Roving Networks
    00-06-67   # Tripp Lite
    00-06-68   # Vicon Industries Inc.
    00-06-69   # Datasound Laboratories Ltd
    00-06-6A   # InfiniCon Systems, Inc.
    00-06-6B   # Sysmex Corporation
    00-06-6C   # Robinson Corporation
    00-06-6D   # Compuprint S.P.A.
    00-06-6E   # Delta Electronics, Inc.
    00-06-6F   # Korea Data Systems
    00-06-70   # Upponetti Oy
    00-06-71   # Softing AG
    00-06-72   # Netezza
    00-06-73   # TKH Security Solutions USA
    00-06-74   # Spectrum Control, Inc.
    00-06-75   # Banderacom, Inc.
    00-06-76   # Novra Technologies Inc.
    00-06-77   # SICK AG
    00-06-78   # Marantz Brand Company
    00-06-79   # Konami Corporation
    00-06-7A   # JMP Systems
    00-06-7B   # Toplink C&C Corporation
    00-06-7C   # Cisco Systems, Inc
    00-06-7D   # Takasago Ltd.
    00-06-7E   # WinCom Systems, Inc.
    00-06-7F   # Digeo, Inc.
    00-06-80   # Card Access, Inc.
    00-06-81   # Goepel Electronic GmbH
    00-06-82   # Convedia
    00-06-83   # Bravara Communications, Inc.
    00-06-84   # Biacore AB
    00-06-85   # NetNearU Corporation
    00-06-86   # ZARDCOM Co., Ltd.
    00-06-87   # Omnitron Systems Technology, Inc.
    00-06-88   # Telways Communication Co., Ltd.
    00-06-89   # yLez Technologies Pte Ltd
    00-06-8A   # NeuronNet Co. Ltd. R&D Center
    00-06-8B   # AirRunner Technologies, Inc.
    00-06-8C   # 3COM CORPORATION
    00-06-8D   # SEPATON, Inc.
    00-06-8E   # HID Corporation
    00-06-8F   # Telemonitor, Inc.
    00-06-90   # Euracom Communication GmbH
    00-06-91   # PT Inovacao
    00-06-92   # Intruvert Networks, Inc.
    00-06-93   # Flexus Computer Technology, Inc.
    00-06-94   # Mobillian Corporation
    00-06-95   # Ensure Technologies, Inc.
    00-06-96   # Advent Networks
    00-06-97   # R & D Center
    00-06-98   # egnite GmbH
    00-06-99   # Vida Design Co.
    00-06-9A   # e & Tel
    00-06-9B   # AVT Audio Video Technologies GmbH
    00-06-9C   # Transmode Systems AB
    00-06-9D   # Petards Ltd
    00-06-9E   # UNIQA, Inc.
    00-06-9F   # Kuokoa Networks
    00-06-A0   # Mx Imaging
    00-06-A1   # Celsian Technologies, Inc.
    00-06-A2   # Microtune, Inc.
    00-06-A3   # Bitran Corporation
    00-06-A4   # INNOWELL Corp.
    00-06-A5   # PINON Corp.
    00-06-A6   # Artistic Licence Engineering Ltd
    00-06-A7   # Primarion
    00-06-A8   # KC Technology, Inc.
    00-06-A9   # Universal Instruments Corp.
    00-06-AA   # VT Miltope
    00-06-AB   # W-Link Systems, Inc.
    00-06-AC   # Intersoft Co.
    00-06-AD   # KB Electronics Ltd.
    00-06-AE   # Himachal Futuristic Communications Ltd
    00-06-AF   # Xalted Networks
    00-06-B0   # Comtech EF Data Corp.
    00-06-B1   # Sonicwall
    00-06-B2   # Linxtek Co.
    00-06-B3   # Diagraph Corporation
    00-06-B4   # Vorne Industries, Inc.
    00-06-B5   # Source Photonics, Inc.
    00-06-B6   # Nir-Or Israel Ltd.
    00-06-B7   # TELEM GmbH
    00-06-B8   # Bandspeed Pty Ltd
    00-06-B9   # A5TEK Corp.
    00-06-BA   # Westwave Communications
    00-06-BB   # ATI Technologies Inc.
    00-06-BC   # Macrolink, Inc.
    00-06-BD   # BNTECHNOLOGY Co., Ltd.
    00-06-BE   # Baumer Optronic GmbH
    00-06-BF   # Accella Technologies Co., Ltd.
    00-06-C0   # United Internetworks, Inc.
    00-06-C1   # Cisco Systems, Inc
    00-06-C2   # Smartmatic Corporation
    00-06-C3   # Schindler Elevator Ltd.
    00-06-C4   # Piolink Inc.
    00-06-C5   # INNOVI Technologies Limited
    00-06-C6   # lesswire AG
    00-06-C7   # RFNET Technologies Pte Ltd (S)
    00-06-C8   # Sumitomo Metal Micro Devices, Inc.
    00-06-C9   # Technical Marketing Research, Inc.
    00-06-CA   # American Computer & Digital Components, Inc. (ACDC)
    00-06-CB   # Jotron Electronics A/S
    00-06-CC   # JMI Electronics Co., Ltd.
    00-06-CD   # Leaf Imaging Ltd.
    00-06-CE   # DATENO
    00-06-CF   # Thales Avionics In-Flight Systems, LLC
    00-06-D0   # Elgar Electronics Corp.
    00-06-D1   # Tahoe Networks, Inc.
    00-06-D2   # Tundra Semiconductor Corp.
    00-06-D3   # Alpha Telecom, Inc. U.S.A.
    00-06-D4   # Interactive Objects, Inc.
    00-06-D5   # Diamond Systems Corp.
    00-06-D6   # Cisco Systems, Inc
    00-06-D7   # Cisco Systems, Inc
    00-06-D8   # Maple Optical Systems
    00-06-D9   # IPM-Net S.p.A.
    00-06-DA   # ITRAN Communications Ltd.
    00-06-DB   # ICHIPS Co., Ltd.
    00-06-DC   # Syabas Technology (Amquest)
    00-06-DD   # AT & T Laboratories - Cambridge Ltd
    00-06-DE   # Flash Technology
    00-06-DF   # AIDONIC Corporation
    00-06-E0   # MAT Co., Ltd.
    00-06-E1   # Techno Trade s.a
    00-06-E2   # Ceemax Technology Co., Ltd.
    00-06-E3   # Quantitative Imaging Corporation
    00-06-E4   # Citel Technologies Ltd.
    00-06-E5   # Fujian Newland Computer Ltd. Co.
    00-06-E6   # DongYang Telecom Co., Ltd.
    00-06-E7   # Bit Blitz Communications Inc.
    00-06-E8   # Optical Network Testing, Inc.
    00-06-E9   # Intime Corp.
    00-06-EA   # ELZET80 Mikrocomputer GmbH&Co. KG
    00-06-EB   # Global Data
    00-06-EC   # Harris Corporation
    00-06-ED   # Inara Networks
    00-06-EE   # Shenyang Neu-era Information & Technology Stock Co., Ltd
    00-06-EF   # Maxxan Systems, Inc.
    00-06-F0   # Digeo, Inc.
    00-06-F1   # Optillion
    00-06-F2   # Platys Communications
    00-06-F3   # AcceLight Networks
    00-06-F4   # Prime Electronics & Satellitics Inc.
    00-06-F5   # ALPS ELECTRIC CO.,LTD.
    00-06-F6   # Cisco Systems, Inc
    00-06-F7   # ALPS ELECTRIC CO.,LTD.
    00-06-F8   # The Boeing Company
    00-06-F9   # Mitsui Zosen Systems Research Inc.
    00-06-FA   # IP SQUARE Co, Ltd.
    00-06-FB   # Hitachi Printing Solutions, Ltd.
    00-06-FC   # Fnet Co., Ltd.
    00-06-FD   # Comjet Information Systems Corp.
    00-06-FE   # Ambrado, Inc
    00-06-FF   # Sheba Systems Co., Ltd.
    00-07-00   # Zettamedia Korea
    00-07-01   # RACAL-DATACOM
    00-07-02   # Varian Medical Systems
    00-07-03   # CSEE Transport
    00-07-04   # ALPS ELECTRIC CO.,LTD.
    00-07-05   # Endress & Hauser GmbH & Co
    00-07-06   # Sanritz Corporation
    00-07-07   # Interalia Inc.
    00-07-08   # Bitrage Inc.
    00-07-09   # Westerstrand Urfabrik AB
    00-07-0A   # Unicom Automation Co., Ltd.
    00-07-0B   # Novabase SGPS, SA
    00-07-0C   # SVA-Intrusion.com Co. Ltd.
    00-07-0D   # Cisco Systems, Inc
    00-07-0E   # Cisco Systems, Inc
    00-07-0F   # Fujant, Inc.
    00-07-10   # Adax, Inc.
    00-07-11   # Acterna
    00-07-12   # JAL Information Technology
    00-07-13   # IP One, Inc.
    00-07-14   # Brightcom
    00-07-15   # General Research of Electronics, Inc.
    00-07-16   # J & S Marine Ltd.
    00-07-17   # Wieland Electric GmbH
    00-07-18   # iCanTek Co., Ltd.
    00-07-19   # Mobiis Co., Ltd.
    00-07-1A   # Finedigital Inc.
    00-07-1B   # CDVI Americas Ltd
    00-07-1C   # AT&T Fixed Wireless Services
    00-07-1D   # Satelsa Sistemas Y Aplicaciones De Telecomunicaciones, S.A.
    00-07-1E   # Tri-M Engineering / Nupak Dev. Corp.
    00-07-1F   # European Systems Integration
    00-07-20   # Trutzschler GmbH & Co. KG
    00-07-21   # Formac Elektronik GmbH
    00-07-22   # The Nielsen Company
    00-07-23   # ELCON Systemtechnik GmbH
    00-07-24   # Telemax Co., Ltd.
    00-07-25   # Bematech International Corp.
    00-07-26   # Shenzhen Gongjin Electronics Co., Ltd.
    00-07-27   # Zi Corporation (HK) Ltd.
    00-07-28   # Neo Telecom
    00-07-29   # Kistler Instrumente AG
    00-07-2A   # Innovance Networks
    00-07-2B   # Jung Myung Telecom Co., Ltd.
    00-07-2C   # Fabricom
    00-07-2D   # CNSystems
    00-07-2E   # North Node AB
    00-07-2F   # Intransa, Inc.
    00-07-30   # Hutchison OPTEL Telecom Technology Co., Ltd.
    00-07-31   # Ophir-Spiricon LLC
    00-07-32   # AAEON Technology Inc.
    00-07-33   # DANCONTROL Engineering
    00-07-34   # ONStor, Inc.
    00-07-35   # Flarion Technologies, Inc.
    00-07-36   # Data Video Technologies Co., Ltd.
    00-07-37   # Soriya Co. Ltd.
    00-07-38   # Young Technology Co., Ltd.
    00-07-39   # Scotty Group Austria Gmbh
    00-07-3A   # Inventel Systemes
    00-07-3B   # Tenovis GmbH & Co KG
    00-07-3C   # Telecom Design
    00-07-3D   # Nanjing Postel Telecommunications Co., Ltd.
    00-07-3E   # China Great-Wall Computer Shenzhen Co., Ltd.
    00-07-3F   # Woojyun Systec Co., Ltd.
    00-07-40   # BUFFALO.INC
    00-07-41   # Sierra Automated Systems
    00-07-42   # Ormazabal
    00-07-43   # Chelsio Communications
    00-07-44   # Unico, Inc.
    00-07-45   # Radlan Computer Communications Ltd.
    00-07-46   # TURCK, Inc.
    00-07-47   # Mecalc
    00-07-48   # The Imaging Source Europe
    00-07-49   # CENiX Inc.
    00-07-4A   # Carl Valentin GmbH
    00-07-4B   # Daihen Corporation
    00-07-4C   # Beicom Inc.
    00-07-4D   # Zebra Technologies Corp.
    00-07-4E   # IPFRONT Inc
    00-07-4F   # Cisco Systems, Inc
    00-07-50   # Cisco Systems, Inc
    00-07-51   # m-u-t AG
    00-07-52   # Rhythm Watch Co., Ltd.
    00-07-53   # Beijing Qxcomm Technology Co., Ltd.
    00-07-54   # Xyterra Computing, Inc.
    00-07-55   # Lafon
    00-07-56   # Juyoung Telecom
    00-07-57   # Topcall International AG
    00-07-58   # Dragonwave
    00-07-59   # Boris Manufacturing Corp.
    00-07-5A   # Air Products and Chemicals, Inc.
    00-07-5B   # Gibson Guitars
    00-07-5C   # Eastman Kodak Company
    00-07-5D   # Celleritas Inc.
    00-07-5E   # Ametek Power Instruments
    00-07-5F   # VCS Video Communication Systems AG
    00-07-60   # TOMIS Information & Telecom Corp.
    00-07-61   # Logitech Europe SA
    00-07-62   # Group Sense Limited
    00-07-63   # Sunniwell Cyber Tech. Co., Ltd.
    00-07-64   # YoungWoo Telecom Co. Ltd.
    00-07-65   # Jade Quantum Technologies, Inc.
    00-07-66   # Chou Chin Industrial Co., Ltd.
    00-07-67   # Yuxing Electronics Company Limited
    00-07-68   # Danfoss A/S
    00-07-69   # Italiana Macchi SpA
    00-07-6A   # NEXTEYE Co., Ltd.
    00-07-6B   # Stralfors AB
    00-07-6C   # Daehanet, Inc.
    00-07-6D   # Flexlight Networks
    00-07-6E   # Sinetica Corporation Limited
    00-07-6F   # Synoptics Limited
    00-07-70   # Ubiquoss Inc
    00-07-71   # Embedded System Corporation
    00-07-72   # Alcatel Shanghai Bell Co., Ltd.
    00-07-73   # Ascom Powerline Communications Ltd.
    00-07-74   # GuangZhou Thinker Technology Co. Ltd.
    00-07-75   # Valence Semiconductor, Inc.
    00-07-76   # Federal APD
    00-07-77   # Motah Ltd.
    00-07-78   # GERSTEL GmbH & Co. KG
    00-07-79   # Sungil Telecom Co., Ltd.
    00-07-7A   # Infoware System Co., Ltd.
    00-07-7B   # Millimetrix Broadband Networks
    00-07-7C   # Westermo Teleindustri AB
    00-07-7D   # Cisco Systems, Inc
    00-07-7E   # Elrest GmbH
    00-07-7F   # J Communications Co., Ltd.
    00-07-80   # Bluegiga Technologies OY
    00-07-81   # Itron Inc.
    00-07-82   # Oracle Corporation
    00-07-83   # SynCom Network, Inc.
    00-07-84   # Cisco Systems, Inc
    00-07-85   # Cisco Systems, Inc
    00-07-86   # Wireless Networks Inc.
    00-07-87   # Idea System Co., Ltd.
    00-07-88   # Clipcomm, Inc.
    00-07-89   # DONGWON SYSTEMS
    00-07-8A   # Mentor Data System Inc.
    00-07-8B   # Wegener Communications, Inc.
    00-07-8C   # Elektronikspecialisten i Borlange AB
    00-07-8D   # NetEngines Ltd.
    00-07-8E   # Garz & Friche GmbH
    00-07-8F   # Emkay Innovative Products
    00-07-90   # Tri-M Technologies (s) Limited
    00-07-91   # International Data Communications, Inc.
    00-07-92   # Sütron Electronic GmbH
    00-07-93   # Shin Satellite Public Company Limited
    00-07-94   # Simple Devices, Inc.
    00-07-95   # Elitegroup Computer System Co. (ECS)
    00-07-96   # LSI Systems, Inc.
    00-07-97   # Netpower Co., Ltd.
    00-07-98   # Selea SRL
    00-07-99   # Tipping Point Technologies, Inc.
    00-07-9A   # Verint Systems Inc
    00-07-9B   # Aurora Networks
    00-07-9C   # Golden Electronics Technology Co., Ltd.
    00-07-9D   # Musashi Co., Ltd.
    00-07-9E   # Ilinx Co., Ltd.
    00-07-9F   # Action Digital Inc.
    00-07-A0   # e-Watch Inc.
    00-07-A1   # VIASYS Healthcare GmbH
    00-07-A2   # Opteon Corporation
    00-07-A3   # Ositis Software, Inc.
    00-07-A4   # GN Netcom Ltd.
    00-07-A5   # Y.D.K Co. Ltd.
    00-07-A6   # Home Automation, Inc.
    00-07-A7   # A-Z Inc.
    00-07-A8   # Haier Group Technologies Ltd.
    00-07-A9   # Novasonics
    00-07-AA   # Quantum Data Inc.
    00-07-AB   # Samsung Electronics Co.,Ltd
    00-07-AC   # Eolring
    00-07-AD   # Pentacon GmbH Foto-und Feinwerktechnik
    00-07-AE   # Britestream Networks, Inc.
    00-07-AF   # Red Lion Controls, LP
    00-07-B0   # Office Details, Inc.
    00-07-B1   # Equator Technologies
    00-07-B2   # Transaccess S.A.
    00-07-B3   # Cisco Systems, Inc
    00-07-B4   # Cisco Systems, Inc
    00-07-B5   # Any One Wireless Ltd.
    00-07-B6   # Telecom Technology Ltd.
    00-07-B7   # Samurai Ind. Prods Eletronicos Ltda
    00-07-B8   # Corvalent Corporation
    00-07-B9   # Ginganet Corporation
    00-07-BA   # UTStarcom, Inc.
    00-07-BB   # Candera Inc.
    00-07-BC   # Identix Inc.
    00-07-BD   # Radionet Ltd.
    00-07-BE   # DataLogic SpA
    00-07-BF   # Armillaire Technologies, Inc.
    00-07-C0   # NetZerver Inc.
    00-07-C1   # Overture Networks, Inc.
    00-07-C2   # Netsys Telecom
    00-07-C3   # Thomson
    00-07-C4   # JEAN Co. Ltd.
    00-07-C5   # Gcom, Inc.
    00-07-C6   # VDS Vosskuhler GmbH
    00-07-C7   # Synectics Systems Limited
    00-07-C8   # Brain21, Inc.
    00-07-C9   # Technol Seven Co., Ltd.
    00-07-CA   # Creatix Polymedia Ges Fur Kommunikaitonssysteme
    00-07-CB   # FREEBOX SAS
    00-07-CC   # Kaba Benzing GmbH
    00-07-CD   # Kumoh Electronic Co, Ltd
    00-07-CE   # Cabletime Limited
    00-07-CF   # Anoto AB
    00-07-D0   # Automat Engenharia de Automação Ltda.
    00-07-D1   # Spectrum Signal Processing Inc.
    00-07-D2   # Logopak Systeme GmbH & Co. KG
    00-07-D3   # SPGPrints B.V.
    00-07-D4   # Zhejiang Yutong Network Communication Co Ltd.
    00-07-D5   # 3e Technologies Int;., Inc.
    00-07-D6   # Commil Ltd.
    00-07-D7   # Caporis Networks AG
    00-07-D8   # Hitron Technologies. Inc
    00-07-D9   # Splicecom
    00-07-DA   # Neuro Telecom Co., Ltd.
    00-07-DB   # Kirana Networks, Inc.
    00-07-DC   # Atek Co, Ltd.
    00-07-DD   # Cradle Technologies
    00-07-DE   # eCopilt AB
    00-07-DF   # Vbrick Systems Inc.
    00-07-E0   # Palm Inc.
    00-07-E1   # WIS Communications Co. Ltd.
    00-07-E2   # Bitworks, Inc.
    00-07-E3   # Navcom Technology, Inc.
    00-07-E4   # SoftRadio Co., Ltd.
    00-07-E5   # Coup Corporation
    00-07-E6   # edgeflow Canada Inc.
    00-07-E7   # FreeWave Technologies
    00-07-E8   # EdgeWave
    00-07-E9   # Intel Corporation
    00-07-EA   # Massana, Inc.
    00-07-EB   # Cisco Systems, Inc
    00-07-EC   # Cisco Systems, Inc
    00-07-ED   # Altera Corporation
    00-07-EE   # telco Informationssysteme GmbH
    00-07-EF   # Lockheed Martin Tactical Systems
    00-07-F0   # LogiSync LLC
    00-07-F1   # TeraBurst Networks Inc.
    00-07-F2   # IOA Corporation
    00-07-F3   # Thinkengine Networks
    00-07-F4   # Eletex Co., Ltd.
    00-07-F5   # Bridgeco Co AG
    00-07-F6   # Qqest Software Systems
    00-07-F7   # Galtronics
    00-07-F8   # ITDevices, Inc.
    00-07-F9   # Sensaphone
    00-07-FA   # ITT Co., Ltd.
    00-07-FB   # Giga Stream UMTS Technologies GmbH
    00-07-FC   # Adept Systems Inc.
    00-07-FD   # LANergy Ltd.
    00-07-FE   # Rigaku Corporation
    00-07-FF   # Gluon Networks
    00-08-00   # MULTITECH SYSTEMS, INC.
    00-08-01   # HighSpeed Surfing Inc.
    00-08-02   # Hewlett Packard
    00-08-03   # Cos Tron
    00-08-04   # ICA Inc.
    00-08-05   # Techno-Holon Corporation
    00-08-06   # Raonet Systems, Inc.
    00-08-07   # Access Devices Limited
    00-08-08   # PPT Vision, Inc.
    00-08-09   # Systemonic AG
    00-08-0A   # Espera-Werke GmbH
    00-08-0B   # Birka BPA Informationssystem AB
    00-08-0C   # VDA Elettronica spa
    00-08-0D   # Toshiba
    00-08-0E   # ARRIS Group, Inc.
    00-08-0F   # Proximion Fiber Optics AB
    00-08-10   # Key Technology, Inc.
    00-08-11   # VOIX Corporation
    00-08-12   # GM-2 Corporation
    00-08-13   # Diskbank, Inc.
    00-08-14   # TIL Technologies
    00-08-15   # CATS Co., Ltd.
    00-08-16   # Bluelon ApS
    00-08-17   # EmergeCore Networks LLC
    00-08-18   # Pixelworks, Inc.
    00-08-19   # Banksys
    00-08-1A   # Sanrad Intelligence Storage Communications (2000) Ltd.
    00-08-1B   # Windigo Systems
    00-08-1C   # @pos.com
    00-08-1D   # Ipsil, Incorporated
    00-08-1E   # Repeatit AB
    00-08-1F   # Pou Yuen Tech Corp. Ltd.
    00-08-20   # Cisco Systems, Inc
    00-08-21   # Cisco Systems, Inc
    00-08-22   # InPro Comm
    00-08-23   # Texa Corp.
    00-08-24   # Nuance Document Imaging
    00-08-25   # Acme Packet
    00-08-26   # Colorado Med Tech
    00-08-27   # ADB Broadband Italia
    00-08-28   # Koei Engineering Ltd.
    00-08-29   # Aval Nagasaki Corporation
    00-08-2A   # Powerwallz Network Security
    00-08-2B   # Wooksung Electronics, Inc.
    00-08-2C   # Homag AG
    00-08-2D   # Indus Teqsite Private Limited
    00-08-2E   # Multitone Electronics PLC
    00-08-2F   # Cisco Systems, Inc
    00-08-30   # Cisco Systems, Inc
    00-08-31   # Cisco Systems, Inc
    00-08-32   # Cisco Systems, Inc
    00-08-4E   # DivergeNet, Inc.
    00-08-4F   # Qualstar Corporation
    00-08-50   # Arizona Instrument Corp.
    00-08-51   # Canadian Bank Note Company, Ltd.
    00-08-52   # Davolink Co. Inc.
    00-08-53   # Schleicher GmbH & Co. Relaiswerke KG
    00-08-54   # Netronix, Inc.
    00-08-55   # NASA-Goddard Space Flight Center
    00-08-56   # Gamatronic Electronic Industries Ltd.
    00-08-57   # Polaris Networks, Inc.
    00-08-58   # Novatechnology Inc.
    00-08-59   # ShenZhen Unitone Electronics Co., Ltd.
    00-08-5A   # IntiGate Inc.
    00-08-5B   # Hanbit Electronics Co., Ltd.
    00-08-5C   # Shanghai Dare Technologies Co. Ltd.
    00-08-5D   # Aastra
    00-08-5E   # PCO AG
    00-08-5F   # Picanol N.V.
    00-08-60   # LodgeNet Entertainment Corp.
    00-08-61   # SoftEnergy Co., Ltd.
    00-08-62   # NEC Eluminant Technologies, Inc.
    00-08-63   # Entrisphere Inc.
    00-08-64   # Fasy S.p.A.
    00-08-65   # JASCOM CO., LTD
    00-08-66   # DSX Access Systems, Inc.
    00-08-67   # Uptime Devices
    00-08-68   # PurOptix
    00-08-69   # Command-e Technology Co.,Ltd.
    00-08-6A   # Securiton Gmbh
    00-08-6B   # MIPSYS
    00-08-6C   # Plasmon LMS
    00-08-6D   # Missouri FreeNet
    00-08-6E   # Hyglo AB
    00-08-6F   # Resources Computer Network Ltd.
    00-08-70   # Rasvia Systems, Inc.
    00-08-71   # NORTHDATA Co., Ltd.
    00-08-72   # Sorenson Communications
    00-08-73   # DapTechnology B.V.
    00-08-74   # Dell Inc.
    00-08-75   # Acorp Electronics Corp.
    00-08-76   # SDSystem
    00-08-77   # Liebert-Hiross Spa
    00-08-78   # Benchmark Storage Innovations
    00-08-79   # CEM Corporation
    00-08-7A   # Wipotec GmbH
    00-08-7B   # RTX Telecom A/S
    00-08-7C   # Cisco Systems, Inc
    00-08-7D   # Cisco Systems, Inc
    00-08-7E   # Bon Electro-Telecom Inc.
    00-08-7F   # SPAUN electronic GmbH & Co. KG
    00-08-80   # BroadTel Canada Communications inc.
    00-08-81   # DIGITAL HANDS CO.,LTD.
    00-08-82   # SIGMA CORPORATION
    00-08-83   # Hewlett Packard
    00-08-84   # Index Braille AB
    00-08-85   # EMS Dr. Thomas Wünsche
    00-08-86   # Hansung Teliann, Inc.
    00-08-87   # Maschinenfabrik Reinhausen GmbH
    00-08-88   # OULLIM Information Technology Inc,.
    00-08-89   # Echostar Technologies Corp
    00-08-8A   # Minds@Work
    00-08-8B   # Tropic Networks Inc.
    00-08-8C   # Quanta Network Systems Inc.
    00-08-8D   # Sigma-Links Inc.
    00-08-8E   # Nihon Computer Co., Ltd.
    00-08-8F   # ADVANCED DIGITAL TECHNOLOGY
    00-08-90   # AVILINKS SA
    00-08-91   # Lyan Inc.
    00-08-92   # EM Solutions
    00-08-93   # LE INFORMATION COMMUNICATION INC.
    00-08-94   # InnoVISION Multimedia Ltd.
    00-08-95   # DIRC Technologie GmbH & Co.KG
    00-08-96   # Printronix, Inc.
    00-08-97   # Quake Technologies
    00-08-98   # Gigabit Optics Corporation
    00-08-99   # Netbind, Inc.
    00-08-9A   # Alcatel Microelectronics
    00-08-9B   # ICP Electronics Inc.
    00-08-9C   # Elecs Industry Co., Ltd.
    00-08-9D   # UHD-Elektronik
    00-08-9E   # Beijing Enter-Net co.LTD
    00-08-9F   # EFM Networks
    00-08-A0   # Stotz Feinmesstechnik GmbH
    00-08-A1   # CNet Technology Inc.
    00-08-A2   # ADI Engineering, Inc.
    00-08-A3   # Cisco Systems, Inc
    00-08-A4   # Cisco Systems, Inc
    00-08-A5   # Peninsula Systems Inc.
    00-08-A6   # Multiware & Image Co., Ltd.
    00-08-A7   # iLogic Inc.
    00-08-A8   # Systec Co., Ltd.
    00-08-A9   # SangSang Technology, Inc.
    00-08-AA   # KARAM
    00-08-AB   # EnerLinx.com, Inc.
    00-08-AC   # Eltromat GmbH
    00-08-AD   # Toyo-Linx Co., Ltd.
    00-08-AE   # PacketFront Network Products AB
    00-08-AF   # Novatec Corporation
    00-08-B0   # BKtel communications GmbH
    00-08-B1   # ProQuent Systems
    00-08-B2   # SHENZHEN COMPASS TECHNOLOGY DEVELOPMENT CO.,LTD
    00-08-B3   # Fastwel
    00-08-B4   # SYSPOL
    00-08-B5   # TAI GUEN ENTERPRISE CO., LTD
    00-08-B6   # RouteFree, Inc.
    00-08-B7   # HIT Incorporated
    00-08-B8   # E.F. Johnson
    00-08-B9   # KAON MEDIA Co., Ltd.
    00-08-BA   # Erskine Systems Ltd
    00-08-BB   # NetExcell
    00-08-BC   # Ilevo AB
    00-08-BD   # TEPG-US
    00-08-BE   # XENPAK MSA Group
    00-08-BF   # Aptus Elektronik AB
    00-08-C0   # ASA SYSTEMS
    00-08-C1   # Avistar Communications Corporation
    00-08-C2   # Cisco Systems, Inc
    00-08-C3   # Contex A/S
    00-08-C4   # Hikari Co.,Ltd.
    00-08-C5   # Liontech Co., Ltd.
    00-08-C6   # Philips Consumer Communications
    00-08-C7   # Hewlett Packard
    00-08-C8   # Soneticom, Inc.
    00-08-C9   # TechniSat Digital GmbH
    00-08-CA   # TwinHan Technology Co.,Ltd
    00-08-CB   # Zeta Broadband Inc.
    00-08-CC   # Remotec, Inc.
    00-08-CD   # With-Net Inc
    00-08-CE   # IPMobileNet Inc.
    00-08-CF   # Nippon Koei Power Systems Co., Ltd.
    00-08-D0   # Musashi Engineering Co., LTD.
    00-08-D1   # KAREL INC.
    00-08-D2   # ZOOM Networks Inc.
    00-08-D3   # Hercules Technologies S.A.S.
    00-08-D4   # IneoQuest Technologies, Inc
    00-08-D5   # Vanguard Networks Solutions, LLC
    00-08-D6   # HASSNET Inc.
    00-08-D7   # HOW CORPORATION
    00-08-D8   # Dowkey Microwave
    00-08-D9   # Mitadenshi Co.,LTD
    00-08-DA   # SofaWare Technologies Ltd.
    00-08-DB   # Corrigent Systems
    00-08-DC   # Wiznet
    00-08-DD   # Telena Communications, Inc.
    00-08-DE   # 3UP Systems
    00-08-DF   # Alistel Inc.
    00-08-E0   # ATO Technology Ltd.
    00-08-E1   # Barix AG
    00-08-E2   # Cisco Systems, Inc
    00-08-E3   # Cisco Systems, Inc
    00-08-E4   # Envenergy Inc
    00-08-E5   # IDK Corporation
    00-08-E6   # Littlefeet
    00-08-E7   # SHI ControlSystems,Ltd.
    00-08-E8   # Excel Master Ltd.
    00-08-E9   # NextGig
    00-08-EA   # Motion Control Engineering, Inc
    00-08-EB   # ROMWin Co.,Ltd.
    00-08-EC   # Optical Zonu Corporation
    00-08-ED   # ST&T Instrument Corp.
    00-08-EE   # Logic Product Development
    00-08-EF   # DIBAL,S.A.
    00-08-F0   # Next Generation Systems, Inc.
    00-08-F1   # Voltaire
    00-08-F2   # C&S Technology
    00-08-F3   # WANY
    00-08-F4   # Bluetake Technology Co., Ltd.
    00-08-F5   # YESTECHNOLOGY Co.,Ltd.
    00-08-F6   # Sumitomo Electric Industries,Ltd
    00-08-F7   # Hitachi Ltd, Semiconductor & Integrated Circuits Gr
    00-08-F8   # UTC CCS
    00-08-F9   # Artesyn Embedded Technologies
    00-08-FA   # Karl E.Brinkmann GmbH
    00-08-FB   # SonoSite, Inc.
    00-08-FC   # Gigaphoton Inc.
    00-08-FD   # BlueKorea Co., Ltd.
    00-08-FE   # UNIK C&C Co.,Ltd.
    00-08-FF   # Trilogy Communications Ltd
    00-09-00   # TMT
    00-09-01   # Shenzhen Shixuntong Information & Technoligy Co
    00-09-02   # Redline Communications Inc.
    00-09-03   # Panasas, Inc
    00-09-04   # MONDIAL electronic
    00-09-05   # iTEC Technologies Ltd.
    00-09-06   # Esteem Networks
    00-09-07   # Chrysalis Development
    00-09-08   # VTech Technology Corp.
    00-09-09   # Telenor Connect A/S
    00-09-0A   # SnedFar Technology Co., Ltd.
    00-09-0B   # MTL  Instruments PLC
    00-09-0C   # Mayekawa Mfg. Co. Ltd.
    00-09-0D   # LEADER ELECTRONICS CORP.
    00-09-0E   # Helix Technology Inc.
    00-09-0F   # Fortinet Inc.
    00-09-10   # Simple Access Inc.
    00-09-11   # Cisco Systems, Inc
    00-09-12   # Cisco Systems, Inc
    00-09-13   # SystemK Corporation
    00-09-14   # COMPUTROLS INC.
    00-09-15   # CAS Corp.
    00-09-16   # Listman Home Technologies, Inc.
    00-09-17   # WEM Technology Inc
    00-09-18   # SAMSUNG TECHWIN CO.,LTD
    00-09-19   # MDS Gateways
    00-09-1A   # Macat Optics & Electronics Co., Ltd.
    00-09-1B   # Digital Generation Inc.
    00-09-1C   # CacheVision, Inc
    00-09-1D   # Proteam Computer Corporation
    00-09-1E   # Firstech Technology Corp.
    00-09-1F   # A&D Co., Ltd.
    00-09-20   # EpoX COMPUTER CO.,LTD.
    00-09-21   # Planmeca Oy
    00-09-22   # TST Biometrics GmbH
    00-09-23   # Heaman System Co., Ltd
    00-09-24   # Telebau GmbH
    00-09-25   # VSN Systemen BV
    00-09-26   # YODA COMMUNICATIONS, INC.
    00-09-27   # TOYOKEIKI CO.,LTD.
    00-09-28   # Telecore
    00-09-29   # Sanyo Industries (UK) Limited
    00-09-2A   # MYTECS Co.,Ltd.
    00-09-2B   # iQstor Networks, Inc.
    00-09-2C   # Hitpoint Inc.
    00-09-2D   # HTC Corporation
    00-09-2E   # B&Tech System Inc.
    00-09-2F   # Akom Technology Corporation
    00-09-30   # AeroConcierge Inc.
    00-09-31   # Future Internet, Inc.
    00-09-32   # Omnilux
    00-09-33   # Ophit Co.Ltd.
    00-09-34   # Dream-Multimedia-Tv GmbH
    00-09-35   # Sandvine Incorporated
    00-09-36   # Ipetronik GmbH & Co. KG
    00-09-37   # Inventec Appliance Corp
    00-09-38   # Allot Communications
    00-09-39   # ShibaSoku Co.,Ltd.
    00-09-3A   # Molex Fiber Optics
    00-09-3B   # HYUNDAI NETWORKS INC.
    00-09-3C   # Jacques Technologies P/L
    00-09-3D   # Newisys,Inc.
    00-09-3E   # C&I Technologies
    00-09-3F   # Double-Win Enterpirse CO., LTD
    00-09-40   # AGFEO GmbH & Co. KG
    00-09-41   # Allied Telesis R&D Center K.K.
    00-09-42   # Wireless Technologies, Inc
    00-09-43   # Cisco Systems, Inc
    00-09-44   # Cisco Systems, Inc
    00-09-45   # Palmmicro Communications Inc
    00-09-46   # Cluster Labs GmbH
    00-09-47   # Aztek, Inc.
    00-09-48   # Vista Control Systems, Corp.
    00-09-49   # Glyph Technologies Inc.
    00-09-4A   # Homenet Communications
    00-09-4B   # FillFactory NV
    00-09-4C   # Communication Weaver Co.,Ltd.
    00-09-4D   # Braintree Communications Pty Ltd
    00-09-4E   # BARTECH SYSTEMS INTERNATIONAL, INC
    00-09-4F   # elmegt GmbH & Co. KG
    00-09-50   # Independent Storage Corporation
    00-09-51   # Apogee Imaging Systems
    00-09-52   # Auerswald GmbH & Co. KG
    00-09-53   # Linkage System Integration Co.Ltd.
    00-09-54   # AMiT spol. s. r. o.
    00-09-55   # Young Generation International Corp.
    00-09-56   # Network Systems Group, Ltd. (NSG)
    00-09-57   # Supercaller, Inc.
    00-09-58   # INTELNET S.A.
    00-09-59   # Sitecsoft
    00-09-5A   # RACEWOOD TECHNOLOGY
    00-09-5B   # NETGEAR
    00-09-5C   # Philips Medical Systems - Cardiac and Monitoring Systems (CM
    00-09-5D   # Dialogue Technology Corp.
    00-09-5E   # Masstech Group Inc.
    00-09-5F   # Telebyte, Inc.
    00-09-60   # YOZAN Inc.
    00-09-61   # Switchgear and Instrumentation Ltd
    00-09-62   # Sonitor Technologies AS
    00-09-63   # Dominion Lasercom Inc.
    00-09-64   # Hi-Techniques, Inc.
    00-09-65   # HyunJu Computer Co., Ltd.
    00-09-66   # Thales Navigation
    00-09-67   # Tachyon, Inc
    00-09-68   # TECHNOVENTURE, INC.
    00-09-69   # Meret Optical Communications
    00-09-6A   # Cloverleaf Communications Inc.
    00-09-6B   # IBM Corp
    00-09-6C   # Imedia Semiconductor Corp.
    00-09-6D   # Powernet Technologies Corp.
    00-09-6E   # GIANT ELECTRONICS LTD.
    00-09-6F   # Beijing Zhongqing Elegant Tech. Corp.,Limited
    00-09-70   # Vibration Research Corporation
    00-09-71   # Time Management, Inc.
    00-09-72   # Securebase,Inc
    00-09-73   # Lenten Technology Co., Ltd.
    00-09-74   # Innopia Technologies, Inc.
    00-09-75   # fSONA Communications Corporation
    00-09-76   # Datasoft ISDN Systems GmbH
    00-09-77   # Brunner Elektronik AG
    00-09-78   # AIJI System Co., Ltd.
    00-09-79   # Advanced Television Systems Committee, Inc.
    00-09-7A   # Louis Design Labs.
    00-09-7B   # Cisco Systems, Inc
    00-09-7C   # Cisco Systems, Inc
    00-09-7D   # SecWell Networks Oy
    00-09-7E   # IMI TECHNOLOGY CO., LTD
    00-09-7F   # Vsecure 2000 LTD.
    00-09-80   # Power Zenith Inc.
    00-09-81   # Newport Networks
    00-09-82   # Loewe Opta GmbH
    00-09-83   # GlobalTop Technology, Inc.
    00-09-84   # MyCasa Network Inc.
    00-09-85   # Auto Telecom Company
    00-09-86   # Metalink LTD.
    00-09-87   # NISHI NIPPON ELECTRIC WIRE & CABLE CO.,LTD.
    00-09-88   # Nudian Electron Co., Ltd.
    00-09-89   # VividLogic Inc.
    00-09-8A   # EqualLogic Inc
    00-09-8B   # Entropic Communications, Inc.
    00-09-8C   # Option Wireless Sweden
    00-09-8D   # Velocity Semiconductor
    00-09-8E   # ipcas GmbH
    00-09-8F   # Cetacean Networks
    00-09-90   # ACKSYS Communications & systems
    00-09-91   # GE Fanuc Automation Manufacturing, Inc.
    00-09-92   # InterEpoch Technology,INC.
    00-09-93   # Visteon Corporation
    00-09-94   # Cronyx Engineering
    00-09-95   # Castle Technology Ltd
    00-09-96   # RDI
    00-09-97   # Nortel Networks
    00-09-98   # Capinfo Company Limited
    00-09-99   # CP GEORGES RENAULT
    00-09-9A   # ELMO COMPANY, LIMITED
    00-09-9B   # Western Telematic Inc.
    00-09-9C   # Naval Research Laboratory
    00-09-9D   # Haliplex Communications
    00-09-9E   # Testech, Inc.
    00-09-9F   # VIDEX INC.
    00-09-A0   # Microtechno Corporation
    00-09-A1   # Telewise Communications, Inc.
    00-09-A2   # Interface Co., Ltd.
    00-09-A3   # Leadfly Techologies Corp. Ltd.
    00-09-A4   # HARTEC Corporation
    00-09-A5   # HANSUNG ELETRONIC INDUSTRIES DEVELOPMENT CO., LTD
    00-09-A6   # Ignis Optics, Inc.
    00-09-A7   # Bang & Olufsen A/S
    00-09-A8   # Eastmode Pte Ltd
    00-09-A9   # Ikanos Communications
    00-09-AA   # Data Comm for Business, Inc.
    00-09-AB   # Netcontrol Oy
    00-09-AC   # LANVOICE
    00-09-AD   # HYUNDAI SYSCOMM, INC.
    00-09-AE   # OKANO ELECTRIC CO.,LTD
    00-09-AF   # e-generis
    00-09-B0   # Onkyo Corporation
    00-09-B1   # Kanematsu Electronics, Ltd.
    00-09-B2   # L&F Inc.
    00-09-B3   # MCM Systems Ltd
    00-09-B4   # KISAN TELECOM CO., LTD.
    00-09-B5   # 3J Tech. Co., Ltd.
    00-09-B6   # Cisco Systems, Inc
    00-09-B7   # Cisco Systems, Inc
    00-09-B8   # Entise Systems
    00-09-B9   # Action Imaging Solutions
    00-09-BA   # MAKU Informationstechik GmbH
    00-09-BB   # MathStar, Inc.
    00-09-BC   # Digital Safety Technologies, Inc
    00-09-BD   # Epygi Technologies, Ltd.
    00-09-BE   # Mamiya-OP Co.,Ltd.
    00-09-BF   # Nintendo Co., Ltd.
    00-09-C0   # 6WIND
    00-09-C1   # PROCES-DATA A/S
    00-09-C2   # Onity, Inc.
    00-09-C3   # NETAS
    00-09-C4   # Medicore Co., Ltd
    00-09-C5   # KINGENE Technology Corporation
    00-09-C6   # Visionics Corporation
    00-09-C7   # Movistec
    00-09-C8   # SINAGAWA TSUSHIN KEISOU SERVICE
    00-09-C9   # BlueWINC Co., Ltd.
    00-09-CA   # iMaxNetworks(Shenzhen)Limited.
    00-09-CB   # HBrain
    00-09-CC   # Moog GmbH
    00-09-CD   # HUDSON SOFT CO.,LTD.
    00-09-CE   # SpaceBridge Semiconductor Corp.
    00-09-CF   # iAd GmbH
    00-09-D0   # Solacom Technologies Inc.
    00-09-D1   # SERANOA NETWORKS INC
    00-09-D2   # Mai Logic Inc.
    00-09-D3   # Western DataCom Co., Inc.
    00-09-D4   # Transtech Networks
    00-09-D5   # Signal Communication, Inc.
    00-09-D6   # KNC One GmbH
    00-09-D7   # DC Security Products
    00-09-D8   # Fält Communications AB
    00-09-D9   # Neoscale Systems, Inc
    00-09-DA   # Control Module Inc.
    00-09-DB   # eSpace
    00-09-DC   # Galaxis Technology AG
    00-09-DD   # Mavin Technology Inc.
    00-09-DE   # Samjin Information & Communications Co., Ltd.
    00-09-DF   # Vestel Komunikasyon Sanayi ve Ticaret A.S.
    00-09-E0   # XEMICS S.A.
    00-09-E1   # Gemtek Technology Co., Ltd.
    00-09-E2   # Sinbon Electronics Co., Ltd.
    00-09-E3   # Angel Iglesias S.A.
    00-09-E4   # K Tech Infosystem Inc.
    00-09-E5   # Hottinger Baldwin Messtechnik GmbH
    00-09-E6   # Cyber Switching Inc.
    00-09-E7   # ADC Techonology
    00-09-E8   # Cisco Systems, Inc
    00-09-E9   # Cisco Systems, Inc
    00-09-EA   # YEM Inc.
    00-09-EB   # HuMANDATA LTD.
    00-09-EC   # Daktronics, Inc.
    00-09-ED   # CipherOptics
    00-09-EE   # MEIKYO ELECTRIC CO.,LTD
    00-09-EF   # Vocera Communications
    00-09-F0   # Shimizu Technology Inc.
    00-09-F1   # Yamaki Electric Corporation
    00-09-F2   # Cohu, Inc., Electronics Division
    00-09-F3   # WELL Communication Corp.
    00-09-F4   # Alcon Laboratories, Inc.
    00-09-F5   # Emerson Network Power Co.,Ltd
    00-09-F6   # Shenzhen Eastern Digital Tech Ltd.
    00-09-F7   # SED, a division of Calian
    00-09-F8   # UNIMO TECHNOLOGY CO., LTD.
    00-09-F9   # ART JAPAN CO., LTD.
    00-09-FB   # Philips Patient Monitoring
    00-09-FC   # IPFLEX Inc.
    00-09-FD   # Ubinetics Limited
    00-09-FE   # Daisy Technologies, Inc.
    00-09-FF   # X.net 2000 GmbH
    00-0A-00   # Mediatek Corp.
    00-0A-01   # SOHOware, Inc.
    00-0A-02   # ANNSO CO., LTD.
    00-0A-03   # ENDESA SERVICIOS, S.L.
    00-0A-04   # 3Com Ltd
    00-0A-05   # Widax Corp.
    00-0A-06   # Teledex LLC
    00-0A-07   # WebWayOne Ltd
    00-0A-08   # ALPINE ELECTRONICS, INC.
    00-0A-09   # TaraCom Integrated Products, Inc.
    00-0A-0A   # SUNIX Co., Ltd.
    00-0A-0B   # Sealevel Systems, Inc.
    00-0A-0C   # Scientific Research Corporation
    00-0A-0D   # FCI Deutschland GmbH
    00-0A-0E   # Invivo Research Inc.
    00-0A-0F   # Ilryung Telesys, Inc
    00-0A-10   # FAST media integrations AG
    00-0A-11   # ExPet Technologies, Inc
    00-0A-12   # Azylex Technology, Inc
    00-0A-13   # Honeywell Video Systems
    00-0A-14   # TECO a.s.
    00-0A-15   # Silicon Data, Inc
    00-0A-16   # Lassen Research
    00-0A-17   # NESTAR COMMUNICATIONS, INC
    00-0A-18   # Vichel Inc.
    00-0A-19   # Valere Power, Inc.
    00-0A-1A   # Imerge Ltd
    00-0A-1B   # Stream Labs
    00-0A-1C   # Bridge Information Co., Ltd.
    00-0A-1D   # Optical Communications Products Inc.
    00-0A-1E   # Red-M Products Limited
    00-0A-1F   # ART WARE Telecommunication Co., Ltd.
    00-0A-20   # SVA Networks, Inc.
    00-0A-21   # Integra Telecom Co. Ltd
    00-0A-22   # Amperion Inc
    00-0A-23   # Parama Networks Inc
    00-0A-24   # Octave Communications
    00-0A-25   # CERAGON NETWORKS
    00-0A-26   # CEIA S.p.A.
    00-0A-27   # Apple, Inc.
    00-0A-28   # Motorola
    00-0A-29   # Pan Dacom Networking AG
    00-0A-2A   # QSI Systems Inc.
    00-0A-2B   # Etherstuff
    00-0A-2C   # Active Tchnology Corporation
    00-0A-2D   # Cabot Communications Limited
    00-0A-2E   # MAPLE NETWORKS CO., LTD
    00-0A-2F   # Artnix Inc.
    00-0A-30   # Visteon Corporation
    00-0A-31   # HCV Consulting
    00-0A-32   # Xsido Corporation
    00-0A-33   # Emulex Corporation
    00-0A-34   # Identicard Systems Incorporated
    00-0A-35   # Xilinx
    00-0A-36   # Synelec Telecom Multimedia
    00-0A-37   # Procera Networks, Inc.
    00-0A-38   # Apani Networks
    00-0A-39   # LoPA Information Technology
    00-0A-3A   # J-THREE INTERNATIONAL Holding Co., Ltd.
    00-0A-3B   # GCT Semiconductor, Inc
    00-0A-3C   # Enerpoint Ltd.
    00-0A-3D   # Elo Sistemas Eletronicos S.A.
    00-0A-3E   # EADS Telecom
    00-0A-3F   # Data East Corporation
    00-0A-40   # Crown Audio -- Harmanm International
    00-0A-41   # Cisco Systems, Inc
    00-0A-42   # Cisco Systems, Inc
    00-0A-43   # Chunghwa Telecom Co., Ltd.
    00-0A-44   # Avery Dennison Deutschland GmbH
    00-0A-45   # Audio-Technica Corp.
    00-0A-46   # ARO WELDING TECHNOLOGIES SAS
    00-0A-47   # Allied Vision Technologies
    00-0A-48   # Albatron Technology
    00-0A-49   # F5 Networks, Inc.
    00-0A-4A   # Targa Systems Ltd.
    00-0A-4B   # DataPower Technology, Inc.
    00-0A-4C   # Molecular Devices Corporation
    00-0A-4D   # Noritz Corporation
    00-0A-4E   # UNITEK Electronics INC.
    00-0A-4F   # Brain Boxes Limited
    00-0A-50   # REMOTEK CORPORATION
    00-0A-51   # GyroSignal Technology Co., Ltd.
    00-0A-52   # AsiaRF Ltd.
    00-0A-53   # Intronics, Incorporated
    00-0A-54   # Laguna Hills, Inc.
    00-0A-55   # MARKEM Corporation
    00-0A-56   # HITACHI Maxell Ltd.
    00-0A-57   # Hewlett Packard
    00-0A-58   # Freyer & Siegel Elektronik GmbH & Co. KG
    00-0A-59   # HW server
    00-0A-5A   # GreenNET Technologies Co.,Ltd.
    00-0A-5B   # Power-One as
    00-0A-5C   # Carel s.p.a.
    00-0A-5D   # FingerTec Worldwide Sdn Bhd
    00-0A-5E   # 3COM Corporation
    00-0A-5F   # almedio inc.
    00-0A-60   # Autostar Technology Pte Ltd
    00-0A-61   # Cellinx Systems Inc.
    00-0A-62   # Crinis Networks, Inc.
    00-0A-63   # DHD GmbH
    00-0A-64   # Eracom Technologies
    00-0A-65   # GentechMedia.co.,ltd.
    00-0A-66   # MITSUBISHI ELECTRIC SYSTEM & SERVICE CO.,LTD.
    00-0A-67   # OngCorp
    00-0A-68   # SolarFlare Communications, Inc.
    00-0A-69   # SUNNY bell Technology Co., Ltd.
    00-0A-6A   # SVM Microwaves s.r.o.
    00-0A-6B   # Tadiran Telecom Business Systems LTD
    00-0A-6C   # Walchem Corporation
    00-0A-6D   # EKS Elektronikservice GmbH
    00-0A-6E   # Harmonic, Inc
    00-0A-6F   # ZyFLEX Technologies Inc
    00-0A-70   # MPLS Forum
    00-0A-71   # Avrio Technologies, Inc
    00-0A-72   # STEC, INC.
    00-0A-73   # Scientific Atlanta
    00-0A-74   # Manticom Networks Inc.
    00-0A-75   # Caterpillar, Inc
    00-0A-76   # Beida Jade Bird Huaguang Technology Co.,Ltd
    00-0A-77   # Bluewire Technologies LLC
    00-0A-78   # OLITEC
    00-0A-79   # corega K.K
    00-0A-7A   # Kyoritsu Electric Co., Ltd.
    00-0A-7B   # Cornelius Consult
    00-0A-7C   # Tecton Ltd
    00-0A-7D   # Valo, Inc.
    00-0A-7E   # The Advantage Group
    00-0A-7F   # Teradon Industries, Inc
    00-0A-80   # Telkonet Inc.
    00-0A-81   # TEIMA Audiotex S.L.
    00-0A-82   # TATSUTA SYSTEM ELECTRONICS CO.,LTD.
    00-0A-83   # SALTO SYSTEMS S.L.
    00-0A-84   # Rainsun Enterprise Co., Ltd.
    00-0A-85   # PLAT'C2,Inc
    00-0A-86   # Lenze
    00-0A-87   # Integrated Micromachines Inc.
    00-0A-88   # InCypher S.A.
    00-0A-89   # Creval Systems, Inc.
    00-0A-8A   # Cisco Systems, Inc
    00-0A-8B   # Cisco Systems, Inc
    00-0A-8C   # Guardware Systems Ltd.
    00-0A-8D   # EUROTHERM LIMITED
    00-0A-8E   # Invacom Ltd
    00-0A-8F   # Aska International Inc.
    00-0A-90   # Bayside Interactive, Inc.
    00-0A-91   # HemoCue AB
    00-0A-92   # Presonus Corporation
    00-0A-93   # W2 Networks, Inc.
    00-0A-94   # ShangHai cellink CO., LTD
    00-0A-95   # Apple, Inc.
    00-0A-96   # MEWTEL TECHNOLOGY INC.
    00-0A-97   # SONICblue, Inc.
    00-0A-98   # M+F Gwinner GmbH & Co
    00-0A-99   # Calamp Wireless Networks Inc
    00-0A-9A   # Aiptek International Inc
    00-0A-9B   # TB Group Inc
    00-0A-9C   # Server Technology, Inc.
    00-0A-9D   # King Young Technology Co. Ltd.
    00-0A-9E   # BroadWeb Corportation
    00-0A-9F   # Pannaway Technologies, Inc.
    00-0A-A0   # Cedar Point Communications
    00-0A-A1   # V V S Limited
    00-0A-A2   # SYSTEK INC.
    00-0A-A3   # SHIMAFUJI ELECTRIC CO.,LTD.
    00-0A-A4   # SHANGHAI SURVEILLANCE TECHNOLOGY CO,LTD
    00-0A-A5   # MAXLINK INDUSTRIES LIMITED
    00-0A-A6   # Hochiki Corporation
    00-0A-A7   # FEI Electron Optics
    00-0A-A8   # ePipe Pty. Ltd.
    00-0A-A9   # Brooks Automation GmbH
    00-0A-AA   # AltiGen Communications Inc.
    00-0A-AB   # Toyota Technical Development Corporation
    00-0A-AC   # TerraTec Electronic GmbH
    00-0A-AD   # Stargames Corporation
    00-0A-AE   # Rosemount Process Analytical
    00-0A-AF   # Pipal Systems
    00-0A-B0   # LOYTEC electronics GmbH
    00-0A-B1   # GENETEC Corporation
    00-0A-B2   # Fresnel Wireless Systems
    00-0A-B3   # Fa. GIRA
    00-0A-B4   # ETIC Telecommunications
    00-0A-B5   # Digital Electronic Network
    00-0A-B6   # COMPUNETIX, INC
    00-0A-B7   # Cisco Systems, Inc
    00-0A-B8   # Cisco Systems, Inc
    00-0A-B9   # Astera Technologies Corp.
    00-0A-BA   # Arcon Technology Limited
    00-0A-BB   # Taiwan Secom Co,. Ltd
    00-0A-BC   # Seabridge Ltd.
    00-0A-BD   # Rupprecht & Patashnick Co.
    00-0A-BE   # OPNET Technologies CO., LTD.
    00-0A-BF   # HIROTA SS
    00-0A-C0   # Fuyoh Video Industry CO., LTD.
    00-0A-C1   # Futuretel
    00-0A-C2   # FiberHome Telecommunication Technologies CO.,LTD
    00-0A-C3   # eM Technics Co., Ltd.
    00-0A-C4   # Daewoo Teletech Co., Ltd
    00-0A-C5   # Color Kinetics
    00-0A-C6   # Overture Networks.
    00-0A-C7   # Unication Group
    00-0A-C8   # ZPSYS CO.,LTD. (Planning&Management)
    00-0A-C9   # Zambeel Inc
    00-0A-CA   # YOKOYAMA SHOKAI CO.,Ltd.
    00-0A-CB   # XPAK MSA Group
    00-0A-CC   # Winnow Networks, Inc.
    00-0A-CD   # Sunrich Technology Limited
    00-0A-CE   # RADIANTECH, INC.
    00-0A-CF   # PROVIDEO Multimedia Co. Ltd.
    00-0A-D0   # Niigata Develoment Center,  F.I.T. Co., Ltd.
    00-0A-D1   # MWS
    00-0A-D2   # JEPICO Corporation
    00-0A-D3   # INITECH Co., Ltd
    00-0A-D4   # CoreBell Systems Inc.
    00-0A-D5   # Brainchild Electronic Co., Ltd.
    00-0A-D6   # BeamReach Networks
    00-0A-D7   # Origin ELECTRIC CO.,LTD.
    00-0A-D8   # IPCserv Technology Corp.
    00-0A-D9   # Sony Mobile Communications AB
    00-0A-DA   # Vindicator Technologies
    00-0A-DB   # SkyPilot Network, Inc
    00-0A-DC   # RuggedCom Inc.
    00-0A-DD   # Allworx Corp.
    00-0A-DE   # Happy Communication Co., Ltd.
    00-0A-DF   # Gennum Corporation
    00-0A-E0   # Fujitsu Softek
    00-0A-E1   # EG Technology
    00-0A-E2   # Binatone Electronics International, Ltd
    00-0A-E3   # YANG MEI TECHNOLOGY CO., LTD
    00-0A-E4   # Wistron Corp.
    00-0A-E5   # ScottCare Corporation
    00-0A-E6   # Elitegroup Computer System Co. (ECS)
    00-0A-E7   # ELIOP S.A.
    00-0A-E8   # Cathay Roxus Information Technology Co. LTD
    00-0A-E9   # AirVast Technology Inc.
    00-0A-EA   # ADAM ELEKTRONIK LTD. ŞTI
    00-0A-EB   # Shenzhen Tp-Link Technology Co; Ltd.
    00-0A-EC   # Koatsu Gas Kogyo Co., Ltd.
    00-0A-ED   # HARTING Systems GmbH & Co KG
    00-0A-EE   # GCD Hard- & Software GmbH
    00-0A-EF   # OTRUM ASA
    00-0A-F0   # SHIN-OH ELECTRONICS CO., LTD. R&D
    00-0A-F1   # Clarity Design, Inc.
    00-0A-F2   # NeoAxiom Corp.
    00-0A-F3   # Cisco Systems, Inc
    00-0A-F4   # Cisco Systems, Inc
    00-0A-F5   # Airgo Networks, Inc.
    00-0A-F6   # Emerson Climate Technologies Retail Solutions, Inc.
    00-0A-F7   # Broadcom
    00-0A-F8   # American Telecare Inc.
    00-0A-F9   # HiConnect, Inc.
    00-0A-FA   # Traverse Technologies Australia
    00-0A-FB   # Ambri Limited
    00-0A-FC   # Core Tec Communications, LLC
    00-0A-FD   # Kentec Electronics
    00-0A-FE   # NovaPal Ltd
    00-0A-FF   # Kilchherr Elektronik AG
    00-0B-00   # FUJIAN START COMPUTER EQUIPMENT CO.,LTD
    00-0B-01   # DAIICHI ELECTRONICS CO., LTD.
    00-0B-02   # Dallmeier electronic
    00-0B-03   # Taekwang Industrial Co., Ltd
    00-0B-04   # Volktek Corporation
    00-0B-05   # Pacific Broadband Networks
    00-0B-06   # ARRIS Group, Inc.
    00-0B-07   # Voxpath Networks
    00-0B-08   # Pillar Data Systems
    00-0B-09   # Ifoundry Systems Singapore
    00-0B-0A   # dBm Optics
    00-0B-0B   # Corrent Corporation
    00-0B-0C   # Agile Systems Inc.
    00-0B-0D   # Air2U, Inc.
    00-0B-0E   # Trapeze Networks
    00-0B-0F   # Bosch Rexroth
    00-0B-10   # 11wave Technonlogy Co.,Ltd
    00-0B-11   # HIMEJI ABC TRADING CO.,LTD.
    00-0B-12   # NURI Telecom Co., Ltd.
    00-0B-13   # ZETRON INC
    00-0B-14   # ViewSonic Corporation
    00-0B-15   # Platypus Technology
    00-0B-16   # Communication Machinery Corporation
    00-0B-17   # MKS Instruments
    00-0B-18   # Private
    00-0B-19   # Vernier Networks, Inc.
    00-0B-1A   # Industrial Defender, Inc.
    00-0B-1B   # Systronix, Inc.
    00-0B-1C   # SIBCO bv
    00-0B-1D   # LayerZero Power Systems, Inc.
    00-0B-1E   # KAPPA opto-electronics GmbH
    00-0B-1F   # I CON Computer Co.
    00-0B-20   # Hirata corporation
    00-0B-21   # G-Star Communications Inc.
    00-0B-22   # Environmental Systems and Services
    00-0B-23   # Siemens Subscriber Networks
    00-0B-24   # AirLogic
    00-0B-25   # Aeluros
    00-0B-26   # Wetek Corporation
    00-0B-27   # Scion Corporation
    00-0B-28   # Quatech Inc.
    00-0B-29   # LS(LG) Industrial Systems co.,Ltd
    00-0B-2A   # HOWTEL Co., Ltd.
    00-0B-2B   # HOSTNET CORPORATION
    00-0B-2C   # Eiki Industrial Co. Ltd.
    00-0B-2D   # Danfoss Inc.
    00-0B-2E   # Cal-Comp Electronics (Thailand) Public Company Limited Taipe
    00-0B-2F   # bplan GmbH
    00-0B-30   # Beijing Gongye Science & Technology Co.,Ltd
    00-0B-31   # Yantai ZhiYang Scientific and technology industry CO., LTD
    00-0B-32   # VORMETRIC, INC.
    00-0B-33   # Vivato Technologies
    00-0B-34   # ShangHai Broadband Technologies CO.LTD
    00-0B-35   # Quad Bit System co., Ltd.
    00-0B-36   # Productivity Systems, Inc.
    00-0B-37   # MANUFACTURE DES MONTRES ROLEX SA
    00-0B-38   # Knürr GmbH
    00-0B-39   # Keisoku Giken Co.,Ltd.
    00-0B-3A   # QuStream Corporation
    00-0B-3B   # devolo AG
    00-0B-3C   # Cygnal Integrated Products, Inc.
    00-0B-3D   # CONTAL OK Ltd.
    00-0B-3E   # BittWare, Inc
    00-0B-3F   # Anthology Solutions Inc.
    00-0B-40   # Oclaro
    00-0B-41   # Ing. Büro Dr. Beutlhauser
    00-0B-42   # commax Co., Ltd.
    00-0B-43   # Microscan Systems, Inc.
    00-0B-44   # Concord IDea Corp.
    00-0B-45   # Cisco Systems, Inc
    00-0B-46   # Cisco Systems, Inc
    00-0B-47   # Advanced Energy
    00-0B-48   # sofrel
    00-0B-49   # RF-Link System Inc.
    00-0B-4A   # Visimetrics (UK) Ltd
    00-0B-4B   # VISIOWAVE SA
    00-0B-4C   # Clarion (M) Sdn Bhd
    00-0B-4D   # Emuzed
    00-0B-4E   # VertexRSI, General Dynamics SatCOM Technologies, Inc.
    00-0B-4F   # Verifone, INC.
    00-0B-50   # Oxygnet
    00-0B-51   # Micetek International Inc.
    00-0B-52   # JOYMAX ELECTRONICS CO. LTD.
    00-0B-53   # INITIUM Co., Ltd.
    00-0B-54   # BiTMICRO Networks, Inc.
    00-0B-55   # ADInstruments
    00-0B-56   # Cybernetics
    00-0B-57   # Silicon Laboratories
    00-0B-58   # Astronautics C.A  LTD
    00-0B-59   # ScriptPro, LLC
    00-0B-5A   # HyperEdge
    00-0B-5B   # Rincon Research Corporation
    00-0B-5C   # Newtech Co.,Ltd
    00-0B-5D   # FUJITSU LIMITED
    00-0B-5E   # Audio Engineering Society Inc.
    00-0B-5F   # Cisco Systems, Inc
    00-0B-60   # Cisco Systems, Inc
    00-0B-61   # Friedrich Lütze GmbH & Co. KG
    00-0B-62   # ib-mohnen KG
    00-0B-63   # Kaleidescape
    00-0B-64   # Kieback & Peter GmbH & Co KG
    00-0B-65   # Sy.A.C. srl
    00-0B-66   # Teralink Communications
    00-0B-67   # Topview Technology Corporation
    00-0B-68   # Addvalue Communications Pte Ltd
    00-0B-69   # Franke Finland Oy
    00-0B-6A   # Asiarock Technology Limited
    00-0B-6B   # Wistron Neweb Corp.
    00-0B-6C   # Sychip Inc.
    00-0B-6D   # SOLECTRON JAPAN NAKANIIDA
    00-0B-6E   # Neff Instrument Corp.
    00-0B-6F   # Media Streaming Networks Inc
    00-0B-70   # Load Technology, Inc.
    00-0B-71   # Litchfield Communications Inc.
    00-0B-72   # Lawo AG
    00-0B-73   # Kodeos Communications
    00-0B-74   # Kingwave Technology Co., Ltd.
    00-0B-75   # Iosoft Ltd.
    00-0B-76   # ET&T Technology Co. Ltd.
    00-0B-77   # Cogent Systems, Inc.
    00-0B-78   # TAIFATECH INC.
    00-0B-79   # X-COM, Inc.
    00-0B-7A   # L-3 Linkabit
    00-0B-7B   # Test-Um Inc.
    00-0B-7C   # Telex Communications
    00-0B-7D   # SOLOMON EXTREME INTERNATIONAL LTD.
    00-0B-7E   # SAGINOMIYA Seisakusho Inc.
    00-0B-7F   # Align Engineering LLC
    00-0B-80   # Lycium Networks
    00-0B-81   # Kaparel Corporation
    00-0B-82   # Grandstream Networks, Inc.
    00-0B-83   # DATAWATT B.V.
    00-0B-84   # BODET
    00-0B-85   # Cisco Systems, Inc
    00-0B-86   # Aruba Networks
    00-0B-87   # American Reliance Inc.
    00-0B-88   # Vidisco ltd.
    00-0B-89   # Top Global Technology, Ltd.
    00-0B-8A   # MITEQ Inc.
    00-0B-8B   # KERAJET, S.A.
    00-0B-8C   # Flextronics
    00-0B-8D   # Avvio Networks
    00-0B-8E   # Ascent Corporation
    00-0B-8F   # AKITA ELECTRONICS SYSTEMS CO.,LTD.
    00-0B-90   # ADVA Optical Networking Ltd.
    00-0B-91   # Aglaia Gesellschaft für Bildverarbeitung und Kommunikation mbH
    00-0B-92   # Ascom Danmark A/S
    00-0B-93   # Ritter Elektronik
    00-0B-94   # Digital Monitoring Products, Inc.
    00-0B-95   # eBet Gaming Systems Pty Ltd
    00-0B-96   # Innotrac Diagnostics Oy
    00-0B-97   # Matsushita Electric Industrial Co.,Ltd.
    00-0B-98   # NiceTechVision
    00-0B-99   # SensAble Technologies, Inc.
    00-0B-9A   # Shanghai Ulink Telecom Equipment Co. Ltd.
    00-0B-9B   # Sirius System Co, Ltd.
    00-0B-9C   # TriBeam Technologies, Inc.
    00-0B-9D   # TwinMOS Technologies Inc.
    00-0B-9E   # Yasing Technology Corp.
    00-0B-9F   # Neue ELSA GmbH
    00-0B-A0   # T&L Information Inc.
    00-0B-A1   # SYSCOM Ltd.
    00-0B-A2   # Sumitomo Electric Industries,Ltd
    00-0B-A3   # Siemens AG, I&S
    00-0B-A4   # Shiron Satellite Communications Ltd. (1996)
    00-0B-A5   # Quasar Cipta Mandiri, PT
    00-0B-A6   # Miyakawa Electric Works Ltd.
    00-0B-A7   # Maranti Networks
    00-0B-A8   # HANBACK ELECTRONICS CO., LTD.
    00-0B-A9   # CloudShield Technologies, Inc.
    00-0B-AA   # Aiphone co.,Ltd
    00-0B-AB   # Advantech Technology (CHINA) Co., Ltd.
    00-0B-AC   # 3Com Ltd
    00-0B-AD   # PC-PoS Inc.
    00-0B-AE   # Vitals System Inc.
    00-0B-AF   # WOOJU COMMUNICATIONS Co,.Ltd
    00-0B-B0   # Sysnet Telematica srl
    00-0B-B1   # Super Star Technology Co., Ltd.
    00-0B-B2   # SMALLBIG TECHNOLOGY
    00-0B-B3   # RiT technologies Ltd.
    00-0B-B4   # RDC Semiconductor Inc.,
    00-0B-B5   # nStor Technologies, Inc.
    00-0B-B6   # Metalligence Technology Corp.
    00-0B-B7   # Micro Systems Co.,Ltd.
    00-0B-B8   # Kihoku Electronic Co.
    00-0B-B9   # Imsys AB
    00-0B-BA   # Harmonic, Inc
    00-0B-BB   # Etin Systems Co., Ltd
    00-0B-BC   # En Garde Systems, Inc.
    00-0B-BD   # Connexionz Limited
    00-0B-BE   # Cisco Systems, Inc
    00-0B-BF   # Cisco Systems, Inc
    00-0B-C0   # China IWNComm Co., Ltd.
    00-0B-C1   # Bay Microsystems, Inc.
    00-0B-C2   # Corinex Communication Corp.
    00-0B-C3   # Multiplex, Inc.
    00-0B-C4   # BIOTRONIK GmbH & Co
    00-0B-C5   # SMC Networks, Inc.
    00-0B-C6   # ISAC, Inc.
    00-0B-C7   # ICET S.p.A.
    00-0B-C8   # AirFlow Networks
    00-0B-C9   # Electroline Equipment
    00-0B-CA   # DATAVAN TC
    00-0B-CB   # Fagor Automation , S. Coop
    00-0B-CC   # JUSAN, S.A.
    00-0B-CD   # Hewlett Packard
    00-0B-CE   # Free2move AB
    00-0B-CF   # AGFA NDT INC.
    00-0B-D0   # XiMeta Technology Americas Inc.
    00-0B-D1   # Aeronix, Inc.
    00-0B-D2   # Remopro Technology Inc.
    00-0B-D3   # cd3o
    00-0B-D4   # Beijing Wise Technology & Science Development Co.Ltd
    00-0B-D5   # Nvergence, Inc.
    00-0B-D6   # Paxton Access Ltd
    00-0B-D7   # DORMA Time + Access GmbH
    00-0B-D8   # Industrial Scientific Corp.
    00-0B-D9   # General Hydrogen
    00-0B-DA   # EyeCross Co.,Inc.
    00-0B-DB   # Dell Inc.
    00-0B-DC   # AKCP
    00-0B-DD   # TOHOKU RICOH Co., LTD.
    00-0B-DE   # TELDIX GmbH
    00-0B-DF   # Shenzhen RouterD Networks Limited
    00-0B-E0   # SercoNet Ltd.
    00-0B-E1   # Nokia NET Product Operations
    00-0B-E2   # Lumenera Corporation
    00-0B-E3   # Key Stream Co., Ltd.
    00-0B-E4   # Hosiden Corporation
    00-0B-E5   # HIMS International Corporation
    00-0B-E6   # Datel Electronics
    00-0B-E7   # COMFLUX TECHNOLOGY INC.
    00-0B-E8   # AOIP
    00-0B-E9   # Actel Corporation
    00-0B-EA   # Zultys Technologies
    00-0B-EB   # Systegra AG
    00-0B-EC   # NIPPON ELECTRIC INSTRUMENT, INC.
    00-0B-ED   # ELM Inc.
    00-0B-EE   # inc.jet, Incorporated
    00-0B-EF   # Code Corporation
    00-0B-F0   # MoTEX Products Co., Ltd.
    00-0B-F1   # LAP Laser Applikations
    00-0B-F2   # Chih-Kan Technology Co., Ltd.
    00-0B-F3   # BAE SYSTEMS
    00-0B-F4   # Private
    00-0B-F5   # Shanghai Sibo Telecom Technology Co.,Ltd
    00-0B-F6   # Nitgen Co., Ltd
    00-0B-F7   # NIDEK CO.,LTD
    00-0B-F8   # Infinera
    00-0B-F9   # Gemstone Communications, Inc.
    00-0B-FA   # EXEMYS SRL
    00-0B-FB   # D-NET International Corporation
    00-0B-FC   # Cisco Systems, Inc
    00-0B-FD   # Cisco Systems, Inc
    00-0B-FE   # CASTEL Broadband Limited
    00-0B-FF   # Berkeley Camera Engineering
    00-0C-00   # BEB Industrie-Elektronik AG
    00-0C-01   # Abatron AG
    00-0C-02   # ABB Oy
    00-0C-03   # HDMI Licensing, LLC
    00-0C-04   # Tecnova
    00-0C-05   # RPA Reserch Co., Ltd.
    00-0C-06   # Nixvue Systems  Pte Ltd
    00-0C-07   # Iftest AG
    00-0C-08   # HUMEX Technologies Corp.
    00-0C-09   # Hitachi IE Systems Co., Ltd
    00-0C-0A   # Guangdong Province Electronic Technology Research Institute
    00-0C-0B   # Broadbus Technologies
    00-0C-0C   # APPRO TECHNOLOGY INC.
    00-0C-0D   # Communications & Power Industries / Satcom Division
    00-0C-0E   # XtremeSpectrum, Inc.
    00-0C-0F   # Techno-One Co., Ltd
    00-0C-10   # PNI Corporation
    00-0C-11   # NIPPON DEMPA CO.,LTD.
    00-0C-12   # Micro-Optronic-Messtechnik GmbH
    00-0C-13   # MediaQ
    00-0C-14   # Diagnostic Instruments, Inc.
    00-0C-15   # CyberPower Systems, Inc.
    00-0C-16   # Concorde Microsystems Inc.
    00-0C-17   # AJA Video Systems Inc
    00-0C-18   # Zenisu Keisoku Inc.
    00-0C-19   # Telio Communications GmbH
    00-0C-1A   # Quest Technical Solutions Inc.
    00-0C-1B   # ORACOM Co, Ltd.
    00-0C-1C   # MicroWeb Co., Ltd.
    00-0C-1D   # Mettler & Fuchs AG
    00-0C-1E   # Global Cache
    00-0C-1F   # Glimmerglass Networks
    00-0C-20   # Fi WIn, Inc.
    00-0C-21   # Faculty of Science and Technology, Keio University
    00-0C-22   # Double D Electronics Ltd
    00-0C-23   # Beijing Lanchuan Tech. Co., Ltd.
    00-0C-24   # ANATOR
    00-0C-25   # Allied Telesis Labs, Inc.
    00-0C-26   # Weintek Labs. Inc.
    00-0C-27   # Sammy Corporation
    00-0C-28   # RIFATRON
    00-0C-29   # VMware, Inc.
    00-0C-2A   # OCTTEL Communication Co., Ltd.
    00-0C-2B   # ELIAS Technology, Inc.
    00-0C-2C   # Enwiser Inc.
    00-0C-2D   # FullWave Technology Co., Ltd.
    00-0C-2E   # Openet information technology(shenzhen) Co., Ltd.
    00-0C-2F   # SeorimTechnology Co.,Ltd.
    00-0C-30   # Cisco Systems, Inc
    00-0C-31   # Cisco Systems, Inc
    00-0C-32   # Avionic Design Development GmbH
    00-0C-33   # Compucase Enterprise Co. Ltd.
    00-0C-34   # Vixen Co., Ltd.
    00-0C-35   # KaVo Dental GmbH & Co. KG
    00-0C-36   # SHARP TAKAYA ELECTRONICS INDUSTRY CO.,LTD.
    00-0C-37   # Geomation, Inc.
    00-0C-38   # TelcoBridges Inc.
    00-0C-39   # Sentinel Wireless Inc.
    00-0C-3A   # Oxance
    00-0C-3B   # Orion Electric Co., Ltd.
    00-0C-3C   # MediaChorus, Inc.
    00-0C-3D   # Glsystech Co., Ltd.
    00-0C-3E   # Crest Audio
    00-0C-3F   # Cogent Defence & Security Networks,
    00-0C-40   # Altech Controls
    00-0C-41   # Cisco-Linksys, LLC
    00-0C-42   # Routerboard.com
    00-0C-43   # Ralink Technology, Corp.
    00-0C-44   # Automated Interfaces, Inc.
    00-0C-45   # Animation Technologies Inc.
    00-0C-46   # Allied Telesyn Inc.
    00-0C-47   # SK Teletech(R&D Planning Team)
    00-0C-48   # QoStek Corporation
    00-0C-49   # Dangaard Telecom RTC Division A/S
    00-0C-4A   # Cygnus Microsystems (P) Limited
    00-0C-4B   # Cheops Elektronik
    00-0C-4C   # Arcor AG&Co.
    00-0C-4D   # Curtiss-Wright Controls Avionics & Electronics
    00-0C-4E   # Winbest Technology CO,LT
    00-0C-4F   # UDTech Japan Corporation
    00-0C-50   # Seagate Technology
    00-0C-51   # Scientific Technologies Inc.
    00-0C-52   # Roll Systems Inc.
    00-0C-53   # Private
    00-0C-54   # Pedestal Networks, Inc
    00-0C-55   # Microlink Communications Inc.
    00-0C-56   # Megatel Computer (1986) Corp.
    00-0C-57   # MACKIE Engineering Services Belgium BVBA
    00-0C-58   # M&S Systems
    00-0C-59   # Indyme Electronics, Inc.
    00-0C-5A   # IBSmm Embedded Electronics Consulting
    00-0C-5B   # HANWANG TECHNOLOGY CO.,LTD
    00-0C-5C   # GTN Systems B.V.
    00-0C-5D   # CHIC TECHNOLOGY (CHINA) CORP.
    00-0C-5E   # Calypso Medical
    00-0C-5F   # Avtec, Inc.
    00-0C-60   # ACM Systems
    00-0C-61   # AC Tech corporation DBA Advanced Digital
    00-0C-62   # ABB AB, Cewe-Control
    00-0C-63   # Zenith Electronics Corporation
    00-0C-64   # X2 MSA Group
    00-0C-65   # Sunin Telecom
    00-0C-66   # Pronto Networks Inc
    00-0C-67   # OYO ELECTRIC CO.,LTD
    00-0C-68   # SigmaTel, Inc.
    00-0C-69   # National Radio Astronomy Observatory
    00-0C-6A   # MBARI
    00-0C-6B   # Kurz Industrie-Elektronik GmbH
    00-0C-6C   # Elgato Systems LLC
    00-0C-6D   # Edwards Ltd.
    00-0C-6E   # ASUSTek COMPUTER INC.
    00-0C-6F   # Amtek system co.,LTD.
    00-0C-70   # ACC GmbH
    00-0C-71   # Wybron, Inc
    00-0C-72   # Tempearl Industrial Co., Ltd.
    00-0C-73   # TELSON ELECTRONICS CO., LTD
    00-0C-74   # RIVERTEC CORPORATION
    00-0C-75   # Oriental integrated electronics. LTD
    00-0C-76   # MICRO-STAR INTERNATIONAL CO., LTD.
    00-0C-77   # Life Racing Ltd
    00-0C-78   # In-Tech Electronics Limited
    00-0C-79   # Extel Communications P/L
    00-0C-7A   # DaTARIUS Technologies GmbH
    00-0C-7B   # ALPHA PROJECT Co.,Ltd.
    00-0C-7C   # Internet Information Image Inc.
    00-0C-7D   # TEIKOKU ELECTRIC MFG. CO., LTD
    00-0C-7E   # Tellium Incorporated
    00-0C-7F   # synertronixx GmbH
    00-0C-80   # Opelcomm Inc.
    00-0C-81   # Schneider Electric (Australia)
    00-0C-82   # NETWORK TECHNOLOGIES INC
    00-0C-83   # Logical Solutions
    00-0C-84   # Eazix, Inc.
    00-0C-85   # Cisco Systems, Inc
    00-0C-86   # Cisco Systems, Inc
    00-0C-87   # AMD
    00-0C-88   # Apache Micro Peripherals, Inc.
    00-0C-89   # AC Electric Vehicles, Ltd.
    00-0C-8A   # Bose Corporation
    00-0C-8B   # Connect Tech Inc
    00-0C-8C   # KODICOM CO.,LTD.
    00-0C-8D   # MATRIX VISION GmbH
    00-0C-8E   # Mentor Engineering Inc
    00-0C-8F   # Nergal s.r.l.
    00-0C-90   # Octasic Inc.
    00-0C-91   # Riverhead Networks Inc.
    00-0C-92   # WolfVision Gmbh
    00-0C-93   # Xeline Co., Ltd.
    00-0C-94   # United Electronic Industries, Inc. (EUI)
    00-0C-95   # PrimeNet
    00-0C-96   # OQO, Inc.
    00-0C-97   # NV ADB TTV Technologies SA
    00-0C-98   # LETEK Communications Inc.
    00-0C-99   # HITEL LINK Co.,Ltd
    00-0C-9A   # Hitech Electronics Corp.
    00-0C-9B   # EE Solutions, Inc
    00-0C-9C   # Chongho information & communications
    00-0C-9D   # UbeeAirWalk, Inc.
    00-0C-9E   # MemoryLink Corp.
    00-0C-9F   # NKE Corporation
    00-0C-A0   # StorCase Technology, Inc.
    00-0C-A1   # SIGMACOM Co., LTD.
    00-0C-A2   # Harmonic Video Network
    00-0C-A3   # Rancho Technology, Inc.
    00-0C-A4   # Prompttec Product Management GmbH
    00-0C-A5   # Naman NZ LTd
    00-0C-A6   # Mintera Corporation
    00-0C-A7   # Metro (Suzhou) Technologies Co., Ltd.
    00-0C-A8   # Garuda Networks Corporation
    00-0C-A9   # Ebtron Inc.
    00-0C-AA   # Cubic Transportation Systems Inc
    00-0C-AB   # COMMEND International
    00-0C-AC   # Citizen Watch Co., Ltd.
    00-0C-AD   # BTU International
    00-0C-AE   # Ailocom Oy
    00-0C-AF   # TRI TERM CO.,LTD.
    00-0C-B0   # Star Semiconductor Corporation
    00-0C-B1   # Salland Engineering (Europe) BV
    00-0C-B2   # UNION co., ltd.
    00-0C-B3   # ROUND Co.,Ltd.
    00-0C-B4   # AutoCell Laboratories, Inc.
    00-0C-B5   # Premier Technolgies, Inc
    00-0C-B6   # NANJING SEU MOBILE & INTERNET TECHNOLOGY CO.,LTD
    00-0C-B7   # Nanjing Huazhuo Electronics Co., Ltd.
    00-0C-B8   # MEDION AG
    00-0C-B9   # LEA
    00-0C-BA   # Jamex, Inc.
    00-0C-BB   # ISKRAEMECO
    00-0C-BC   # Iscutum
    00-0C-BD   # Interface Masters, Inc
    00-0C-BE   # Innominate Security Technologies AG
    00-0C-BF   # Holy Stone Ent. Co., Ltd.
    00-0C-C0   # Genera Oy
    00-0C-C1   # Cooper Industries Inc.
    00-0C-C2   # ControlNet (India) Private Limited
    00-0C-C3   # BeWAN systems
    00-0C-C4   # Tiptel AG
    00-0C-C5   # Nextlink Co., Ltd.
    00-0C-C6   # Ka-Ro electronics GmbH
    00-0C-C7   # Intelligent Computer Solutions Inc.
    00-0C-C8   # Xytronix Research & Design, Inc.
    00-0C-C9   # ILWOO DATA & TECHNOLOGY CO.,LTD
    00-0C-CA   # HGST a Western Digital Company
    00-0C-CB   # Design Combus Ltd
    00-0C-CC   # Aeroscout Ltd.
    00-0C-CD   # IEC - TC57
    00-0C-CE   # Cisco Systems, Inc
    00-0C-CF   # Cisco Systems, Inc
    00-0C-D0   # Symetrix
    00-0C-D1   # SFOM Technology Corp.
    00-0C-D2   # Schaffner EMV AG
    00-0C-D3   # Prettl Elektronik Radeberg GmbH
    00-0C-D4   # Positron Public Safety Systems inc.
    00-0C-D5   # Passave Inc.
    00-0C-D6   # PARTNER TECH
    00-0C-D7   # Nallatech Ltd
    00-0C-D8   # M. K. Juchheim GmbH & Co
    00-0C-D9   # Itcare Co., Ltd
    00-0C-DA   # FreeHand Systems, Inc.
    00-0C-DB   # Brocade Communications Systems, Inc.
    00-0C-DC   # BECS Technology, Inc
    00-0C-DD   # AOS technologies AG
    00-0C-DE   # ABB STOTZ-KONTAKT GmbH
    00-0C-DF   # PULNiX America, Inc
    00-0C-E0   # Trek Diagnostics Inc.
    00-0C-E1   # The Open Group
    00-0C-E2   # Rolls-Royce
    00-0C-E3   # Option International N.V.
    00-0C-E4   # NeuroCom International, Inc.
    00-0C-E5   # ARRIS Group, Inc.
    00-0C-E6   # Meru Networks Inc
    00-0C-E7   # MediaTek Inc.
    00-0C-E8   # GuangZhou AnJuBao Co., Ltd
    00-0C-E9   # BLOOMBERG L.P.
    00-0C-EA   # aphona Kommunikationssysteme
    00-0C-EB   # CNMP Networks, Inc.
    00-0C-EC   # Spectracom Corp.
    00-0C-ED   # Real Digital Media
    00-0C-EE   # jp-embedded
    00-0C-EF   # Open Networks Engineering Ltd
    00-0C-F0   # M & N GmbH
    00-0C-F1   # Intel Corporation
    00-0C-F2   # GAMESA Eólica
    00-0C-F3   # CALL IMAGE SA
    00-0C-F4   # AKATSUKI ELECTRIC MFG.CO.,LTD.
    00-0C-F5   # InfoExpress
    00-0C-F6   # Sitecom Europe BV
    00-0C-F7   # Nortel Networks
    00-0C-F8   # Nortel Networks
    00-0C-F9   # Xylem Water Solutions
    00-0C-FA   # Digital Systems Corp
    00-0C-FB   # Korea Network Systems
    00-0C-FC   # S2io Technologies Corp
    00-0C-FD   # Hyundai ImageQuest Co.,Ltd.
    00-0C-FE   # Grand Electronic Co., Ltd
    00-0C-FF   # MRO-TEK LIMITED
    00-0D-00   # Seaway Networks Inc.
    00-0D-01   # P&E Microcomputer Systems, Inc.
    00-0D-02   # NEC Platforms, Ltd.
    00-0D-03   # Matrics, Inc.
    00-0D-04   # Foxboro Eckardt Development GmbH
    00-0D-05   # cybernet manufacturing inc.
    00-0D-06   # Compulogic Limited
    00-0D-07   # Calrec Audio Ltd
    00-0D-08   # AboveCable, Inc.
    00-0D-09   # Yuehua(Zhuhai) Electronic CO. LTD
    00-0D-0A   # Projectiondesign as
    00-0D-0B   # BUFFALO.INC
    00-0D-0C   # MDI Security Systems
    00-0D-0D   # ITSupported, LLC
    00-0D-0E   # Inqnet Systems, Inc.
    00-0D-0F   # Finlux Ltd
    00-0D-10   # Embedtronics Oy
    00-0D-11   # DENTSPLY - Gendex
    00-0D-12   # AXELL Corporation
    00-0D-13   # Wilhelm Rutenbeck GmbH&Co.KG
    00-0D-14   # Vtech Innovation LP dba Advanced American Telephones
    00-0D-15   # Voipac s.r.o.
    00-0D-16   # UHS Systems Pty Ltd
    00-0D-17   # Turbo Networks Co.Ltd
    00-0D-18   # Mega-Trend Electronics CO., LTD.
    00-0D-19   # ROBE Show lighting
    00-0D-1A   # Mustek System Inc.
    00-0D-1B   # Kyoto Electronics Manufacturing Co., Ltd.
    00-0D-1C   # Amesys Defense
    00-0D-1D   # HIGH-TEK HARNESS ENT. CO., LTD.
    00-0D-1E   # Control Techniques
    00-0D-1F   # AV Digital
    00-0D-20   # ASAHIKASEI TECHNOSYSTEM CO.,LTD.
    00-0D-21   # WISCORE Inc.
    00-0D-22   # Unitronics LTD
    00-0D-23   # Smart Solution, Inc
    00-0D-24   # SENTEC E&E CO., LTD.
    00-0D-25   # SANDEN CORPORATION
    00-0D-26   # Primagraphics Limited
    00-0D-27   # MICROPLEX Printware AG
    00-0D-28   # Cisco Systems, Inc
    00-0D-29   # Cisco Systems, Inc
    00-0D-2A   # Scanmatic AS
    00-0D-2B   # Racal Instruments
    00-0D-2C   # Patapsco Designs Ltd
    00-0D-2D   # NCT Deutschland GmbH
    00-0D-2E   # Matsushita Avionics Systems Corporation
    00-0D-2F   # AIN Comm.Tech.Co., LTD
    00-0D-30   # IceFyre Semiconductor
    00-0D-31   # Compellent Technologies, Inc.
    00-0D-32   # DispenseSource, Inc.
    00-0D-33   # Prediwave Corp.
    00-0D-34   # Shell International Exploration and Production, Inc.
    00-0D-35   # PAC International Ltd
    00-0D-36   # Wu Han Routon Electronic Co., Ltd
    00-0D-37   # WIPLUG
    00-0D-38   # NISSIN INC.
    00-0D-39   # Network Electronics
    00-0D-3A   # Microsoft Corp.
    00-0D-3B   # Microelectronics Technology Inc.
    00-0D-3C   # i.Tech Dynamic Ltd
    00-0D-3D   # Hammerhead Systems, Inc.
    00-0D-3E   # APLUX Communications Ltd.
    00-0D-3F   # VTI Instruments Corporation
    00-0D-40   # Verint Loronix Video Solutions
    00-0D-41   # Siemens AG ICM MP UC RD IT KLF1
    00-0D-42   # Newbest Development Limited
    00-0D-43   # DRS Tactical Systems Inc.
    00-0D-44   # Audio BU - Logitech
    00-0D-45   # Tottori SANYO Electric Co., Ltd.
    00-0D-46   # Parker SSD Drives
    00-0D-47   # Collex
    00-0D-48   # AEWIN Technologies Co., Ltd.
    00-0D-49   # Triton Systems of Delaware, Inc.
    00-0D-4A   # Steag ETA-Optik
    00-0D-4B   # Roku, Inc.
    00-0D-4C   # Outline Electronics Ltd.
    00-0D-4D   # Ninelanes
    00-0D-4E   # NDR Co.,LTD.
    00-0D-4F   # Kenwood Corporation
    00-0D-50   # Galazar Networks
    00-0D-51   # DIVR Systems, Inc.
    00-0D-52   # Comart system
    00-0D-53   # Beijing 5w Communication Corp.
    00-0D-54   # 3Com Ltd
    00-0D-55   # SANYCOM Technology Co.,Ltd
    00-0D-56   # Dell Inc.
    00-0D-57   # Fujitsu I-Network Systems Limited.
    00-0D-58   # Private
    00-0D-59   # Amity Systems, Inc.
    00-0D-5A   # Tiesse SpA
    00-0D-5B   # Smart Empire Investments Limited
    00-0D-5C   # Robert Bosch GmbH, VT-ATMO
    00-0D-5D   # Raritan Computer, Inc
    00-0D-5E   # NEC Personal Products
    00-0D-5F   # Minds Inc
    00-0D-60   # IBM Corp
    00-0D-61   # Giga-Byte Technology Co., Ltd.
    00-0D-62   # Funkwerk Dabendorf GmbH
    00-0D-63   # DENT Instruments, Inc.
    00-0D-64   # COMAG Handels AG
    00-0D-65   # Cisco Systems, Inc
    00-0D-66   # Cisco Systems, Inc
    00-0D-67   # Ericsson
    00-0D-68   # Vinci Systems, Inc.
    00-0D-69   # TMT&D Corporation
    00-0D-6A   # Redwood Technologies LTD
    00-0D-6B   # Mita-Teknik A/S
    00-0D-6C   # M-Audio
    00-0D-6D   # K-Tech Devices Corp.
    00-0D-6E   # K-Patents Oy
    00-0D-6F   # Ember Corporation
    00-0D-70   # Datamax Corporation
    00-0D-71   # boca systems
    00-0D-72   # 2Wire Inc
    00-0D-73   # Technical Support, Inc.
    00-0D-74   # Sand Network Systems, Inc.
    00-0D-75   # Kobian Pte Ltd - Taiwan Branch
    00-0D-76   # Hokuto Denshi Co,. Ltd.
    00-0D-77   # FalconStor Software
    00-0D-78   # Engineering & Security
    00-0D-79   # Dynamic Solutions Co,.Ltd.
    00-0D-7A   # DiGATTO Asia Pacific Pte Ltd
    00-0D-7B   # Consensys Computers Inc.
    00-0D-7C   # Codian Ltd
    00-0D-7D   # Afco Systems
    00-0D-7E   # Axiowave Networks, Inc.
    00-0D-7F   # MIDAS  COMMUNICATION TECHNOLOGIES PTE LTD ( Foreign Branch)
    00-0D-80   # Online Development Inc
    00-0D-81   # Pepperl+Fuchs GmbH
    00-0D-82   # PHS srl
    00-0D-83   # Sanmina-SCI Hungary  Ltd.
    00-0D-84   # Makus Inc.
    00-0D-85   # Tapwave, Inc.
    00-0D-86   # Huber + Suhner AG
    00-0D-87   # Elitegroup Computer System Co. (ECS)
    00-0D-88   # D-Link Corporation
    00-0D-89   # Bils Technology Inc
    00-0D-8A   # Winners Electronics Co., Ltd.
    00-0D-8B   # T&D Corporation
    00-0D-8C   # Shanghai Wedone Digital Ltd. CO.
    00-0D-8D   # Prosoft Technology, Inc
    00-0D-8E   # Koden Electronics Co., Ltd.
    00-0D-8F   # King Tsushin Kogyo Co., LTD.
    00-0D-90   # Factum Electronics AB
    00-0D-91   # Eclipse (HQ Espana) S.L.
    00-0D-92   # ARIMA Communications Corp.
    00-0D-93   # Apple, Inc.
    00-0D-94   # AFAR Communications,Inc
    00-0D-95   # Opti-cell, Inc.
    00-0D-96   # Vtera Technology Inc.
    00-0D-97   # ABB Inc./Tropos
    00-0D-98   # S.W.A.C. Schmitt-Walter Automation Consult GmbH
    00-0D-99   # Orbital Sciences Corp.; Launch Systems Group
    00-0D-9A   # INFOTEC LTD
    00-0D-9B   # Heraeus Electro-Nite International N.V.
    00-0D-9C   # Elan GmbH & Co KG
    00-0D-9D   # Hewlett Packard
    00-0D-9E   # TOKUDEN OHIZUMI SEISAKUSYO Co.,Ltd.
    00-0D-9F   # RF Micro Devices
    00-0D-A0   # NEDAP N.V.
    00-0D-A1   # MIRAE ITS Co.,LTD.
    00-0D-A2   # Infrant Technologies, Inc.
    00-0D-A3   # Emerging Technologies Limited
    00-0D-A4   # DOSCH & AMAND SYSTEMS AG
    00-0D-A5   # Fabric7 Systems, Inc
    00-0D-A6   # Universal Switching Corporation
    00-0D-A7   # Private
    00-0D-A8   # Teletronics Technology Corporation
    00-0D-A9   # T.E.A.M. S.L.
    00-0D-AA   # S.A.Tehnology co.,Ltd.
    00-0D-AB   # Parker Hannifin GmbH Electromechanical Division Europe
    00-0D-AC   # Japan CBM Corporation
    00-0D-AD   # Dataprobe, Inc.
    00-0D-AE   # SAMSUNG HEAVY INDUSTRIES CO., LTD.
    00-0D-AF   # Plexus Corp (UK) Ltd
    00-0D-B0   # Olym-tech Co.,Ltd.
    00-0D-B1   # Japan Network Service Co., Ltd.
    00-0D-B2   # Ammasso, Inc.
    00-0D-B3   # SDO Communication Corperation
    00-0D-B4   # NETASQ
    00-0D-B5   # GLOBALSAT TECHNOLOGY CORPORATION
    00-0D-B6   # Broadcom
    00-0D-B7   # SANKO ELECTRIC CO,.LTD
    00-0D-B8   # SCHILLER AG
    00-0D-B9   # PC Engines GmbH
    00-0D-BA   # Océ Document Technologies GmbH
    00-0D-BB   # Nippon Dentsu Co.,Ltd.
    00-0D-BC   # Cisco Systems, Inc
    00-0D-BD   # Cisco Systems, Inc
    00-0D-BE   # Bel Fuse Europe Ltd.,UK
    00-0D-BF   # TekTone Sound & Signal Mfg., Inc.
    00-0D-C0   # Spagat AS
    00-0D-C1   # SafeWeb Inc
    00-0D-C2   # Private
    00-0D-C3   # First Communication, Inc.
    00-0D-C4   # Emcore Corporation
    00-0D-C5   # EchoStar Global B.V.
    00-0D-C6   # DigiRose Technology Co., Ltd.
    00-0D-C7   # COSMIC ENGINEERING INC.
    00-0D-C8   # AirMagnet, Inc
    00-0D-C9   # THALES Elektronik Systeme GmbH
    00-0D-CA   # Tait Electronics
    00-0D-CB   # Petcomkorea Co., Ltd.
    00-0D-CC   # NEOSMART Corp.
    00-0D-CD   # GROUPE TXCOM
    00-0D-CE   # Dynavac Technology Pte Ltd
    00-0D-CF   # Cidra Corp.
    00-0D-D0   # TetraTec Instruments GmbH
    00-0D-D1   # Stryker Corporation
    00-0D-D2   # Simrad Optronics ASA
    00-0D-D3   # SAMWOO Telecommunication Co.,Ltd.
    00-0D-D4   # Symantec Corporation
    00-0D-D5   # O'RITE TECHNOLOGY CO.,LTD
    00-0D-D6   # ITI    LTD
    00-0D-D7   # Bright
    00-0D-D8   # BBN
    00-0D-D9   # Anton Paar GmbH
    00-0D-DA   # ALLIED TELESIS K.K.
    00-0D-DB   # AIRWAVE TECHNOLOGIES INC.
    00-0D-DC   # VAC
    00-0D-DD   # Profilo Telra Elektronik Sanayi ve Ticaret. A.Ş
    00-0D-DE   # Joyteck Co., Ltd.
    00-0D-DF   # Japan Image & Network Inc.
    00-0D-E0   # ICPDAS Co.,LTD
    00-0D-E1   # Control Products, Inc.
    00-0D-E2   # CMZ Sistemi Elettronici
    00-0D-E3   # AT Sweden AB
    00-0D-E4   # DIGINICS, Inc.
    00-0D-E5   # Samsung Thales
    00-0D-E6   # YOUNGBO ENGINEERING CO.,LTD
    00-0D-E7   # Snap-on OEM Group
    00-0D-E8   # Nasaco Electronics Pte. Ltd
    00-0D-E9   # Napatech Aps
    00-0D-EA   # Kingtel Telecommunication Corp.
    00-0D-EB   # CompXs Limited
    00-0D-EC   # Cisco Systems, Inc
    00-0D-ED   # Cisco Systems, Inc
    00-0D-EE   # Andrew RF Power Amplifier Group
    00-0D-EF   # Soc. Coop. Bilanciai
    00-0D-F0   # QCOM TECHNOLOGY INC.
    00-0D-F1   # IONIX INC.
    00-0D-F2   # Private
    00-0D-F3   # Asmax Solutions
    00-0D-F4   # Watertek Co.
    00-0D-F5   # Teletronics International Inc.
    00-0D-F6   # Technology Thesaurus Corp.
    00-0D-F7   # Space Dynamics Lab
    00-0D-F8   # ORGA Kartensysteme GmbH
    00-0D-F9   # NDS Limited
    00-0D-FA   # Micro Control Systems Ltd.
    00-0D-FB   # Komax AG
    00-0D-FC   # ITFOR Inc.
    00-0D-FD   # Huges Hi-Tech Inc.,
    00-0D-FE   # Hauppauge Computer Works, Inc.
    00-0D-FF   # CHENMING MOLD INDUSTRY CORP.
    00-0E-00   # Atrie
    00-0E-01   # ASIP Technologies Inc.
    00-0E-02   # Advantech AMT Inc.
    00-0E-03   # Emulex Corporation
    00-0E-04   # CMA/Microdialysis AB
    00-0E-05   # WIRELESS MATRIX CORP.
    00-0E-06   # Team Simoco Ltd
    00-0E-07   # Sony Mobile Communications AB
    00-0E-08   # Cisco-Linksys, LLC
    00-0E-09   # Shenzhen Coship Software Co.,LTD.
    00-0E-0A   # SAKUMA DESIGN OFFICE
    00-0E-0B   # Netac Technology Co., Ltd.
    00-0E-0C   # Intel Corporation
    00-0E-0D   # Hesch Schröder GmbH
    00-0E-0E   # ESA elettronica S.P.A.
    00-0E-0F   # ERMME
    00-0E-10   # C-guys, Inc.
    00-0E-11   # BDT Büro und Datentechnik GmbH & Co.KG
    00-0E-12   # Adaptive Micro Systems Inc.
    00-0E-13   # Accu-Sort Systems inc.
    00-0E-14   # Visionary Solutions, Inc.
    00-0E-15   # Tadlys LTD
    00-0E-16   # SouthWing S.L.
    00-0E-17   # Private
    00-0E-18   # MyA Technology
    00-0E-19   # LogicaCMG Pty Ltd
    00-0E-1A   # JPS Communications
    00-0E-1B   # IAV GmbH
    00-0E-1C   # Hach Company
    00-0E-1D   # ARION Technology Inc.
    00-0E-1E   # QLogic Corporation
    00-0E-1F   # TCL Networks Equipment Co., Ltd.
    00-0E-20   # ACCESS Systems Americas, Inc.
    00-0E-21   # MTU Friedrichshafen GmbH
    00-0E-22   # Private
    00-0E-23   # Incipient, Inc.
    00-0E-24   # Huwell Technology Inc.
    00-0E-25   # Hannae Technology Co., Ltd
    00-0E-26   # Gincom Technology Corp.
    00-0E-27   # Crere Networks, Inc.
    00-0E-28   # Dynamic Ratings P/L
    00-0E-29   # Shester Communications Inc
    00-0E-2A   # Private
    00-0E-2B   # Safari Technologies
    00-0E-2C   # Netcodec co.
    00-0E-2D   # Hyundai Digital Technology Co.,Ltd.
    00-0E-2E   # EDIMAX TECHNOLOGY CO., LTD.
    00-0E-2F   # Roche Diagnostics GmbH
    00-0E-30   # AERAS Networks, Inc.
    00-0E-31   # Olympus Soft Imaging Solutions GmbH
    00-0E-32   # Kontron Medical
    00-0E-33   # Shuko Electronics Co.,Ltd
    00-0E-34   # NexGen City, LP
    00-0E-35   # Intel Corporation
    00-0E-36   # HEINESYS, Inc.
    00-0E-37   # Harms & Wende GmbH & Co.KG
    00-0E-38   # Cisco Systems, Inc
    00-0E-39   # Cisco Systems, Inc
    00-0E-3A   # Cirrus Logic
    00-0E-3B   # Hawking Technologies, Inc.
    00-0E-3C   # Transact Technologies Inc
    00-0E-3D   # Televic N.V.
    00-0E-3E   # Sun Optronics Inc
    00-0E-3F   # Soronti, Inc.
    00-0E-40   # Nortel Networks
    00-0E-41   # NIHON MECHATRONICS CO.,LTD.
    00-0E-42   # Motic Incoporation Ltd.
    00-0E-43   # G-Tek Electronics Sdn. Bhd.
    00-0E-44   # Digital 5, Inc.
    00-0E-45   # Beijing Newtry Electronic Technology Ltd
    00-0E-46   # Niigata Seimitsu Co.,Ltd.
    00-0E-47   # NCI System Co.,Ltd.
    00-0E-48   # Lipman TransAction Solutions
    00-0E-49   # Forsway Scandinavia AB
    00-0E-4A   # Changchun Huayu WEBPAD Co.,LTD
    00-0E-4B   # atrium c and i
    00-0E-4C   # Bermai Inc.
    00-0E-4D   # Numesa Inc.
    00-0E-4E   # Waveplus Technology Co., Ltd.
    00-0E-4F   # Trajet GmbH
    00-0E-50   # Thomson Telecom Belgium
    00-0E-51   # tecna elettronica srl
    00-0E-52   # Optium Corporation
    00-0E-53   # AV TECH CORPORATION
    00-0E-54   # AlphaCell Wireless Ltd.
    00-0E-55   # AUVITRAN
    00-0E-56   # 4G Systems GmbH & Co. KG
    00-0E-57   # Iworld Networking, Inc.
    00-0E-58   # Sonos, Inc.
    00-0E-59   # Sagemcom Broadband SAS
    00-0E-5A   # TELEFIELD inc.
    00-0E-5B   # ParkerVision - Direct2Data
    00-0E-5C   # ARRIS Group, Inc.
    00-0E-5D   # Triple Play Technologies A/S
    00-0E-5E   # Raisecom Technology
    00-0E-5F   # activ-net GmbH & Co. KG
    00-0E-60   # 360SUN Digital Broadband Corporation
    00-0E-61   # MICROTROL LIMITED
    00-0E-62   # Nortel Networks
    00-0E-63   # Lemke Diagnostics GmbH
    00-0E-64   # Elphel, Inc
    00-0E-65   # TransCore
    00-0E-66   # Hitachi Industry & Control Solutions, Ltd.
    00-0E-67   # Eltis Microelectronics Ltd.
    00-0E-68   # E-TOP Network Technology Inc.
    00-0E-69   # China Electric Power Research Institute
    00-0E-6A   # 3Com Ltd
    00-0E-6B   # Janitza electronics GmbH
    00-0E-6C   # Device Drivers Limited
    00-0E-6D   # Murata Manufacturing Co., Ltd.
    00-0E-6E   # MAT S.A. (Mircrelec Advanced Technology)
    00-0E-6F   # IRIS Corporation Berhad
    00-0E-70   # in2 Networks
    00-0E-71   # Gemstar Technology Development Ltd.
    00-0E-72   # CTS electronics
    00-0E-73   # Tpack A/S
    00-0E-74   # Solar Telecom. Tech
    00-0E-75   # New York Air Brake Corp.
    00-0E-76   # GEMSOC INNOVISION INC.
    00-0E-77   # Decru, Inc.
    00-0E-78   # Amtelco
    00-0E-79   # Ample Communications Inc.
    00-0E-7A   # GemWon Communications Co., Ltd.
    00-0E-7B   # Toshiba
    00-0E-7C   # Televes S.A.
    00-0E-7D   # Electronics Line 3000 Ltd.
    00-0E-7E   # ionSign Oy
    00-0E-7F   # Hewlett Packard
    00-0E-80   # Thomson Technology Inc
    00-0E-81   # Devicescape Software, Inc.
    00-0E-82   # Commtech Wireless
    00-0E-83   # Cisco Systems, Inc
    00-0E-84   # Cisco Systems, Inc
    00-0E-85   # Catalyst Enterprises, Inc.
    00-0E-86   # Alcatel North America
    00-0E-87   # adp Gauselmann GmbH
    00-0E-88   # VIDEOTRON CORP.
    00-0E-89   # CLEMATIC
    00-0E-8A   # Avara Technologies Pty. Ltd.
    00-0E-8B   # Astarte Technology Co, Ltd.
    00-0E-8C   # Siemens AG A&D ET
    00-0E-8D   # Systems in Progress Holding GmbH
    00-0E-8E   # SparkLAN Communications, Inc.
    00-0E-8F   # Sercomm Corp.
    00-0E-90   # PONICO CORP.
    00-0E-91   # Navico Auckland Ltd
    00-0E-92   # Open Telecom
    00-0E-93   # Milénio 3 Sistemas Electrónicos, Lda.
    00-0E-94   # Maas International BV
    00-0E-95   # Fujiya Denki Seisakusho Co.,Ltd.
    00-0E-96   # Cubic Defense Applications, Inc.
    00-0E-97   # Ultracker Technology CO., Inc
    00-0E-98   # HME Clear-Com LTD.
    00-0E-99   # Spectrum Digital, Inc
    00-0E-9A   # BOE TECHNOLOGY GROUP CO.,LTD
    00-0E-9B   # Ambit Microsystems Corporation
    00-0E-9C   # Benchmark Electronics
    00-0E-9D   # Tiscali UK Ltd
    00-0E-9E   # Topfield Co., Ltd
    00-0E-9F   # TEMIC SDS GmbH
    00-0E-A0   # NetKlass Technology Inc.
    00-0E-A1   # Formosa Teletek Corporation
    00-0E-A2   # McAfee, Inc
    00-0E-A3   # CNCR-IT CO.,LTD,HangZhou P.R.CHINA
    00-0E-A4   # Certance Inc.
    00-0E-A5   # BLIP Systems
    00-0E-A6   # ASUSTek COMPUTER INC.
    00-0E-A7   # Endace Technology
    00-0E-A8   # United Technologists Europe Limited
    00-0E-A9   # Shanghai Xun Shi Communications Equipment Ltd. Co.
    00-0E-AA   # Scalent Systems, Inc.
    00-0E-AB   # Cray Inc
    00-0E-AC   # MINTRON ENTERPRISE CO., LTD.
    00-0E-AD   # Metanoia Technologies, Inc.
    00-0E-AE   # GAWELL TECHNOLOGIES CORP.
    00-0E-AF   # CASTEL
    00-0E-B0   # Solutions Radio BV
    00-0E-B1   # Newcotech,Ltd
    00-0E-B2   # Micro-Research Finland Oy
    00-0E-B3   # Hewlett Packard
    00-0E-B4   # GUANGZHOU GAOKE COMMUNICATIONS TECHNOLOGY CO.LTD.
    00-0E-B5   # Ecastle Electronics Co., Ltd.
    00-0E-B6   # Riverbed Technology, Inc.
    00-0E-B7   # Knovative, Inc.
    00-0E-B8   # Iiga co.,Ltd
    00-0E-B9   # HASHIMOTO Electronics Industry Co.,Ltd.
    00-0E-BA   # HANMI SEMICONDUCTOR CO., LTD.
    00-0E-BB   # Everbee Networks
    00-0E-BC   # Paragon Fidelity GmbH
    00-0E-BD   # Burdick, a Quinton Compny
    00-0E-BE   # B&B Electronics Manufacturing Co.
    00-0E-BF   # Remsdaq Limited
    00-0E-C0   # Nortel Networks
    00-0E-C1   # MYNAH Technologies
    00-0E-C2   # Lowrance Electronics, Inc.
    00-0E-C3   # Logic Controls, Inc.
    00-0E-C4   # Iskra Transmission d.d.
    00-0E-C5   # Digital Multitools Inc
    00-0E-C6   # ASIX ELECTRONICS CORP.
    00-0E-C7   # Motorola Korea
    00-0E-C8   # Zoran Corporation
    00-0E-C9   # YOKO Technology Corp.
    00-0E-CA   # WTSS Inc
    00-0E-CB   # VineSys Technology
    00-0E-CC   # Tableau, LLC
    00-0E-CD   # SKOV A/S
    00-0E-CE   # S.I.T.T.I. S.p.A.
    00-0E-CF   # PROFIBUS Nutzerorganisation e.V.
    00-0E-D0   # Privaris, Inc.
    00-0E-D1   # Osaka Micro Computer.
    00-0E-D2   # Filtronic plc
    00-0E-D3   # Epicenter, Inc.
    00-0E-D4   # CRESITT INDUSTRIE
    00-0E-D5   # COPAN Systems Inc.
    00-0E-D6   # Cisco Systems, Inc
    00-0E-D7   # Cisco Systems, Inc
    00-0E-D8   # Positron Access Solutions Corp
    00-0E-D9   # Aksys, Ltd.
    00-0E-DA   # C-TECH UNITED CORP.
    00-0E-DB   # XiNCOM Corp.
    00-0E-DC   # Tellion INC.
    00-0E-DD   # SHURE INCORPORATED
    00-0E-DE   # REMEC, Inc.
    00-0E-DF   # PLX Technology
    00-0E-E0   # Mcharge
    00-0E-E1   # ExtremeSpeed Inc.
    00-0E-E2   # Custom Engineering
    00-0E-E3   # Chiyu Technology Co.,Ltd
    00-0E-E4   # BOE TECHNOLOGY GROUP CO.,LTD
    00-0E-E5   # bitWallet, Inc.
    00-0E-E6   # Adimos Systems LTD
    00-0E-E7   # AAC ELECTRONICS CORP.
    00-0E-E8   # zioncom
    00-0E-E9   # WayTech Development, Inc.
    00-0E-EA   # Shadong Luneng Jicheng Electronics,Co.,Ltd
    00-0E-EB   # Sandmartin(zhong shan)Electronics Co.,Ltd
    00-0E-EC   # Orban
    00-0E-ED   # Nokia Danmark A/S
    00-0E-EE   # Muco Industrie BV
    00-0E-EF   # Private
    00-0E-F0   # Festo AG & Co. KG
    00-0E-F1   # EZQUEST INC.
    00-0E-F2   # Infinico Corporation
    00-0E-F3   # Smarthome
    00-0E-F4   # Kasda Networks Inc
    00-0E-F5   # iPAC Technology Co., Ltd.
    00-0E-F6   # E-TEN Information Systems Co., Ltd.
    00-0E-F7   # Vulcan Portals Inc
    00-0E-F8   # SBC ASI
    00-0E-F9   # REA Elektronik GmbH
    00-0E-FA   # Optoway Technology Incorporation
    00-0E-FB   # Macey Enterprises
    00-0E-FC   # JTAG Technologies B.V.
    00-0E-FD   # FUJINON CORPORATION
    00-0E-FE   # EndRun Technologies LLC
    00-0E-FF   # Megasolution,Inc.
    00-0F-00   # Legra Systems, Inc.
    00-0F-01   # DIGITALKS INC
    00-0F-02   # Digicube Technology Co., Ltd
    00-0F-03   # COM&C CO., LTD
    00-0F-04   # cim-usa inc
    00-0F-05   # 3B SYSTEM INC.
    00-0F-06   # Nortel Networks
    00-0F-07   # Mangrove Systems, Inc.
    00-0F-08   # Indagon Oy
    00-0F-09   # Private
    00-0F-0A   # Clear Edge Networks
    00-0F-0B   # Kentima Technologies AB
    00-0F-0C   # SYNCHRONIC ENGINEERING
    00-0F-0D   # Hunt Electronic Co., Ltd.
    00-0F-0E   # WaveSplitter Technologies, Inc.
    00-0F-0F   # Real ID Technology Co., Ltd.
    00-0F-10   # RDM Corporation
    00-0F-11   # Prodrive B.V.
    00-0F-12   # Panasonic Europe Ltd.
    00-0F-13   # Nisca corporation
    00-0F-14   # Mindray Co., Ltd.
    00-0F-15   # Kjaerulff1 A/S
    00-0F-16   # JAY HOW TECHNOLOGY CO.,
    00-0F-17   # Insta Elektro GmbH
    00-0F-18   # Industrial Control Systems
    00-0F-19   # Boston Scientific
    00-0F-1A   # Gaming Support B.V.
    00-0F-1B   # Ego Systems Inc.
    00-0F-1C   # DigitAll World Co., Ltd
    00-0F-1D   # Cosmo Techs Co., Ltd.
    00-0F-1E   # Chengdu KT Electric Co.of High & New Technology
    00-0F-1F   # Dell Inc.
    00-0F-20   # Hewlett Packard
    00-0F-21   # Scientific Atlanta, Inc
    00-0F-22   # Helius, Inc.
    00-0F-23   # Cisco Systems, Inc
    00-0F-24   # Cisco Systems, Inc
    00-0F-25   # AimValley B.V.
    00-0F-26   # WorldAccxx  LLC
    00-0F-27   # TEAL Electronics, Inc.
    00-0F-28   # Itronix Corporation
    00-0F-29   # Augmentix Corporation
    00-0F-2A   # Cableware Electronics
    00-0F-2B   # GREENBELL SYSTEMS
    00-0F-2C   # Uplogix, Inc.
    00-0F-2D   # CHUNG-HSIN ELECTRIC & MACHINERY MFG.CORP.
    00-0F-2E   # Megapower International Corp.
    00-0F-2F   # W-LINX TECHNOLOGY CO., LTD.
    00-0F-30   # Raza Microelectronics Inc
    00-0F-31   # Allied Vision Technologies Canada Inc
    00-0F-32   # Lootom Telcovideo Network Wuxi Co Ltd
    00-0F-33   # DUALi Inc.
    00-0F-34   # Cisco Systems, Inc
    00-0F-35   # Cisco Systems, Inc
    00-0F-36   # Accurate Techhnologies, Inc.
    00-0F-37   # Xambala Incorporated
    00-0F-38   # Netstar
    00-0F-39   # IRIS SENSORS
    00-0F-3A   # HISHARP
    00-0F-3B   # Fuji System Machines Co., Ltd.
    00-0F-3C   # Endeleo Limited
    00-0F-3D   # D-Link Corporation
    00-0F-3E   # CardioNet, Inc
    00-0F-3F   # Big Bear Networks
    00-0F-40   # Optical Internetworking Forum
    00-0F-41   # Zipher Ltd
    00-0F-42   # Xalyo Systems
    00-0F-43   # Wasabi Systems Inc.
    00-0F-44   # Tivella Inc.
    00-0F-45   # Stretch, Inc.
    00-0F-46   # SINAR AG
    00-0F-47   # ROBOX SPA
    00-0F-48   # Polypix Inc.
    00-0F-49   # Northover Solutions Limited
    00-0F-4A   # Kyushu-kyohan co.,ltd
    00-0F-4B   # Oracle Corporation
    00-0F-4C   # Elextech INC
    00-0F-4D   # TalkSwitch
    00-0F-4E   # Cellink
    00-0F-4F   # Cadmus Technology Ltd
    00-0F-50   # StreamScale Limited
    00-0F-51   # Azul Systems, Inc.
    00-0F-52   # YORK Refrigeration, Marine & Controls
    00-0F-53   # Solarflare Communications Inc
    00-0F-54   # Entrelogic Corporation
    00-0F-55   # Datawire Communication Networks Inc.
    00-0F-56   # Continuum Photonics Inc
    00-0F-57   # CABLELOGIC Co., Ltd.
    00-0F-58   # Adder Technology Limited
    00-0F-59   # Phonak Communications AG
    00-0F-5A   # Peribit Networks
    00-0F-5B   # Delta Information Systems, Inc.
    00-0F-5C   # Day One Digital Media Limited
    00-0F-5D   # Genexis BV
    00-0F-5E   # Veo
    00-0F-5F   # Nicety Technologies Inc. (NTS)
    00-0F-60   # Lifetron Co.,Ltd
    00-0F-61   # Hewlett Packard
    00-0F-62   # Alcatel Bell Space N.V.
    00-0F-63   # Obzerv Technologies
    00-0F-64   # D&R Electronica Weesp BV
    00-0F-65   # icube Corp.
    00-0F-66   # Cisco-Linksys, LLC
    00-0F-67   # West Instruments
    00-0F-68   # Vavic Network Technology, Inc.
    00-0F-69   # SEW Eurodrive GmbH & Co. KG
    00-0F-6A   # Nortel Networks
    00-0F-6B   # GateWare Communications GmbH
    00-0F-6C   # ADDI-DATA GmbH
    00-0F-6D   # Midas Engineering
    00-0F-6E   # BBox
    00-0F-6F   # FTA Communication Technologies
    00-0F-70   # Wintec Industries, inc.
    00-0F-71   # Sanmei Electronics Co.,Ltd
    00-0F-72   # Sandburst
    00-0F-73   # RS Automation Co., Ltd
    00-0F-74   # Qamcom Technology AB
    00-0F-75   # First Silicon Solutions
    00-0F-76   # Digital Keystone, Inc.
    00-0F-77   # DENTUM CO.,LTD
    00-0F-78   # Datacap Systems Inc
    00-0F-79   # Bluetooth Interest Group Inc.
    00-0F-7A   # BeiJing NuQX Technology CO.,LTD
    00-0F-7B   # Arce Sistemas, S.A.
    00-0F-7C   # ACTi Corporation
    00-0F-7D   # Xirrus
    00-0F-7E   # Ablerex Electronics Co., LTD
    00-0F-7F   # UBSTORAGE Co.,Ltd.
    00-0F-80   # Trinity Security Systems,Inc.
    00-0F-81   # PAL Pacific Inc.
    00-0F-82   # Mortara Instrument, Inc.
    00-0F-83   # Brainium Technologies Inc.
    00-0F-84   # Astute Networks, Inc.
    00-0F-85   # ADDO-Japan Corporation
    00-0F-86   # BlackBerry RTS
    00-0F-87   # Maxcess International
    00-0F-88   # AMETEK, Inc.
    00-0F-89   # Winnertec System Co., Ltd.
    00-0F-8A   # WideView
    00-0F-8B   # Orion MultiSystems Inc
    00-0F-8C   # Gigawavetech Pte Ltd
    00-0F-8D   # FAST TV-Server AG
    00-0F-8E   # DONGYANG TELECOM CO.,LTD.
    00-0F-8F   # Cisco Systems, Inc
    00-0F-90   # Cisco Systems, Inc
    00-0F-91   # Aerotelecom Co.,Ltd.
    00-0F-92   # Microhard Systems Inc.
    00-0F-93   # Landis+Gyr Ltd.
    00-0F-94   # Genexis BV
    00-0F-95   # ELECOM Co.,LTD Laneed Division
    00-0F-96   # Telco Systems, Inc.
    00-0F-97   # Avanex Corporation
    00-0F-98   # Avamax Co. Ltd.
    00-0F-99   # APAC opto Electronics Inc.
    00-0F-9A   # Synchrony, Inc.
    00-0F-9B   # Ross Video Limited
    00-0F-9C   # Panduit Corp
    00-0F-9D   # DisplayLink (UK) Ltd
    00-0F-9E   # Murrelektronik GmbH
    00-0F-9F   # ARRIS Group, Inc.
    00-0F-A0   # CANON KOREA BUSINESS SOLUTIONS INC.
    00-0F-A1   # Gigabit Systems Inc.
    00-0F-A2   # 2xWireless
    00-0F-A3   # Alpha Networks Inc.
    00-0F-A4   # Sprecher Automation GmbH
    00-0F-A5   # BWA Technology GmbH
    00-0F-A6   # S2 Security Corporation
    00-0F-A7   # Raptor Networks Technology
    00-0F-A8   # Photometrics, Inc.
    00-0F-A9   # PC Fabrik
    00-0F-AA   # Nexus Technologies
    00-0F-AB   # Kyushu Electronics Systems Inc.
    00-0F-AC   # IEEE 802.11
    00-0F-AD   # FMN communications GmbH
    00-0F-AE   # E2O Communications
    00-0F-AF   # Dialog Inc.
    00-0F-B0   # COMPAL ELECTRONICS, INC.
    00-0F-B1   # Cognio Inc.
    00-0F-B2   # Broadband Pacenet (India) Pvt. Ltd.
    00-0F-B3   # Actiontec Electronics, Inc
    00-0F-B4   # Timespace Technology
    00-0F-B5   # NETGEAR
    00-0F-B6   # Europlex Technologies
    00-0F-B7   # Cavium
    00-0F-B8   # CallURL Inc.
    00-0F-B9   # Adaptive Instruments
    00-0F-BA   # Tevebox AB
    00-0F-BB   # Nokia Siemens Networks GmbH & Co. KG.
    00-0F-BC   # Onkey Technologies, Inc.
    00-0F-BD   # MRV Communications (Networks) LTD
    00-0F-BE   # e-w/you Inc.
    00-0F-BF   # DGT Sp. z o.o.
    00-0F-C0   # DELCOMp
    00-0F-C1   # WAVE Corporation
    00-0F-C2   # Uniwell Corporation
    00-0F-C3   # PalmPalm Technology, Inc.
    00-0F-C4   # NST co.,LTD.
    00-0F-C5   # KeyMed Ltd
    00-0F-C6   # Eurocom Industries A/S
    00-0F-C7   # Dionica R&D Ltd.
    00-0F-C8   # Chantry Networks
    00-0F-C9   # Allnet GmbH
    00-0F-CA   # A-JIN TECHLINE CO, LTD
    00-0F-CB   # 3Com Ltd
    00-0F-CC   # ARRIS Group, Inc.
    00-0F-CD   # Nortel Networks
    00-0F-CE   # Kikusui Electronics Corp.
    00-0F-CF   # DataWind Research
    00-0F-D0   # ASTRI
    00-0F-D1   # Applied Wireless Identifications Group, Inc.
    00-0F-D2   # EWA Technologies, Inc.
    00-0F-D3   # Digium
    00-0F-D4   # Soundcraft
    00-0F-D5   # Schwechat - RISE
    00-0F-D6   # Sarotech Co., Ltd
    00-0F-D7   # Harman Music Group
    00-0F-D8   # Force, Inc.
    00-0F-D9   # FlexDSL Telecommunications AG
    00-0F-DA   # YAZAKI CORPORATION
    00-0F-DB   # Westell Technologies
    00-0F-DC   # Ueda Japan  Radio Co., Ltd.
    00-0F-DD   # SORDIN AB
    00-0F-DE   # Sony Mobile Communications AB
    00-0F-DF   # SOLOMON Technology Corp.
    00-0F-E0   # NComputing Co.,Ltd.
    00-0F-E1   # ID DIGITAL CORPORATION
    00-0F-E2   # Hangzhou H3C Technologies Co., Ltd.
    00-0F-E3   # Damm Cellular Systems A/S
    00-0F-E4   # Pantech Co.,Ltd
    00-0F-E5   # MERCURY SECURITY CORPORATION
    00-0F-E6   # MBTech Systems, Inc.
    00-0F-E7   # Lutron Electronics Co., Inc.
    00-0F-E8   # Lobos, Inc.
    00-0F-E9   # GW TECHNOLOGIES CO.,LTD.
    00-0F-EA   # Giga-Byte Technology Co.,LTD.
    00-0F-EB   # Cylon Controls
    00-0F-EC   # ARKUS Inc.
    00-0F-ED   # Anam Electronics Co., Ltd
    00-0F-EE   # XTec, Incorporated
    00-0F-EF   # Thales e-Transactions GmbH
    00-0F-F0   # Sunray Co. Ltd.
    00-0F-F1   # nex-G Systems Pte.Ltd
    00-0F-F2   # Loud Technologies Inc.
    00-0F-F3   # Jung Myoung Communications&Technology
    00-0F-F4   # Guntermann & Drunck GmbH
    00-0F-F5   # GN&S company
    00-0F-F6   # DARFON LIGHTING CORP
    00-0F-F7   # Cisco Systems, Inc
    00-0F-F8   # Cisco Systems, Inc
    00-0F-F9   # Valcretec, Inc.
    00-0F-FA   # Optinel Systems, Inc.
    00-0F-FB   # Nippon Denso Industry Co., Ltd.
    00-0F-FC   # Merit Li-Lin Ent.
    00-0F-FD   # Glorytek Network Inc.
    00-0F-FE   # G-PRO COMPUTER
    00-0F-FF   # Control4
    00-10-00   # CABLE TELEVISION LABORATORIES, INC.
    00-10-01   # Citel
    00-10-02   # ACTIA
    00-10-03   # IMATRON, INC.
    00-10-04   # THE BRANTLEY COILE COMPANY,INC
    00-10-05   # UEC COMMERCIAL
    00-10-06   # Thales Contact Solutions Ltd.
    00-10-07   # Cisco Systems, Inc
    00-10-08   # VIENNA SYSTEMS CORPORATION
    00-10-09   # HORO QUARTZ
    00-10-0A   # WILLIAMS COMMUNICATIONS GROUP
    00-10-0B   # Cisco Systems, Inc
    00-10-0C   # ITO CO., LTD.
    00-10-0D   # Cisco Systems, Inc
    00-10-0E   # MICRO LINEAR COPORATION
    00-10-0F   # INDUSTRIAL CPU SYSTEMS
    00-10-10   # INITIO CORPORATION
    00-10-11   # Cisco Systems, Inc
    00-10-12   # PROCESSOR SYSTEMS (I) PVT LTD
    00-10-13   # Kontron America, Inc.
    00-10-14   # Cisco Systems, Inc
    00-10-15   # OOmon Inc.
    00-10-16   # T.SQWARE
    00-10-17   # Bosch Access Systems GmbH
    00-10-18   # Broadcom
    00-10-19   # SIRONA DENTAL SYSTEMS GmbH & Co. KG
    00-10-1A   # PictureTel Corp.
    00-10-1B   # CORNET TECHNOLOGY, INC.
    00-10-1C   # OHM TECHNOLOGIES INTL, LLC
    00-10-1D   # WINBOND ELECTRONICS CORP.
    00-10-1E   # MATSUSHITA ELECTRONIC INSTRUMENTS CORP.
    00-10-1F   # Cisco Systems, Inc
    00-10-20   # Hand Held Products Inc
    00-10-21   # ENCANTO NETWORKS, INC.
    00-10-22   # SatCom Media Corporation
    00-10-23   # Network Equipment Technologies
    00-10-24   # NAGOYA ELECTRIC WORKS CO., LTD
    00-10-25   # Grayhill, Inc
    00-10-26   # ACCELERATED NETWORKS, INC.
    00-10-27   # L-3 COMMUNICATIONS EAST
    00-10-28   # COMPUTER TECHNICA, INC.
    00-10-29   # Cisco Systems, Inc
    00-10-2A   # ZF MICROSYSTEMS, INC.
    00-10-2B   # UMAX DATA SYSTEMS, INC.
    00-10-2C   # Lasat Networks A/S
    00-10-2D   # HITACHI SOFTWARE ENGINEERING
    00-10-2E   # NETWORK SYSTEMS & TECHNOLOGIES PVT. LTD.
    00-10-2F   # Cisco Systems, Inc
    00-10-30   # EION Inc.
    00-10-31   # OBJECTIVE COMMUNICATIONS, INC.
    00-10-32   # ALTA TECHNOLOGY
    00-10-33   # ACCESSLAN COMMUNICATIONS, INC.
    00-10-34   # GNP Computers
    00-10-35   # ELITEGROUP COMPUTER SYSTEMS CO., LTD
    00-10-36   # INTER-TEL INTEGRATED SYSTEMS
    00-10-37   # CYQ've Technology Co., Ltd.
    00-10-38   # MICRO RESEARCH INSTITUTE, INC.
    00-10-39   # Vectron Systems AG
    00-10-3A   # DIAMOND NETWORK TECH
    00-10-3B   # HIPPI NETWORKING FORUM
    00-10-3C   # IC ENSEMBLE, INC.
    00-10-3D   # PHASECOM, LTD.
    00-10-3E   # NETSCHOOLS CORPORATION
    00-10-3F   # TOLLGRADE COMMUNICATIONS, INC.
    00-10-40   # INTERMEC CORPORATION
    00-10-41   # BRISTOL BABCOCK, INC.
    00-10-42   # Alacritech, Inc.
    00-10-43   # A2 CORPORATION
    00-10-44   # InnoLabs Corporation
    00-10-45   # Nortel Networks
    00-10-46   # ALCORN MCBRIDE INC.
    00-10-47   # ECHO ELETRIC CO. LTD.
    00-10-48   # HTRC AUTOMATION, INC.
    00-10-49   # ShoreTel, Inc
    00-10-4A   # The Parvus Corporation
    00-10-4B   # 3COM CORPORATION
    00-10-4C   # Teledyne LeCroy, Inc
    00-10-4D   # SURTEC INDUSTRIES, INC.
    00-10-4E   # CEOLOGIC
    00-10-4F   # Oracle Corporation
    00-10-50   # RION CO., LTD.
    00-10-51   # CMICRO CORPORATION
    00-10-52   # METTLER-TOLEDO (ALBSTADT) GMBH
    00-10-53   # COMPUTER TECHNOLOGY CORP.
    00-10-54   # Cisco Systems, Inc
    00-10-55   # FUJITSU MICROELECTRONICS, INC.
    00-10-56   # SODICK CO., LTD.
    00-10-57   # Rebel.com, Inc.
    00-10-58   # ArrowPoint Communications
    00-10-59   # DIABLO RESEARCH CO. LLC
    00-10-5A   # 3COM CORPORATION
    00-10-5B   # NET INSIGHT AB
    00-10-5C   # QUANTUM DESIGNS (H.K.) LTD.
    00-10-5D   # Draeger Medical
    00-10-5E   # Spirent plc, Service Assurance Broadband
    00-10-5F   # ZODIAC DATA SYSTEMS
    00-10-60   # BILLIONTON SYSTEMS, INC.
    00-10-61   # HOSTLINK CORP.
    00-10-62   # NX SERVER, ILNC.
    00-10-63   # STARGUIDE DIGITAL NETWORKS
    00-10-64   # DNPG, LLC
    00-10-65   # RADYNE CORPORATION
    00-10-66   # ADVANCED CONTROL SYSTEMS, INC.
    00-10-67   # Ericsson
    00-10-68   # COMOS TELECOM
    00-10-69   # HELIOSS COMMUNICATIONS, INC.
    00-10-6A   # DIGITAL MICROWAVE CORPORATION
    00-10-6B   # SONUS NETWORKS, INC.
    00-10-6C   # EDNT GmbH
    00-10-6D   # Axxcelera Broadband Wireless
    00-10-6E   # TADIRAN COM. LTD.
    00-10-6F   # TRENTON TECHNOLOGY INC.
    00-10-70   # CARADON TREND LTD.
    00-10-71   # ADVANET INC.
    00-10-72   # GVN TECHNOLOGIES, INC.
    00-10-73   # TECHNOBOX, INC.
    00-10-74   # ATEN INTERNATIONAL CO., LTD.
    00-10-75   # Segate Technology LLC
    00-10-76   # EUREM GmbH
    00-10-77   # SAF DRIVE SYSTEMS, LTD.
    00-10-78   # NUERA COMMUNICATIONS, INC.
    00-10-79   # Cisco Systems, Inc
    00-10-7A   # AmbiCom, Inc.
    00-10-7B   # Cisco Systems, Inc
    00-10-7C   # P-COM, INC.
    00-10-7D   # AURORA COMMUNICATIONS, LTD.
    00-10-7E   # BACHMANN ELECTRONIC GmbH
    00-10-7F   # CRESTRON ELECTRONICS, INC.
    00-10-80   # METAWAVE COMMUNICATIONS
    00-10-81   # DPS, INC.
    00-10-82   # JNA TELECOMMUNICATIONS LIMITED
    00-10-83   # Hewlett Packard
    00-10-84   # K-BOT COMMUNICATIONS
    00-10-85   # POLARIS COMMUNICATIONS, INC.
    00-10-86   # ATTO Technology, Inc.
    00-10-87   # Xstreamis PLC
    00-10-88   # AMERICAN NETWORKS INC.
    00-10-89   # WebSonic
    00-10-8A   # TeraLogic, Inc.
    00-10-8B   # LASERANIMATION SOLLINGER GMBH
    00-10-8C   # FUJITSU TELECOMMUNICATIONS EUROPE, LTD.
    00-10-8D   # Johnson Controls, Inc.
    00-10-8E   # HUGH SYMONS CONCEPT Technologies Ltd.
    00-10-8F   # RAPTOR SYSTEMS
    00-10-90   # CIMETRICS, INC.
    00-10-91   # NO WIRES NEEDED BV
    00-10-92   # NETCORE INC.
    00-10-93   # CMS COMPUTERS, LTD.
    00-10-94   # Performance Analysis Broadband, Spirent plc
    00-10-95   # Thomson Inc.
    00-10-96   # TRACEWELL SYSTEMS, INC.
    00-10-97   # WinNet Metropolitan Communications Systems, Inc.
    00-10-98   # STARNET TECHNOLOGIES, INC.
    00-10-99   # InnoMedia, Inc.
    00-10-9A   # NETLINE
    00-10-9B   # Emulex Corporation
    00-10-9C   # M-SYSTEM CO., LTD.
    00-10-9D   # CLARINET SYSTEMS, INC.
    00-10-9E   # AWARE, INC.
    00-10-9F   # PAVO, INC.
    00-10-A0   # INNOVEX TECHNOLOGIES, INC.
    00-10-A1   # KENDIN SEMICONDUCTOR, INC.
    00-10-A2   # TNS
    00-10-A3   # OMNITRONIX, INC.
    00-10-A4   # XIRCOM
    00-10-A5   # OXFORD INSTRUMENTS
    00-10-A6   # Cisco Systems, Inc
    00-10-A7   # UNEX TECHNOLOGY CORPORATION
    00-10-A8   # RELIANCE COMPUTER CORP.
    00-10-A9   # ADHOC TECHNOLOGIES
    00-10-AA   # MEDIA4, INC.
    00-10-AB   # KOITO ELECTRIC INDUSTRIES, LTD.
    00-10-AC   # IMCI TECHNOLOGIES
    00-10-AD   # SOFTRONICS USB, INC.
    00-10-AE   # SHINKO ELECTRIC INDUSTRIES CO.
    00-10-AF   # TAC SYSTEMS, INC.
    00-10-B0   # MERIDIAN TECHNOLOGY CORP.
    00-10-B1   # FOR-A CO., LTD.
    00-10-B2   # COACTIVE AESTHETICS
    00-10-B3   # NOKIA MULTIMEDIA TERMINALS
    00-10-B4   # ATMOSPHERE NETWORKS
    00-10-B5   # Accton Technology Corp
    00-10-B6   # ENTRATA COMMUNICATIONS CORP.
    00-10-B7   # COYOTE TECHNOLOGIES, LLC
    00-10-B8   # ISHIGAKI COMPUTER SYSTEM CO.
    00-10-B9   # MAXTOR CORP.
    00-10-BA   # MARTINHO-DAVIS SYSTEMS, INC.
    00-10-BB   # DATA & INFORMATION TECHNOLOGY
    00-10-BC   # Aastra Telecom
    00-10-BD   # THE TELECOMMUNICATION TECHNOLOGY COMMITTEE (TTC)
    00-10-BE   # MARCH NETWORKS CORPORATION
    00-10-BF   # InterAir Wireless
    00-10-C0   # ARMA, Inc.
    00-10-C1   # OI ELECTRIC CO., LTD.
    00-10-C2   # WILLNET, INC.
    00-10-C3   # CSI-CONTROL SYSTEMS
    00-10-C4   # MEDIA GLOBAL LINKS CO., LTD.
    00-10-C5   # PROTOCOL TECHNOLOGIES, INC.
    00-10-C6   # Universal Global Scientific Industrial Co., Ltd.
    00-10-C7   # DATA TRANSMISSION NETWORK
    00-10-C8   # COMMUNICATIONS ELECTRONICS SECURITY GROUP
    00-10-C9   # MITSUBISHI ELECTRONICS LOGISTIC SUPPORT CO.
    00-10-CA   # Telco Systems, Inc.
    00-10-CB   # FACIT K.K.
    00-10-CC   # CLP COMPUTER LOGISTIK PLANUNG GmbH
    00-10-CD   # INTERFACE CONCEPT
    00-10-CE   # VOLAMP, LTD.
    00-10-CF   # FIBERLANE COMMUNICATIONS
    00-10-D0   # WITCOM, LTD.
    00-10-D1   # Top Layer Networks, Inc.
    00-10-D2   # NITTO TSUSHINKI CO., LTD
    00-10-D3   # GRIPS ELECTRONIC GMBH
    00-10-D4   # STORAGE COMPUTER CORPORATION
    00-10-D5   # IMASDE CANARIAS, S.A.
    00-10-D6   # Exelis
    00-10-D7   # ARGOSY RESEARCH INC.
    00-10-D8   # CALISTA
    00-10-D9   # IBM JAPAN, FUJISAWA MT+D
    00-10-DA   # Kollmorgen Corp
    00-10-DB   # Juniper Networks
    00-10-DC   # MICRO-STAR INTERNATIONAL CO., LTD.
    00-10-DD   # ENABLE SEMICONDUCTOR, INC.
    00-10-DE   # INTERNATIONAL DATACASTING CORPORATION
    00-10-DF   # RISE COMPUTER INC.
    00-10-E0   # Oracle Corporation
    00-10-E1   # S.I. TECH, INC.
    00-10-E2   # ArrayComm, Inc.
    00-10-E3   # Hewlett Packard
    00-10-E4   # NSI CORPORATION
    00-10-E5   # SOLECTRON TEXAS
    00-10-E6   # APPLIED INTELLIGENT SYSTEMS, INC.
    00-10-E7   # Breezecom, Ltd.
    00-10-E8   # TELOCITY, INCORPORATED
    00-10-E9   # RAIDTEC LTD.
    00-10-EA   # ADEPT TECHNOLOGY
    00-10-EB   # SELSIUS SYSTEMS, INC.
    00-10-EC   # RPCG, LLC
    00-10-ED   # SUNDANCE TECHNOLOGY, INC.
    00-10-EE   # CTI PRODUCTS, INC.
    00-10-EF   # DBTEL INCORPORATED
    00-10-F0   # RITTAL-WERK RUDOLF LOH GmbH & Co.
    00-10-F1   # I-O CORPORATION
    00-10-F2   # ANTEC
    00-10-F3   # Nexcom International Co., Ltd.
    00-10-F4   # Vertical Communications
    00-10-F5   # AMHERST SYSTEMS, INC.
    00-10-F6   # Cisco Systems, Inc
    00-10-F7   # IRIICHI TECHNOLOGIES Inc.
    00-10-F8   # TEXIO TECHNOLOGY CORPORATION
    00-10-F9   # UNIQUE SYSTEMS, INC.
    00-10-FA   # Apple, Inc.
    00-10-FB   # ZIDA TECHNOLOGIES LIMITED
    00-10-FC   # BROADBAND NETWORKS, INC.
    00-10-FD   # COCOM A/S
    00-10-FE   # DIGITAL EQUIPMENT CORPORATION
    00-10-FF   # Cisco Systems, Inc
    00-11-00   # Schneider Electric
    00-11-01   # CET Technologies Pte Ltd
    00-11-02   # Aurora Multimedia Corp.
    00-11-03   # kawamura electric inc.
    00-11-04   # TELEXY
    00-11-05   # Sunplus Technology Co., Ltd.
    00-11-06   # Siemens NV (Belgium)
    00-11-07   # RGB Networks Inc.
    00-11-08   # Orbital Data Corporation
    00-11-09   # Micro-Star International
    00-11-0A   # Hewlett Packard
    00-11-0B   # Franklin Technology Systems
    00-11-0C   # Atmark Techno, Inc.
    00-11-0D   # SANBlaze Technology, Inc.
    00-11-0E   # Tsurusaki Sealand Transportation Co. Ltd.
    00-11-0F   # netplat,Inc.
    00-11-10   # Maxanna Technology Co., Ltd.
    00-11-11   # Intel Corporation
    00-11-12   # Honeywell CMSS
    00-11-13   # Fraunhofer FOKUS
    00-11-14   # EverFocus Electronics Corp.
    00-11-15   # EPIN Technologies, Inc.
    00-11-16   # COTEAU VERT CO., LTD.
    00-11-17   # CESNET
    00-11-18   # BLX IC Design Corp., Ltd.
    00-11-19   # Solteras, Inc.
    00-11-1A   # ARRIS Group, Inc.
    00-11-1B   # Targa Systems Div L-3 Communications Canada
    00-11-1C   # Pleora Technologies Inc.
    00-11-1D   # Hectrix Limited
    00-11-1E   # EPSG (Ethernet Powerlink Standardization Group)
    00-11-1F   # Doremi Labs, Inc.
    00-11-20   # Cisco Systems, Inc
    00-11-21   # Cisco Systems, Inc
    00-11-22   # CIMSYS Inc
    00-11-23   # Appointech, Inc.
    00-11-24   # Apple, Inc.
    00-11-25   # IBM Corp
    00-11-26   # Venstar Inc.
    00-11-27   # TASI, Inc
    00-11-28   # Streamit
    00-11-29   # Paradise Datacom Ltd.
    00-11-2A   # Niko NV
    00-11-2B   # NetModule AG
    00-11-2C   # IZT GmbH
    00-11-2D   # iPulse Systems
    00-11-2E   # CEICOM
    00-11-2F   # ASUSTek COMPUTER INC.
    00-11-30   # Allied Telesis (Hong Kong) Ltd.
    00-11-31   # UNATECH. CO.,LTD
    00-11-32   # Synology Incorporated
    00-11-33   # Siemens Austria SIMEA
    00-11-34   # MediaCell, Inc.
    00-11-35   # Grandeye Ltd
    00-11-36   # Goodrich Sensor Systems
    00-11-37   # AICHI ELECTRIC CO., LTD.
    00-11-38   # TAISHIN CO., LTD.
    00-11-39   # STOEBER ANTRIEBSTECHNIK GmbH + Co. KG.
    00-11-3A   # SHINBORAM
    00-11-3B   # Micronet Communications Inc.
    00-11-3C   # Micronas GmbH
    00-11-3D   # KN SOLTEC CO.,LTD.
    00-11-3E   # JL Corporation
    00-11-3F   # Alcatel DI
    00-11-40   # Nanometrics Inc.
    00-11-41   # GoodMan Corporation
    00-11-42   # e-SMARTCOM  INC.
    00-11-43   # Dell Inc.
    00-11-44   # Assurance Technology Corp
    00-11-45   # ValuePoint Networks
    00-11-46   # Telecard-Pribor Ltd
    00-11-47   # Secom-Industry co.LTD.
    00-11-48   # Prolon Control Systems
    00-11-49   # Proliphix Inc.
    00-11-4A   # KAYABA INDUSTRY Co,.Ltd.
    00-11-4B   # Francotyp-Postalia GmbH
    00-11-4C   # caffeina applied research ltd.
    00-11-4D   # Atsumi Electric Co.,LTD.
    00-11-4E   # 690885 Ontario Inc.
    00-11-4F   # US Digital Television, Inc
    00-11-50   # Belkin Corporation
    00-11-51   # Mykotronx
    00-11-52   # Eidsvoll Electronics AS
    00-11-53   # Trident Tek, Inc.
    00-11-54   # Webpro Technologies Inc.
    00-11-55   # Sevis Systems
    00-11-56   # Pharos Systems NZ
    00-11-57   # Oki Electric Industry Co., Ltd.
    00-11-58   # Nortel Networks
    00-11-59   # MATISSE NETWORKS INC
    00-11-5A   # Ivoclar Vivadent AG
    00-11-5B   # Elitegroup Computer System Co. (ECS)
    00-11-5C   # Cisco Systems, Inc
    00-11-5D   # Cisco Systems, Inc
    00-11-5E   # ProMinent Dosiertechnik GmbH
    00-11-5F   # ITX Security Co., Ltd.
    00-11-60   # ARTDIO Company Co., LTD
    00-11-61   # NetStreams, LLC
    00-11-62   # STAR MICRONICS CO.,LTD.
    00-11-63   # SYSTEM SPA DEPT. ELECTRONICS
    00-11-64   # ACARD Technology Corp.
    00-11-65   # Znyx Networks
    00-11-66   # Taelim Electronics Co., Ltd.
    00-11-67   # Integrated System Solution Corp.
    00-11-68   # HomeLogic LLC
    00-11-69   # EMS Satcom
    00-11-6A   # Domo Ltd
    00-11-6B   # Digital Data Communications Asia Co.,Ltd
    00-11-6C   # Nanwang Multimedia Inc.,Ltd
    00-11-6D   # American Time and Signal
    00-11-6E   # PePLink Ltd.
    00-11-6F   # Netforyou Co., LTD.
    00-11-70   # GSC SRL
    00-11-71   # DEXTER Communications, Inc.
    00-11-72   # COTRON CORPORATION
    00-11-73   # SMART Storage Systems
    00-11-74   # Wibhu Technologies, Inc.
    00-11-75   # Intel Corporation
    00-11-76   # Intellambda Systems, Inc.
    00-11-77   # Coaxial Networks, Inc.
    00-11-78   # Chiron Technology Ltd
    00-11-79   # Singular Technology Co. Ltd.
    00-11-7A   # Singim International Corp.
    00-11-7B   # Büchi  Labortechnik AG
    00-11-7C   # e-zy.net
    00-11-7D   # ZMD America, Inc.
    00-11-7E   # Progeny, A division of Midmark Corp
    00-11-7F   # Neotune Information Technology Corporation,.LTD
    00-11-80   # ARRIS Group, Inc.
    00-11-81   # InterEnergy Co.Ltd,
    00-11-82   # IMI Norgren Ltd
    00-11-83   # Datalogic ADC, Inc.
    00-11-84   # Humo Laboratory,Ltd.
    00-11-85   # Hewlett Packard
    00-11-86   # Prime Systems, Inc.
    00-11-87   # Category Solutions, Inc
    00-11-88   # Enterasys
    00-11-89   # Aerotech Inc
    00-11-8A   # Viewtran Technology Limited
    00-11-8B   # Alcatel-Lucent, Enterprise Business Group
    00-11-8C   # Missouri Department of Transportation
    00-11-8D   # Hanchang System Corp.
    00-11-8E   # Halytech Mace
    00-11-8F   # EUTECH INSTRUMENTS PTE. LTD.
    00-11-90   # Digital Design Corporation
    00-11-91   # CTS-Clima Temperatur Systeme GmbH
    00-11-92   # Cisco Systems, Inc
    00-11-93   # Cisco Systems, Inc
    00-11-94   # Chi Mei Communication Systems, Inc.
    00-11-95   # D-Link Corporation
    00-11-96   # Actuality Systems, Inc.
    00-11-97   # Monitoring Technologies Limited
    00-11-98   # Prism Media Products Limited
    00-11-99   # 2wcom Systems GmbH
    00-11-9A   # Alkeria srl
    00-11-9B   # Telesynergy Research Inc.
    00-11-9C   # EP&T Energy
    00-11-9D   # Diginfo Technology Corporation
    00-11-9E   # Solectron Brazil
    00-11-9F   # Nokia Danmark A/S
    00-11-A0   # Vtech Engineering Canada Ltd
    00-11-A1   # VISION NETWARE CO.,LTD
    00-11-A2   # Manufacturing Technology Inc
    00-11-A3   # LanReady Technologies Inc.
    00-11-A4   # JStream Technologies Inc.
    00-11-A5   # Fortuna Electronic Corp.
    00-11-A6   # Sypixx Networks
    00-11-A7   # Infilco Degremont Inc.
    00-11-A8   # Quest Technologies
    00-11-A9   # MOIMSTONE Co., LTD
    00-11-AA   # Uniclass Technology, Co., LTD
    00-11-AB   # TRUSTABLE TECHNOLOGY CO.,LTD.
    00-11-AC   # Simtec Electronics
    00-11-AD   # Shanghai Ruijie Technology
    00-11-AE   # ARRIS Group, Inc.
    00-11-AF   # Medialink-i,Inc
    00-11-B0   # Fortelink Inc.
    00-11-B1   # BlueExpert Technology Corp.
    00-11-B2   # 2001 Technology Inc.
    00-11-B3   # YOSHIMIYA CO.,LTD.
    00-11-B4   # Westermo Teleindustri AB
    00-11-B5   # Shenzhen Powercom Co.,Ltd
    00-11-B6   # Open Systems International
    00-11-B7   # Octalix B.V.
    00-11-B8   # Liebherr - Elektronik GmbH
    00-11-B9   # Inner Range Pty. Ltd.
    00-11-BA   # Elexol Pty Ltd
    00-11-BB   # Cisco Systems, Inc
    00-11-BC   # Cisco Systems, Inc
    00-11-BD   # Bombardier Transportation
    00-11-BE   # AGP Telecom Co. Ltd
    00-11-BF   # AESYS S.p.A.
    00-11-C0   # Aday Technology Inc
    00-11-C1   # 4P MOBILE DATA PROCESSING
    00-11-C2   # United Fiber Optic Communication
    00-11-C3   # Transceiving System Technology Corporation
    00-11-C4   # Terminales de Telecomunicacion Terrestre, S.L.
    00-11-C5   # TEN Technology
    00-11-C6   # Seagate Technology
    00-11-C7   # Raymarine UK Ltd
    00-11-C8   # Powercom Co., Ltd.
    00-11-C9   # MTT Corporation
    00-11-CA   # Long Range Systems, Inc.
    00-11-CB   # Jacobsons AB
    00-11-CC   # Guangzhou Jinpeng Group Co.,Ltd.
    00-11-CD   # Axsun Technologies
    00-11-CE   # Ubisense Limited
    00-11-CF   # Thrane & Thrane A/S
    00-11-D0   # Tandberg Data ASA
    00-11-D1   # Soft Imaging System GmbH
    00-11-D2   # Perception Digital Ltd
    00-11-D3   # NextGenTel Holding ASA
    00-11-D4   # NetEnrich, Inc
    00-11-D5   # Hangzhou Sunyard System Engineering Co.,Ltd.
    00-11-D6   # HandEra, Inc.
    00-11-D7   # eWerks Inc
    00-11-D8   # ASUSTek COMPUTER INC.
    00-11-D9   # TiVo
    00-11-DA   # Vivaas Technology Inc.
    00-11-DB   # Land-Cellular Corporation
    00-11-DC   # Glunz & Jensen
    00-11-DD   # FROMUS TEC. Co., Ltd.
    00-11-DE   # EURILOGIC
    00-11-DF   # Current Energy
    00-11-E0   # U-MEDIA Communications, Inc.
    00-11-E1   # Arcelik A.S
    00-11-E2   # Hua Jung Components Co., Ltd.
    00-11-E3   # Thomson, Inc.
    00-11-E4   # Danelec Electronics A/S
    00-11-E5   # KCodes Corporation
    00-11-E6   # Scientific Atlanta
    00-11-E7   # WORLDSAT - Texas de France
    00-11-E8   # Tixi.Com
    00-11-E9   # STARNEX CO., LTD.
    00-11-EA   # IWICS Inc.
    00-11-EB   # Innovative Integration
    00-11-EC   # AVIX INC.
    00-11-ED   # 802 Global
    00-11-EE   # Estari, Inc.
    00-11-EF   # Conitec Datensysteme GmbH
    00-11-F0   # Wideful Limited
    00-11-F1   # QinetiQ Ltd
    00-11-F2   # Institute of Network Technologies
    00-11-F3   # NeoMedia Europe AG
    00-11-F4   # woori-net
    00-11-F5   # ASKEY COMPUTER CORP
    00-11-F6   # Asia Pacific Microsystems , Inc.
    00-11-F7   # Shenzhen Forward Industry Co., Ltd
    00-11-F8   # AIRAYA Corp
    00-11-F9   # Nortel Networks
    00-11-FA   # Rane Corporation
    00-11-FB   # Heidelberg Engineering GmbH
    00-11-FC   # HARTING Electric Gmbh & Co.KG
    00-11-FD   # KORG INC.
    00-11-FE   # Keiyo System Research, Inc.
    00-11-FF   # Digitro Tecnologia Ltda
    00-12-00   # Cisco Systems, Inc
    00-12-01   # Cisco Systems, Inc
    00-12-02   # Decrane Aerospace - Audio International Inc.
    00-12-03   # ActivNetworks
    00-12-04   # u10 Networks, Inc.
    00-12-05   # Terrasat Communications, Inc.
    00-12-06   # iQuest (NZ) Ltd
    00-12-07   # Head Strong International Limited
    00-12-08   # Gantner Instruments GmbH
    00-12-09   # Fastrax Ltd
    00-12-0A   # Emerson Climate Technologies GmbH
    00-12-0B   # Chinasys Technologies Limited
    00-12-0C   # CE-Infosys Pte Ltd
    00-12-0D   # Advanced Telecommunication Technologies, Inc.
    00-12-0E   # AboCom
    00-12-0F   # IEEE 802.3
    00-12-10   # WideRay Corp
    00-12-11   # Protechna Herbst GmbH & Co. KG
    00-12-12   # PLUS  Corporation
    00-12-13   # Metrohm AG
    00-12-14   # Koenig & Bauer AG
    00-12-15   # iStor Networks, Inc.
    00-12-16   # ICP Internet Communication Payment AG
    00-12-17   # Cisco-Linksys, LLC
    00-12-18   # ARUZE Corporation
    00-12-19   # Ahead Communication Systems Inc
    00-12-1A   # Techno Soft Systemnics Inc.
    00-12-1B   # Sound Devices, LLC
    00-12-1C   # PARROT S.A.
    00-12-1D   # Netfabric Corporation
    00-12-1E   # Juniper Networks
    00-12-1F   # Harding Instruments
    00-12-20   # Cadco Systems
    00-12-21   # B.Braun Melsungen AG
    00-12-22   # Skardin (UK) Ltd
    00-12-23   # Pixim
    00-12-24   # NexQL Corporation
    00-12-25   # ARRIS Group, Inc.
    00-12-26   # Japan Direx Corporation
    00-12-27   # Franklin Electric Co., Inc.
    00-12-28   # Data Ltd.
    00-12-29   # BroadEasy Technologies Co.,Ltd
    00-12-2A   # VTech Telecommunications Ltd.
    00-12-2B   # Virbiage Pty Ltd
    00-12-2C   # Soenen Controls N.V.
    00-12-2D   # SiNett Corporation
    00-12-2E   # Signal Technology - AISD
    00-12-2F   # Sanei Electric Inc.
    00-12-30   # Picaso Infocommunication CO., LTD.
    00-12-31   # Motion Control Systems, Inc.
    00-12-32   # LeWiz Communications Inc.
    00-12-33   # JRC TOKKI Co.,Ltd.
    00-12-34   # Camille Bauer
    00-12-35   # Andrew Corporation
    00-12-36   # ConSentry Networks
    00-12-37   # Texas Instruments
    00-12-38   # SetaBox Technology Co., Ltd.
    00-12-39   # S Net Systems Inc.
    00-12-3A   # Posystech Inc., Co.
    00-12-3B   # KeRo Systems ApS
    00-12-3C   # Second Rule LLC
    00-12-3D   # GES Co, Ltd
    00-12-3E   # ERUNE technology Co., Ltd.
    00-12-3F   # Dell Inc.
    00-12-40   # AMOI ELECTRONICS CO.,LTD
    00-12-41   # a2i marketing center
    00-12-42   # Millennial Net
    00-12-43   # Cisco Systems, Inc
    00-12-44   # Cisco Systems, Inc
    00-12-45   # Zellweger Analytics, Inc.
    00-12-46   # T.O.M TECHNOLOGY INC..
    00-12-47   # Samsung Electronics Co., Ltd.
    00-12-48   # EMC Corporation (Kashya)
    00-12-49   # Delta Elettronica S.p.A.
    00-12-4A   # Dedicated Devices, Inc.
    00-12-4B   # Texas Instruments
    00-12-4C   # BBWM Corporation
    00-12-4D   # Inducon BV
    00-12-4E   # XAC AUTOMATION CORP.
    00-12-4F   # Pentair Thermal Management
    00-12-50   # Tokyo Aircaft Instrument Co., Ltd.
    00-12-51   # SILINK
    00-12-52   # Citronix, LLC
    00-12-53   # AudioDev AB
    00-12-54   # Spectra Technologies Holdings Company Ltd
    00-12-55   # NetEffect Incorporated
    00-12-56   # LG INFORMATION & COMM.
    00-12-57   # LeapComm Communication Technologies Inc.
    00-12-58   # Activis Polska
    00-12-59   # THERMO ELECTRON KARLSRUHE
    00-12-5A   # Microsoft Corporation
    00-12-5B   # KAIMEI ELECTRONI
    00-12-5C   # Green Hills Software, Inc.
    00-12-5D   # CyberNet Inc.
    00-12-5E   # CAEN
    00-12-5F   # AWIND Inc.
    00-12-60   # Stanton Magnetics,inc.
    00-12-61   # Adaptix, Inc
    00-12-62   # Nokia Danmark A/S
    00-12-63   # Data Voice Technologies GmbH
    00-12-64   # daum electronic gmbh
    00-12-65   # Enerdyne Technologies, Inc.
    00-12-66   # Swisscom Hospitality Services SA
    00-12-67   # Panasonic Corporation
    00-12-68   # IPS d.o.o.
    00-12-69   # Value Electronics
    00-12-6A   # OPTOELECTRONICS Co., Ltd.
    00-12-6B   # Ascalade Communications Limited
    00-12-6C   # Visonic Ltd.
    00-12-6D   # University of California, Berkeley
    00-12-6E   # Seidel Elektronik GmbH Nfg.KG
    00-12-6F   # Rayson Technology Co., Ltd.
    00-12-70   # NGES Denro Systems
    00-12-71   # Measurement Computing Corp
    00-12-72   # Redux Communications Ltd.
    00-12-73   # Stoke Inc
    00-12-74   # NIT lab
    00-12-75   # Sentilla Corporation
    00-12-76   # CG Power Systems Ireland Limited
    00-12-77   # Korenix Technologies Co., Ltd.
    00-12-78   # International Bar Code
    00-12-79   # Hewlett Packard
    00-12-7A   # Sanyu Industry Co.,Ltd.
    00-12-7B   # VIA Networking Technologies, Inc.
    00-12-7C   # SWEGON AB
    00-12-7D   # MobileAria
    00-12-7E   # Digital Lifestyles Group, Inc.
    00-12-7F   # Cisco Systems, Inc
    00-12-80   # Cisco Systems, Inc
    00-12-81   # March Networks S.p.A.
    00-12-82   # Qovia
    00-12-83   # Nortel Networks
    00-12-84   # Lab33 Srl
    00-12-85   # Gizmondo Europe Ltd
    00-12-86   # ENDEVCO CORP
    00-12-87   # Digital Everywhere Unterhaltungselektronik GmbH
    00-12-88   # 2Wire Inc
    00-12-89   # Advance Sterilization Products
    00-12-8A   # ARRIS Group, Inc.
    00-12-8B   # Sensory Networks Inc
    00-12-8C   # Woodward Governor
    00-12-8D   # STB Datenservice GmbH
    00-12-8E   # Q-Free ASA
    00-12-8F   # Montilio
    00-12-90   # KYOWA Electric & Machinery Corp.
    00-12-91   # KWS Computersysteme GmbH
    00-12-92   # Griffin Technology
    00-12-93   # GE Energy
    00-12-94   # SUMITOMO ELECTRIC DEVICE INNOVATIONS, INC
    00-12-95   # Aiware Inc.
    00-12-96   # Addlogix
    00-12-97   # O2Micro, Inc.
    00-12-98   # MICO ELECTRIC(SHENZHEN) LIMITED
    00-12-99   # Ktech Telecommunications Inc
    00-12-9A   # IRT Electronics Pty Ltd
    00-12-9B   # E2S Electronic Engineering Solutions, S.L.
    00-12-9C   # Yulinet
    00-12-9D   # First International Computer do Brasil
    00-12-9E   # Surf Communications Inc.
    00-12-9F   # RAE Systems
    00-12-A0   # NeoMeridian Sdn Bhd
    00-12-A1   # BluePacket Communications Co., Ltd.
    00-12-A2   # VITA
    00-12-A3   # Trust International B.V.
    00-12-A4   # ThingMagic, LLC
    00-12-A5   # Stargen, Inc.
    00-12-A6   # Dolby Australia
    00-12-A7   # ISR TECHNOLOGIES Inc
    00-12-A8   # intec GmbH
    00-12-A9   # 3Com Ltd
    00-12-AA   # IEE, Inc.
    00-12-AB   # WiLife, Inc.
    00-12-AC   # ONTIMETEK INC.
    00-12-AD   # IDS GmbH
    00-12-AE   # HLS HARD-LINE Solutions Inc.
    00-12-AF   # ELPRO Technologies
    00-12-B0   # Efore Oyj   (Plc)
    00-12-B1   # Dai Nippon Printing Co., Ltd
    00-12-B2   # AVOLITES LTD.
    00-12-B3   # Advance Wireless Technology Corp.
    00-12-B4   # Work Microwave GmbH
    00-12-B5   # Vialta, Inc.
    00-12-B6   # Santa Barbara Infrared, Inc.
    00-12-B7   # PTW Freiburg
    00-12-B8   # G2 Microsystems
    00-12-B9   # Fusion Digital Technology
    00-12-BA   # FSI Systems, Inc.
    00-12-BB   # Telecommunications Industry Association TR-41 Committee
    00-12-BC   # Echolab LLC
    00-12-BD   # Avantec Manufacturing Limited
    00-12-BE   # Astek Corporation
    00-12-BF   # Arcadyan Technology Corporation
    00-12-C0   # HotLava Systems, Inc.
    00-12-C1   # Check Point Software Technologies
    00-12-C2   # Apex Electronics Factory
    00-12-C3   # WIT S.A.
    00-12-C4   # Viseon, Inc.
    00-12-C5   # V-Show  Technology (China) Co.,Ltd
    00-12-C6   # TGC America, Inc
    00-12-C7   # SECURAY Technologies Ltd.Co.
    00-12-C8   # Perfect tech
    00-12-C9   # ARRIS Group, Inc.
    00-12-CA   # Mechatronic Brick Aps
    00-12-CB   # CSS Inc.
    00-12-CC   # Bitatek CO., LTD
    00-12-CD   # ASEM SpA
    00-12-CE   # Advanced Cybernetics Group
    00-12-CF   # Accton Technology Corp
    00-12-D0   # Gossen-Metrawatt-GmbH
    00-12-D1   # Texas Instruments
    00-12-D2   # Texas Instruments
    00-12-D3   # Zetta Systems, Inc.
    00-12-D4   # Princeton Technology, Ltd
    00-12-D5   # Motion Reality Inc.
    00-12-D6   # Jiangsu Yitong High-Tech Co.,Ltd
    00-12-D7   # Invento Networks, Inc.
    00-12-D8   # International Games System Co., Ltd.
    00-12-D9   # Cisco Systems, Inc
    00-12-DA   # Cisco Systems, Inc
    00-12-DB   # ZIEHL industrie-elektronik GmbH + Co KG
    00-12-DC   # SunCorp Industrial Limited
    00-12-DD   # Shengqu Information Technology (Shanghai) Co., Ltd.
    00-12-DE   # Radio Components Sweden AB
    00-12-DF   # Novomatic AG
    00-12-E0   # Codan Limited
    00-12-E1   # Alliant Networks, Inc
    00-12-E2   # ALAXALA Networks Corporation
    00-12-E3   # Agat-RT, Ltd.
    00-12-E4   # ZIEHL industrie-electronik GmbH + Co KG
    00-12-E5   # Time America, Inc.
    00-12-E6   # SPECTEC COMPUTER CO., LTD.
    00-12-E7   # Projectek Networking Electronics Corp.
    00-12-E8   # Fraunhofer IMS
    00-12-E9   # Abbey Systems Ltd
    00-12-EA   # Trane
    00-12-EB   # PDH Solutions, LLC
    00-12-EC   # Movacolor b.v.
    00-12-ED   # AVG Advanced Technologies
    00-12-EE   # Sony Mobile Communications AB
    00-12-EF   # OneAccess SA
    00-12-F0   # Intel Corporate
    00-12-F1   # IFOTEC
    00-12-F2   # Brocade Communications Systems, Inc.
    00-12-F3   # connectBlue AB
    00-12-F4   # Belco International Co.,Ltd.
    00-12-F5   # Imarda New Zealand Limited
    00-12-F6   # MDK CO.,LTD.
    00-12-F7   # Xiamen Xinglian Electronics Co., Ltd.
    00-12-F8   # WNI Resources, LLC
    00-12-F9   # URYU SEISAKU, LTD.
    00-12-FA   # THX LTD
    00-12-FB   # Samsung Electronics
    00-12-FC   # PLANET System Co.,LTD
    00-12-FD   # OPTIMUS IC S.A.
    00-12-FE   # Lenovo Mobile Communication Technology Ltd.
    00-12-FF   # Lely Industries N.V.
    00-13-00   # IT-FACTORY, INC.
    00-13-01   # IronGate S.L.
    00-13-02   # Intel Corporate
    00-13-03   # GateConnect
    00-13-04   # Flaircomm Technologies Co. LTD
    00-13-05   # Epicom, Inc.
    00-13-06   # Always On Wireless
    00-13-07   # Paravirtual Corporation
    00-13-08   # Nuvera Fuel Cells
    00-13-09   # Ocean Broadband Networks
    00-13-0A   # Nortel
    00-13-0B   # Mextal B.V.
    00-13-0C   # HF System Corporation
    00-13-0D   # GALILEO AVIONICA
    00-13-0E   # Focusrite Audio Engineering Limited
    00-13-0F   # EGEMEN Bilgisayar Muh San ve Tic LTD STI
    00-13-10   # Cisco-Linksys, LLC
    00-13-11   # ARRIS Group, Inc.
    00-13-12   # Amedia Networks Inc.
    00-13-13   # GuangZhou Post & Telecom Equipment ltd
    00-13-14   # Asiamajor Inc.
    00-13-15   # Sony Computer Entertainment Inc.
    00-13-16   # L-S-B Broadcast Technologies GmbH
    00-13-17   # GN Netcom as
    00-13-18   # DGSTATION Co., Ltd.
    00-13-19   # Cisco Systems, Inc
    00-13-1A   # Cisco Systems, Inc
    00-13-1B   # BeCell Innovations Corp.
    00-13-1C   # LiteTouch, Inc.
    00-13-1D   # Scanvaegt International A/S
    00-13-1E   # Peiker acustic GmbH & Co. KG
    00-13-1F   # NxtPhase T&D, Corp.
    00-13-20   # Intel Corporate
    00-13-21   # Hewlett Packard
    00-13-22   # DAQ Electronics, Inc.
    00-13-23   # Cap Co., Ltd.
    00-13-24   # Schneider Electric Ultra Terminal
    00-13-25   # Cortina Systems Inc
    00-13-26   # ECM Systems Ltd
    00-13-27   # Data Acquisitions limited
    00-13-28   # Westech Korea Inc.,
    00-13-29   # VSST Co., LTD
    00-13-2A   # Sitronics Telecom Solutions
    00-13-2B   # Phoenix Digital
    00-13-2C   # MAZ Brandenburg GmbH
    00-13-2D   # iWise Communications
    00-13-2E   # ITian Coporation
    00-13-2F   # Interactek
    00-13-30   # EURO PROTECTION SURVEILLANCE
    00-13-31   # CellPoint Connect
    00-13-32   # Beijing Topsec Network Security Technology Co., Ltd.
    00-13-33   # BaudTec Corporation
    00-13-34   # Arkados, Inc.
    00-13-35   # VS Industry Berhad
    00-13-36   # Tianjin 712 Communication Broadcasting co., ltd.
    00-13-37   # Orient Power Home Network Ltd.
    00-13-38   # FRESENIUS-VIAL
    00-13-39   # CCV Deutschland GmbH
    00-13-3A   # VadaTech Inc.
    00-13-3B   # Speed Dragon Multimedia Limited
    00-13-3C   # QUINTRON SYSTEMS INC.
    00-13-3D   # Micro Memory Curtiss Wright Co
    00-13-3E   # MetaSwitch
    00-13-3F   # Eppendorf Instrumente GmbH
    00-13-40   # AD.EL s.r.l.
    00-13-41   # Shandong New Beiyang Information Technology Co.,Ltd
    00-13-42   # Vision Research, Inc.
    00-13-43   # Matsushita Electronic Components (Europe) GmbH
    00-13-44   # Fargo Electronics Inc.
    00-13-45   # Eaton Corporation
    00-13-46   # D-Link Corporation
    00-13-47   # Red Lion Controls, LP
    00-13-48   # Artila Electronics Co., Ltd.
    00-13-49   # ZyXEL Communications Corporation
    00-13-4A   # Engim, Inc.
    00-13-4B   # ToGoldenNet Technology Inc.
    00-13-4C   # YDT Technology International
    00-13-4D   # Inepro BV
    00-13-4E   # Valox Systems, Inc.
    00-13-4F   # Tranzeo Wireless Technologies Inc.
    00-13-50   # Silver Spring Networks, Inc
    00-13-51   # Niles Audio Corporation
    00-13-52   # Naztec, Inc.
    00-13-53   # HYDAC Filtertechnik GMBH
    00-13-54   # Zcomax Technologies, Inc.
    00-13-55   # TOMEN Cyber-business Solutions, Inc.
    00-13-56   # FLIR Radiation Inc
    00-13-57   # Soyal Technology Co., Ltd.
    00-13-58   # Realm Systems, Inc.
    00-13-59   # ProTelevision Technologies A/S
    00-13-5A   # Project T&E Limited
    00-13-5B   # PanelLink Cinema, LLC
    00-13-5C   # OnSite Systems, Inc.
    00-13-5D   # NTTPC Communications, Inc.
    00-13-5E   # EAB/RWI/K
    00-13-5F   # Cisco Systems, Inc
    00-13-60   # Cisco Systems, Inc
    00-13-61   # Biospace Co., Ltd.
    00-13-62   # ShinHeung Precision Co., Ltd.
    00-13-63   # Verascape, Inc.
    00-13-64   # Paradigm Technology Inc..
    00-13-65   # Nortel
    00-13-66   # Neturity Technologies Inc.
    00-13-67   # Narayon. Co., Ltd.
    00-13-68   # Saab Danmark A/S
    00-13-69   # Honda Electron Co., LED.
    00-13-6A   # Hach Lange Sarl
    00-13-6B   # E-TEC
    00-13-6C   # TomTom
    00-13-6D   # Tentaculus AB
    00-13-6E   # Techmetro Corp.
    00-13-6F   # PacketMotion, Inc.
    00-13-70   # Nokia Danmark A/S
    00-13-71   # ARRIS Group, Inc.
    00-13-72   # Dell Inc.
    00-13-73   # BLwave Electronics Co., Ltd
    00-13-74   # Atheros Communications, Inc.
    00-13-75   # American Security Products Co.
    00-13-76   # Tabor Electronics Ltd.
    00-13-77   # Samsung Electronics CO., LTD
    00-13-78   # Qsan Technology, Inc.
    00-13-79   # PONDER INFORMATION INDUSTRIES LTD.
    00-13-7A   # Netvox Technology Co., Ltd.
    00-13-7B   # Movon Corporation
    00-13-7C   # Kaicom co., Ltd.
    00-13-7D   # Dynalab, Inc.
    00-13-7E   # CorEdge Networks, Inc.
    00-13-7F   # Cisco Systems, Inc
    00-13-80   # Cisco Systems, Inc
    00-13-81   # CHIPS & Systems, Inc.
    00-13-82   # Cetacea Networks Corporation
    00-13-83   # Application Technologies and Engineering Research Laboratory
    00-13-84   # Advanced Motion Controls
    00-13-85   # Add-On Technology Co., LTD.
    00-13-86   # ABB Inc./Totalflow
    00-13-87   # 27M Technologies AB
    00-13-88   # WiMedia Alliance
    00-13-89   # Redes de Telefonía Móvil S.A.
    00-13-8A   # QINGDAO GOERTEK ELECTRONICS CO.,LTD.
    00-13-8B   # Phantom Technologies LLC
    00-13-8C   # Kumyoung.Co.Ltd
    00-13-8D   # Kinghold
    00-13-8E   # FOAB Elektronik AB
    00-13-8F   # Asiarock Technology Limited
    00-13-90   # Termtek Computer Co., Ltd
    00-13-91   # OUEN CO.,LTD.
    00-13-92   # Ruckus Wireless
    00-13-93   # Panta Systems, Inc.
    00-13-94   # Infohand Co.,Ltd
    00-13-95   # congatec AG
    00-13-96   # Acbel Polytech Inc.
    00-13-97   # Oracle Corporation
    00-13-98   # TrafficSim Co.,Ltd
    00-13-99   # STAC Corporation.
    00-13-9A   # K-ubique ID Corp.
    00-13-9B   # ioIMAGE Ltd.
    00-13-9C   # Exavera Technologies, Inc.
    00-13-9D   # Marvell Hispana S.L.
    00-13-9E   # Ciara Technologies Inc.
    00-13-9F   # Electronics Design Services, Co., Ltd.
    00-13-A0   # ALGOSYSTEM Co., Ltd.
    00-13-A1   # Crow Electronic Engeneering
    00-13-A2   # MaxStream, Inc
    00-13-A3   # Siemens Com CPE Devices
    00-13-A4   # KeyEye Communications
    00-13-A5   # General Solutions, LTD.
    00-13-A6   # Extricom Ltd
    00-13-A7   # BATTELLE MEMORIAL INSTITUTE
    00-13-A8   # Tanisys Technology
    00-13-A9   # Sony Corporation
    00-13-AA   # ALS  & TEC Ltd.
    00-13-AB   # Telemotive AG
    00-13-AC   # Sunmyung Electronics Co., LTD
    00-13-AD   # Sendo Ltd
    00-13-AE   # Radiance Technologies, Inc.
    00-13-AF   # NUMA Technology,Inc.
    00-13-B0   # Jablotron
    00-13-B1   # Intelligent Control Systems (Asia) Pte Ltd
    00-13-B2   # Carallon Limited
    00-13-B3   # Ecom Communications Technology Co., Ltd.
    00-13-B4   # Appear TV
    00-13-B5   # Wavesat
    00-13-B6   # Sling Media, Inc.
    00-13-B7   # Scantech ID
    00-13-B8   # RyCo Electronic Systems Limited
    00-13-B9   # BM SPA
    00-13-BA   # ReadyLinks Inc
    00-13-BB   # Smartvue Corporation
    00-13-BC   # Artimi Ltd
    00-13-BD   # HYMATOM SA
    00-13-BE   # Virtual Conexions
    00-13-BF   # Media System Planning Corp.
    00-13-C0   # Trix Tecnologia Ltda.
    00-13-C1   # Asoka USA Corporation
    00-13-C2   # WACOM Co.,Ltd
    00-13-C3   # Cisco Systems, Inc
    00-13-C4   # Cisco Systems, Inc
    00-13-C5   # LIGHTRON FIBER-OPTIC DEVICES INC.
    00-13-C6   # OpenGear, Inc
    00-13-C7   # IONOS Co.,Ltd.
    00-13-C8   # ADB Broadband Italia
    00-13-C9   # Beyond Achieve Enterprises Ltd.
    00-13-CA   # Pico Digital
    00-13-CB   # Zenitel Norway AS
    00-13-CC   # Tall Maple Systems
    00-13-CD   # MTI co. LTD
    00-13-CE   # Intel Corporate
    00-13-CF   # 4Access Communications
    00-13-D0   # t+ Medical Ltd
    00-13-D1   # KIRK telecom A/S
    00-13-D2   # PAGE IBERICA, S.A.
    00-13-D3   # MICRO-STAR INTERNATIONAL CO., LTD.
    00-13-D4   # ASUSTek COMPUTER INC.
    00-13-D5   # RuggedCom
    00-13-D6   # TII NETWORK TECHNOLOGIES, INC.
    00-13-D7   # SPIDCOM Technologies SA
    00-13-D8   # Princeton Instruments
    00-13-D9   # Matrix Product Development, Inc.
    00-13-DA   # Diskware Co., Ltd
    00-13-DB   # SHOEI Electric Co.,Ltd
    00-13-DC   # IBTEK INC.
    00-13-DD   # Abbott Diagnostics
    00-13-DE   # Adapt4, LLC
    00-13-DF   # Ryvor Corp.
    00-13-E0   # Murata Manufacturing Co., Ltd.
    00-13-E1   # Iprobe AB
    00-13-E2   # GeoVision Inc.
    00-13-E3   # CoVi Technologies, Inc.
    00-13-E4   # YANGJAE SYSTEMS CORP.
    00-13-E5   # TENOSYS, INC.
    00-13-E6   # Technolution
    00-13-E7   # Halcro
    00-13-E8   # Intel Corporate
    00-13-E9   # VeriWave, Inc.
    00-13-EA   # Kamstrup A/S
    00-13-EB   # Sysmaster Corporation
    00-13-EC   # Netsnapper Technologies SARL
    00-13-ED   # PSIA
    00-13-EE   # JBX Designs Inc.
    00-13-EF   # Kingjon Digital Technology Co.,Ltd
    00-13-F0   # Wavefront Semiconductor
    00-13-F1   # AMOD Technology Co., Ltd.
    00-13-F2   # Klas Ltd
    00-13-F3   # Giga-byte Communications Inc.
    00-13-F4   # Psitek (Pty) Ltd
    00-13-F5   # Akimbi Systems
    00-13-F6   # Cintech
    00-13-F7   # SMC Networks, Inc.
    00-13-F8   # Dex Security Solutions
    00-13-F9   # Cavera Systems
    00-13-FA   # LifeSize Communications, Inc
    00-13-FB   # RKC INSTRUMENT INC.
    00-13-FC   # SiCortex, Inc
    00-13-FD   # Nokia Danmark A/S
    00-13-FE   # GRANDTEC ELECTRONIC CORP.
    00-13-FF   # Dage-MTI of MC, Inc.
    00-14-00   # MINERVA KOREA CO., LTD
    00-14-01   # Rivertree Networks Corp.
    00-14-02   # kk-electronic a/s
    00-14-03   # Renasis, LLC
    00-14-04   # ARRIS Group, Inc.
    00-14-05   # OpenIB, Inc.
    00-14-06   # Go Networks
    00-14-07   # Sperian Protection Instrumentation
    00-14-08   # Eka Systems Inc.
    00-14-09   # MAGNETI MARELLI   S.E. S.p.A.
    00-14-0A   # WEPIO Co., Ltd.
    00-14-0B   # FIRST INTERNATIONAL COMPUTER, INC.
    00-14-0C   # GKB CCTV CO., LTD.
    00-14-0D   # Nortel
    00-14-0E   # Nortel
    00-14-0F   # Federal State Unitary Enterprise Leningrad R&D Institute of
    00-14-10   # Suzhou Keda Technology CO.,Ltd
    00-14-11   # Deutschmann Automation GmbH & Co. KG
    00-14-12   # S-TEC electronics AG
    00-14-13   # Trebing & Himstedt Prozeßautomation GmbH & Co. KG
    00-14-14   # Jumpnode Systems LLC.
    00-14-15   # Intec Automation inc.
    00-14-16   # Scosche Industries, Inc.
    00-14-17   # RSE Informations Technologie GmbH
    00-14-18   # C4Line
    00-14-19   # SIDSA
    00-14-1A   # DEICY CORPORATION
    00-14-1B   # Cisco Systems, Inc
    00-14-1C   # Cisco Systems, Inc
    00-14-1D   # LTi DRIVES GmbH
    00-14-1E   # P.A. Semi, Inc.
    00-14-1F   # SunKwang Electronics Co., Ltd
    00-14-20   # G-Links networking company
    00-14-21   # Total Wireless Technologies Pte. Ltd.
    00-14-22   # Dell Inc.
    00-14-23   # J-S Co. NEUROCOM
    00-14-24   # Merry Electrics CO., LTD.
    00-14-25   # Galactic Computing Corp.
    00-14-26   # NL Technology
    00-14-27   # JazzMutant
    00-14-28   # Vocollect, Inc
    00-14-29   # V Center Technologies Co., Ltd.
    00-14-2A   # Elitegroup Computer System Co., Ltd
    00-14-2B   # Edata Communication Inc.
    00-14-2C   # Koncept International, Inc.
    00-14-2D   # Toradex AG
    00-14-2E   # 77 Elektronika Kft.
    00-14-2F   # Savvius
    00-14-30   # ViPowER, Inc
    00-14-31   # PDL Electronics Ltd
    00-14-32   # Tarallax Wireless, Inc.
    00-14-33   # Empower Technologies(Canada) Inc.
    00-14-34   # Keri Systems, Inc
    00-14-35   # CityCom Corp.
    00-14-36   # Qwerty Elektronik AB
    00-14-37   # GSTeletech Co.,Ltd.
    00-14-38   # Hewlett Packard
    00-14-39   # Blonder Tongue Laboratories, Inc.
    00-14-3A   # RAYTALK INTERNATIONAL SRL
    00-14-3B   # Sensovation AG
    00-14-3C   # Rheinmetall Canada Inc.
    00-14-3D   # Aevoe Inc.
    00-14-3E   # AirLink Communications, Inc.
    00-14-3F   # Hotway Technology Corporation
    00-14-40   # ATOMIC Corporation
    00-14-41   # Innovation Sound Technology Co., LTD.
    00-14-42   # ATTO CORPORATION
    00-14-43   # Consultronics Europe Ltd
    00-14-44   # Grundfos Holding
    00-14-45   # Telefon-Gradnja d.o.o.
    00-14-46   # SuperVision Solutions LLC
    00-14-47   # BOAZ Inc.
    00-14-48   # Inventec Multimedia & Telecom Corporation
    00-14-49   # Sichuan Changhong Electric Ltd.
    00-14-4A   # Taiwan Thick-Film Ind. Corp.
    00-14-4B   # Hifn, Inc.
    00-14-4C   # General Meters Corp.
    00-14-4D   # Intelligent Systems
    00-14-4E   # SRISA
    00-14-4F   # Oracle Corporation
    00-14-50   # Heim Systems GmbH
    00-14-51   # Apple, Inc.
    00-14-52   # CALCULEX,INC.
    00-14-53   # ADVANTECH TECHNOLOGIES CO.,LTD
    00-14-54   # Symwave
    00-14-55   # Coder Electronics Corporation
    00-14-56   # Edge Products
    00-14-57   # T-VIPS AS
    00-14-58   # HS Automatic ApS
    00-14-59   # Moram Co., Ltd.
    00-14-5A   # Neratec Solutions AG
    00-14-5B   # SeekerNet Inc.
    00-14-5C   # Intronics B.V.
    00-14-5D   # WJ Communications, Inc.
    00-14-5E   # IBM Corp
    00-14-5F   # ADITEC CO. LTD
    00-14-60   # Kyocera Wireless Corp.
    00-14-61   # CORONA CORPORATION
    00-14-62   # Digiwell Technology, inc
    00-14-63   # IDCS N.V.
    00-14-64   # Cryptosoft
    00-14-65   # Novo Nordisk A/S
    00-14-66   # Kleinhenz Elektronik GmbH
    00-14-67   # ArrowSpan Inc.
    00-14-68   # CelPlan International, Inc.
    00-14-69   # Cisco Systems, Inc
    00-14-6A   # Cisco Systems, Inc
    00-14-6B   # Anagran, Inc.
    00-14-6C   # NETGEAR
    00-14-6D   # RF Technologies
    00-14-6E   # H. Stoll GmbH & Co. KG
    00-14-6F   # Kohler Co
    00-14-70   # Prokom Software SA
    00-14-71   # Eastern Asia Technology Limited
    00-14-72   # China Broadband Wireless IP Standard Group
    00-14-73   # Bookham Inc
    00-14-74   # K40 Electronics
    00-14-75   # Wiline Networks, Inc.
    00-14-76   # MultiCom Industries Limited
    00-14-77   # Nertec  Inc.
    00-14-78   # ShenZhen TP-LINK Technologies Co., Ltd.
    00-14-79   # NEC Magnus Communications,Ltd.
    00-14-7A   # Eubus GmbH
    00-14-7B   # Iteris, Inc.
    00-14-7C   # 3Com Ltd
    00-14-7D   # Aeon Digital International
    00-14-7E   # InnerWireless
    00-14-7F   # Thomson Telecom Belgium
    00-14-80   # Hitachi-LG Data Storage Korea, Inc
    00-14-81   # Multilink Inc
    00-14-82   # Aurora Networks
    00-14-83   # eXS Inc.
    00-14-84   # Cermate Technologies Inc.
    00-14-85   # Giga-Byte
    00-14-86   # Echo Digital Audio Corporation
    00-14-87   # American Technology Integrators
    00-14-88   # Akorri
    00-14-89   # B15402100 - JANDEI, S.L.
    00-14-8A   # Elin Ebg Traction Gmbh
    00-14-8B   # Globo Electronic GmbH & Co. KG
    00-14-8C   # Fortress Technologies
    00-14-8D   # Cubic Defense Simulation Systems
    00-14-8E   # Tele Power Inc.
    00-14-8F   # Protronic (Far East) Ltd.
    00-14-90   # ASP Corporation
    00-14-91   # Daniels Electronics Ltd. dbo Codan Rado Communications
    00-14-92   # Liteon, Mobile Media Solution SBU
    00-14-93   # Systimax Solutions
    00-14-94   # ESU AG
    00-14-95   # 2Wire Inc
    00-14-96   # Phonic Corp.
    00-14-97   # ZHIYUAN Eletronics co.,ltd.
    00-14-98   # Viking Design Technology
    00-14-99   # Helicomm Inc
    00-14-9A   # ARRIS Group, Inc.
    00-14-9B   # Nokota Communications, LLC
    00-14-9C   # HF Company
    00-14-9D   # Sound ID Inc.
    00-14-9E   # UbONE Co., Ltd
    00-14-9F   # System and Chips, Inc.
    00-14-A0   # Accsense, Inc.
    00-14-A1   # Synchronous Communication Corp
    00-14-A2   # Core Micro Systems Inc.
    00-14-A3   # Vitelec BV
    00-14-A4   # Hon Hai Precision Ind. Co.,Ltd.
    00-14-A5   # Gemtek Technology Co., Ltd.
    00-14-A6   # Teranetics, Inc.
    00-14-A7   # Nokia Danmark A/S
    00-14-A8   # Cisco Systems, Inc
    00-14-A9   # Cisco Systems, Inc
    00-14-AA   # Ashly Audio, Inc.
    00-14-AB   # Senhai Electronic Technology Co., Ltd.
    00-14-AC   # Bountiful WiFi
    00-14-AD   # Gassner Wiege- und Meßtechnik GmbH
    00-14-AE   # Wizlogics Co., Ltd.
    00-14-AF   # Datasym POS Inc.
    00-14-B0   # Naeil Community
    00-14-B1   # Axell Wireless Limited
    00-14-B2   # mCubelogics Corporation
    00-14-B3   # CoreStar International Corp
    00-14-B4   # General Dynamics United Kingdom Ltd
    00-14-B5   # PHYSIOMETRIX,INC
    00-14-B6   # Enswer Technology Inc.
    00-14-B7   # AR Infotek Inc.
    00-14-B8   # Hill-Rom
    00-14-B9   # MSTAR SEMICONDUCTOR
    00-14-BA   # Carvers SA de CV
    00-14-BB   # Open Interface North America
    00-14-BC   # SYNECTIC TELECOM EXPORTS PVT. LTD.
    00-14-BD   # incNETWORKS, Inc
    00-14-BE   # Wink communication technology CO.LTD
    00-14-BF   # Cisco-Linksys, LLC
    00-14-C0   # Symstream Technology Group Ltd
    00-14-C1   # U.S. Robotics Corporation
    00-14-C2   # Hewlett Packard
    00-14-C3   # Seagate Technology
    00-14-C4   # Vitelcom Mobile Technology
    00-14-C5   # Alive Technologies Pty Ltd
    00-14-C6   # Quixant Ltd
    00-14-C7   # Nortel
    00-14-C8   # Contemporary Research Corp
    00-14-C9   # Brocade Communications Systems, Inc.
    00-14-CA   # Key Radio Systems Limited
    00-14-CB   # LifeSync Corporation
    00-14-CC   # Zetec, Inc.
    00-14-CD   # DigitalZone Co., Ltd.
    00-14-CE   # NF CORPORATION
    00-14-CF   # INVISIO Communications
    00-14-D0   # BTI Systems Inc.
    00-14-D1   # TRENDnet
    00-14-D2   # Kyuden Technosystems Corporation
    00-14-D3   # SEPSA
    00-14-D4   # K Technology Corporation
    00-14-D5   # Datang Telecom Technology CO. , LCD,Optical Communication Br
    00-14-D6   # Jeongmin Electronics Co.,Ltd.
    00-14-D7   # Datastore Technology Corp
    00-14-D8   # bio-logic SA
    00-14-D9   # IP Fabrics, Inc.
    00-14-DA   # Huntleigh Healthcare
    00-14-DB   # Elma Trenew Electronic GmbH
    00-14-DC   # Communication System Design & Manufacturing (CSDM)
    00-14-DD   # Covergence Inc.
    00-14-DE   # Sage Instruments Inc.
    00-14-DF   # HI-P Tech Corporation
    00-14-E0   # LET'S Corporation
    00-14-E1   # Data Display AG
    00-14-E2   # datacom systems inc.
    00-14-E3   # mm-lab GmbH
    00-14-E4   # infinias, LLC
    00-14-E5   # Alticast
    00-14-E6   # AIM Infrarotmodule GmbH
    00-14-E7   # Stolinx,. Inc
    00-14-E8   # ARRIS Group, Inc.
    00-14-E9   # Nortech International
    00-14-EA   # S Digm Inc. (Safe Paradigm Inc.)
    00-14-EB   # AwarePoint Corporation
    00-14-EC   # Acro Telecom
    00-14-ED   # Airak, Inc.
    00-14-EE   # Western Digital Technologies, Inc.
    00-14-EF   # TZero Technologies, Inc.
    00-14-F0   # Business Security OL AB
    00-14-F1   # Cisco Systems, Inc
    00-14-F2   # Cisco Systems, Inc
    00-14-F3   # ViXS Systems Inc
    00-14-F4   # DekTec Digital Video B.V.
    00-14-F5   # OSI Security Devices
    00-14-F6   # Juniper Networks
    00-14-F7   # CREVIS Co., LTD
    00-14-F8   # Scientific Atlanta
    00-14-F9   # Vantage Controls
    00-14-FA   # AsGa S.A.
    00-14-FB   # Technical Solutions Inc.
    00-14-FC   # Extandon, Inc.
    00-14-FD   # Thecus Technology Corp.
    00-14-FE   # Artech Electronics
    00-14-FF   # Precise Automation, Inc.
    00-15-00   # Intel Corporate
    00-15-01   # LexBox
    00-15-02   # BETA tech
    00-15-03   # PROFIcomms s.r.o.
    00-15-04   # GAME PLUS CO., LTD.
    00-15-05   # Actiontec Electronics, Inc
    00-15-06   # Neo Photonics
    00-15-07   # Renaissance Learning Inc
    00-15-08   # Global Target Enterprise Inc
    00-15-09   # Plus Technology Co., Ltd
    00-15-0A   # Sonoa Systems, Inc
    00-15-0B   # SAGE INFOTECH LTD.
    00-15-0C   # AVM GmbH
    00-15-0D   # Hoana Medical, Inc.
    00-15-0E   # OPENBRAIN TECHNOLOGIES CO., LTD.
    00-15-0F   # mingjong
    00-15-10   # Techsphere Co., Ltd
    00-15-11   # Data Center Systems
    00-15-12   # Zurich University of Applied Sciences
    00-15-13   # EFS sas
    00-15-14   # Hu Zhou NAVA Networks&Electronics Ltd.
    00-15-15   # Leipold+Co.GmbH
    00-15-16   # URIEL SYSTEMS INC.
    00-15-17   # Intel Corporate
    00-15-18   # Shenzhen 10MOONS Technology Development CO.,Ltd
    00-15-19   # StoreAge Networking Technologies
    00-15-1A   # Hunter Engineering Company
    00-15-1B   # Isilon Systems Inc.
    00-15-1C   # LENECO
    00-15-1D   # M2I CORPORATION
    00-15-1E   # Ethernet Powerlink Standardization Group (EPSG)
    00-15-1F   # Multivision Intelligent Surveillance (Hong Kong) Ltd
    00-15-20   # Radiocrafts AS
    00-15-21   # Horoquartz
    00-15-22   # Dea Security
    00-15-23   # Meteor Communications Corporation
    00-15-24   # Numatics, Inc.
    00-15-25   # Chamberlain Access Solutions
    00-15-26   # Remote Technologies Inc
    00-15-27   # Balboa Instruments
    00-15-28   # Beacon Medical Products LLC d.b.a. BeaconMedaes
    00-15-29   # N3 Corporation
    00-15-2A   # Nokia GmbH
    00-15-2B   # Cisco Systems, Inc
    00-15-2C   # Cisco Systems, Inc
    00-15-2D   # TenX Networks, LLC
    00-15-2E   # PacketHop, Inc.
    00-15-2F   # ARRIS Group, Inc.
    00-15-30   # EMC Corporation
    00-15-31   # KOCOM
    00-15-32   # Consumer Technologies Group, LLC
    00-15-33   # NADAM.CO.,LTD
    00-15-34   # A Beltrónica-Companhia de Comunicações, Lda
    00-15-35   # OTE Spa
    00-15-36   # Powertech co.,Ltd
    00-15-37   # Ventus Networks
    00-15-38   # RFID, Inc.
    00-15-39   # Technodrive srl
    00-15-3A   # Shenzhen Syscan Technology Co.,Ltd.
    00-15-3B   # EMH metering GmbH & Co. KG
    00-15-3C   # Kprotech Co., Ltd.
    00-15-3D   # ELIM PRODUCT CO.
    00-15-3E   # Q-Matic Sweden AB
    00-15-3F   # Alcatel Alenia Space Italia
    00-15-40   # Nortel
    00-15-41   # StrataLight Communications, Inc.
    00-15-42   # MICROHARD S.R.L.
    00-15-43   # Aberdeen Test Center
    00-15-44   # coM.s.a.t. AG
    00-15-45   # SEECODE Co., Ltd.
    00-15-46   # ITG Worldwide Sdn Bhd
    00-15-47   # AiZen Solutions Inc.
    00-15-48   # CUBE TECHNOLOGIES
    00-15-49   # Dixtal Biomedica Ind. Com. Ltda
    00-15-4A   # WANSHIH ELECTRONIC CO., LTD
    00-15-4B   # Wonde Proud Technology Co., Ltd
    00-15-4C   # Saunders Electronics
    00-15-4D   # Netronome Systems, Inc.
    00-15-4E   # IEC
    00-15-4F   # one RF Technology
    00-15-50   # Nits Technology Inc
    00-15-51   # RadioPulse Inc.
    00-15-52   # Wi-Gear Inc.
    00-15-53   # Cytyc Corporation
    00-15-54   # Atalum Wireless S.A.
    00-15-55   # DFM GmbH
    00-15-56   # Sagemcom Broadband SAS
    00-15-57   # Olivetti
    00-15-58   # FOXCONN
    00-15-59   # Securaplane Technologies, Inc.
    00-15-5A   # DAINIPPON PHARMACEUTICAL CO., LTD.
    00-15-5B   # Sampo Corporation
    00-15-5C   # Dresser Wayne
    00-15-5D   # Microsoft Corporation
    00-15-5E   # Morgan Stanley
    00-15-5F   # GreenPeak Technologies
    00-15-60   # Hewlett Packard
    00-15-61   # JJPlus Corporation
    00-15-62   # Cisco Systems, Inc
    00-15-63   # Cisco Systems, Inc
    00-15-64   # BEHRINGER Spezielle Studiotechnik GmbH
    00-15-65   # XIAMEN YEALINK NETWORK TECHNOLOGY CO.,LTD
    00-15-66   # A-First Technology Co., Ltd.
    00-15-67   # RADWIN Inc.
    00-15-68   # Dilithium Networks
    00-15-69   # PECO II, Inc.
    00-15-6A   # DG2L Technologies Pvt. Ltd.
    00-15-6B   # Perfisans Networks Corp.
    00-15-6C   # SANE SYSTEM CO., LTD
    00-15-6D   # Ubiquiti Networks Inc.
    00-15-6E   # A. W. Communication Systems Ltd
    00-15-6F   # Xiranet Communications GmbH
    00-15-70   # Zebra Technologies Inc
    00-15-71   # Nolan Systems
    00-15-72   # Red-Lemon
    00-15-73   # NewSoft  Technology Corporation
    00-15-74   # Horizon Semiconductors Ltd.
    00-15-75   # Nevis Networks Inc.
    00-15-76   # LABiTec - Labor Biomedical Technologies GmbH
    00-15-77   # Allied Telesis, Inc.
    00-15-78   # Audio / Video Innovations
    00-15-79   # Lunatone Industrielle Elektronik GmbH
    00-15-7A   # Telefin S.p.A.
    00-15-7B   # Leuze electronic GmbH + Co. KG
    00-15-7C   # Dave Networks, Inc.
    00-15-7D   # POSDATA CO., LTD.
    00-15-7E   # Weidmüller Interface GmbH & Co. KG
    00-15-7F   # ChuanG International Holding CO.,LTD.
    00-15-80   # U-WAY CORPORATION
    00-15-81   # MAKUS Inc.
    00-15-82   # Pulse Eight Limited
    00-15-83   # IVT corporation
    00-15-84   # Schenck Process GmbH
    00-15-85   # Aonvision Technolopy Corp.
    00-15-86   # Xiamen Overseas Chinese Electronic Co., Ltd.
    00-15-87   # Takenaka Seisakusho Co.,Ltd
    00-15-88   # Salutica Allied Solutions Sdn Bhd
    00-15-89   # D-MAX Technology Co.,Ltd
    00-15-8A   # SURECOM Technology Corp.
    00-15-8B   # Park Air Systems Ltd
    00-15-8C   # Liab ApS
    00-15-8D   # Jennic Ltd
    00-15-8E   # Plustek.INC
    00-15-8F   # NTT Advanced Technology Corporation
    00-15-90   # Hectronic GmbH
    00-15-91   # RLW Inc.
    00-15-92   # Facom UK Ltd (Melksham)
    00-15-93   # U4EA Technologies Inc.
    00-15-94   # BIXOLON CO.,LTD
    00-15-95   # Quester Tangent Corporation
    00-15-96   # ARRIS Group, Inc.
    00-15-97   # AETA AUDIO SYSTEMS
    00-15-98   # Kolektor group
    00-15-99   # Samsung Electronics Co., LTD
    00-15-9A   # ARRIS Group, Inc.
    00-15-9B   # Nortel
    00-15-9C   # B-KYUNG SYSTEM Co.,Ltd.
    00-15-9D   # Tripp Lite
    00-15-9E   # Mad Catz Interactive Inc
    00-15-9F   # Terascala, Inc.
    00-15-A0   # Nokia Danmark A/S
    00-15-A1   # ECA-SINTERS
    00-15-A2   # ARRIS Group, Inc.
    00-15-A3   # ARRIS Group, Inc.
    00-15-A4   # ARRIS Group, Inc.
    00-15-A5   # DCI Co., Ltd.
    00-15-A6   # Digital Electronics Products Ltd.
    00-15-A7   # Robatech AG
    00-15-A8   # ARRIS Group, Inc.
    00-15-A9   # KWANG WOO I&C CO.,LTD
    00-15-AA   # Rextechnik International Co.,
    00-15-AB   # PRO CO SOUND INC
    00-15-AC   # Capelon AB
    00-15-AD   # Accedian Networks
    00-15-AE   # kyung il
    00-15-AF   # AzureWave Technology Inc.
    00-15-B0   # AUTOTELENET CO.,LTD
    00-15-B1   # Ambient Corporation
    00-15-B2   # Advanced Industrial Computer, Inc.
    00-15-B3   # Caretech AB
    00-15-B4   # Polymap  Wireless LLC
    00-15-B5   # CI Network Corp.
    00-15-B6   # ShinMaywa Industries, Ltd.
    00-15-B7   # Toshiba
    00-15-B8   # Tahoe
    00-15-B9   # Samsung Electronics Co., Ltd.
    00-15-BA   # iba AG
    00-15-BB   # SMA Solar Technology AG
    00-15-BC   # Develco
    00-15-BD   # Group 4 Technology Ltd
    00-15-BE   # Iqua Ltd.
    00-15-BF   # technicob
    00-15-C0   # DIGITAL TELEMEDIA CO.,LTD.
    00-15-C1   # Sony Computer Entertainment Inc.
    00-15-C2   # 3M Germany
    00-15-C3   # Ruf Telematik AG
    00-15-C4   # FLOVEL CO., LTD.
    00-15-C5   # Dell Inc.
    00-15-C6   # Cisco Systems, Inc
    00-15-C7   # Cisco Systems, Inc
    00-15-C8   # FlexiPanel Ltd
    00-15-C9   # Gumstix, Inc
    00-15-CA   # TeraRecon, Inc.
    00-15-CB   # Surf Communication Solutions Ltd.
    00-15-CC   # UQUEST, LTD.
    00-15-CD   # Exartech International Corp.
    00-15-CE   # ARRIS Group, Inc.
    00-15-CF   # ARRIS Group, Inc.
    00-15-D0   # ARRIS Group, Inc.
    00-15-D1   # ARRIS Group, Inc.
    00-15-D2   # Xantech Corporation
    00-15-D3   # Pantech&Curitel Communications, Inc.
    00-15-D4   # Emitor AB
    00-15-D5   # NICEVT
    00-15-D6   # OSLiNK Sp. z o.o.
    00-15-D7   # Reti Corporation
    00-15-D8   # Interlink Electronics
    00-15-D9   # PKC Electronics Oy
    00-15-DA   # IRITEL A.D.
    00-15-DB   # Canesta Inc.
    00-15-DC   # KT&C Co., Ltd.
    00-15-DD   # IP Control Systems Ltd.
    00-15-DE   # Nokia Danmark A/S
    00-15-DF   # Clivet S.p.A.
    00-15-E0   # Ericsson
    00-15-E1   # Picochip Ltd
    00-15-E2   # Dr.Ing. Herbert Knauer GmbH
    00-15-E3   # Dream Technologies Corporation
    00-15-E4   # Zimmer Elektromedizin
    00-15-E5   # Cheertek Inc.
    00-15-E6   # MOBILE TECHNIKA Inc.
    00-15-E7   # Quantec Tontechnik
    00-15-E8   # Nortel
    00-15-E9   # D-Link Corporation
    00-15-EA   # Tellumat (Pty) Ltd
    00-15-EB   # zte corporation
    00-15-EC   # Boca Devices LLC
    00-15-ED   # Fulcrum Microsystems, Inc.
    00-15-EE   # Omnex Control Systems
    00-15-EF   # NEC TOKIN Corporation
    00-15-F0   # EGO BV
    00-15-F1   # KYLINK Communications Corp.
    00-15-F2   # ASUSTek COMPUTER INC.
    00-15-F3   # PELTOR AB
    00-15-F4   # Eventide
    00-15-F5   # Sustainable Energy Systems
    00-15-F6   # SCIENCE AND ENGINEERING SERVICES, INC.
    00-15-F7   # Wintecronics Ltd.
    00-15-F8   # Kingtronics Industrial Co. Ltd.
    00-15-F9   # Cisco Systems, Inc
    00-15-FA   # Cisco Systems, Inc
    00-15-FB   # setex schermuly textile computer gmbh
    00-15-FC   # Littelfuse Startco
    00-15-FD   # Complete Media Systems
    00-15-FE   # SCHILLING ROBOTICS LLC
    00-15-FF   # Novatel Wireless, Inc.
    00-16-00   # CelleBrite Mobile Synchronization
    00-16-01   # BUFFALO.INC
    00-16-02   # CEYON TECHNOLOGY CO.,LTD.
    00-16-03   # COOLKSKY Co., LTD
    00-16-04   # Sigpro
    00-16-05   # YORKVILLE SOUND INC.
    00-16-06   # Ideal Industries
    00-16-07   # Curves International Inc.
    00-16-08   # Sequans Communications
    00-16-09   # Unitech electronics co., ltd.
    00-16-0A   # SWEEX Europe BV
    00-16-0B   # TVWorks LLC
    00-16-0C   # LPL  DEVELOPMENT S.A. DE C.V
    00-16-0D   # Be Here Corporation
    00-16-0E   # Optica Technologies Inc.
    00-16-0F   # BADGER METER INC
    00-16-10   # Carina Technology
    00-16-11   # Altecon Srl
    00-16-12   # Otsuka Electronics Co., Ltd.
    00-16-13   # LibreStream Technologies Inc.
    00-16-14   # Picosecond Pulse Labs
    00-16-15   # Nittan Company, Limited
    00-16-16   # BROWAN COMMUNICATION INC.
    00-16-17   # MSI
    00-16-18   # HIVION Co., Ltd.
    00-16-19   # Lancelan Technologies S.L.
    00-16-1A   # Dametric AB
    00-16-1B   # Micronet Corporation
    00-16-1C   # e:cue
    00-16-1D   # Innovative Wireless Technologies, Inc.
    00-16-1E   # Woojinnet
    00-16-1F   # SUNWAVETEC Co., Ltd.
    00-16-20   # Sony Mobile Communications AB
    00-16-21   # Colorado Vnet
    00-16-22   # BBH SYSTEMS GMBH
    00-16-23   # Interval Media
    00-16-24   # Teneros, Inc.
    00-16-25   # Impinj, Inc.
    00-16-26   # ARRIS Group, Inc.
    00-16-27   # embedded-logic DESIGN AND MORE GmbH
    00-16-28   # Ultra Electronics Manufacturing and Card Systems
    00-16-29   # Nivus GmbH
    00-16-2A   # Antik computers & communications s.r.o.
    00-16-2B   # Togami Electric Mfg.co.,Ltd.
    00-16-2C   # Xanboo
    00-16-2D   # STNet Co., Ltd.
    00-16-2E   # Space Shuttle Hi-Tech Co., Ltd.
    00-16-2F   # Geutebrück GmbH
    00-16-30   # Vativ Technologies
    00-16-31   # Xteam
    00-16-32   # SAMSUNG ELECTRONICS CO., LTD.
    00-16-33   # Oxford Diagnostics Ltd.
    00-16-34   # Mathtech, Inc.
    00-16-35   # Hewlett Packard
    00-16-36   # Quanta Computer Inc.
    00-16-37   # CITEL SpA
    00-16-38   # TECOM Co., Ltd.
    00-16-39   # UBIQUAM Co.,Ltd
    00-16-3A   # YVES TECHNOLOGY CO., LTD.
    00-16-3B   # VertexRSI/General Dynamics
    00-16-3C   # Rebox B.V.
    00-16-3D   # Tsinghua Tongfang Legend Silicon Tech. Co., Ltd.
    00-16-3E   # Xensource, Inc.
    00-16-3F   # CReTE SYSTEMS Inc.
    00-16-40   # Asmobile Communication Inc.
    00-16-41   # Universal Global Scientific Industrial Co., Ltd.
    00-16-42   # Pangolin
    00-16-43   # Sunhillo Corporation
    00-16-44   # LITE-ON Technology Corp.
    00-16-45   # Power Distribution, Inc.
    00-16-46   # Cisco Systems, Inc
    00-16-47   # Cisco Systems, Inc
    00-16-48   # SSD Company Limited
    00-16-49   # SetOne GmbH
    00-16-4A   # Vibration Technology Limited
    00-16-4B   # Quorion Data Systems GmbH
    00-16-4C   # PLANET INT Co., Ltd
    00-16-4D   # Alcatel North America IP Division
    00-16-4E   # Nokia Danmark A/S
    00-16-4F   # World Ethnic Broadcastin Inc.
    00-16-50   # Herley General Microwave Israel.
    00-16-51   # Exeo Systems
    00-16-52   # Hoatech Technologies, Inc.
    00-16-53   # LEGO System A/S IE Electronics Division
    00-16-54   # Flex-P Industries Sdn. Bhd.
    00-16-55   # FUHO TECHNOLOGY Co., LTD
    00-16-56   # Nintendo Co., Ltd.
    00-16-57   # Aegate Ltd
    00-16-58   # Fusiontech Technologies Inc.
    00-16-59   # Z.M.P. RADWAG
    00-16-5A   # Harman Specialty Group
    00-16-5B   # Grip Audio
    00-16-5C   # Trackflow Ltd
    00-16-5D   # AirDefense, Inc.
    00-16-5E   # Precision I/O
    00-16-5F   # Fairmount Automation
    00-16-60   # Nortel
    00-16-61   # Novatium Solutions (P) Ltd
    00-16-62   # Liyuh Technology Ltd.
    00-16-63   # KBT Mobile
    00-16-64   # Prod-El SpA
    00-16-65   # Cellon France
    00-16-66   # Quantier Communication Inc.
    00-16-67   # A-TEC Subsystem INC.
    00-16-68   # Eishin Electronics
    00-16-69   # MRV Communication (Networks) LTD
    00-16-6A   # TPS
    00-16-6B   # Samsung Electronics
    00-16-6C   # Samsung Electonics Digital Video System Division
    00-16-6D   # Yulong Computer Telecommunication Scientific(shenzhen)Co.,Lt
    00-16-6E   # Arbitron Inc.
    00-16-6F   # Intel Corporate
    00-16-70   # SKNET Corporation
    00-16-71   # Symphox Information Co.
    00-16-72   # Zenway enterprise ltd
    00-16-73   # Bury GmbH & Co. KG
    00-16-74   # EuroCB (Phils.), Inc.
    00-16-75   # ARRIS Group, Inc.
    00-16-76   # Intel Corporate
    00-16-77   # Bihl + Wiedemann GmbH
    00-16-78   # SHENZHEN BAOAN GAOKE ELECTRONICS CO., LTD
    00-16-79   # eOn Communications
    00-16-7A   # Skyworth Overseas Dvelopment Ltd.
    00-16-7B   # Haver&Boecker
    00-16-7C   # iRex Technologies BV
    00-16-7D   # Sky-Line Information Co., Ltd.
    00-16-7E   # DIBOSS.CO.,LTD
    00-16-7F   # Bluebird Soft Inc.
    00-16-80   # Bally Gaming + Systems
    00-16-81   # Vector Informatik GmbH
    00-16-82   # Pro Dex, Inc
    00-16-83   # WEBIO International Co.,.Ltd.
    00-16-84   # Donjin Co.,Ltd.
    00-16-85   # Elisa Oyj
    00-16-86   # Karl Storz Imaging
    00-16-87   # Chubb CSC-Vendor AP
    00-16-88   # ServerEngines LLC
    00-16-89   # Pilkor Electronics Co., Ltd
    00-16-8A   # id-Confirm Inc
    00-16-8B   # Paralan Corporation
    00-16-8C   # DSL Partner AS
    00-16-8D   # KORWIN CO., Ltd.
    00-16-8E   # Vimicro corporation
    00-16-8F   # GN Netcom as
    00-16-90   # J-TEK INCORPORATION
    00-16-91   # Moser-Baer AG
    00-16-92   # Scientific-Atlanta, Inc.
    00-16-93   # PowerLink Technology Inc.
    00-16-94   # Sennheiser Communications A/S
    00-16-95   # AVC Technology (International) Limited
    00-16-96   # QDI Technology (H.K.) Limited
    00-16-97   # NEC Corporation
    00-16-98   # T&A Mobile Phones
    00-16-99   # Tonic DVB Marketing Ltd
    00-16-9A   # Quadrics Ltd
    00-16-9B   # Alstom Transport
    00-16-9C   # Cisco Systems, Inc
    00-16-9D   # Cisco Systems, Inc
    00-16-9E   # TV One Ltd
    00-16-9F   # Vimtron Electronics Co., Ltd.
    00-16-A0   # Auto-Maskin
    00-16-A1   # 3Leaf Networks
    00-16-A2   # CentraLite Systems, Inc.
    00-16-A3   # Ingeteam Transmission&Distribution, S.A.
    00-16-A4   # Ezurio Ltd
    00-16-A5   # Tandberg Storage ASA
    00-16-A6   # Dovado FZ-LLC
    00-16-A7   # AWETA G&P
    00-16-A8   # CWT CO., LTD.
    00-16-A9   # 2EI
    00-16-AA   # Kei Communication Technology Inc.
    00-16-AB   # Dansensor A/S
    00-16-AC   # Toho Technology Corp.
    00-16-AD   # BT-Links Company Limited
    00-16-AE   # INVENTEL
    00-16-AF   # Shenzhen Union Networks Equipment Co.,Ltd.
    00-16-B0   # VK Corporation
    00-16-B1   # KBS
    00-16-B2   # DriveCam Inc
    00-16-B3   # Photonicbridges (China) Co., Ltd.
    00-16-B4   # Private
    00-16-B5   # ARRIS Group, Inc.
    00-16-B6   # Cisco-Linksys, LLC
    00-16-B7   # Seoul Commtech
    00-16-B8   # Sony Mobile Communications AB
    00-16-B9   # ProCurve Networking
    00-16-BA   # WEATHERNEWS INC.
    00-16-BB   # Law-Chain Computer Technology Co Ltd
    00-16-BC   # Nokia Danmark A/S
    00-16-BD   # ATI Industrial Automation
    00-16-BE   # INFRANET, Inc.
    00-16-BF   # PaloDEx Group Oy
    00-16-C0   # Semtech Corporation
    00-16-C1   # Eleksen Ltd
    00-16-C2   # Avtec Systems Inc
    00-16-C3   # BA Systems Inc
    00-16-C4   # SiRF Technology, Inc.
    00-16-C5   # Shenzhen Xing Feng Industry Co.,Ltd
    00-16-C6   # North Atlantic Industries
    00-16-C7   # Cisco Systems, Inc
    00-16-C8   # Cisco Systems, Inc
    00-16-C9   # NAT Seattle, Inc.
    00-16-CA   # Nortel
    00-16-CB   # Apple, Inc.
    00-16-CC   # Xcute Mobile Corp.
    00-16-CD   # HIJI HIGH-TECH CO., LTD.
    00-16-CE   # Hon Hai Precision Ind. Co.,Ltd.
    00-16-CF   # Hon Hai Precision Ind. Co.,Ltd.
    00-16-D0   # ATech elektronika d.o.o.
    00-16-D1   # ZAT a.s.
    00-16-D2   # Caspian
    00-16-D3   # Wistron Corporation
    00-16-D4   # Compal Communications, Inc.
    00-16-D5   # Synccom Co., Ltd
    00-16-D6   # TDA Tech Pty Ltd
    00-16-D7   # Sunways AG
    00-16-D8   # Senea AB
    00-16-D9   # NINGBO BIRD CO.,LTD.
    00-16-DA   # Futronic Technology Co. Ltd.
    00-16-DB   # Samsung Electronics Co., Ltd.
    00-16-DC   # ARCHOS
    00-16-DD   # Gigabeam Corporation
    00-16-DE   # FAST Inc
    00-16-DF   # Lundinova AB
    00-16-E0   # 3Com Ltd
    00-16-E1   # SiliconStor, Inc.
    00-16-E2   # American Fibertek, Inc.
    00-16-E3   # ASKEY COMPUTER CORP
    00-16-E4   # VANGUARD SECURITY ENGINEERING CORP.
    00-16-E5   # FORDLEY DEVELOPMENT LIMITED
    00-16-E6   # GIGA-BYTE TECHNOLOGY CO.,LTD.
    00-16-E7   # Dynamix Promotions Limited
    00-16-E8   # Sigma Designs, Inc.
    00-16-E9   # Tiba Medical Inc
    00-16-EA   # Intel Corporate
    00-16-EB   # Intel Corporate
    00-16-EC   # Elitegroup Computer Systems Co., Ltd.
    00-16-ED   # Digital Safety Technologies, Inc
    00-16-EE   # Royaldigital Inc.
    00-16-EF   # Koko Fitness, Inc.
    00-16-F0   # Dell
    00-16-F1   # OmniSense, LLC
    00-16-F2   # Dmobile System Co., Ltd.
    00-16-F3   # CAST Information Co., Ltd
    00-16-F4   # Eidicom Co., Ltd.
    00-16-F5   # Dalian Golden Hualu Digital Technology Co.,Ltd
    00-16-F6   # Video Products Group
    00-16-F7   # L-3 Communications, Aviation Recorders
    00-16-F8   # AVIQTECH TECHNOLOGY CO., LTD.
    00-16-F9   # CETRTA POT, d.o.o., Kranj
    00-16-FA   # ECI Telecom Ltd.
    00-16-FB   # SHENZHEN MTC CO.,LTD.
    00-16-FC   # TOHKEN CO.,LTD.
    00-16-FD   # Jaty Electronics
    00-16-FE   # ALPS ELECTRIC CO.,LTD.
    00-16-FF   # Wamin Optocomm Mfg Corp
    00-17-00   # ARRIS Group, Inc.
    00-17-01   # KDE, Inc.
    00-17-02   # Osung Midicom Co., Ltd
    00-17-03   # MOSDAN Internation Co.,Ltd
    00-17-04   # Shinco Electronics Group Co.,Ltd
    00-17-05   # Methode Electronics
    00-17-06   # Techfaith Wireless Communication Technology Limited.
    00-17-07   # InGrid, Inc
    00-17-08   # Hewlett Packard
    00-17-09   # Exalt Communications
    00-17-0A   # INEW DIGITAL COMPANY
    00-17-0B   # Contela, Inc.
    00-17-0C   # Twig Com Ltd.
    00-17-0D   # Dust Networks Inc.
    00-17-0E   # Cisco Systems, Inc
    00-17-0F   # Cisco Systems, Inc
    00-17-10   # Casa Systems Inc.
    00-17-11   # GE Healthcare Bio-Sciences AB
    00-17-12   # ISCO International
    00-17-13   # Tiger NetCom
    00-17-14   # BR Controls Nederland bv
    00-17-15   # Qstik
    00-17-16   # Qno Technology Inc.
    00-17-17   # Leica Geosystems AG
    00-17-18   # Vansco Electronics Oy
    00-17-19   # Audiocodes USA, Inc
    00-17-1A   # Winegard Company
    00-17-1B   # Innovation Lab Corp.
    00-17-1C   # NT MicroSystems, Inc.
    00-17-1D   # DIGIT
    00-17-1E   # Theo Benning GmbH & Co. KG
    00-17-1F   # IMV Corporation
    00-17-20   # Image Sensing Systems, Inc.
    00-17-21   # FITRE S.p.A.
    00-17-22   # Hanazeder Electronic GmbH
    00-17-23   # Summit Data Communications
    00-17-24   # Studer Professional Audio GmbH
    00-17-25   # Liquid Computing
    00-17-26   # m2c Electronic Technology Ltd.
    00-17-27   # Thermo Ramsey Italia s.r.l.
    00-17-28   # Selex Communications
    00-17-29   # Ubicod Co.LTD
    00-17-2A   # Proware Technology Corp.(By Unifosa)
    00-17-2B   # Global Technologies Inc.
    00-17-2C   # TAEJIN INFOTECH
    00-17-2D   # Axcen Photonics Corporation
    00-17-2E   # FXC Inc.
    00-17-2F   # NeuLion Incorporated
    00-17-30   # Automation Electronics
    00-17-31   # ASUSTek COMPUTER INC.
    00-17-32   # Science-Technical Center RISSA
    00-17-33   # SFR
    00-17-34   # ADC Telecommunications
    00-17-35   # Intel Wireless Network Group
    00-17-36   # iiTron Inc.
    00-17-37   # Industrie Dial Face S.p.A.
    00-17-38   # International Business Machines
    00-17-39   # Bright Headphone Electronics Company
    00-17-3A   # Reach Systems Inc.
    00-17-3B   # Cisco Systems, Inc
    00-17-3C   # Extreme Engineering Solutions
    00-17-3D   # Neology
    00-17-3E   # LeucotronEquipamentos Ltda.
    00-17-3F   # Belkin International Inc.
    00-17-40   # Bluberi Gaming Technologies Inc
    00-17-41   # DEFIDEV
    00-17-42   # FUJITSU LIMITED
    00-17-43   # Deck Srl
    00-17-44   # Araneo Ltd.
    00-17-45   # INNOTZ CO., Ltd
    00-17-46   # Freedom9 Inc.
    00-17-47   # Trimble
    00-17-48   # Neokoros Brasil Ltda
    00-17-49   # HYUNDAE YONG-O-SA CO.,LTD
    00-17-4A   # SOCOMEC
    00-17-4B   # Nokia Danmark A/S
    00-17-4C   # Millipore
    00-17-4D   # DYNAMIC NETWORK FACTORY, INC.
    00-17-4E   # Parama-tech Co.,Ltd.
    00-17-4F   # iCatch Inc.
    00-17-50   # GSI Group, MicroE Systems
    00-17-51   # Online Corporation
    00-17-52   # DAGS, Inc
    00-17-53   # nFore Technology Inc.
    00-17-54   # Arkino HiTOP Corporation Limited
    00-17-55   # GE Security
    00-17-56   # Vinci Labs Oy
    00-17-57   # RIX TECHNOLOGY LIMITED
    00-17-58   # ThruVision Ltd
    00-17-59   # Cisco Systems, Inc
    00-17-5A   # Cisco Systems, Inc
    00-17-5B   # ACS Solutions Switzerland Ltd.
    00-17-5C   # SHARP CORPORATION
    00-17-5D   # Dongseo system.
    00-17-5E   # Zed-3
    00-17-5F   # XENOLINK Communications Co., Ltd.
    00-17-60   # Naito Densei Machida MFG.CO.,LTD
    00-17-61   # Private
    00-17-62   # Solar Technology, Inc.
    00-17-63   # Essentia S.p.A.
    00-17-64   # ATMedia GmbH
    00-17-65   # Nortel
    00-17-66   # Accense Technology, Inc.
    00-17-67   # Earforce AS
    00-17-68   # Zinwave Ltd
    00-17-69   # Cymphonix Corp
    00-17-6A   # Avago Technologies
    00-17-6B   # Kiyon, Inc.
    00-17-6C   # Pivot3, Inc.
    00-17-6D   # CORE CORPORATION
    00-17-6E   # DUCATI SISTEMI
    00-17-6F   # PAX Computer Technology(Shenzhen) Ltd.
    00-17-70   # Arti Industrial Electronics Ltd.
    00-17-71   # APD Communications Ltd
    00-17-72   # ASTRO Strobel Kommunikationssysteme GmbH
    00-17-73   # Laketune Technologies Co. Ltd
    00-17-74   # Elesta GmbH
    00-17-75   # TTE Germany GmbH
    00-17-76   # Meso Scale Diagnostics, LLC
    00-17-77   # Obsidian Research Corporation
    00-17-78   # Central Music Co.
    00-17-79   # QuickTel
    00-17-7A   # ASSA ABLOY AB
    00-17-7B   # Azalea Networks inc
    00-17-7C   # Smartlink Network Systems Limited
    00-17-7D   # IDT International Limited
    00-17-7E   # Meshcom Technologies Inc.
    00-17-7F   # Worldsmart Retech
    00-17-80   # Applied Biosystems B.V.
    00-17-81   # Greystone Data System, Inc.
    00-17-82   # LoBenn Inc.
    00-17-83   # Texas Instruments
    00-17-84   # ARRIS Group, Inc.
    00-17-85   # Sparr Electronics Ltd
    00-17-86   # wisembed
    00-17-87   # Brother, Brother & Sons ApS
    00-17-88   # Philips Lighting BV
    00-17-89   # Zenitron Corporation
    00-17-8A   # DARTS TECHNOLOGIES CORP.
    00-17-8B   # Teledyne Technologies Incorporated
    00-17-8C   # Independent Witness, Inc
    00-17-8D   # Checkpoint Systems, Inc.
    00-17-8E   # Gunnebo Cash Automation AB
    00-17-8F   # NINGBO YIDONG ELECTRONIC CO.,LTD.
    00-17-90   # HYUNDAI DIGITECH Co, Ltd.
    00-17-91   # LinTech GmbH
    00-17-92   # Falcom Wireless Comunications Gmbh
    00-17-93   # Tigi Corporation
    00-17-94   # Cisco Systems, Inc
    00-17-95   # Cisco Systems, Inc
    00-17-96   # Rittmeyer AG
    00-17-97   # Telsy Elettronica S.p.A.
    00-17-98   # Azonic Technology Co., LTD
    00-17-99   # SmarTire Systems Inc.
    00-17-9A   # D-Link Corporation
    00-17-9B   # Chant Sincere CO., LTD.
    00-17-9C   # DEPRAG SCHULZ GMBH u. CO.
    00-17-9D   # Kelman Limited
    00-17-9E   # Sirit Inc
    00-17-9F   # Apricorn
    00-17-A0   # RoboTech srl
    00-17-A1   # 3soft inc.
    00-17-A2   # Camrivox Ltd.
    00-17-A3   # MIX s.r.l.
    00-17-A4   # Hewlett Packard
    00-17-A5   # Ralink Technology Corp
    00-17-A6   # YOSIN ELECTRONICS CO., LTD.
    00-17-A7   # Mobile Computing Promotion Consortium
    00-17-A8   # EDM Corporation
    00-17-A9   # Sentivision
    00-17-AA   # elab-experience inc.
    00-17-AB   # Nintendo Co., Ltd.
    00-17-AC   # O'Neil Product Development Inc.
    00-17-AD   # AceNet Corporation
    00-17-AE   # GAI-Tronics
    00-17-AF   # Enermet
    00-17-B0   # Nokia Danmark A/S
    00-17-B1   # ACIST Medical Systems, Inc.
    00-17-B2   # SK Telesys
    00-17-B3   # Aftek Infosys Limited
    00-17-B4   # Remote Security Systems, LLC
    00-17-B5   # Peerless Systems Corporation
    00-17-B6   # Aquantia
    00-17-B7   # Tonze Technology Co.
    00-17-B8   # NOVATRON CO., LTD.
    00-17-B9   # Gambro Lundia AB
    00-17-BA   # SEDO CO., LTD.
    00-17-BB   # Syrinx Industrial Electronics
    00-17-BC   # Touchtunes Music Corporation
    00-17-BD   # Tibetsystem
    00-17-BE   # Tratec Telecom B.V.
    00-17-BF   # Coherent Research Limited
    00-17-C0   # PureTech Systems, Inc.
    00-17-C1   # CM Precision Technology LTD.
    00-17-C2   # ADB Broadband Italia
    00-17-C3   # KTF Technologies Inc.
    00-17-C4   # Quanta Microsystems, INC.
    00-17-C5   # SonicWALL
    00-17-C6   # Cross Match Technologies Inc
    00-17-C7   # MARA Systems Consulting AB
    00-17-C8   # KYOCERA Document Solutions Inc.
    00-17-C9   # Samsung Electronics Co., Ltd.
    00-17-CA   # Qisda Corporation
    00-17-CB   # Juniper Networks
    00-17-CC   # Alcatel-Lucent
    00-17-CD   # CEC Wireless R&D Ltd.
    00-17-CE   # Screen Service Spa
    00-17-CF   # iMCA-GmbH
    00-17-D0   # Opticom Communications, LLC
    00-17-D1   # Nortel
    00-17-D2   # THINLINX PTY LTD
    00-17-D3   # Etymotic Research, Inc.
    00-17-D4   # Monsoon Multimedia, Inc
    00-17-D5   # Samsung Electronics Co., Ltd.
    00-17-D6   # Bluechips Microhouse Co.,Ltd.
    00-17-D7   # ION Geophysical Corporation Inc.
    00-17-D8   # Magnum Semiconductor, Inc.
    00-17-D9   # AAI Corporation
    00-17-DA   # Spans Logic
    00-17-DB   # CANKO TECHNOLOGIES INC.
    00-17-DC   # DAEMYUNG ZERO1
    00-17-DD   # Clipsal Australia
    00-17-DE   # Advantage Six Ltd
    00-17-DF   # Cisco Systems, Inc
    00-17-E0   # Cisco Systems, Inc
    00-17-E1   # DACOS Technologies Co., Ltd.
    00-17-E2   # ARRIS Group, Inc.
    00-17-E3   # Texas Instruments
    00-17-E4   # Texas Instruments
    00-17-E5   # Texas Instruments
    00-17-E6   # Texas Instruments
    00-17-E7   # Texas Instruments
    00-17-E8   # Texas Instruments
    00-17-E9   # Texas Instruments
    00-17-EA   # Texas Instruments
    00-17-EB   # Texas Instruments
    00-17-EC   # Texas Instruments
    00-17-ED   # WooJooIT Ltd.
    00-17-EE   # ARRIS Group, Inc.
    00-17-EF   # IBM Corp
    00-17-F0   # SZCOM Broadband Network Technology Co.,Ltd
    00-17-F1   # Renu Electronics Pvt Ltd
    00-17-F2   # Apple, Inc.
    00-17-F3   # Harris Corparation
    00-17-F4   # ZERON ALLIANCE
    00-17-F5   # LIG NEOPTEK
    00-17-F6   # Pyramid Meriden Inc.
    00-17-F7   # CEM Solutions Pvt Ltd
    00-17-F8   # Motech Industries Inc.
    00-17-F9   # Forcom Sp. z o.o.
    00-17-FA   # Microsoft Corporation
    00-17-FB   # FA
    00-17-FC   # Suprema Inc.
    00-17-FD   # Amulet Hotkey
    00-17-FE   # TALOS SYSTEM INC.
    00-17-FF   # PLAYLINE Co.,Ltd.
    00-18-00   # UNIGRAND LTD
    00-18-01   # Actiontec Electronics, Inc
    00-18-02   # Alpha Networks Inc.
    00-18-03   # ArcSoft Shanghai Co. LTD
    00-18-04   # E-TEK DIGITAL TECHNOLOGY LIMITED
    00-18-05   # Beijing InHand Networking Technology Co.,Ltd.
    00-18-06   # Hokkei Industries Co., Ltd.
    00-18-07   # Fanstel Corp.
    00-18-08   # SightLogix, Inc.
    00-18-09   # CRESYN
    00-18-0A   # Meraki, Inc.
    00-18-0B   # Brilliant Telecommunications
    00-18-0C   # Optelian Access Networks
    00-18-0D   # Terabytes Server Storage Tech Corp
    00-18-0E   # Avega Systems
    00-18-0F   # Nokia Danmark A/S
    00-18-10   # IPTrade S.A.
    00-18-11   # Neuros Technology International, LLC.
    00-18-12   # Beijing Xinwei Telecom Technology Co., Ltd.
    00-18-13   # Sony Mobile Communications AB
    00-18-14   # Mitutoyo Corporation
    00-18-15   # GZ Technologies, Inc.
    00-18-16   # Ubixon Co., Ltd.
    00-18-17   # D. E. Shaw Research, LLC
    00-18-18   # Cisco Systems, Inc
    00-18-19   # Cisco Systems, Inc
    00-18-1A   # AVerMedia Information Inc.
    00-18-1B   # TaiJin Metal Co., Ltd.
    00-18-1C   # Exterity Limited
    00-18-1D   # ASIA ELECTRONICS CO.,LTD
    00-18-1E   # GDX Technologies Ltd.
    00-18-1F   # Palmmicro Communications
    00-18-20   # w5networks
    00-18-21   # SINDORICOH
    00-18-22   # CEC TELECOM CO.,LTD.
    00-18-23   # Delta Electronics, Inc.
    00-18-24   # Kimaldi Electronics, S.L.
    00-18-25   # Private
    00-18-26   # Cale Access AB
    00-18-27   # NEC UNIFIED SOLUTIONS NEDERLAND B.V.
    00-18-28   # e2v technologies (UK) ltd.
    00-18-29   # Gatsometer
    00-18-2A   # Taiwan Video & Monitor
    00-18-2B   # Softier
    00-18-2C   # Ascend Networks, Inc.
    00-18-2D   # Artec Design
    00-18-2E   # XStreamHD, LLC
    00-18-2F   # Texas Instruments
    00-18-30   # Texas Instruments
    00-18-31   # Texas Instruments
    00-18-32   # Texas Instruments
    00-18-33   # Texas Instruments
    00-18-34   # Texas Instruments
    00-18-35   # Thoratec / ITC
    00-18-36   # Reliance Electric Limited
    00-18-37   # Universal ABIT Co., Ltd.
    00-18-38   # PanAccess Communications,Inc.
    00-18-39   # Cisco-Linksys, LLC
    00-18-3A   # Westell Technologies
    00-18-3B   # CENITS Co., Ltd.
    00-18-3C   # Encore Software Limited
    00-18-3D   # Vertex Link Corporation
    00-18-3E   # Digilent, Inc
    00-18-3F   # 2Wire Inc
    00-18-40   # 3 Phoenix, Inc.
    00-18-41   # High Tech Computer Corp
    00-18-42   # Nokia Danmark A/S
    00-18-43   # Dawevision Ltd
    00-18-44   # Heads Up Technologies, Inc.
    00-18-45   # Pulsar-Telecom LLC.
    00-18-46   # Crypto S.A.
    00-18-47   # AceNet Technology Inc.
    00-18-48   # Vecima Networks Inc.
    00-18-49   # Pigeon Point Systems LLC
    00-18-4A   # Catcher, Inc.
    00-18-4B   # Las Vegas Gaming, Inc.
    00-18-4C   # Bogen Communications
    00-18-4D   # NETGEAR
    00-18-4E   # Lianhe Technologies, Inc.
    00-18-4F   # 8 Ways Technology Corp.
    00-18-50   # Secfone Kft
    00-18-51   # SWsoft
    00-18-52   # StorLink Semiconductors, Inc.
    00-18-53   # Atera Networks LTD.
    00-18-54   # Argard Co., Ltd
    00-18-55   # Aeromaritime Systembau GmbH
    00-18-56   # EyeFi, Inc
    00-18-57   # Unilever R&D
    00-18-58   # TagMaster AB
    00-18-59   # Strawberry Linux Co.,Ltd.
    00-18-5A   # uControl, Inc.
    00-18-5B   # Network Chemistry, Inc
    00-18-5C   # EDS Lab Pte Ltd
    00-18-5D   # TAIGUEN TECHNOLOGY (SHEN-ZHEN) CO., LTD.
    00-18-5E   # Nexterm Inc.
    00-18-5F   # TAC Inc.
    00-18-60   # SIM Technology Group Shanghai Simcom Ltd.,
    00-18-61   # Ooma, Inc.
    00-18-62   # Seagate Technology
    00-18-63   # Veritech Electronics Limited
    00-18-64   # Eaton Corporation
    00-18-65   # Siemens Healthcare Diagnostics Manufacturing Ltd
    00-18-66   # Leutron Vision
    00-18-67   # Datalogic ADC
    00-18-68   # Cisco SPVTG
    00-18-69   # KINGJIM
    00-18-6A   # Global Link Digital Technology Co,.LTD
    00-18-6B   # Sambu Communics CO., LTD.
    00-18-6C   # Neonode AB
    00-18-6D   # Zhenjiang Sapphire Electronic Industry CO.
    00-18-6E   # 3Com Ltd
    00-18-6F   # Setha Industria Eletronica LTDA
    00-18-70   # E28 Shanghai Limited
    00-18-71   # Hewlett Packard
    00-18-72   # Expertise Engineering
    00-18-73   # Cisco Systems, Inc
    00-18-74   # Cisco Systems, Inc
    00-18-75   # AnaCise Testnology Pte Ltd
    00-18-76   # WowWee Ltd.
    00-18-77   # Amplex A/S
    00-18-78   # Mackware GmbH
    00-18-79   # dSys
    00-18-7A   # Wiremold
    00-18-7B   # 4NSYS Co. Ltd.
    00-18-7C   # INTERCROSS, LLC
    00-18-7D   # Armorlink shanghai Co. Ltd
    00-18-7E   # RGB Spectrum
    00-18-7F   # ZODIANET
    00-18-80   # Maxim Integrated Products
    00-18-81   # Buyang Electronics Industrial Co., Ltd
    00-18-82   # HUAWEI TECHNOLOGIES CO.,LTD
    00-18-83   # FORMOSA21 INC.
    00-18-84   # Fon Technology S.L.
    00-18-85   # Avigilon Corporation
    00-18-86   # EL-TECH, INC.
    00-18-87   # Metasystem SpA
    00-18-88   # GOTIVE a.s.
    00-18-89   # WinNet Solutions Limited
    00-18-8A   # Infinova LLC
    00-18-8B   # Dell Inc.
    00-18-8C   # Mobile Action Technology Inc.
    00-18-8D   # Nokia Danmark A/S
    00-18-8E   # Ekahau, Inc.
    00-18-8F   # Montgomery Technology, Inc.
    00-18-90   # RadioCOM, s.r.o.
    00-18-91   # Zhongshan General K-mate Electronics Co., Ltd
    00-18-92   # ads-tec GmbH
    00-18-93   # SHENZHEN PHOTON BROADBAND TECHNOLOGY CO.,LTD
    00-18-94   # NPCore, Inc.
    00-18-95   # Hansun Technologies Inc.
    00-18-96   # Great Well Electronic LTD
    00-18-97   # JESS-LINK PRODUCTS Co., LTD
    00-18-98   # KINGSTATE ELECTRONICS CORPORATION
    00-18-99   # ShenZhen jieshun Science&Technology Industry CO,LTD.
    00-18-9A   # HANA Micron Inc.
    00-18-9B   # Thomson Inc.
    00-18-9C   # Weldex Corporation
    00-18-9D   # Navcast Inc.
    00-18-9E   # OMNIKEY GmbH.
    00-18-9F   # Lenntek Corporation
    00-18-A0   # Cierma Ascenseurs
    00-18-A1   # Tiqit Computers, Inc.
    00-18-A2   # XIP Technology AB
    00-18-A3   # ZIPPY TECHNOLOGY CORP.
    00-18-A4   # ARRIS Group, Inc.
    00-18-A5   # ADigit Technologies Corp.
    00-18-A6   # Persistent Systems, LLC
    00-18-A7   # Yoggie Security Systems LTD.
    00-18-A8   # AnNeal Technology Inc.
    00-18-A9   # Ethernet Direct Corporation
    00-18-AA   # Protec Fire Detection plc
    00-18-AB   # BEIJING LHWT MICROELECTRONICS INC.
    00-18-AC   # Shanghai Jiao Da HISYS Technology Co. Ltd.
    00-18-AD   # NIDEC SANKYO CORPORATION
    00-18-AE   # TVT CO.,LTD
    00-18-AF   # Samsung Electronics Co., Ltd.
    00-18-B0   # Nortel
    00-18-B1   # IBM Corp
    00-18-B2   # ADEUNIS RF
    00-18-B3   # TEC WizHome Co., Ltd.
    00-18-B4   # Dawon Media Inc.
    00-18-B5   # Magna Carta
    00-18-B6   # S3C, Inc.
    00-18-B7   # D3 LED, LLC
    00-18-B8   # New Voice International AG
    00-18-B9   # Cisco Systems, Inc
    00-18-BA   # Cisco Systems, Inc
    00-18-BB   # Eliwell Controls srl
    00-18-BC   # ZAO NVP Bolid
    00-18-BD   # SHENZHEN DVBWORLD TECHNOLOGY CO., LTD.
    00-18-BE   # ANSA Corporation
    00-18-BF   # Essence Technology Solution, Inc.
    00-18-C0   # ARRIS Group, Inc.
    00-18-C1   # Almitec Informática e Comércio
    00-18-C2   # Firetide, Inc
    00-18-C3   # CS Corporation
    00-18-C4   # Raba Technologies LLC
    00-18-C5   # Nokia Danmark A/S
    00-18-C6   # OPW Fuel Management Systems
    00-18-C7   # Real Time Automation
    00-18-C8   # ISONAS Inc.
    00-18-C9   # EOps Technology Limited
    00-18-CA   # Viprinet GmbH
    00-18-CB   # Tecobest Technology Limited
    00-18-CC   # AXIOHM SAS
    00-18-CD   # Erae Electronics Industry Co., Ltd
    00-18-CE   # Dreamtech Co., Ltd
    00-18-CF   # Baldor Electric Company
    00-18-D0   # AtRoad,  A Trimble Company
    00-18-D1   # Siemens Home & Office Comm. Devices
    00-18-D2   # High-Gain Antennas LLC
    00-18-D3   # TEAMCAST
    00-18-D4   # Unified Display Interface SIG
    00-18-D5   # REIGNCOM
    00-18-D6   # Swirlnet A/S
    00-18-D7   # Javad Navigation Systems Inc.
    00-18-D8   # ARCH METER Corporation
    00-18-D9   # Santosha Internatonal, Inc
    00-18-DA   # AMBER wireless GmbH
    00-18-DB   # EPL Technology Ltd
    00-18-DC   # Prostar Co., Ltd.
    00-18-DD   # Silicondust Engineering Ltd
    00-18-DE   # Intel Corporate
    00-18-DF   # The Morey Corporation
    00-18-E0   # ANAVEO
    00-18-E1   # Verkerk Service Systemen
    00-18-E2   # Topdata Sistemas de Automacao Ltda
    00-18-E3   # Visualgate Systems, Inc.
    00-18-E4   # YIGUANG
    00-18-E5   # Adhoco AG
    00-18-E6   # Computer Hardware Design SIA
    00-18-E7   # Cameo Communications, INC.
    00-18-E8   # Hacetron Corporation
    00-18-E9   # Numata Corporation
    00-18-EA   # Alltec GmbH
    00-18-EB   # Blue Zen Enterprises Private Limited
    00-18-EC   # Welding Technology Corporation
    00-18-ED   # Accutech Ultrasystems Co., Ltd.
    00-18-EE   # Videology Imaging Solutions, Inc.
    00-18-EF   # Escape Communications, Inc.
    00-18-F0   # JOYTOTO Co., Ltd.
    00-18-F1   # Chunichi Denshi Co.,LTD.
    00-18-F2   # Beijing Tianyu Communication Equipment Co., Ltd
    00-18-F3   # ASUSTek COMPUTER INC.
    00-18-F4   # EO TECHNICS Co., Ltd.
    00-18-F5   # Shenzhen Streaming Video Technology Company Limited
    00-18-F6   # Thomson Telecom Belgium
    00-18-F7   # Kameleon Technologies
    00-18-F8   # Cisco-Linksys, LLC
    00-18-F9   # VVOND, Inc.
    00-18-FA   # Yushin Precision Equipment Co.,Ltd.
    00-18-FB   # Compro Technology
    00-18-FC   # Altec Electronic AG
    00-18-FD   # Optimal Technologies International Inc.
    00-18-FE   # Hewlett Packard
    00-18-FF   # PowerQuattro Co.
    00-19-00   # Intelliverese - DBA Voicecom
    00-19-01   # F1MEDIA
    00-19-02   # Cambridge Consultants Ltd
    00-19-03   # Bigfoot Networks Inc
    00-19-04   # WB Electronics Sp. z o.o.
    00-19-05   # SCHRACK Seconet AG
    00-19-06   # Cisco Systems, Inc
    00-19-07   # Cisco Systems, Inc
    00-19-08   # Duaxes Corporation
    00-19-09   # DEVI - Danfoss A/S
    00-19-0A   # HASWARE INC.
    00-19-0B   # Southern Vision Systems, Inc.
    00-19-0C   # Encore Electronics, Inc.
    00-19-0D   # IEEE 1394c
    00-19-0E   # Atech Technology Co., Ltd.
    00-19-0F   # Advansus Corp.
    00-19-10   # Knick Elektronische Messgeraete GmbH & Co. KG
    00-19-11   # Just In Mobile Information Technologies (Shanghai) Co., Ltd.
    00-19-12   # Welcat Inc
    00-19-13   # Chuang-Yi Network Equipment Co.Ltd.
    00-19-14   # Winix Co., Ltd
    00-19-15   # TECOM Co., Ltd.
    00-19-16   # PayTec AG
    00-19-17   # Posiflex Inc.
    00-19-18   # Interactive Wear AG
    00-19-19   # ASTEL Inc.
    00-19-1A   # IRLINK
    00-19-1B   # Sputnik Engineering AG
    00-19-1C   # Sensicast Systems
    00-19-1D   # Nintendo Co., Ltd.
    00-19-1E   # Beyondwiz Co., Ltd.
    00-19-1F   # Microlink communications Inc.
    00-19-20   # KUME electric Co.,Ltd.
    00-19-21   # Elitegroup Computer System Co.
    00-19-22   # CM Comandos Lineares
    00-19-23   # Phonex Korea Co., LTD.
    00-19-24   # LBNL  Engineering
    00-19-25   # Intelicis Corporation
    00-19-26   # BitsGen Co., Ltd.
    00-19-27   # ImCoSys Ltd
    00-19-28   # Siemens AG, Transportation Systems
    00-19-29   # 2M2B Montadora de Maquinas Bahia Brasil LTDA
    00-19-2A   # Antiope Associates
    00-19-2B   # Aclara RF Systems Inc.
    00-19-2C   # ARRIS Group, Inc.
    00-19-2D   # Nokia Corporation
    00-19-2E   # Spectral Instruments, Inc.
    00-19-2F   # Cisco Systems, Inc
    00-19-30   # Cisco Systems, Inc
    00-19-31   # Balluff GmbH
    00-19-32   # Gude Analog- und Digialsysteme GmbH
    00-19-33   # Strix Systems, Inc.
    00-19-34   # TRENDON TOUCH TECHNOLOGY CORP.
    00-19-35   # DUERR DENTAL AG
    00-19-36   # STERLITE OPTICAL TECHNOLOGIES LIMITED
    00-19-37   # CommerceGuard AB
    00-19-38   # UMB Communications Co., Ltd.
    00-19-39   # Gigamips
    00-19-3A   # OESOLUTIONS
    00-19-3B   # Wilibox Deliberant Group LLC
    00-19-3C   # HighPoint Technologies Incorporated
    00-19-3D   # GMC Guardian Mobility Corp.
    00-19-3E   # ADB Broadband Italia
    00-19-3F   # RDI technology(Shenzhen) Co.,LTD
    00-19-40   # Rackable Systems
    00-19-41   # Pitney Bowes, Inc
    00-19-42   # ON SOFTWARE INTERNATIONAL LIMITED
    00-19-43   # Belden
    00-19-44   # Fossil Partners, L.P.
    00-19-45   # RF COncepts, LLC
    00-19-46   # Cianet Industria e Comercio S/A
    00-19-47   # Cisco SPVTG
    00-19-48   # AireSpider Networks
    00-19-49   # TENTEL  COMTECH CO., LTD.
    00-19-4A   # TESTO AG
    00-19-4B   # Sagemcom Broadband SAS
    00-19-4C   # Fujian Stelcom information & Technology CO.,Ltd
    00-19-4D   # Avago Technologies Sdn Bhd
    00-19-4E   # Ultra Electronics - TCS (Tactical Communication Systems)
    00-19-4F   # Nokia Danmark A/S
    00-19-50   # Harman Multimedia
    00-19-51   # NETCONS, s.r.o.
    00-19-52   # ACOGITO Co., Ltd
    00-19-53   # Chainleader Communications Corp.
    00-19-54   # Leaf Corporation.
    00-19-55   # Cisco Systems, Inc
    00-19-56   # Cisco Systems, Inc
    00-19-57   # Saafnet Canada Inc.
    00-19-58   # Bluetooth SIG, Inc.
    00-19-59   # Staccato Communications Inc.
    00-19-5A   # Jenaer Antriebstechnik GmbH
    00-19-5B   # D-Link Corporation
    00-19-5C   # Innotech Corporation
    00-19-5D   # ShenZhen XinHuaTong Opto Electronics Co.,Ltd
    00-19-5E   # ARRIS Group, Inc.
    00-19-5F   # Valemount Networks Corporation
    00-19-60   # DoCoMo Systems, Inc.
    00-19-61   # Blaupunkt  Embedded Systems GmbH
    00-19-62   # Commerciant, LP
    00-19-63   # Sony Mobile Communications AB
    00-19-64   # Doorking Inc.
    00-19-65   # YuHua TelTech (ShangHai) Co., Ltd.
    00-19-66   # Asiarock Technology Limited
    00-19-67   # TELDAT Sp.J.
    00-19-68   # Digital Video Networks(Shanghai) CO. LTD.
    00-19-69   # Nortel
    00-19-6A   # MikroM GmbH
    00-19-6B   # Danpex Corporation
    00-19-6C   # ETROVISION TECHNOLOGY
    00-19-6D   # Raybit Systems Korea, Inc
    00-19-6E   # Metacom (Pty) Ltd.
    00-19-6F   # SensoPart GmbH
    00-19-70   # Z-Com, Inc.
    00-19-71   # Guangzhou Unicomp Technology Co.,Ltd
    00-19-72   # Plexus (Xiamen) Co.,ltd
    00-19-73   # Zeugma Systems
    00-19-74   # 16063
    00-19-75   # Beijing Huisen networks technology Inc
    00-19-76   # Xipher Technologies, LLC
    00-19-77   # Aerohive Networks Inc.
    00-19-78   # Datum Systems, Inc.
    00-19-79   # Nokia Danmark A/S
    00-19-7A   # MAZeT GmbH
    00-19-7B   # Picotest Corp.
    00-19-7C   # Riedel Communications GmbH
    00-19-7D   # Hon Hai Precision Ind. Co.,Ltd.
    00-19-7E   # Hon Hai Precision Ind. Co.,Ltd.
    00-19-7F   # PLANTRONICS, INC.
    00-19-80   # Gridpoint Systems
    00-19-81   # Vivox Inc
    00-19-82   # SmarDTV
    00-19-83   # CCT R&D Limited
    00-19-84   # ESTIC Corporation
    00-19-85   # IT Watchdogs, Inc
    00-19-86   # Cheng Hongjian
    00-19-87   # Panasonic Mobile Communications Co., Ltd.
    00-19-88   # Wi2Wi, Inc
    00-19-89   # Sonitrol Corporation
    00-19-8A   # Northrop Grumman Systems Corp.
    00-19-8B   # Novera Optics Korea, Inc.
    00-19-8C   # iXSea
    00-19-8D   # Ocean Optics, Inc.
    00-19-8E   # Oticon A/S
    00-19-8F   # Alcatel Bell N.V.
    00-19-90   # ELM DATA Co., Ltd.
    00-19-91   # avinfo
    00-19-92   # ADTRAN INC.
    00-19-93   # Changshu Switchgear MFG. Co.,Ltd. (Former Changshu Switchgea
    00-19-94   # Jorjin Technologies Inc.
    00-19-95   # Jurong Hi-Tech (Suzhou)Co.ltd
    00-19-96   # TurboChef Technologies Inc.
    00-19-97   # Soft Device Sdn Bhd
    00-19-98   # SATO CORPORATION
    00-19-99   # Fujitsu Technology Solutions GmbH
    00-19-9A   # EDO-EVI
    00-19-9B   # Diversified Technical Systems, Inc.
    00-19-9C   # CTRING
    00-19-9D   # VIZIO, Inc.
    00-19-9E   # Nifty
    00-19-9F   # DKT A/S
    00-19-A0   # NIHON DATA SYSTENS, INC.
    00-19-A1   # LG INFORMATION & COMM.
    00-19-A2   # ORDYN TECHNOLOGIES
    00-19-A3   # asteel electronique atlantique
    00-19-A4   # Austar Technology (hang zhou) Co.,Ltd
    00-19-A5   # RadarFind Corporation
    00-19-A6   # ARRIS Group, Inc.
    00-19-A7   # ITU-T
    00-19-A8   # WiQuest Communications
    00-19-A9   # Cisco Systems, Inc
    00-19-AA   # Cisco Systems, Inc
    00-19-AB   # Raycom CO ., LTD
    00-19-AC   # GSP SYSTEMS Inc.
    00-19-AD   # BOBST SA
    00-19-AE   # Hopling Technologies b.v.
    00-19-AF   # Rigol Technologies, Inc.
    00-19-B0   # HanYang System
    00-19-B1   # Arrow7 Corporation
    00-19-B2   # XYnetsoft Co.,Ltd
    00-19-B3   # Stanford Research Systems
    00-19-B4   # Intellio Ltd
    00-19-B5   # Famar Fueguina S.A.
    00-19-B6   # Euro Emme s.r.l.
    00-19-B7   # Nokia Danmark A/S
    00-19-B8   # Boundary Devices
    00-19-B9   # Dell Inc.
    00-19-BA   # Paradox Security Systems Ltd
    00-19-BB   # Hewlett Packard
    00-19-BC   # ELECTRO CHANCE SRL
    00-19-BD   # New Media Life
    00-19-BE   # Altai Technologies Limited
    00-19-BF   # Citiway technology Co.,ltd
    00-19-C0   # ARRIS Group, Inc.
    00-19-C1   # ALPS ELECTRIC CO.,LTD.
    00-19-C2   # Equustek Solutions, Inc.
    00-19-C3   # Qualitrol
    00-19-C4   # Infocrypt Inc.
    00-19-C5   # Sony Computer Entertainment Inc.
    00-19-C6   # zte corporation
    00-19-C7   # Cambridge Industries(Group) Co.,Ltd.
    00-19-C8   # AnyDATA Corporation
    00-19-C9   # S&C ELECTRIC COMPANY
    00-19-CA   # Broadata Communications, Inc
    00-19-CB   # ZyXEL Communications Corporation
    00-19-CC   # RCG (HK) Ltd
    00-19-CD   # Chengdu ethercom information technology Ltd.
    00-19-CE   # Progressive Gaming International
    00-19-CF   # SALICRU, S.A.
    00-19-D0   # Cathexis
    00-19-D1   # Intel Corporate
    00-19-D2   # Intel Corporate
    00-19-D3   # TRAK Microwave
    00-19-D4   # ICX Technologies
    00-19-D5   # IP Innovations, Inc.
    00-19-D6   # LS Cable and System Ltd.
    00-19-D7   # FORTUNETEK CO., LTD
    00-19-D8   # MAXFOR
    00-19-D9   # Zeutschel GmbH
    00-19-DA   # Welltrans O&E Technology Co. , Ltd.
    00-19-DB   # MICRO-STAR INTERNATIONAL CO., LTD.
    00-19-DC   # ENENSYS Technologies
    00-19-DD   # FEI-Zyfer, Inc.
    00-19-DE   # MOBITEK
    00-19-DF   # Thomson Inc.
    00-19-E0   # TP-LINK TECHNOLOGIES CO.,LTD.
    00-19-E1   # Nortel
    00-19-E2   # Juniper Networks
    00-19-E3   # Apple, Inc.
    00-19-E4   # 2Wire Inc
    00-19-E5   # Lynx Studio Technology, Inc.
    00-19-E6   # TOYO MEDIC CO.,LTD.
    00-19-E7   # Cisco Systems, Inc
    00-19-E8   # Cisco Systems, Inc
    00-19-E9   # S-Information Technolgy, Co., Ltd.
    00-19-EA   # TeraMage Technologies Co., Ltd.
    00-19-EB   # Pyronix Ltd
    00-19-EC   # Sagamore Systems, Inc.
    00-19-ED   # Axesstel Inc.
    00-19-EE   # CARLO GAVAZZI CONTROLS SPA-Controls Division
    00-19-EF   # SHENZHEN LINNKING ELECTRONICS CO.,LTD
    00-19-F0   # UNIONMAN TECHNOLOGY CO.,LTD
    00-19-F1   # Star Communication Network Technology Co.,Ltd
    00-19-F2   # Teradyne K.K.
    00-19-F3   # Cetis, Inc
    00-19-F4   # Convergens Oy Ltd
    00-19-F5   # Imagination Technologies Ltd
    00-19-F6   # Acconet (PTE) Ltd
    00-19-F7   # Onset Computer Corporation
    00-19-F8   # Embedded Systems Design, Inc.
    00-19-F9   # TDK-Lambda
    00-19-FA   # Cable Vision Electronics CO., LTD.
    00-19-FB   # BSkyB Ltd
    00-19-FC   # PT. Ufoakses Sukses Luarbiasa
    00-19-FD   # Nintendo Co., Ltd.
    00-19-FE   # SHENZHEN SEECOMM TECHNOLOGY CO.,LTD.
    00-19-FF   # Finnzymes
    00-1A-00   # MATRIX INC.
    00-1A-01   # Smiths Medical
    00-1A-02   # SECURE CARE PRODUCTS, INC
    00-1A-03   # Angel Electronics Co., Ltd.
    00-1A-04   # Interay Solutions BV
    00-1A-05   # OPTIBASE LTD
    00-1A-06   # OpVista, Inc.
    00-1A-07   # Arecont Vision
    00-1A-08   # Simoco Ltd.
    00-1A-09   # Wayfarer Transit Systems Ltd
    00-1A-0A   # Adaptive Micro-Ware Inc.
    00-1A-0B   # BONA TECHNOLOGY INC.
    00-1A-0C   # Swe-Dish Satellite Systems AB
    00-1A-0D   # HandHeld entertainment, Inc.
    00-1A-0E   # Cheng Uei Precision Industry Co.,Ltd
    00-1A-0F   # Sistemas Avanzados de Control, S.A.
    00-1A-10   # LUCENT TRANS ELECTRONICS CO.,LTD
    00-1A-11   # Google, Inc.
    00-1A-12   # Essilor
    00-1A-13   # Wanlida Group Co., LTD
    00-1A-14   # Xin Hua Control Engineering Co.,Ltd.
    00-1A-15   # gemalto e-Payment
    00-1A-16   # Nokia Danmark A/S
    00-1A-17   # Teak Technologies, Inc.
    00-1A-18   # Advanced Simulation Technology inc.
    00-1A-19   # Computer Engineering Limited
    00-1A-1A   # Gentex Corporation/Electro-Acoustic Products
    00-1A-1B   # ARRIS Group, Inc.
    00-1A-1C   # GT&T Engineering Pte Ltd
    00-1A-1D   # PChome Online Inc.
    00-1A-1E   # Aruba Networks
    00-1A-1F   # Coastal Environmental Systems
    00-1A-20   # CMOTECH Co. Ltd.
    00-1A-21   # Indac B.V.
    00-1A-22   # eQ-3 Entwicklung GmbH
    00-1A-23   # Ice Qube, Inc
    00-1A-24   # Galaxy Telecom Technologies Ltd
    00-1A-25   # DELTA DORE
    00-1A-26   # Deltanode Solutions AB
    00-1A-27   # Ubistar
    00-1A-28   # ASWT Co., LTD. Taiwan Branch H.K.
    00-1A-29   # Johnson Outdoors Marine Electronics, Inc
    00-1A-2A   # Arcadyan Technology Corporation
    00-1A-2B   # Ayecom Technology Co., Ltd.
    00-1A-2C   # SATEC Co.,LTD
    00-1A-2D   # The Navvo Group
    00-1A-2E   # Ziova Coporation
    00-1A-2F   # Cisco Systems, Inc
    00-1A-30   # Cisco Systems, Inc
    00-1A-31   # SCAN COIN Industries AB
    00-1A-32   # ACTIVA MULTIMEDIA
    00-1A-33   # ASI Communications, Inc.
    00-1A-34   # Konka Group Co., Ltd.
    00-1A-35   # BARTEC GmbH
    00-1A-36   # Aipermon GmbH & Co. KG
    00-1A-37   # Lear Corporation
    00-1A-38   # Sanmina-SCI
    00-1A-39   # Merten GmbH&CoKG
    00-1A-3A   # Dongahelecomm
    00-1A-3B   # Doah Elecom Inc.
    00-1A-3C   # Technowave Ltd.
    00-1A-3D   # Ajin Vision Co.,Ltd
    00-1A-3E   # Faster Technology LLC
    00-1A-3F   # intelbras
    00-1A-40   # A-FOUR TECH CO., LTD.
    00-1A-41   # INOCOVA Co.,Ltd
    00-1A-42   # Techcity Technology co., Ltd.
    00-1A-43   # Logical Link Communications
    00-1A-44   # JWTrading Co., Ltd
    00-1A-45   # GN Netcom as
    00-1A-46   # Digital Multimedia Technology Co., Ltd
    00-1A-47   # Agami Systems, Inc.
    00-1A-48   # Takacom Corporation
    00-1A-49   # Micro Vision Co.,LTD
    00-1A-4A   # Qumranet Inc.
    00-1A-4B   # Hewlett Packard
    00-1A-4C   # Crossbow Technology, Inc
    00-1A-4D   # GIGA-BYTE TECHNOLOGY CO.,LTD.
    00-1A-4E   # NTI AG / LinMot
    00-1A-4F   # AVM GmbH
    00-1A-50   # PheeNet Technology Corp.
    00-1A-51   # Alfred Mann Foundation
    00-1A-52   # Meshlinx Wireless Inc.
    00-1A-53   # Zylaya
    00-1A-54   # Hip Shing Electronics Ltd.
    00-1A-55   # ACA-Digital Corporation
    00-1A-56   # ViewTel Co,. Ltd.
    00-1A-57   # Matrix Design Group, LLC
    00-1A-58   # CCV Deutschland GmbH - Celectronic eHealth Div.
    00-1A-59   # Ircona
    00-1A-5A   # Korea Electric Power Data Network  (KDN) Co., Ltd
    00-1A-5B   # NetCare Service Co., Ltd.
    00-1A-5C   # Euchner GmbH+Co. KG
    00-1A-5D   # Mobinnova Corp.
    00-1A-5E   # Thincom Technology Co.,Ltd
    00-1A-5F   # KitWorks.fi Ltd.
    00-1A-60   # Wave Electronics Co.,Ltd.
    00-1A-61   # PacStar Corp.
    00-1A-62   # Data Robotics, Incorporated
    00-1A-63   # Elster Solutions, LLC,
    00-1A-64   # IBM Corp
    00-1A-65   # Seluxit
    00-1A-66   # ARRIS Group, Inc.
    00-1A-67   # Infinite QL Sdn Bhd
    00-1A-68   # Weltec Enterprise Co., Ltd.
    00-1A-69   # Wuhan Yangtze Optical Technology CO.,Ltd.
    00-1A-6A   # Tranzas, Inc.
    00-1A-6B   # Universal Global Scientific Industrial Co., Ltd.
    00-1A-6C   # Cisco Systems, Inc
    00-1A-6D   # Cisco Systems, Inc
    00-1A-6E   # Impro Technologies
    00-1A-6F   # MI.TEL s.r.l.
    00-1A-70   # Cisco-Linksys, LLC
    00-1A-71   # Diostech Co., Ltd.
    00-1A-72   # Mosart Semiconductor Corp.
    00-1A-73   # Gemtek Technology Co., Ltd.
    00-1A-74   # Procare International Co
    00-1A-75   # Sony Mobile Communications AB
    00-1A-76   # SDT information Technology Co.,LTD.
    00-1A-77   # ARRIS Group, Inc.
    00-1A-78   # ubtos
    00-1A-79   # TELECOMUNICATION TECHNOLOGIES LTD.
    00-1A-7A   # Lismore Instruments Limited
    00-1A-7B   # Teleco, Inc.
    00-1A-7C   # Hirschmann Multimedia B.V.
    00-1A-7D   # cyber-blue(HK)Ltd
    00-1A-7E   # LN Srithai Comm Ltd.
    00-1A-7F   # GCI Science & Technology Co.,LTD
    00-1A-80   # Sony Corporation
    00-1A-81   # Zelax
    00-1A-82   # PROBA Building Automation Co.,LTD
    00-1A-83   # Pegasus Technologies Inc.
    00-1A-84   # V One Multimedia Pte Ltd
    00-1A-85   # NV Michel Van de Wiele
    00-1A-86   # AdvancedIO Systems Inc
    00-1A-87   # Canhold International Limited
    00-1A-88   # Venergy,Co,Ltd
    00-1A-89   # Nokia Danmark A/S
    00-1A-8A   # Samsung Electronics Co., Ltd.
    00-1A-8B   # CHUNIL ELECTRIC IND., CO.
    00-1A-8C   # Sophos Ltd
    00-1A-8D   # AVECS Bergen GmbH
    00-1A-8E   # 3Way Networks Ltd
    00-1A-8F   # Nortel
    00-1A-90   # Trópico Sistemas e Telecomunicações da Amazônia LTDA.
    00-1A-91   # FusionDynamic Ltd.
    00-1A-92   # ASUSTek COMPUTER INC.
    00-1A-93   # ERCO Leuchten GmbH
    00-1A-94   # Votronic GmbH
    00-1A-95   # Hisense Mobile Communications Technoligy Co.,Ltd.
    00-1A-96   # ECLER S.A.
    00-1A-97   # fitivision technology Inc.
    00-1A-98   # Asotel Communication Limited Taiwan Branch
    00-1A-99   # Smarty (HZ) Information Electronics Co., Ltd
    00-1A-9A   # Skyworth Digital Technology(Shenzhen) Co.,Ltd
    00-1A-9B   # ADEC & Parter AG
    00-1A-9C   # RightHand Technologies, Inc.
    00-1A-9D   # Skipper Wireless, Inc.
    00-1A-9E   # ICON Digital International Limited
    00-1A-9F   # A-Link Ltd
    00-1A-A0   # Dell Inc.
    00-1A-A1   # Cisco Systems, Inc
    00-1A-A2   # Cisco Systems, Inc
    00-1A-A3   # DELORME
    00-1A-A4   # Future University-Hakodate
    00-1A-A5   # BRN Phoenix
    00-1A-A6   # Telefunken Radio Communication Systems GmbH &CO.KG
    00-1A-A7   # Torian Wireless
    00-1A-A8   # Mamiya Digital Imaging Co., Ltd.
    00-1A-A9   # FUJIAN STAR-NET COMMUNICATION CO.,LTD
    00-1A-AA   # Analogic Corp.
    00-1A-AB   # eWings s.r.l.
    00-1A-AC   # Corelatus AB
    00-1A-AD   # ARRIS Group, Inc.
    00-1A-AE   # Savant Systems LLC
    00-1A-AF   # BLUSENS TECHNOLOGY
    00-1A-B0   # Signal Networks Pvt. Ltd.,
    00-1A-B1   # Asia Pacific Satellite Industries Co., Ltd.
    00-1A-B2   # Cyber Solutions Inc.
    00-1A-B3   # VISIONITE INC.
    00-1A-B4   # FFEI Ltd.
    00-1A-B5   # Home Network System
    00-1A-B6   # Texas Instruments
    00-1A-B7   # Ethos Networks LTD.
    00-1A-B8   # Anseri Corporation
    00-1A-B9   # PMC
    00-1A-BA   # Caton Overseas Limited
    00-1A-BB   # Fontal Technology Incorporation
    00-1A-BC   # U4EA Technologies Ltd
    00-1A-BD   # Impatica Inc.
    00-1A-BE   # COMPUTER HI-TECH INC.
    00-1A-BF   # TRUMPF Laser Marking Systems AG
    00-1A-C0   # JOYBIEN TECHNOLOGIES CO., LTD.
    00-1A-C1   # 3Com Ltd
    00-1A-C2   # YEC Co.,Ltd.
    00-1A-C3   # Scientific-Atlanta, Inc
    00-1A-C4   # 2Wire Inc
    00-1A-C5   # BreakingPoint Systems, Inc.
    00-1A-C6   # Micro Control Designs
    00-1A-C7   # UNIPOINT
    00-1A-C8   # ISL (Instrumentation Scientifique de Laboratoire)
    00-1A-C9   # SUZUKEN CO.,LTD
    00-1A-CA   # Tilera Corporation
    00-1A-CB   # Autocom Products Ltd
    00-1A-CC   # Celestial Semiconductor, Ltd
    00-1A-CD   # Tidel Engineering LP
    00-1A-CE   # YUPITERU CORPORATION
    00-1A-CF   # C.T. ELETTRONICA
    00-1A-D0   # Albis Technologies AG
    00-1A-D1   # FARGO CO., LTD.
    00-1A-D2   # Eletronica Nitron Ltda
    00-1A-D3   # Vamp Ltd.
    00-1A-D4   # iPOX Technology Co., Ltd.
    00-1A-D5   # KMC CHAIN INDUSTRIAL CO., LTD.
    00-1A-D6   # JIAGNSU AETNA ELECTRIC CO.,LTD
    00-1A-D7   # Christie Digital Systems, Inc.
    00-1A-D8   # AlsterAero GmbH
    00-1A-D9   # International Broadband Electric Communications, Inc.
    00-1A-DA   # Biz-2-Me Inc.
    00-1A-DB   # ARRIS Group, Inc.
    00-1A-DC   # Nokia Danmark A/S
    00-1A-DD   # PePWave Ltd
    00-1A-DE   # ARRIS Group, Inc.
    00-1A-DF   # Interactivetv Pty Limited
    00-1A-E0   # Mythology Tech Express Inc.
    00-1A-E1   # EDGE ACCESS INC
    00-1A-E2   # Cisco Systems, Inc
    00-1A-E3   # Cisco Systems, Inc
    00-1A-E4   # Medicis Technologies Corporation
    00-1A-E5   # Mvox Technologies Inc.
    00-1A-E6   # Atlanta Advanced Communications Holdings Limited
    00-1A-E7   # Aztek Networks, Inc.
    00-1A-E8   # Unify GmbH and Co KG
    00-1A-E9   # Nintendo Co., Ltd.
    00-1A-EA   # Radio Terminal Systems Pty Ltd
    00-1A-EB   # Allied Telesis R&D Center K.K.
    00-1A-EC   # Keumbee Electronics Co.,Ltd.
    00-1A-ED   # INCOTEC GmbH
    00-1A-EE   # Shenztech Ltd
    00-1A-EF   # Loopcomm Technology, Inc.
    00-1A-F0   # Alcatel - IPD
    00-1A-F1   # Embedded Artists AB
    00-1A-F2   # Dynavisions Schweiz AG
    00-1A-F3   # Samyoung Electronics
    00-1A-F4   # Handreamnet
    00-1A-F5   # PENTAONE. CO., LTD.
    00-1A-F6   # Woven Systems, Inc.
    00-1A-F7   # dataschalt e+a GmbH
    00-1A-F8   # Copley Controls Corporation
    00-1A-F9   # AeroVIronment (AV Inc)
    00-1A-FA   # Welch Allyn, Inc.
    00-1A-FB   # Joby Inc.
    00-1A-FC   # ModusLink Corporation
    00-1A-FD   # EVOLIS
    00-1A-FE   # SOFACREAL
    00-1A-FF   # Wizyoung Tech.
    00-1B-00   # Neopost Technologies
    00-1B-01   # Applied Radio Technologies
    00-1B-02   # ED Co.Ltd
    00-1B-03   # Action Technology (SZ) Co., Ltd
    00-1B-04   # Affinity International S.p.a
    00-1B-05   # YMC AG
    00-1B-06   # Ateliers R. LAUMONIER
    00-1B-07   # Mendocino Software
    00-1B-08   # Danfoss Drives A/S
    00-1B-09   # Matrix Telecom Pvt. Ltd.
    00-1B-0A   # Intelligent Distributed Controls Ltd
    00-1B-0B   # Phidgets Inc.
    00-1B-0C   # Cisco Systems, Inc
    00-1B-0D   # Cisco Systems, Inc
    00-1B-0E   # InoTec GmbH Organisationssysteme
    00-1B-0F   # Petratec
    00-1B-10   # ShenZhen Kang Hui Technology Co.,ltd
    00-1B-11   # D-Link Corporation
    00-1B-12   # Apprion
    00-1B-13   # Icron Technologies Corporation
    00-1B-14   # Carex Lighting Equipment Factory
    00-1B-15   # Voxtel, Inc.
    00-1B-16   # Celtro Ltd.
    00-1B-17   # Palo Alto Networks
    00-1B-18   # Tsuken Electric Ind. Co.,Ltd
    00-1B-19   # IEEE I&M Society TC9
    00-1B-1A   # e-trees Japan, Inc.
    00-1B-1B   # Siemens AG,
    00-1B-1C   # Coherent
    00-1B-1D   # Phoenix International Co., Ltd
    00-1B-1E   # HART Communication Foundation
    00-1B-1F   # DELTA - Danish Electronics, Light & Acoustics
    00-1B-20   # TPine Technology
    00-1B-21   # Intel Corporate
    00-1B-22   # Palit Microsystems ( H.K.) Ltd.
    00-1B-23   # SimpleComTools
    00-1B-24   # Quanta Computer Inc.
    00-1B-25   # Nortel
    00-1B-26   # RON-Telecom ZAO
    00-1B-27   # Merlin CSI
    00-1B-28   # POLYGON, JSC
    00-1B-29   # Avantis.Co.,Ltd
    00-1B-2A   # Cisco Systems, Inc
    00-1B-2B   # Cisco Systems, Inc
    00-1B-2C   # ATRON electronic GmbH
    00-1B-2D   # Med-Eng Systems Inc.
    00-1B-2E   # Sinkyo Electron Inc
    00-1B-2F   # NETGEAR
    00-1B-30   # Solitech Inc.
    00-1B-31   # Neural Image. Co. Ltd.
    00-1B-32   # QLogic Corporation
    00-1B-33   # Nokia Danmark A/S
    00-1B-34   # Focus System Inc.
    00-1B-35   # ChongQing JINOU Science & Technology Development CO.,Ltd
    00-1B-36   # Tsubata Engineering Co.,Ltd. (Head Office)
    00-1B-37   # Computec Oy
    00-1B-38   # COMPAL INFORMATION (KUNSHAN) CO., LTD.
    00-1B-39   # Proxicast
    00-1B-3A   # SIMS Corp.
    00-1B-3B   # Yi-Qing CO., LTD
    00-1B-3C   # Software Technologies Group,Inc.
    00-1B-3D   # EuroTel Spa
    00-1B-3E   # Curtis, Inc.
    00-1B-3F   # ProCurve Networking by HP
    00-1B-40   # Network Automation mxc AB
    00-1B-41   # General Infinity Co.,Ltd.
    00-1B-42   # Wise & Blue
    00-1B-43   # Beijing DG Telecommunications equipment Co.,Ltd
    00-1B-44   # SanDisk Corporation
    00-1B-45   # ABB AS, Division Automation Products
    00-1B-46   # Blueone Technology Co.,Ltd
    00-1B-47   # Futarque A/S
    00-1B-48   # Shenzhen Lantech Electronics Co., Ltd.
    00-1B-49   # Roberts Radio limited
    00-1B-4A   # W&W Communications, Inc.
    00-1B-4B   # SANION Co., Ltd.
    00-1B-4C   # Signtech
    00-1B-4D   # Areca Technology Corporation
    00-1B-4E   # Navman New Zealand
    00-1B-4F   # Avaya Inc
    00-1B-50   # Nizhny Novgorod Factory named after M.Frunze, FSUE (NZiF)
    00-1B-51   # Vector Technology Corp.
    00-1B-52   # ARRIS Group, Inc.
    00-1B-53   # Cisco Systems, Inc
    00-1B-54   # Cisco Systems, Inc
    00-1B-55   # Hurco Automation Ltd.
    00-1B-56   # Tehuti Networks Ltd.
    00-1B-57   # SEMINDIA SYSTEMS PRIVATE LIMITED
    00-1B-58   # ACE CAD Enterprise Co., Ltd.
    00-1B-59   # Sony Mobile Communications AB
    00-1B-5A   # Apollo Imaging Technologies, Inc.
    00-1B-5B   # 2Wire Inc
    00-1B-5C   # Azuretec Co., Ltd.
    00-1B-5D   # Vololink Pty Ltd
    00-1B-5E   # BPL Limited
    00-1B-5F   # Alien Technology
    00-1B-60   # NAVIGON AG
    00-1B-61   # Digital Acoustics, LLC
    00-1B-62   # JHT Optoelectronics Co.,Ltd.
    00-1B-63   # Apple, Inc.
    00-1B-64   # IsaacLandKorea Co., Ltd,
    00-1B-65   # China Gridcom Co., Ltd
    00-1B-66   # Sennheiser electronic GmbH & Co. KG
    00-1B-67   # Cisco Systems Inc
    00-1B-68   # Modnnet Co., Ltd
    00-1B-69   # Equaline Corporation
    00-1B-6A   # Powerwave Technologies Sweden AB
    00-1B-6B   # Swyx Solutions AG
    00-1B-6C   # LookX Digital Media BV
    00-1B-6D   # Midtronics, Inc.
    00-1B-6E   # Anue Systems, Inc.
    00-1B-6F   # Teletrak Ltd
    00-1B-70   # IRI Ubiteq, INC.
    00-1B-71   # Telular Corp.
    00-1B-72   # Sicep s.p.a.
    00-1B-73   # DTL Broadcast Ltd
    00-1B-74   # MiraLink Corporation
    00-1B-75   # Hypermedia Systems
    00-1B-76   # Ripcode, Inc.
    00-1B-77   # Intel Corporate
    00-1B-78   # Hewlett Packard
    00-1B-79   # FAIVELEY TRANSPORT
    00-1B-7A   # Nintendo Co., Ltd.
    00-1B-7B   # The Tintometer Ltd
    00-1B-7C   # A & R Cambridge
    00-1B-7D   # CXR Anderson Jacobson
    00-1B-7E   # Beckmann GmbH
    00-1B-7F   # TMN Technologies Telecomunicacoes Ltda
    00-1B-80   # LORD Corporation
    00-1B-81   # DATAQ Instruments, Inc.
    00-1B-82   # Taiwan Semiconductor Co., Ltd.
    00-1B-83   # Finsoft Ltd
    00-1B-84   # Scan Engineering Telecom
    00-1B-85   # MAN Diesel SE
    00-1B-86   # Bosch Access Systems GmbH
    00-1B-87   # Deepsound Tech. Co., Ltd
    00-1B-88   # Divinet Access Technologies Ltd
    00-1B-89   # EMZA Visual Sense Ltd.
    00-1B-8A   # 2M Electronic A/S
    00-1B-8B   # NEC Platforms, Ltd.
    00-1B-8C   # JMicron Technology Corp.
    00-1B-8D   # Electronic Computer Systems, Inc.
    00-1B-8E   # Hulu Sweden AB
    00-1B-8F   # Cisco Systems, Inc
    00-1B-90   # Cisco Systems, Inc
    00-1B-91   # EFKON AG
    00-1B-92   # l-acoustics
    00-1B-93   # JC Decaux SA DNT
    00-1B-94   # T.E.M.A. S.p.A.
    00-1B-95   # VIDEO SYSTEMS SRL
    00-1B-96   # General Sensing
    00-1B-97   # Violin Technologies
    00-1B-98   # Samsung Electronics Co., Ltd.
    00-1B-99   # KS System GmbH
    00-1B-9A   # Apollo Fire Detectors Ltd
    00-1B-9B   # Hose-McCann Communications
    00-1B-9C   # SATEL sp. z o.o.
    00-1B-9D   # Novus Security Sp. z o.o.
    00-1B-9E   # ASKEY COMPUTER CORP
    00-1B-9F   # Calyptech Pty Ltd
    00-1B-A0   # Awox
    00-1B-A1   # Åmic AB
    00-1B-A2   # IDS Imaging Development Systems GmbH
    00-1B-A3   # Flexit Group GmbH
    00-1B-A4   # S.A.E Afikim
    00-1B-A5   # MyungMin Systems, Inc.
    00-1B-A6   # intotech inc.
    00-1B-A7   # Lorica Solutions
    00-1B-A8   # UBI&MOBI,.Inc
    00-1B-A9   # Brother industries, LTD.
    00-1B-AA   # XenICs nv
    00-1B-AB   # Telchemy, Incorporated
    00-1B-AC   # Curtiss Wright Controls Embedded Computing
    00-1B-AD   # iControl Incorporated
    00-1B-AE   # Micro Control Systems, Inc
    00-1B-AF   # Nokia Danmark A/S
    00-1B-B0   # BHARAT ELECTRONICS
    00-1B-B1   # Wistron Neweb Corp.
    00-1B-B2   # Intellect International NV
    00-1B-B3   # Condalo GmbH
    00-1B-B4   # Airvod Limited
    00-1B-B5   # ZF Electronics GmbH
    00-1B-B6   # Bird Electronic Corp.
    00-1B-B7   # Alta Heights Technology Corp.
    00-1B-B8   # BLUEWAY ELECTRONIC CO;LTD
    00-1B-B9   # Elitegroup Computer System Co.
    00-1B-BA   # Nortel
    00-1B-BB   # RFTech Co.,Ltd
    00-1B-BC   # Silver Peak Systems, Inc.
    00-1B-BD   # FMC Kongsberg Subsea AS
    00-1B-BE   # ICOP Digital
    00-1B-BF   # Sagemcom Broadband SAS
    00-1B-C0   # Juniper Networks
    00-1B-C1   # HOLUX Technology, Inc.
    00-1B-C2   # Integrated Control Technology Limitied
    00-1B-C3   # Mobisolution Co.,Ltd
    00-1B-C4   # Ultratec, Inc.
    00-1B-C5   # IEEE REGISTRATION AUTHORITY  - Please see OUI36/MA-S public listing for more information.
    00-1B-C6   # Strato Rechenzentrum AG
    00-1B-C7   # StarVedia Technology Inc.
    00-1B-C8   # MIURA CO.,LTD
    00-1B-C9   # FSN DISPLAY INC
    00-1B-CA   # Beijing Run Technology LTD. Company
    00-1B-CB   # PEMPEK SYSTEMS PTY LTD
    00-1B-CC   # KINGTEK CCTV ALLIANCE CO., LTD.
    00-1B-CD   # DAVISCOMMS (S) PTE LTD
    00-1B-CE   # Measurement Devices Ltd
    00-1B-CF   # Dataupia Corporation
    00-1B-D0   # IDENTEC SOLUTIONS
    00-1B-D1   # SOGESTMATIC
    00-1B-D2   # ULTRA-X ASIA PACIFIC Inc.
    00-1B-D3   # Panasonic Corp. AVC Company
    00-1B-D4   # Cisco Systems, Inc
    00-1B-D5   # Cisco Systems, Inc
    00-1B-D6   # Kelvin Hughes Ltd
    00-1B-D7   # Cisco SPVTG
    00-1B-D8   # DVTel LTD
    00-1B-D9   # Edgewater Computer Systems
    00-1B-DA   # UTStarcom Inc
    00-1B-DB   # Valeo VECS
    00-1B-DC   # Vencer Co., Ltd.
    00-1B-DD   # ARRIS Group, Inc.
    00-1B-DE   # Renkus-Heinz, Inc.
    00-1B-DF   # Iskra Sistemi d.d.
    00-1B-E0   # TELENOT ELECTRONIC GmbH
    00-1B-E1   # ViaLogy
    00-1B-E2   # AhnLab,Inc.
    00-1B-E3   # Health Hero Network, Inc.
    00-1B-E4   # TOWNET SRL
    00-1B-E5   # 802automation Limited
    00-1B-E6   # VR AG
    00-1B-E7   # Postek Electronics Co., Ltd.
    00-1B-E8   # Ultratronik GmbH
    00-1B-E9   # Broadcom
    00-1B-EA   # Nintendo Co., Ltd.
    00-1B-EB   # DMP Electronics INC.
    00-1B-EC   # Netio Technologies Co., Ltd
    00-1B-ED   # Brocade Communications Systems, Inc.
    00-1B-EE   # Nokia Danmark A/S
    00-1B-EF   # Blossoms Digital Technology Co.,Ltd.
    00-1B-F0   # Value Platforms Limited
    00-1B-F1   # Nanjing SilverNet Software Co., Ltd.
    00-1B-F2   # KWORLD COMPUTER CO., LTD
    00-1B-F3   # TRANSRADIO SenderSysteme Berlin AG
    00-1B-F4   # KENWIN INDUSTRIAL(HK) LTD.
    00-1B-F5   # Tellink Sistemas de Telecomunicación S.L.
    00-1B-F6   # CONWISE Technology Corporation Ltd.
    00-1B-F7   # Lund IP Products AB
    00-1B-F8   # Digitrax Inc.
    00-1B-F9   # Intellitect Water Ltd
    00-1B-FA   # G.i.N. mbH
    00-1B-FB   # ALPS ELECTRIC CO.,LTD.
    00-1B-FC   # ASUSTek COMPUTER INC.
    00-1B-FD   # Dignsys Inc.
    00-1B-FE   # Zavio Inc.
    00-1B-FF   # Millennia Media inc.
    00-1C-00   # Entry Point, LLC
    00-1C-01   # ABB Oy Drives
    00-1C-02   # Pano Logic
    00-1C-03   # Betty TV Technology AG
    00-1C-04   # Airgain, Inc.
    00-1C-05   # Nonin Medical Inc.
    00-1C-06   # Siemens Numerical Control Ltd., Nanjing
    00-1C-07   # Cwlinux Limited
    00-1C-08   # Echo360, Inc.
    00-1C-09   # SAE Electronic Co.,Ltd.
    00-1C-0A   # Shenzhen AEE Technology Co.,Ltd.
    00-1C-0B   # SmartAnt Telecom
    00-1C-0C   # TANITA Corporation
    00-1C-0D   # G-Technology, Inc.
    00-1C-0E   # Cisco Systems, Inc
    00-1C-0F   # Cisco Systems, Inc
    00-1C-10   # Cisco-Linksys, LLC
    00-1C-11   # ARRIS Group, Inc.
    00-1C-12   # ARRIS Group, Inc.
    00-1C-13   # OPTSYS TECHNOLOGY CO., LTD.
    00-1C-14   # VMware, Inc
    00-1C-15   # iPhotonix LLC
    00-1C-16   # ThyssenKrupp Elevator
    00-1C-17   # Nortel
    00-1C-18   # Sicert S.r.L.
    00-1C-19   # secunet Security Networks AG
    00-1C-1A   # Thomas Instrumentation, Inc
    00-1C-1B   # Hyperstone GmbH
    00-1C-1C   # Center Communication Systems GmbH
    00-1C-1D   # CHENZHOU GOSPELL DIGITAL TECHNOLOGY CO.,LTD
    00-1C-1E   # emtrion GmbH
    00-1C-1F   # Quest Retail Technology Pty Ltd
    00-1C-20   # CLB Benelux
    00-1C-21   # Nucsafe Inc.
    00-1C-22   # Aeris Elettronica s.r.l.
    00-1C-23   # Dell Inc.
    00-1C-24   # Formosa Wireless Systems Corp.
    00-1C-25   # Hon Hai Precision Ind. Co.,Ltd.
    00-1C-26   # Hon Hai Precision Ind. Co.,Ltd.
    00-1C-27   # Sunell Electronics Co.
    00-1C-28   # Sphairon Technologies GmbH
    00-1C-29   # CORE DIGITAL ELECTRONICS CO., LTD
    00-1C-2A   # Envisacor Technologies Inc.
    00-1C-2B   # Alertme.com Limited
    00-1C-2C   # Synapse
    00-1C-2D   # FlexRadio Systems
    00-1C-2E   # HPN Supply Chain
    00-1C-2F   # Pfister GmbH
    00-1C-30   # Mode Lighting (UK ) Ltd.
    00-1C-31   # Mobile XP Technology Co., LTD
    00-1C-32   # Telian Corporation
    00-1C-33   # Sutron
    00-1C-34   # HUEY CHIAO INTERNATIONAL CO., LTD.
    00-1C-35   # Nokia Danmark A/S
    00-1C-36   # iNEWiT NV
    00-1C-37   # Callpod, Inc.
    00-1C-38   # Bio-Rad Laboratories, Inc.
    00-1C-39   # S Netsystems Inc.
    00-1C-3A   # Element Labs, Inc.
    00-1C-3B   # AmRoad Technology Inc.
    00-1C-3C   # Seon Design Inc.
    00-1C-3D   # WaveStorm
    00-1C-3E   # ECKey Corporation
    00-1C-3F   # International Police Technologies, Inc.
    00-1C-40   # VDG-Security bv
    00-1C-41   # scemtec Transponder Technology GmbH
    00-1C-42   # Parallels, Inc.
    00-1C-43   # Samsung Electronics Co.,Ltd
    00-1C-44   # Bosch Security Systems BV
    00-1C-45   # Chenbro Micom Co., Ltd.
    00-1C-46   # QTUM
    00-1C-47   # Hangzhou Hollysys Automation Co., Ltd
    00-1C-48   # WiDeFi, Inc.
    00-1C-49   # Zoltan Technology Inc.
    00-1C-4A   # AVM GmbH
    00-1C-4B   # Gener8, Inc.
    00-1C-4C   # Petrotest Instruments
    00-1C-4D   # Aplix IP Holdings Corporation
    00-1C-4E   # TASA International Limited
    00-1C-4F   # MACAB AB
    00-1C-50   # TCL Technoly Electronics (Huizhou) Co., Ltd.
    00-1C-51   # Celeno Communications
    00-1C-52   # VISIONEE SRL
    00-1C-53   # Synergy Lighting Controls
    00-1C-54   # Hillstone Networks Inc
    00-1C-55   # Shenzhen Kaifa Technology Co.
    00-1C-56   # Pado Systems, Inc.
    00-1C-57   # Cisco Systems, Inc
    00-1C-58   # Cisco Systems, Inc
    00-1C-59   # DEVON IT
    00-1C-5A   # Advanced Relay Corporation
    00-1C-5B   # Chubb Electronic Security Systems Ltd
    00-1C-5C   # Integrated Medical Systems, Inc.
    00-1C-5D   # Leica Microsystems
    00-1C-5E   # ASTON France
    00-1C-5F   # Winland Electronics, Inc.
    00-1C-60   # CSP Frontier Technologies,Inc.
    00-1C-61   # Galaxy  Microsystems LImited
    00-1C-62   # LG Electronics Inc
    00-1C-63   # TRUEN
    00-1C-64   # Landis+Gyr
    00-1C-65   # JoeScan, Inc.
    00-1C-66   # UCAMP CO.,LTD
    00-1C-67   # Pumpkin Networks, Inc.
    00-1C-68   # Anhui Sun Create Electronics Co., Ltd
    00-1C-69   # Packet Vision Ltd
    00-1C-6A   # Weiss Engineering Ltd.
    00-1C-6B   # COVAX  Co. Ltd
    00-1C-6C   # Jabil Circuit (Guangzhou) Limited
    00-1C-6D   # KYOHRITSU ELECTRONIC INDUSTRY CO., LTD.
    00-1C-6E   # Newbury Networks, Inc.
    00-1C-6F   # Emfit Ltd
    00-1C-70   # NOVACOMM LTDA
    00-1C-71   # Emergent Electronics
    00-1C-72   # Mayer & Cie GmbH & Co KG
    00-1C-73   # Arista Networks, Inc.
    00-1C-74   # Syswan Technologies Inc.
    00-1C-75   # Segnet Ltd.
    00-1C-76   # The Wandsworth Group Ltd
    00-1C-77   # Prodys
    00-1C-78   # WYPLAY SAS
    00-1C-79   # Cohesive Financial Technologies LLC
    00-1C-7A   # Perfectone Netware Company Ltd
    00-1C-7B   # Castlenet Technology Inc.
    00-1C-7C   # PERQ SYSTEMS CORPORATION
    00-1C-7D   # Excelpoint Manufacturing Pte Ltd
    00-1C-7E   # Toshiba
    00-1C-7F   # Check Point Software Technologies
    00-1C-80   # New Business Division/Rhea-Information CO., LTD.
    00-1C-81   # NextGen Venturi LTD
    00-1C-82   # Genew Technologies
    00-1C-83   # New Level Telecom Co., Ltd.
    00-1C-84   # STL Solution Co.,Ltd.
    00-1C-85   # Eunicorn
    00-1C-86   # Cranite Systems, Inc.
    00-1C-87   # Uriver Inc.
    00-1C-88   # TRANSYSTEM INC.
    00-1C-89   # Force Communications, Inc.
    00-1C-8A   # Cirrascale Corporation
    00-1C-8B   # MJ Innovations Ltd.
    00-1C-8C   # DIAL TECHNOLOGY LTD.
    00-1C-8D   # Mesa Imaging
    00-1C-8E   # Alcatel-Lucent IPD
    00-1C-8F   # Advanced Electronic Design, Inc.
    00-1C-90   # Empacket Corporation
    00-1C-91   # Gefen Inc.
    00-1C-92   # Tervela
    00-1C-93   # ExaDigm Inc
    00-1C-94   # LI-COR Biosciences
    00-1C-95   # Opticomm Corporation
    00-1C-96   # Linkwise Technology Pte Ltd
    00-1C-97   # Enzytek Technology Inc.,
    00-1C-98   # LUCKY TECHNOLOGY (HK) COMPANY LIMITED
    00-1C-99   # Shunra Software Ltd.
    00-1C-9A   # Nokia Danmark A/S
    00-1C-9B   # FEIG ELECTRONIC GmbH
    00-1C-9C   # Nortel
    00-1C-9D   # Liecthi AG
    00-1C-9E   # Dualtech IT AB
    00-1C-9F   # Razorstream, LLC
    00-1C-A0   # Production Resource Group, LLC
    00-1C-A1   # AKAMAI TECHNOLOGIES, INC.
    00-1C-A2   # ADB Broadband Italia
    00-1C-A3   # Terra
    00-1C-A4   # Sony Mobile Communications AB
    00-1C-A5   # Zygo Corporation
    00-1C-A6   # Win4NET
    00-1C-A7   # International Quartz Limited
    00-1C-A8   # AirTies Wireless Netowrks
    00-1C-A9   # Audiomatica Srl
    00-1C-AA   # Bellon Pty Ltd
    00-1C-AB   # Meyer Sound Laboratories, Inc.
    00-1C-AC   # Qniq Technology Corp.
    00-1C-AD   # Wuhan Telecommunication Devices Co.,Ltd
    00-1C-AE   # WiChorus, Inc.
    00-1C-AF   # Plato Networks Inc.
    00-1C-B0   # Cisco Systems, Inc
    00-1C-B1   # Cisco Systems, Inc
    00-1C-B2   # BPT SPA
    00-1C-B3   # Apple, Inc.
    00-1C-B4   # Iridium Satellite LLC
    00-1C-B5   # Neihua Network Technology Co.,LTD.(NHN)
    00-1C-B6   # Duzon CNT Co., Ltd.
    00-1C-B7   # USC DigiArk Corporation
    00-1C-B8   # CBC Co., Ltd
    00-1C-B9   # KWANG SUNG ELECTRONICS CO., LTD.
    00-1C-BA   # VerScient, Inc.
    00-1C-BB   # MusicianLink
    00-1C-BC   # CastGrabber, LLC
    00-1C-BD   # Ezze Mobile Tech., Inc.
    00-1C-BE   # Nintendo Co., Ltd.
    00-1C-BF   # Intel Corporate
    00-1C-C0   # Intel Corporate
    00-1C-C1   # ARRIS Group, Inc.
    00-1C-C2   # Part II Research, Inc.
    00-1C-C3   # Pace plc
    00-1C-C4   # Hewlett Packard
    00-1C-C5   # 3Com Ltd
    00-1C-C6   # ProStor Systems
    00-1C-C7   # Rembrandt Technologies, LLC d/b/a REMSTREAM
    00-1C-C8   # INDUSTRONIC Industrie-Electronic GmbH & Co. KG
    00-1C-C9   # Kaise Electronic Technology Co., Ltd.
    00-1C-CA   # Shanghai Gaozhi Science & Technology Development Co.
    00-1C-CB   # Forth Corporation Public Company Limited
    00-1C-CC   # BlackBerry RTS
    00-1C-CD   # Alektrona Corporation
    00-1C-CE   # By Techdesign
    00-1C-CF   # LIMETEK
    00-1C-D0   # Circleone Co.,Ltd.
    00-1C-D1   # Waves Audio LTD
    00-1C-D2   # King Champion (Hong Kong) Limited
    00-1C-D3   # ZP Engineering SEL
    00-1C-D4   # Nokia Danmark A/S
    00-1C-D5   # ZeeVee, Inc.
    00-1C-D6   # Nokia Danmark A/S
    00-1C-D7   # Harman/Becker Automotive Systems GmbH
    00-1C-D8   # BlueAnt Wireless
    00-1C-D9   # GlobalTop Technology Inc.
    00-1C-DA   # Exegin Technologies Limited
    00-1C-DB   # CARPOINT CO.,LTD
    00-1C-DC   # Custom Computer Services, Inc.
    00-1C-DD   # COWBELL ENGINEERING CO., LTD.
    00-1C-DE   # Interactive Multimedia eXchange Inc.
    00-1C-DF   # Belkin International Inc.
    00-1C-E0   # DASAN TPS
    00-1C-E1   # INDRA SISTEMAS, S.A.
    00-1C-E2   # Attero Tech, LLC.
    00-1C-E3   # Optimedical Systems
    00-1C-E4   # EleSy JSC
    00-1C-E5   # MBS Electronic Systems GmbH
    00-1C-E6   # INNES
    00-1C-E7   # Rocon PLC Research Centre
    00-1C-E8   # Cummins Inc
    00-1C-E9   # Galaxy Technology Limited
    00-1C-EA   # Scientific-Atlanta, Inc
    00-1C-EB   # Nortel
    00-1C-EC   # Mobilesoft (Aust.) Pty Ltd
    00-1C-ED   # ENVIRONNEMENT SA
    00-1C-EE   # SHARP Corporation
    00-1C-EF   # Primax Electronics LTD
    00-1C-F0   # D-Link Corporation
    00-1C-F1   # SUPoX Technology Co. , LTD.
    00-1C-F2   # Tenlon Technology Co.,Ltd.
    00-1C-F3   # EVS BROADCAST EQUIPMENT
    00-1C-F4   # Media Technology Systems Inc
    00-1C-F5   # Wiseblue Technology Limited
    00-1C-F6   # Cisco Systems, Inc
    00-1C-F7   # AudioScience
    00-1C-F8   # Parade Technologies, Ltd.
    00-1C-F9   # Cisco Systems, Inc
    00-1C-FA   # Alarm.com
    00-1C-FB   # ARRIS Group, Inc.
    00-1C-FC   # Sumitomo Electric Industries,Ltd
    00-1C-FD   # Universal Electronics
    00-1C-FE   # Quartics Inc
    00-1C-FF   # Napera Networks Inc
    00-1D-00   # Brivo Systems, LLC
    00-1D-01   # Neptune Digital
    00-1D-02   # Cybertech Telecom Development
    00-1D-03   # Design Solutions Inc.
    00-1D-04   # Zipit Wireless, Inc.
    00-1D-05   # Eaton Corporation
    00-1D-06   # HM Electronics, Inc.
    00-1D-07   # Shenzhen Sang Fei Consumer Communications Co.,Ltd
    00-1D-08   # JIANGSU YINHE ELECTRONICS CO., LTD
    00-1D-09   # Dell Inc.
    00-1D-0A   # Davis Instruments, Inc.
    00-1D-0B   # Power Standards Lab
    00-1D-0C   # MobileCompia
    00-1D-0D   # Sony Computer Entertainment inc.
    00-1D-0E   # Agapha Technology co., Ltd.
    00-1D-0F   # TP-LINK TECHNOLOGIES CO.,LTD.
    00-1D-10   # LightHaus Logic, Inc.
    00-1D-11   # Analogue & Micro Ltd
    00-1D-12   # ROHM CO., LTD.
    00-1D-13   # NextGTV
    00-1D-14   # SPERADTONE INFORMATION TECHNOLOGY LIMITED
    00-1D-15   # Shenzhen Dolphin Electronic Co., Ltd
    00-1D-16   # SFR
    00-1D-17   # Digital Sky Corporation
    00-1D-18   # Power Innovation GmbH
    00-1D-19   # Arcadyan Technology Corporation
    00-1D-1A   # OvisLink S.A.
    00-1D-1B   # Sangean Electronics Inc.
    00-1D-1C   # Gennet s.a.
    00-1D-1D   # Inter-M Corporation
    00-1D-1E   # KYUSHU TEN CO.,LTD
    00-1D-1F   # Siauliu Tauro Televizoriai, JSC
    00-1D-20   # Comtrend Corporation
    00-1D-21   # Alcad SL
    00-1D-22   # Foss Analytical A/S
    00-1D-23   # SENSUS
    00-1D-24   # Aclara Power-Line Systems Inc.
    00-1D-25   # Samsung Electronics Co.,Ltd
    00-1D-26   # Rockridgesound Technology Co.
    00-1D-27   # NAC-INTERCOM
    00-1D-28   # Sony Mobile Communications AB
    00-1D-29   # Doro AB
    00-1D-2A   # SHENZHEN BUL-TECH CO.,LTD.
    00-1D-2B   # Wuhan Pont Technology CO. , LTD
    00-1D-2C   # Wavetrend Technologies (Pty) Limited
    00-1D-2D   # Pylone, Inc.
    00-1D-2E   # Ruckus Wireless
    00-1D-2F   # QuantumVision Corporation
    00-1D-30   # YX Wireless S.A.
    00-1D-31   # HIGHPRO INTERNATIONAL R&D CO,.LTD.
    00-1D-32   # Longkay Communication & Technology (Shanghai) Co. Ltd
    00-1D-33   # Maverick Systems Inc.
    00-1D-34   # SYRIS Technology Corp
    00-1D-35   # Viconics Electronics Inc.
    00-1D-36   # ELECTRONICS CORPORATION OF INDIA LIMITED
    00-1D-37   # Thales-Panda Transportation System
    00-1D-38   # Seagate Technology
    00-1D-39   # MOOHADIGITAL CO., LTD
    00-1D-3A   # mh acoustics LLC
    00-1D-3B   # Nokia Danmark A/S
    00-1D-3C   # Muscle Corporation
    00-1D-3D   # Avidyne Corporation
    00-1D-3E   # SAKA TECHNO SCIENCE CO.,LTD
    00-1D-3F   # Mitron Pty Ltd
    00-1D-40   # Intel – GE Care Innovations LLC
    00-1D-41   # Hardy Instruments
    00-1D-42   # Nortel
    00-1D-43   # Shenzhen G-link Digital Technology Co., Ltd.
    00-1D-44   # KROHNE Messtechnik GmbH
    00-1D-45   # Cisco Systems, Inc
    00-1D-46   # Cisco Systems, Inc
    00-1D-47   # Covote GmbH & Co KG
    00-1D-48   # Sensor-Technik Wiedemann GmbH
    00-1D-49   # Innovation Wireless Inc.
    00-1D-4A   # Carestream Health, Inc.
    00-1D-4B   # Grid Connect Inc.
    00-1D-4C   # Alcatel-Lucent
    00-1D-4D   # Adaptive Recognition Hungary, Inc
    00-1D-4E   # TCM Mobile LLC
    00-1D-4F   # Apple, Inc.
    00-1D-50   # SPINETIX SA
    00-1D-51   # Babcock & Wilcox Power Generation Group, Inc
    00-1D-52   # Defzone B.V.
    00-1D-53   # S&O Electronics (Malaysia) Sdn. Bhd.
    00-1D-54   # Sunnic Technology & Merchandise INC.
    00-1D-55   # ZANTAZ, Inc
    00-1D-56   # Kramer Electronics Ltd.
    00-1D-57   # CAETEC Messtechnik
    00-1D-58   # CQ Inc
    00-1D-59   # Mitra Energy & Infrastructure
    00-1D-5A   # 2Wire Inc
    00-1D-5B   # Tecvan Informática Ltda
    00-1D-5C   # Tom Communication Industrial Co.,Ltd.
    00-1D-5D   # Control Dynamics Pty. Ltd.
    00-1D-5E   # COMING MEDIA CORP.
    00-1D-5F   # OverSpeed SARL
    00-1D-60   # ASUSTek COMPUTER INC.
    00-1D-61   # BIJ Corporation
    00-1D-62   # InPhase Technologies
    00-1D-63   # Miele & Cie. KG
    00-1D-64   # Adam Communications Systems Int Ltd
    00-1D-65   # Microwave Radio Communications
    00-1D-66   # Hyundai Telecom
    00-1D-67   # AMEC
    00-1D-68   # Thomson Telecom Belgium
    00-1D-69   # Knorr-Bremse IT-Services GmbH
    00-1D-6A   # Alpha Networks Inc.
    00-1D-6B   # ARRIS Group, Inc.
    00-1D-6C   # ClariPhy Communications, Inc.
    00-1D-6D   # Confidant International LLC
    00-1D-6E   # Nokia Danmark A/S
    00-1D-6F   # Chainzone Technology Co., Ltd
    00-1D-70   # Cisco Systems, Inc
    00-1D-71   # Cisco Systems, Inc
    00-1D-72   # Wistron Corporation
    00-1D-73   # BUFFALO.INC
    00-1D-74   # Tianjin China-Silicon Microelectronics Co., Ltd.
    00-1D-75   # Radioscape PLC
    00-1D-76   # Eyeheight Ltd.
    00-1D-77   # NSGate
    00-1D-78   # Invengo Information Technology Co.,Ltd
    00-1D-79   # SIGNAMAX LLC
    00-1D-7A   # Wideband Semiconductor, Inc.
    00-1D-7B   # Ice Energy, Inc.
    00-1D-7C   # ABE Elettronica S.p.A.
    00-1D-7D   # GIGA-BYTE TECHNOLOGY CO.,LTD.
    00-1D-7E   # Cisco-Linksys, LLC
    00-1D-7F   # Tekron International Ltd
    00-1D-80   # Beijing Huahuan Eletronics Co.,Ltd
    00-1D-81   # GUANGZHOU GATEWAY ELECTRONICS CO., LTD
    00-1D-82   # GN A/S (GN Netcom A/S)
    00-1D-83   # Emitech Corporation
    00-1D-84   # Gateway, Inc.
    00-1D-85   # Call Direct Cellular Solutions
    00-1D-86   # Shinwa Industries(China) Ltd.
    00-1D-87   # VigTech Labs Sdn Bhd
    00-1D-88   # Clearwire
    00-1D-89   # VaultStor Corporation
    00-1D-8A   # TechTrex Inc
    00-1D-8B   # ADB Broadband Italia
    00-1D-8C   # La Crosse Technology LTD
    00-1D-8D   # Raytek GmbH
    00-1D-8E   # Alereon, Inc.
    00-1D-8F   # PureWave Networks
    00-1D-90   # EMCO Flow Systems
    00-1D-91   # Digitize, Inc
    00-1D-92   # MICRO-STAR INT'L CO.,LTD.
    00-1D-93   # Modacom
    00-1D-94   # Climax Technology Co., Ltd
    00-1D-95   # Flash, Inc.
    00-1D-96   # WatchGuard Video
    00-1D-97   # Alertus Technologies LLC
    00-1D-98   # Nokia Danmark A/S
    00-1D-99   # Cyan Optic, Inc.
    00-1D-9A   # GODEX INTERNATIONAL CO., LTD
    00-1D-9B   # Hokuyo Automatic Co., Ltd.
    00-1D-9C   # Rockwell Automation
    00-1D-9D   # ARTJOY INTERNATIONAL LIMITED
    00-1D-9E   # AXION TECHNOLOGIES
    00-1D-9F   # MATT   R.P.Traczynscy Sp.J.
    00-1D-A0   # Heng Yu Electronic Manufacturing Company Limited
    00-1D-A1   # Cisco Systems, Inc
    00-1D-A2   # Cisco Systems, Inc
    00-1D-A3   # SabiOso
    00-1D-A4   # Hangzhou System Technology CO., LTD
    00-1D-A5   # WB Electronics
    00-1D-A6   # Media Numerics Limited
    00-1D-A7   # Seamless Internet
    00-1D-A8   # Takahata Electronics Co.,Ltd
    00-1D-A9   # Castles Technology, Co., LTD
    00-1D-AA   # DrayTek Corp.
    00-1D-AB   # SwissQual License AG
    00-1D-AC   # Gigamon Systems LLC
    00-1D-AD   # Sinotech Engineering Consultants, Inc.  Geotechnical Enginee
    00-1D-AE   # CHANG TSENG TECHNOLOGY CO., LTD
    00-1D-AF   # Nortel
    00-1D-B0   # FuJian HengTong Information Technology Co.,Ltd
    00-1D-B1   # Crescendo Networks
    00-1D-B2   # HOKKAIDO ELECTRIC ENGINEERING CO.,LTD.
    00-1D-B3   # HPN Supply Chain
    00-1D-B4   # KUMHO ENG CO.,LTD
    00-1D-B5   # Juniper Networks
    00-1D-B6   # BestComm Networks, Inc.
    00-1D-B7   # Tendril Networks, Inc.
    00-1D-B8   # Intoto Inc.
    00-1D-B9   # Wellspring Wireless
    00-1D-BA   # Sony Corporation
    00-1D-BB   # Dynamic System Electronics Corp.
    00-1D-BC   # Nintendo Co., Ltd.
    00-1D-BD   # Versamed Inc.
    00-1D-BE   # ARRIS Group, Inc.
    00-1D-BF   # Radiient Technologies, Inc.
    00-1D-C0   # Enphase Energy
    00-1D-C1   # Audinate Pty L
    00-1D-C2   # XORTEC OY
    00-1D-C3   # RIKOR TV, Ltd
    00-1D-C4   # AIOI Systems Co., Ltd.
    00-1D-C5   # Beijing Jiaxun Feihong Electricial Co., Ltd.
    00-1D-C6   # SNR Inc.
    00-1D-C7   # L-3 Communications Geneva Aerospace
    00-1D-C8   # Navionics Research Inc., dba SCADAmetrics
    00-1D-C9   # GainSpan Corp.
    00-1D-CA   # PAV Electronics Limited
    00-1D-CB   # Exéns Development Oy
    00-1D-CC   # Hetra Secure Solutions
    00-1D-CD   # ARRIS Group, Inc.
    00-1D-CE   # ARRIS Group, Inc.
    00-1D-CF   # ARRIS Group, Inc.
    00-1D-D0   # ARRIS Group, Inc.
    00-1D-D1   # ARRIS Group, Inc.
    00-1D-D2   # ARRIS Group, Inc.
    00-1D-D3   # ARRIS Group, Inc.
    00-1D-D4   # ARRIS Group, Inc.
    00-1D-D5   # ARRIS Group, Inc.
    00-1D-D6   # ARRIS Group, Inc.
    00-1D-D7   # Algolith
    00-1D-D8   # Microsoft Corporation
    00-1D-D9   # Hon Hai Precision Ind. Co.,Ltd.
    00-1D-DA   # Mikroelektronika spol. s r. o.
    00-1D-DB   # C-BEL Corporation
    00-1D-DC   # HangZhou DeChangLong Tech&Info Co.,Ltd
    00-1D-DD   # DAT H.K. LIMITED
    00-1D-DE   # Zhejiang Broadcast&Television Technology Co.,Ltd.
    00-1D-DF   # Sunitec Enterprise Co., Ltd.
    00-1D-E0   # Intel Corporate
    00-1D-E1   # Intel Corporate
    00-1D-E2   # Radionor Communications
    00-1D-E3   # Intuicom
    00-1D-E4   # Visioneered Image Systems
    00-1D-E5   # Cisco Systems, Inc
    00-1D-E6   # Cisco Systems, Inc
    00-1D-E7   # Marine Sonic Technology, Ltd.
    00-1D-E8   # Nikko Denki Tsushin Corporation(NDTC)
    00-1D-E9   # Nokia Danmark A/S
    00-1D-EA   # Commtest Instruments Ltd
    00-1D-EB   # DINEC International
    00-1D-EC   # Marusys
    00-1D-ED   # Grid Net, Inc.
    00-1D-EE   # NEXTVISION SISTEMAS DIGITAIS DE TELEVISÃO LTDA.
    00-1D-EF   # TRIMM, INC.
    00-1D-F0   # Vidient Systems, Inc.
    00-1D-F1   # Intego Systems, Inc.
    00-1D-F2   # Netflix, Inc.
    00-1D-F3   # SBS Science & Technology Co., Ltd
    00-1D-F4   # Magellan Technology Pty Limited
    00-1D-F5   # Sunshine Co,LTD
    00-1D-F6   # Samsung Electronics Co.,Ltd
    00-1D-F7   # R. STAHL Schaltgeräte GmbH
    00-1D-F8   # Webpro Vision Technology Corporation
    00-1D-F9   # Cybiotronics (Far East) Limited
    00-1D-FA   # Fujian LANDI Commercial Equipment Co.,Ltd
    00-1D-FB   # NETCLEUS Systems Corporation
    00-1D-FC   # KSIC
    00-1D-FD   # Nokia Danmark A/S
    00-1D-FE   # Palm, Inc
    00-1D-FF   # Network Critical Solutions Ltd
    00-1E-00   # Shantou Institute of Ultrasonic Instruments
    00-1E-01   # Renesas Technology Sales Co., Ltd.
    00-1E-02   # Sougou Keikaku Kougyou Co.,Ltd.
    00-1E-03   # LiComm Co., Ltd.
    00-1E-04   # Hanson Research Corporation
    00-1E-05   # Xseed Technologies & Computing
    00-1E-06   # WIBRAIN
    00-1E-07   # Winy Technology Co., Ltd.
    00-1E-08   # Centec Networks Inc
    00-1E-09   # ZEFATEK Co.,LTD
    00-1E-0A   # Syba Tech Limited
    00-1E-0B   # Hewlett Packard
    00-1E-0C   # Sherwood Information Partners, Inc.
    00-1E-0D   # Micran Ltd.
    00-1E-0E   # MAXI VIEW HOLDINGS LIMITED
    00-1E-0F   # Briot International
    00-1E-10   # HUAWEI TECHNOLOGIES CO.,LTD
    00-1E-11   # ELELUX INTERNATIONAL LTD
    00-1E-12   # Ecolab
    00-1E-13   # Cisco Systems, Inc
    00-1E-14   # Cisco Systems, Inc
    00-1E-15   # Beech Hill Electronics
    00-1E-16   # Keytronix
    00-1E-17   # STN BV
    00-1E-18   # Radio Activity srl
    00-1E-19   # GTRI
    00-1E-1A   # Best Source Taiwan Inc.
    00-1E-1B   # Digital Stream Technology, Inc.
    00-1E-1C   # SWS Australia Pty Limited
    00-1E-1D   # East Coast Datacom, Inc.
    00-1E-1E   # Honeywell Life Safety
    00-1E-1F   # Nortel
    00-1E-20   # Intertain Inc.
    00-1E-21   # Qisda Co.
    00-1E-22   # ARVOO Imaging Products BV
    00-1E-23   # Electronic Educational Devices, Inc
    00-1E-24   # Zhejiang Bell Technology Co.,ltd
    00-1E-25   # Intek Digital Inc
    00-1E-26   # Digifriends Co. Ltd
    00-1E-27   # SBN TECH Co.,Ltd.
    00-1E-28   # Lumexis Corporation
    00-1E-29   # Hypertherm Inc
    00-1E-2A   # NETGEAR
    00-1E-2B   # Radio Systems Design, Inc.
    00-1E-2C   # CyVerse Corporation
    00-1E-2D   # STIM
    00-1E-2E   # SIRTI S.p.A.
    00-1E-2F   # DiMoto Pty Ltd
    00-1E-30   # Shireen Inc
    00-1E-31   # INFOMARK CO.,LTD.
    00-1E-32   # Zensys
    00-1E-33   # Inventec Corporation
    00-1E-34   # CryptoMetrics
    00-1E-35   # Nintendo Co., Ltd.
    00-1E-36   # IPTE
    00-1E-37   # Universal Global Scientific Industrial Co., Ltd.
    00-1E-38   # Bluecard Software Technology Co., Ltd.
    00-1E-39   # Comsys Communication Ltd.
    00-1E-3A   # Nokia Danmark A/S
    00-1E-3B   # Nokia Danmark A/S
    00-1E-3C   # Lyngbox Media AB
    00-1E-3D   # ALPS ELECTRIC CO.,LTD.
    00-1E-3E   # KMW Inc.
    00-1E-3F   # TrellisWare Technologies, Inc.
    00-1E-40   # Shanghai DareGlobal Technologies  Co.,Ltd.
    00-1E-41   # Microwave Communication & Component, Inc.
    00-1E-42   # Teltonika
    00-1E-43   # AISIN AW CO.,LTD.
    00-1E-44   # SANTEC
    00-1E-45   # Sony Mobile Communications AB
    00-1E-46   # ARRIS Group, Inc.
    00-1E-47   # PT. Hariff Daya Tunggal Engineering
    00-1E-48   # Wi-Links
    00-1E-49   # Cisco Systems, Inc
    00-1E-4A   # Cisco Systems, Inc
    00-1E-4B   # City Theatrical
    00-1E-4C   # Hon Hai Precision Ind. Co.,Ltd.
    00-1E-4D   # Welkin Sciences, LLC
    00-1E-4E   # DAKO EDV-Ingenieur- und Systemhaus GmbH
    00-1E-4F   # Dell Inc.
    00-1E-50   # BATTISTONI RESEARCH
    00-1E-51   # Converter Industry Srl
    00-1E-52   # Apple, Inc.
    00-1E-53   # Further Tech Co., LTD
    00-1E-54   # TOYO ELECTRIC Corporation
    00-1E-55   # COWON SYSTEMS,Inc.
    00-1E-56   # Bally Wulff Entertainment GmbH
    00-1E-57   # ALCOMA, spol. s r.o.
    00-1E-58   # D-Link Corporation
    00-1E-59   # Silicon Turnkey Express, LLC
    00-1E-5A   # ARRIS Group, Inc.
    00-1E-5B   # Unitron Company, Inc.
    00-1E-5C   # RB GeneralEkonomik
    00-1E-5D   # Holosys d.o.o.
    00-1E-5E   # COmputime Ltd.
    00-1E-5F   # KwikByte, LLC
    00-1E-60   # Digital Lighting Systems, Inc
    00-1E-61   # ITEC GmbH
    00-1E-62   # Siemon
    00-1E-63   # Vibro-Meter SA
    00-1E-64   # Intel Corporate
    00-1E-65   # Intel Corporate
    00-1E-66   # RESOL Elektronische Regelungen GmbH
    00-1E-67   # Intel Corporate
    00-1E-68   # Quanta Computer
    00-1E-69   # Thomson Inc.
    00-1E-6A   # Beijing Bluexon Technology Co.,Ltd
    00-1E-6B   # Cisco SPVTG
    00-1E-6C   # Opaque Systems
    00-1E-6D   # IT R&D Center
    00-1E-6E   # Shenzhen First Mile Communications Ltd
    00-1E-6F   # Magna-Power Electronics, Inc.
    00-1E-70   # Cobham Defence Communications Ltd
    00-1E-71   # MIrcom Group of Companies
    00-1E-72   # PCS
    00-1E-73   # zte corporation
    00-1E-74   # Sagemcom Broadband SAS
    00-1E-75   # LG Electronics
    00-1E-76   # Thermo Fisher Scientific
    00-1E-77   # Air2App
    00-1E-78   # Owitek Technology Ltd.,
    00-1E-79   # Cisco Systems, Inc
    00-1E-7A   # Cisco Systems, Inc
    00-1E-7B   # R.I.CO. S.r.l.
    00-1E-7C   # Taiwick Limited
    00-1E-7D   # Samsung Electronics Co.,Ltd
    00-1E-7E   # Nortel
    00-1E-7F   # CBM of America
    00-1E-80   # Last Mile Ltd.
    00-1E-81   # CNB Technology Inc.
    00-1E-82   # SanDisk Corporation
    00-1E-83   # LAN/MAN Standards Association (LMSC)
    00-1E-84   # Pika Technologies Inc.
    00-1E-85   # Lagotek Corporation
    00-1E-86   # MEL Co.,Ltd.
    00-1E-87   # Realease Limited
    00-1E-88   # ANDOR SYSTEM SUPPORT CO., LTD.
    00-1E-89   # CRFS Limited
    00-1E-8A   # eCopy, Inc
    00-1E-8B   # Infra Access Korea Co., Ltd.
    00-1E-8C   # ASUSTek COMPUTER INC.
    00-1E-8D   # ARRIS Group, Inc.
    00-1E-8E   # Hunkeler AG
    00-1E-8F   # CANON INC.
    00-1E-90   # Elitegroup Computer Systems Co
    00-1E-91   # KIMIN Electronic Co., Ltd.
    00-1E-92   # JEULIN S.A.
    00-1E-93   # CiriTech Systems Inc
    00-1E-94   # SUPERCOM TECHNOLOGY CORPORATION
    00-1E-95   # SIGMALINK
    00-1E-96   # Sepura Plc
    00-1E-97   # Medium Link System Technology CO., LTD,
    00-1E-98   # GreenLine Communications
    00-1E-99   # Vantanol Industrial Corporation
    00-1E-9A   # HAMILTON Bonaduz AG
    00-1E-9B   # San-Eisha, Ltd.
    00-1E-9C   # Fidustron INC
    00-1E-9D   # Recall Technologies, Inc.
    00-1E-9E   # ddm hopt + schuler Gmbh + Co. KG
    00-1E-9F   # Visioneering Systems, Inc.
    00-1E-A0   # XLN-t
    00-1E-A1   # Brunata a/s
    00-1E-A2   # Symx Systems, Inc.
    00-1E-A3   # Nokia Danmark A/S
    00-1E-A4   # Nokia Danmark A/S
    00-1E-A5   # ROBOTOUS, Inc.
    00-1E-A6   # Best IT World (India) Pvt. Ltd.
    00-1E-A7   # Actiontec Electronics, Inc
    00-1E-A8   # Datang Mobile Communications Equipment CO.,LTD
    00-1E-A9   # Nintendo Co., Ltd.
    00-1E-AA   # E-Senza Technologies GmbH
    00-1E-AB   # TeleWell Oy
    00-1E-AC   # Armadeus Systems
    00-1E-AD   # Wingtech Group Limited
    00-1E-AE   # Continental Automotive Systems
    00-1E-AF   # Ophir Optronics Ltd
    00-1E-B0   # ImesD Electronica S.L.
    00-1E-B1   # Cryptsoft Pty Ltd
    00-1E-B2   # LG innotek
    00-1E-B3   # Primex Wireless
    00-1E-B4   # UNIFAT TECHNOLOGY LTD.
    00-1E-B5   # Ever Sparkle Technologies Ltd
    00-1E-B6   # TAG Heuer SA
    00-1E-B7   # TBTech, Co., Ltd.
    00-1E-B8   # Fortis, Inc.
    00-1E-B9   # Sing Fai Technology Limited
    00-1E-BA   # High Density Devices AS
    00-1E-BB   # BLUELIGHT TECHNOLOGY INC.
    00-1E-BC   # WINTECH AUTOMATION CO.,LTD.
    00-1E-BD   # Cisco Systems, Inc
    00-1E-BE   # Cisco Systems, Inc
    00-1E-BF   # Haas Automation Inc.
    00-1E-C0   # Microchip Technology Inc.
    00-1E-C1   # 3COM EUROPE LTD
    00-1E-C2   # Apple, Inc.
    00-1E-C3   # Kozio, Inc.
    00-1E-C4   # Celio Corp
    00-1E-C5   # Middle Atlantic Products Inc
    00-1E-C6   # Obvius Holdings LLC
    00-1E-C7   # 2Wire Inc
    00-1E-C8   # Rapid Mobile (Pty) Ltd
    00-1E-C9   # Dell Inc.
    00-1E-CA   # Nortel
    00-1E-CB   # RPC Energoautomatika Ltd
    00-1E-CC   # CDVI
    00-1E-CD   # KYLAND Technology Co. LTD
    00-1E-CE   # BISA Technologies (Hong Kong) Limited
    00-1E-CF   # PHILIPS ELECTRONICS UK LTD
    00-1E-D0   # Ingespace
    00-1E-D1   # Keyprocessor B.V.
    00-1E-D2   # Ray Shine Video Technology Inc
    00-1E-D3   # Dot Technology Int'l Co., Ltd.
    00-1E-D4   # Doble Engineering
    00-1E-D5   # Tekon-Automatics
    00-1E-D6   # Alentec & Orion AB
    00-1E-D7   # H-Stream Wireless, Inc.
    00-1E-D8   # Digital United Inc.
    00-1E-D9   # Mitsubishi Precision Co.,LTd.
    00-1E-DA   # Wesemann Elektrotechniek B.V.
    00-1E-DB   # Giken Trastem Co., Ltd.
    00-1E-DC   # Sony Mobile Communications AB
    00-1E-DD   # WASKO S.A.
    00-1E-DE   # BYD COMPANY LIMITED
    00-1E-DF   # Master Industrialization Center Kista
    00-1E-E0   # Urmet Domus SpA
    00-1E-E1   # Samsung Electronics Co.,Ltd
    00-1E-E2   # Samsung Electronics Co.,Ltd
    00-1E-E3   # T&W Electronics (ShenZhen) Co.,Ltd
    00-1E-E4   # ACS Solutions France
    00-1E-E5   # Cisco-Linksys, LLC
    00-1E-E6   # Shenzhen Advanced Video Info-Tech Co., Ltd.
    00-1E-E7   # Epic Systems Inc
    00-1E-E8   # Mytek
    00-1E-E9   # Stoneridge Electronics AB
    00-1E-EA   # Sensor Switch, Inc.
    00-1E-EB   # Talk-A-Phone Co.
    00-1E-EC   # COMPAL INFORMATION (KUNSHAN) CO., LTD.
    00-1E-ED   # Adventiq Ltd.
    00-1E-EE   # ETL Systems Ltd
    00-1E-EF   # Cantronic International Limited
    00-1E-F0   # Gigafin Networks
    00-1E-F1   # Servimat
    00-1E-F2   # Micro Motion Inc
    00-1E-F3   # From2
    00-1E-F4   # L-3 Communications Display Systems
    00-1E-F5   # Hitek Automated Inc.
    00-1E-F6   # Cisco Systems, Inc
    00-1E-F7   # Cisco Systems, Inc
    00-1E-F8   # Emfinity Inc.
    00-1E-F9   # Pascom Kommunikations systeme GmbH.
    00-1E-FA   # PROTEI Ltd.
    00-1E-FB   # Trio Motion Technology Ltd
    00-1E-FC   # JSC MASSA-K
    00-1E-FD   # Microbit 2.0 AB
    00-1E-FE   # LEVEL s.r.o.
    00-1E-FF   # Mueller-Elektronik GmbH & Co. KG
    00-1F-00   # Nokia Danmark A/S
    00-1F-01   # Nokia Danmark A/S
    00-1F-02   # Pixelmetrix Corporation Pte Ltd
    00-1F-03   # NUM AG
    00-1F-04   # Granch Ltd.
    00-1F-05   # iTAS Technology Corp.
    00-1F-06   # Integrated Dispatch Solutions
    00-1F-07   # AZTEQ Mobile
    00-1F-08   # RISCO LTD
    00-1F-09   # JASTEC CO., LTD.
    00-1F-0A   # Nortel
    00-1F-0B   # Federal State Unitary Enterprise Industrial UnionElectropribor
    00-1F-0C   # Intelligent Digital Services GmbH
    00-1F-0D   # L3 Communications - Telemetry West
    00-1F-0E   # Japan Kyastem Co., Ltd
    00-1F-0F   # Select Engineered Systems
    00-1F-10   # TOLEDO DO BRASIL INDUSTRIA DE BALANCAS  LTDA
    00-1F-11   # OPENMOKO, INC.
    00-1F-12   # Juniper Networks
    00-1F-13   # S.& A.S. Ltd.
    00-1F-14   # NexG
    00-1F-15   # Bioscrypt Inc
    00-1F-16   # Wistron Corporation
    00-1F-17   # IDX Company, Ltd.
    00-1F-18   # Hakusan.Mfg.Co,.Ltd
    00-1F-19   # BEN-RI ELECTRONICA S.A.
    00-1F-1A   # Prominvest
    00-1F-1B   # RoyalTek Company Ltd.
    00-1F-1C   # KOBISHI ELECTRIC Co.,Ltd.
    00-1F-1D   # Atlas Material Testing Technology LLC
    00-1F-1E   # Astec Technology Co., Ltd
    00-1F-1F   # Edimax Technology Co. Ltd.
    00-1F-20   # Logitech Europe SA
    00-1F-21   # Inner Mongolia Yin An Science & Technology Development Co.,L
    00-1F-22   # Source Photonics, Inc.
    00-1F-23   # Interacoustics
    00-1F-24   # DIGITVIEW TECHNOLOGY CO., LTD.
    00-1F-25   # MBS GmbH
    00-1F-26   # Cisco Systems, Inc
    00-1F-27   # Cisco Systems, Inc
    00-1F-28   # HPN Supply Chain
    00-1F-29   # Hewlett Packard
    00-1F-2A   # ACCM
    00-1F-2B   # Orange Logic
    00-1F-2C   # Starbridge Networks
    00-1F-2D   # Electro-Optical Imaging, Inc.
    00-1F-2E   # Triangle Research Int'l Pte Ltd
    00-1F-2F   # Berker GmbH & Co. KG
    00-1F-30   # Travelping
    00-1F-31   # Radiocomp
    00-1F-32   # Nintendo Co., Ltd.
    00-1F-33   # NETGEAR
    00-1F-34   # Lung Hwa Electronics Co., Ltd.
    00-1F-35   # AIR802 LLC
    00-1F-36   # Bellwin Information Co. Ltd.,
    00-1F-37   # Genesis I&C
    00-1F-38   # POSITRON
    00-1F-39   # Construcciones y Auxiliar de Ferrocarriles, S.A.
    00-1F-3A   # Hon Hai Precision Ind. Co.,Ltd.
    00-1F-3B   # Intel Corporate
    00-1F-3C   # Intel Corporate
    00-1F-3D   # Qbit GmbH
    00-1F-3E   # RP-Technik e.K.
    00-1F-3F   # AVM GmbH
    00-1F-40   # Speakercraft Inc.
    00-1F-41   # Ruckus Wireless
    00-1F-42   # Etherstack plc
    00-1F-43   # ENTES ELEKTRONIK
    00-1F-44   # GE Transportation Systems
    00-1F-45   # Enterasys
    00-1F-46   # Nortel
    00-1F-47   # MCS Logic Inc.
    00-1F-48   # Mojix Inc.
    00-1F-49   # Manhattan TV Ltd
    00-1F-4A   # Albentia Systems S.A.
    00-1F-4B   # Lineage Power
    00-1F-4C   # Roseman Engineering Ltd
    00-1F-4D   # Segnetics LLC
    00-1F-4E   # ConMed Linvatec
    00-1F-4F   # Thinkware Co. Ltd.
    00-1F-50   # Swissdis AG
    00-1F-51   # HD Communications Corp
    00-1F-52   # UVT Unternehmensberatung fur Verkehr und Technik GmbH
    00-1F-53   # GEMAC Gesellschaft für Mikroelektronikanwendung Chemnitz mbH
    00-1F-54   # Lorex Technology Inc.
    00-1F-55   # Honeywell Security (China) Co., Ltd.
    00-1F-56   # DIGITAL FORECAST
    00-1F-57   # Phonik Innovation Co.,LTD
    00-1F-58   # EMH Energiemesstechnik GmbH
    00-1F-59   # Kronback Tracers
    00-1F-5A   # Beckwith Electric Co.
    00-1F-5B   # Apple, Inc.
    00-1F-5C   # Nokia Danmark A/S
    00-1F-5D   # Nokia Danmark A/S
    00-1F-5E   # Dyna Technology Co.,Ltd.
    00-1F-5F   # Blatand GmbH
    00-1F-60   # COMPASS SYSTEMS CORP.
    00-1F-61   # Talent Communication Networks Inc.
    00-1F-62   # JSC Stilsoft
    00-1F-63   # JSC Goodwin-Europa
    00-1F-64   # Beijing Autelan Technology Inc.
    00-1F-65   # KOREA ELECTRIC TERMINAL CO., LTD.
    00-1F-66   # PLANAR LLC
    00-1F-67   # Hitachi,Ltd.
    00-1F-68   # Martinsson Elektronik AB
    00-1F-69   # Pingood Technology Co., Ltd.
    00-1F-6A   # PacketFlux Technologies, Inc.
    00-1F-6B   # LG Electronics
    00-1F-6C   # Cisco Systems, Inc
    00-1F-6D   # Cisco Systems, Inc
    00-1F-6E   # Vtech Engineering Corporation
    00-1F-6F   # Fujian Sunnada Communication Co.,Ltd.
    00-1F-70   # Botik Technologies LTD
    00-1F-71   # xG Technology, Inc.
    00-1F-72   # QingDao Hiphone Technology Co,.Ltd
    00-1F-73   # Teraview Technology Co., Ltd.
    00-1F-74   # Eigen Development
    00-1F-75   # GiBahn Media
    00-1F-76   # AirLogic Systems Inc.
    00-1F-77   # HEOL DESIGN
    00-1F-78   # Blue Fox Porini Textile
    00-1F-79   # Lodam Electronics A/S
    00-1F-7A   # WiWide Inc.
    00-1F-7B   # TechNexion Ltd.
    00-1F-7C   # Witelcom AS
    00-1F-7D   # embedded wireless GmbH
    00-1F-7E   # ARRIS Group, Inc.
    00-1F-7F   # Phabrix Limited
    00-1F-80   # Lucas Holding bv
    00-1F-81   # Accel Semiconductor Corp
    00-1F-82   # Cal-Comp Electronics & Communications Co., Ltd
    00-1F-83   # Teleplan Technology Services Sdn Bhd
    00-1F-84   # Gigle Semiconductor
    00-1F-85   # Apriva ISS, LLC
    00-1F-86   # digEcor
    00-1F-87   # Skydigital Inc.
    00-1F-88   # FMS Force Measuring Systems AG
    00-1F-89   # Signalion GmbH
    00-1F-8A   # Ellion Digital Inc.
    00-1F-8B   # Cache IQ
    00-1F-8C   # CCS Inc.
    00-1F-8D   # Ingenieurbuero Stark GmbH und Ko. KG
    00-1F-8E   # Metris USA Inc.
    00-1F-8F   # Shanghai Bellmann Digital Source Co.,Ltd.
    00-1F-90   # Actiontec Electronics, Inc
    00-1F-91   # DBS Lodging Technologies, LLC
    00-1F-92   # VideoIQ, Inc.
    00-1F-93   # Xiotech Corporation
    00-1F-94   # Lascar Electronics Ltd
    00-1F-95   # Sagemcom Broadband SAS
    00-1F-96   # APROTECH CO.LTD
    00-1F-97   # BERTANA srl
    00-1F-98   # DAIICHI-DENTSU LTD.
    00-1F-99   # SERONICS co.ltd
    00-1F-9A   # Nortel Networks
    00-1F-9B   # POSBRO
    00-1F-9C   # LEDCO
    00-1F-9D   # Cisco Systems, Inc
    00-1F-9E   # Cisco Systems, Inc
    00-1F-9F   # Thomson Telecom Belgium
    00-1F-A0   # A10 Networks
    00-1F-A1   # Gtran Inc
    00-1F-A2   # Datron World Communications, Inc.
    00-1F-A3   # T&W Electronics(Shenzhen)Co.,Ltd.
    00-1F-A4   # ShenZhen Gongjin Electronics Co.,Ltd
    00-1F-A5   # Blue-White Industries
    00-1F-A6   # Stilo srl
    00-1F-A7   # Sony Computer Entertainment Inc.
    00-1F-A8   # Smart Energy Instruments Inc.
    00-1F-A9   # Atlanta DTH, Inc.
    00-1F-AA   # Taseon, Inc.
    00-1F-AB   # I.S HIGH TECH.INC
    00-1F-AC   # Goodmill Systems Ltd
    00-1F-AD   # Brown Innovations, Inc
    00-1F-AE   # Blick South Africa (Pty) Ltd
    00-1F-AF   # NextIO, Inc.
    00-1F-B0   # TimeIPS, Inc.
    00-1F-B1   # Cybertech Inc.
    00-1F-B2   # Sontheim Industrie Elektronik GmbH
    00-1F-B3   # 2Wire Inc
    00-1F-B4   # SmartShare Systems
    00-1F-B5   # I/O Interconnect Inc.
    00-1F-B6   # Chi Lin Technology Co., Ltd.
    00-1F-B7   # WiMate Technologies Corp.
    00-1F-B8   # Universal Remote Control, Inc.
    00-1F-B9   # Paltronics
    00-1F-BA   # BoYoung Tech. & Marketing, Inc.
    00-1F-BB   # Xenatech Co.,LTD
    00-1F-BC   # EVGA Corporation
    00-1F-BD   # Kyocera Wireless Corp.
    00-1F-BE   # Shenzhen Mopnet Industrial Co.,Ltd
    00-1F-BF   # Fulhua Microelectronics Corp. Taiwan Branch
    00-1F-C0   # Control Express Finland Oy
    00-1F-C1   # Hanlong Technology Co.,LTD
    00-1F-C2   # Jow Tong Technology Co Ltd
    00-1F-C3   # SmartSynch, Inc
    00-1F-C4   # ARRIS Group, Inc.
    00-1F-C5   # Nintendo Co., Ltd.
    00-1F-C6   # ASUSTek COMPUTER INC.
    00-1F-C7   # Casio Hitachi Mobile Communications Co., Ltd.
    00-1F-C8   # Up-Today Industrial Co., Ltd.
    00-1F-C9   # Cisco Systems, Inc
    00-1F-CA   # Cisco Systems, Inc
    00-1F-CB   # NIW Solutions
    00-1F-CC   # Samsung Electronics Co.,Ltd
    00-1F-CD   # Samsung Electronics
    00-1F-CE   # QTECH LLC
    00-1F-CF   # MSI Technology GmbH
    00-1F-D0   # GIGA-BYTE TECHNOLOGY CO.,LTD.
    00-1F-D1   # OPTEX CO.,LTD.
    00-1F-D2   # COMMTECH TECHNOLOGY MACAO COMMERCIAL OFFSHORE LTD.
    00-1F-D3   # RIVA Networks Inc.
    00-1F-D4   # 4IPNET, INC.
    00-1F-D5   # MICRORISC s.r.o.
    00-1F-D6   # Shenzhen Allywll
    00-1F-D7   # TELERAD SA
    00-1F-D8   # A-TRUST COMPUTER CORPORATION
    00-1F-D9   # RSD Communications Ltd
    00-1F-DA   # Nortel Networks
    00-1F-DB   # Network Supply Corp.,
    00-1F-DC   # Mobile Safe Track Ltd
    00-1F-DD   # GDI LLC
    00-1F-DE   # Nokia Danmark A/S
    00-1F-DF   # Nokia Danmark A/S
    00-1F-E0   # EdgeVelocity Corp
    00-1F-E1   # Hon Hai Precision Ind. Co.,Ltd.
    00-1F-E2   # Hon Hai Precision Ind. Co.,Ltd.
    00-1F-E3   # LG Electronics
    00-1F-E4   # Sony Mobile Communications AB
    00-1F-E5   # In-Circuit GmbH
    00-1F-E6   # Alphion Corporation
    00-1F-E7   # Simet
    00-1F-E8   # KURUSUGAWA Electronics Industry Inc,.
    00-1F-E9   # Printrex, Inc.
    00-1F-EA   # Applied Media Technologies Corporation
    00-1F-EB   # Trio Datacom Pty Ltd
    00-1F-EC   # Synapse Électronique
    00-1F-ED   # Tecan Systems Inc.
    00-1F-EE   # ubisys technologies GmbH
    00-1F-EF   # SHINSEI INDUSTRIES CO.,LTD
    00-1F-F0   # Audio Partnership
    00-1F-F1   # Paradox Hellas S.A.
    00-1F-F2   # VIA Technologies, Inc.
    00-1F-F3   # Apple, Inc.
    00-1F-F4   # Power Monitors, Inc.
    00-1F-F5   # Kongsberg Defence & Aerospace
    00-1F-F6   # PS Audio International
    00-1F-F7   # Nakajima All Precision Co., Ltd.
    00-1F-F8   # Siemens AG, Sector Industry, Drive Technologies, Motion Control Systems
    00-1F-F9   # Advanced Knowledge Associates
    00-1F-FA   # Coretree, Co, Ltd
    00-1F-FB   # Green Packet Bhd
    00-1F-FC   # Riccius+Sohn GmbH
    00-1F-FD   # Indigo Mobile Technologies Corp.
    00-1F-FE   # HPN Supply Chain
    00-1F-FF   # Respironics, Inc.
    00-20-00   # LEXMARK INTERNATIONAL, INC.
    00-20-01   # DSP SOLUTIONS, INC.
    00-20-02   # SERITECH ENTERPRISE CO., LTD.
    00-20-03   # PIXEL POWER LTD.
    00-20-04   # YAMATAKE-HONEYWELL CO., LTD.
    00-20-05   # SIMPLE TECHNOLOGY
    00-20-06   # GARRETT COMMUNICATIONS, INC.
    00-20-07   # SFA, INC.
    00-20-08   # CABLE & COMPUTER TECHNOLOGY
    00-20-09   # PACKARD BELL ELEC., INC.
    00-20-0A   # SOURCE-COMM CORP.
    00-20-0B   # OCTAGON SYSTEMS CORP.
    00-20-0C   # ADASTRA SYSTEMS CORP.
    00-20-0D   # CARL ZEISS
    00-20-0E   # SATELLITE TECHNOLOGY MGMT, INC
    00-20-0F   # EBRAINS Inc
    00-20-10   # JEOL SYSTEM TECHNOLOGY CO. LTD
    00-20-11   # CANOPUS CO., LTD.
    00-20-12   # CAMTRONICS MEDICAL SYSTEMS
    00-20-13   # DIVERSIFIED TECHNOLOGY, INC.
    00-20-14   # GLOBAL VIEW CO., LTD.
    00-20-15   # ACTIS COMPUTER SA
    00-20-16   # SHOWA ELECTRIC WIRE & CABLE CO
    00-20-17   # ORBOTECH
    00-20-18   # CIS TECHNOLOGY INC.
    00-20-19   # OHLER GMBH
    00-20-1A   # MRV Communications, Inc.
    00-20-1B   # NORTHERN TELECOM/NETWORK
    00-20-1C   # EXCEL, INC.
    00-20-1D   # KATANA PRODUCTS
    00-20-1E   # NETQUEST CORPORATION
    00-20-1F   # BEST POWER TECHNOLOGY, INC.
    00-20-20   # MEGATRON COMPUTER INDUSTRIES PTY, LTD.
    00-20-21   # ALGORITHMS SOFTWARE PVT. LTD.
    00-20-22   # NMS Communications
    00-20-23   # T.C. TECHNOLOGIES PTY. LTD
    00-20-24   # PACIFIC COMMUNICATION SCIENCES
    00-20-25   # CONTROL TECHNOLOGY, INC.
    00-20-26   # AMKLY SYSTEMS, INC.
    00-20-27   # MING FORTUNE INDUSTRY CO., LTD
    00-20-28   # WEST EGG SYSTEMS, INC.
    00-20-29   # TELEPROCESSING PRODUCTS, INC.
    00-20-2A   # N.V. DZINE
    00-20-2B   # ADVANCED TELECOMMUNICATIONS MODULES, LTD.
    00-20-2C   # WELLTRONIX CO., LTD.
    00-20-2D   # TAIYO CORPORATION
    00-20-2E   # DAYSTAR DIGITAL
    00-20-2F   # ZETA COMMUNICATIONS, LTD.
    00-20-30   # ANALOG & DIGITAL SYSTEMS
    00-20-31   # Tattile SRL
    00-20-32   # ALCATEL TAISEL
    00-20-33   # SYNAPSE TECHNOLOGIES, INC.
    00-20-34   # ROTEC INDUSTRIEAUTOMATION GMBH
    00-20-35   # IBM Corp
    00-20-36   # BMC SOFTWARE
    00-20-37   # SEAGATE TECHNOLOGY
    00-20-38   # VME MICROSYSTEMS INTERNATIONAL CORPORATION
    00-20-39   # SCINETS
    00-20-3A   # DIGITAL BI0METRICS INC.
    00-20-3B   # WISDM LTD.
    00-20-3C   # EUROTIME AB
    00-20-3D   # Honeywell ECC
    00-20-3E   # LogiCan Technologies, Inc.
    00-20-3F   # JUKI CORPORATION
    00-20-40   # ARRIS Group, Inc.
    00-20-41   # DATA NET
    00-20-42   # DATAMETRICS CORP.
    00-20-43   # NEURON COMPANY LIMITED
    00-20-44   # GENITECH PTY LTD
    00-20-45   # ION Networks, Inc.
    00-20-46   # CIPRICO, INC.
    00-20-47   # STEINBRECHER CORP.
    00-20-48   # Marconi Communications
    00-20-49   # COMTRON, INC.
    00-20-4A   # PRONET GMBH
    00-20-4B   # AUTOCOMPUTER CO., LTD.
    00-20-4C   # MITRON COMPUTER PTE LTD.
    00-20-4D   # INOVIS GMBH
    00-20-4E   # NETWORK SECURITY SYSTEMS, INC.
    00-20-4F   # DEUTSCHE AEROSPACE AG
    00-20-50   # KOREA COMPUTER INC.
    00-20-51   # Verilink Corporation
    00-20-52   # RAGULA SYSTEMS
    00-20-53   # HUNTSVILLE MICROSYSTEMS, INC.
    00-20-54   # Sycamore Networks
    00-20-55   # ALTECH CO., LTD.
    00-20-56   # NEOPRODUCTS
    00-20-57   # TITZE DATENTECHNIK GmbH
    00-20-58   # ALLIED SIGNAL INC.
    00-20-59   # MIRO COMPUTER PRODUCTS AG
    00-20-5A   # COMPUTER IDENTICS
    00-20-5B   # Kentrox, LLC
    00-20-5C   # InterNet Systems of Florida, Inc.
    00-20-5D   # NANOMATIC OY
    00-20-5E   # CASTLE ROCK, INC.
    00-20-5F   # GAMMADATA COMPUTER GMBH
    00-20-60   # ALCATEL ITALIA S.p.A.
    00-20-61   # GarrettCom, Inc.
    00-20-62   # SCORPION LOGIC, LTD.
    00-20-63   # WIPRO INFOTECH LTD.
    00-20-64   # PROTEC MICROSYSTEMS, INC.
    00-20-65   # SUPERNET NETWORKING INC.
    00-20-66   # GENERAL MAGIC, INC.
    00-20-67   # Private
    00-20-68   # ISDYNE
    00-20-69   # ISDN SYSTEMS CORPORATION
    00-20-6A   # OSAKA COMPUTER CORP.
    00-20-6B   # KONICA MINOLTA HOLDINGS, INC.
    00-20-6C   # EVERGREEN TECHNOLOGY CORP.
    00-20-6D   # DATA RACE, INC.
    00-20-6E   # XACT, INC.
    00-20-6F   # FLOWPOINT CORPORATION
    00-20-70   # HYNET, LTD.
    00-20-71   # IBR GMBH
    00-20-72   # WORKLINK INNOVATIONS
    00-20-73   # FUSION SYSTEMS CORPORATION
    00-20-74   # SUNGWOON SYSTEMS
    00-20-75   # MOTOROLA COMMUNICATION ISRAEL
    00-20-76   # REUDO CORPORATION
    00-20-77   # KARDIOS SYSTEMS CORP.
    00-20-78   # RUNTOP, INC.
    00-20-79   # MIKRON GMBH
    00-20-7A   # WiSE Communications, Inc.
    00-20-7B   # Intel Corporation
    00-20-7C   # AUTEC GMBH
    00-20-7D   # ADVANCED COMPUTER APPLICATIONS
    00-20-7E   # FINECOM CO., LTD.
    00-20-7F   # KYOEI SANGYO CO., LTD.
    00-20-80   # SYNERGY (UK) LTD.
    00-20-81   # TITAN ELECTRONICS
    00-20-82   # ONEAC CORPORATION
    00-20-83   # PRESTICOM INCORPORATED
    00-20-84   # OCE PRINTING SYSTEMS, GMBH
    00-20-85   # Eaton Corporation
    00-20-86   # MICROTECH ELECTRONICS LIMITED
    00-20-87   # MEMOTEC, INC.
    00-20-88   # GLOBAL VILLAGE COMMUNICATION
    00-20-89   # T3PLUS NETWORKING, INC.
    00-20-8A   # SONIX COMMUNICATIONS, LTD.
    00-20-8B   # LAPIS TECHNOLOGIES, INC.
    00-20-8C   # GALAXY NETWORKS, INC.
    00-20-8D   # CMD TECHNOLOGY
    00-20-8E   # CHEVIN SOFTWARE ENG. LTD.
    00-20-8F   # ECI TELECOM LTD.
    00-20-90   # ADVANCED COMPRESSION TECHNOLOGY, INC.
    00-20-91   # J125, NATIONAL SECURITY AGENCY
    00-20-92   # CHESS ENGINEERING B.V.
    00-20-93   # LANDINGS TECHNOLOGY CORP.
    00-20-94   # CUBIX CORPORATION
    00-20-95   # RIVA ELECTRONICS
    00-20-96   # Invensys
    00-20-97   # APPLIED SIGNAL TECHNOLOGY
    00-20-98   # HECTRONIC AB
    00-20-99   # BON ELECTRIC CO., LTD.
    00-20-9A   # THE 3DO COMPANY
    00-20-9B   # ERSAT ELECTRONIC GMBH
    00-20-9C   # PRIMARY ACCESS CORP.
    00-20-9D   # LIPPERT AUTOMATIONSTECHNIK
    00-20-9E   # BROWN'S OPERATING SYSTEM SERVICES, LTD.
    00-20-9F   # MERCURY COMPUTER SYSTEMS, INC.
    00-20-A0   # OA LABORATORY CO., LTD.
    00-20-A1   # DOVATRON
    00-20-A2   # GALCOM NETWORKING LTD.
    00-20-A3   # Harmonic, Inc
    00-20-A4   # MULTIPOINT NETWORKS
    00-20-A5   # API ENGINEERING
    00-20-A6   # Proxim Wireless
    00-20-A7   # PAIRGAIN TECHNOLOGIES, INC.
    00-20-A8   # SAST TECHNOLOGY CORP.
    00-20-A9   # WHITE HORSE INDUSTRIAL
    00-20-AA   # Ericsson Television Limited
    00-20-AB   # MICRO INDUSTRIES CORP.
    00-20-AC   # INTERFLEX DATENSYSTEME GMBH
    00-20-AD   # LINQ SYSTEMS
    00-20-AE   # ORNET DATA COMMUNICATION TECH.
    00-20-AF   # 3COM CORPORATION
    00-20-B0   # GATEWAY DEVICES, INC.
    00-20-B1   # COMTECH RESEARCH INC.
    00-20-B2   # GKD Gesellschaft Fur Kommunikation Und Datentechnik
    00-20-B3   # Tattile SRL
    00-20-B4   # TERMA ELEKTRONIK AS
    00-20-B5   # YASKAWA ELECTRIC CORPORATION
    00-20-B6   # AGILE NETWORKS, INC.
    00-20-B7   # NAMAQUA COMPUTERWARE
    00-20-B8   # PRIME OPTION, INC.
    00-20-B9   # METRICOM, INC.
    00-20-BA   # CENTER FOR HIGH PERFORMANCE
    00-20-BB   # ZAX CORPORATION
    00-20-BC   # Long Reach Networks Pty Ltd
    00-20-BD   # NIOBRARA R & D CORPORATION
    00-20-BE   # LAN ACCESS CORP.
    00-20-BF   # AEHR TEST SYSTEMS
    00-20-C0   # PULSE ELECTRONICS, INC.
    00-20-C1   # SAXA, Inc.
    00-20-C2   # TEXAS MEMORY SYSTEMS, INC.
    00-20-C3   # COUNTER SOLUTIONS LTD.
    00-20-C4   # INET,INC.
    00-20-C5   # EAGLE TECHNOLOGY
    00-20-C6   # NECTEC
    00-20-C7   # AKAI Professional M.I. Corp.
    00-20-C8   # LARSCOM INCORPORATED
    00-20-C9   # VICTRON BV
    00-20-CA   # DIGITAL OCEAN
    00-20-CB   # PRETEC ELECTRONICS CORP.
    00-20-CC   # DIGITAL SERVICES, LTD.
    00-20-CD   # HYBRID NETWORKS, INC.
    00-20-CE   # LOGICAL DESIGN GROUP, INC.
    00-20-CF   # TEST & MEASUREMENT SYSTEMS INC
    00-20-D0   # VERSALYNX CORPORATION
    00-20-D1   # MICROCOMPUTER SYSTEMS (M) SDN.
    00-20-D2   # RAD DATA COMMUNICATIONS, LTD.
    00-20-D3   # OST (OUEST STANDARD TELEMATIQU
    00-20-D4   # Cabletron Systems, Inc.
    00-20-D5   # VIPA GMBH
    00-20-D6   # Breezecom, Ltd.
    00-20-D7   # JAPAN MINICOMPUTER SYSTEMS CO., Ltd.
    00-20-D8   # Nortel Networks
    00-20-D9   # PANASONIC TECHNOLOGIES, INC./MIECO-US
    00-20-DA   # Alcatel North America ESD
    00-20-DB   # XNET TECHNOLOGY, INC.
    00-20-DC   # DENSITRON TAIWAN LTD.
    00-20-DD   # Cybertec Pty Ltd
    00-20-DE   # JAPAN DIGITAL LABORAT'Y CO.LTD
    00-20-DF   # KYOSAN ELECTRIC MFG. CO., LTD.
    00-20-E0   # Actiontec Electronics, Inc
    00-20-E1   # ALAMAR ELECTRONICS
    00-20-E2   # INFORMATION RESOURCE ENGINEERING
    00-20-E3   # MCD KENCOM CORPORATION
    00-20-E4   # HSING TECH ENTERPRISE CO., LTD
    00-20-E5   # APEX DATA, INC.
    00-20-E6   # LIDKOPING MACHINE TOOLS AB
    00-20-E7   # B&W NUCLEAR SERVICE COMPANY
    00-20-E8   # DATATREK CORPORATION
    00-20-E9   # DANTEL
    00-20-EA   # EFFICIENT NETWORKS, INC.
    00-20-EB   # CINCINNATI MICROWAVE, INC.
    00-20-EC   # TECHWARE SYSTEMS CORP.
    00-20-ED   # GIGA-BYTE TECHNOLOGY CO., LTD.
    00-20-EE   # GTECH CORPORATION
    00-20-EF   # USC CORPORATION
    00-20-F0   # UNIVERSAL MICROELECTRONICS CO.
    00-20-F1   # ALTOS INDIA LIMITED
    00-20-F2   # Oracle Corporation
    00-20-F3   # RAYNET CORPORATION
    00-20-F4   # SPECTRIX CORPORATION
    00-20-F5   # PANDATEL AG
    00-20-F6   # NET TEK  AND KARLNET, INC.
    00-20-F7   # CYBERDATA CORPORATION
    00-20-F8   # CARRERA COMPUTERS, INC.
    00-20-F9   # PARALINK NETWORKS, INC.
    00-20-FA   # GDE SYSTEMS, INC.
    00-20-FB   # OCTEL COMMUNICATIONS CORP.
    00-20-FC   # MATROX
    00-20-FD   # ITV TECHNOLOGIES, INC.
    00-20-FE   # TOPWARE INC. / GRAND COMPUTER
    00-20-FF   # SYMMETRICAL TECHNOLOGIES
    00-21-00   # Gemtek Technology Co., Ltd.
    00-21-01   # Aplicaciones Electronicas Quasar (AEQ)
    00-21-02   # UpdateLogic Inc.
    00-21-03   # GHI Electronics, LLC
    00-21-04   # Gigaset Communications GmbH
    00-21-05   # Alcatel-Lucent
    00-21-06   # RIM Testing Services
    00-21-07   # Seowonintech Co Ltd.
    00-21-08   # Nokia Danmark A/S
    00-21-09   # Nokia Danmark A/S
    00-21-0A   # byd:sign Corporation
    00-21-0B   # GEMINI TRAZE RFID PVT. LTD.
    00-21-0C   # Cymtec Systems, Inc.
    00-21-0D   # SAMSIN INNOTEC
    00-21-0E   # Orpak Systems L.T.D.
    00-21-0F   # Cernium Corp
    00-21-10   # Clearbox Systems
    00-21-11   # Uniphone Inc.
    00-21-12   # WISCOM SYSTEM CO.,LTD
    00-21-13   # Padtec S/A
    00-21-14   # Hylab Technology Inc.
    00-21-15   # PHYWE Systeme GmbH & Co. KG
    00-21-16   # Transcon Electronic Systems, spol. s r. o.
    00-21-17   # Tellord
    00-21-18   # Athena Tech, Inc.
    00-21-19   # Samsung Electro-Mechanics
    00-21-1A   # LInTech Corporation
    00-21-1B   # Cisco Systems, Inc
    00-21-1C   # Cisco Systems, Inc
    00-21-1D   # Dataline AB
    00-21-1E   # ARRIS Group, Inc.
    00-21-1F   # SHINSUNG DELTATECH CO.,LTD.
    00-21-20   # Sequel Technologies
    00-21-21   # VRmagic GmbH
    00-21-22   # Chip-pro Ltd.
    00-21-23   # Aerosat Avionics
    00-21-24   # Optos Plc
    00-21-25   # KUK JE TONG SHIN Co.,LTD
    00-21-26   # Shenzhen Torch Equipment Co., Ltd.
    00-21-27   # TP-LINK TECHNOLOGIES CO.,LTD.
    00-21-28   # Oracle Corporation
    00-21-29   # Cisco-Linksys, LLC
    00-21-2A   # Audiovox Corporation
    00-21-2B   # MSA Auer
    00-21-2C   # SemIndia System Private Limited
    00-21-2D   # SCIMOLEX CORPORATION
    00-21-2E   # dresden-elektronik
    00-21-2F   # Phoebe Micro Inc.
    00-21-30   # Keico Hightech Inc.
    00-21-31   # Blynke Inc.
    00-21-32   # Masterclock, Inc.
    00-21-33   # Building B, Inc
    00-21-34   # Brandywine Communications
    00-21-35   # ALCATEL-LUCENT
    00-21-36   # ARRIS Group, Inc.
    00-21-37   # Bay Controls, LLC
    00-21-38   # Cepheid
    00-21-39   # Escherlogic Inc.
    00-21-3A   # Winchester Systems Inc.
    00-21-3B   # Berkshire Products, Inc
    00-21-3C   # AliphCom
    00-21-3D   # Cermetek Microelectronics, Inc.
    00-21-3E   # TomTom
    00-21-3F   # A-Team Technology Ltd.
    00-21-40   # EN Technologies Inc.
    00-21-41   # RADLIVE
    00-21-42   # Advanced Control Systems doo
    00-21-43   # ARRIS Group, Inc.
    00-21-44   # SS Telecoms
    00-21-45   # Semptian Technologies Ltd.
    00-21-46   # Sanmina-SCI
    00-21-47   # Nintendo Co., Ltd.
    00-21-48   # Kaco Solar Korea
    00-21-49   # China Daheng Group ,Inc.
    00-21-4A   # Pixel Velocity, Inc
    00-21-4B   # Shenzhen HAMP Science & Technology Co.,Ltd
    00-21-4C   # SAMSUNG ELECTRONICS CO., LTD.
    00-21-4D   # Guangzhou Skytone Transmission Technology Com. Ltd.
    00-21-4E   # GS Yuasa Power Supply Ltd.
    00-21-4F   # ALPS ELECTRIC CO.,LTD.
    00-21-50   # EYEVIEW ELECTRONICS
    00-21-51   # Millinet Co., Ltd.
    00-21-52   # General Satellite Research & Development Limited
    00-21-53   # SeaMicro Inc.
    00-21-54   # D-TACQ Solutions Ltd
    00-21-55   # Cisco Systems, Inc
    00-21-56   # Cisco Systems, Inc
    00-21-57   # National Datacast, Inc.
    00-21-58   # Style Flying Technology Co.
    00-21-59   # Juniper Networks
    00-21-5A   # Hewlett Packard
    00-21-5B   # Inotive
    00-21-5C   # Intel Corporate
    00-21-5D   # Intel Corporate
    00-21-5E   # IBM Corp
    00-21-5F   # IHSE GmbH
    00-21-60   # Hidea Solutions Co. Ltd.
    00-21-61   # Yournet Inc.
    00-21-62   # Nortel
    00-21-63   # ASKEY COMPUTER CORP
    00-21-64   # Special Design Bureau for Seismic Instrumentation
    00-21-65   # Presstek Inc.
    00-21-66   # NovAtel Inc.
    00-21-67   # HWA JIN T&I Corp.
    00-21-68   # iVeia, LLC
    00-21-69   # Prologix, LLC.
    00-21-6A   # Intel Corporate
    00-21-6B   # Intel Corporate
    00-21-6C   # ODVA
    00-21-6D   # Soltech Co., Ltd.
    00-21-6E   # Function ATI (Huizhou) Telecommunications Co., Ltd.
    00-21-6F   # SymCom, Inc.
    00-21-70   # Dell Inc.
    00-21-71   # Wesung TNC Co., Ltd.
    00-21-72   # Seoultek Valley
    00-21-73   # Ion Torrent Systems, Inc.
    00-21-74   # AvaLAN Wireless
    00-21-75   # Pacific Satellite International Ltd.
    00-21-76   # YMax Telecom Ltd.
    00-21-77   # W. L. Gore & Associates
    00-21-78   # Matuschek Messtechnik GmbH
    00-21-79   # IOGEAR, Inc.
    00-21-7A   # Sejin Electron, Inc.
    00-21-7B   # Bastec AB
    00-21-7C   # 2Wire Inc
    00-21-7D   # PYXIS S.R.L.
    00-21-7E   # Telit Communication s.p.a
    00-21-7F   # Intraco Technology Pte Ltd
    00-21-80   # ARRIS Group, Inc.
    00-21-81   # Si2 Microsystems Limited
    00-21-82   # SandLinks Systems, Ltd.
    00-21-83   # VATECH HYDRO
    00-21-84   # POWERSOFT SRL
    00-21-85   # MICRO-STAR INT'L CO.,LTD.
    00-21-86   # Universal Global Scientific Industrial Co., Ltd
    00-21-87   # Imacs GmbH
    00-21-88   # EMC Corporation
    00-21-89   # AppTech, Inc.
    00-21-8A   # Electronic Design and Manufacturing Company
    00-21-8B   # Wescon Technology, Inc.
    00-21-8C   # TopControl GMBH
    00-21-8D   # AP Router Ind. Eletronica LTDA
    00-21-8E   # MEKICS CO., LTD.
    00-21-8F   # Avantgarde Acoustic Lautsprechersysteme GmbH
    00-21-90   # Goliath Solutions
    00-21-91   # D-Link Corporation
    00-21-92   # Baoding Galaxy Electronic Technology  Co.,Ltd
    00-21-93   # Videofon MV
    00-21-94   # Ping Communication
    00-21-95   # GWD Media Limited
    00-21-96   # Telsey  S.p.A.
    00-21-97   # ELITEGROUP COMPUTER SYSTEM
    00-21-98   # Thai Radio Co, LTD
    00-21-99   # Vacon Plc
    00-21-9A   # Cambridge Visual Networks Ltd
    00-21-9B   # Dell Inc.
    00-21-9C   # Honeywld Technology Corp.
    00-21-9D   # Adesys BV
    00-21-9E   # Sony Mobile Communications AB
    00-21-9F   # SATEL OY
    00-21-A0   # Cisco Systems, Inc
    00-21-A1   # Cisco Systems, Inc
    00-21-A2   # EKE-Electronics Ltd.
    00-21-A3   # Micromint
    00-21-A4   # Dbii Networks
    00-21-A5   # ERLPhase Power Technologies Ltd.
    00-21-A6   # Videotec Spa
    00-21-A7   # Hantle System Co., Ltd.
    00-21-A8   # Telephonics Corporation
    00-21-A9   # Mobilink Telecom Co.,Ltd
    00-21-AA   # Nokia Danmark A/S
    00-21-AB   # Nokia Danmark A/S
    00-21-AC   # Infrared Integrated Systems Ltd
    00-21-AD   # Nordic ID Oy
    00-21-AE   # ALCATEL-LUCENT FRANCE - WTD
    00-21-AF   # Radio Frequency Systems
    00-21-B0   # Tyco Telecommunications
    00-21-B1   # DIGITAL SOLUTIONS LTD
    00-21-B2   # Fiberblaze A/S
    00-21-B3   # Ross Controls
    00-21-B4   # APRO MEDIA CO., LTD
    00-21-B5   # Galvanic Ltd
    00-21-B6   # Triacta Power Technologies Inc.
    00-21-B7   # Lexmark International Inc.
    00-21-B8   # Inphi Corporation
    00-21-B9   # Universal Devices Inc.
    00-21-BA   # Texas Instruments
    00-21-BB   # Riken Keiki Co., Ltd.
    00-21-BC   # ZALA COMPUTER
    00-21-BD   # Nintendo Co., Ltd.
    00-21-BE   # Cisco SPVTG
    00-21-BF   # Hitachi High-Tech Control Systems Corporation
    00-21-C0   # Mobile Appliance, Inc.
    00-21-C1   # ABB Oy / Medium Voltage Products
    00-21-C2   # GL Communications Inc
    00-21-C3   # CORNELL Communications, Inc.
    00-21-C4   # Consilium AB
    00-21-C5   # 3DSP Corp
    00-21-C6   # CSJ Global, Inc.
    00-21-C7   # Russound
    00-21-C8   # LOHUIS Networks
    00-21-C9   # Wavecom Asia Pacific Limited
    00-21-CA   # ART System Co., Ltd.
    00-21-CB   # SMS TECNOLOGIA ELETRONICA LTDA
    00-21-CC   # Flextronics International
    00-21-CD   # LiveTV
    00-21-CE   # NTC-Metrotek
    00-21-CF   # The Crypto Group
    00-21-D0   # Global Display Solutions Spa
    00-21-D1   # Samsung Electronics Co.,Ltd
    00-21-D2   # Samsung Electronics Co.,Ltd
    00-21-D3   # BOCOM SECURITY(ASIA PACIFIC) LIMITED
    00-21-D4   # Vollmer Werke GmbH
    00-21-D5   # X2E GmbH
    00-21-D6   # LXI Consortium
    00-21-D7   # Cisco Systems, Inc
    00-21-D8   # Cisco Systems, Inc
    00-21-D9   # SEKONIC CORPORATION
    00-21-DA   # Automation Products Group Inc.
    00-21-DB   # Santachi Video Technology (Shenzhen) Co., Ltd.
    00-21-DC   # TECNOALARM S.r.l.
    00-21-DD   # Northstar Systems Corp
    00-21-DE   # Firepro Wireless
    00-21-DF   # Martin Christ GmbH
    00-21-E0   # CommAgility Ltd
    00-21-E1   # Nortel Networks
    00-21-E2   # Creative Electronic GmbH
    00-21-E3   # SerialTek LLC
    00-21-E4   # I-WIN
    00-21-E5   # Display Solution AG
    00-21-E6   # Starlight Video Limited
    00-21-E7   # Informatics Services Corporation
    00-21-E8   # Murata Manufacturing Co., Ltd.
    00-21-E9   # Apple, Inc.
    00-21-EA   # Bystronic Laser AG
    00-21-EB   # ESP SYSTEMS, LLC
    00-21-EC   # Solutronic GmbH
    00-21-ED   # Telegesis
    00-21-EE   # Full Spectrum Inc.
    00-21-EF   # Kapsys
    00-21-F0   # EW3 Technologies LLC
    00-21-F1   # Tutus Data AB
    00-21-F2   # EASY3CALL Technology Limited
    00-21-F3   # Si14 SpA
    00-21-F4   # INRange Systems, Inc
    00-21-F5   # Western Engravers Supply, Inc.
    00-21-F6   # Oracle Corporation
    00-21-F7   # HPN Supply Chain
    00-21-F8   # Enseo, Inc.
    00-21-F9   # WIRECOM Technologies
    00-21-FA   # A4SP Technologies Ltd.
    00-21-FB   # LG Electronics
    00-21-FC   # Nokia Danmark A/S
    00-21-FD   # LACROIX TRAFFIC S.A.U
    00-21-FE   # Nokia Danmark A/S
    00-21-FF   # Cyfrowy Polsat SA
    00-22-00   # IBM Corp
    00-22-01   # Aksys Networks Inc
    00-22-02   # Excito Elektronik i Skåne AB
    00-22-03   # Glensound Electronics Ltd
    00-22-04   # KORATEK
    00-22-05   # WeLink Solutions, Inc.
    00-22-06   # Cyberdyne Inc.
    00-22-07   # Inteno Broadband Technology AB
    00-22-08   # Certicom Corp
    00-22-09   # Omron Healthcare Co., Ltd
    00-22-0A   # OnLive, Inc
    00-22-0B   # National Source Coding Center
    00-22-0C   # Cisco Systems, Inc
    00-22-0D   # Cisco Systems, Inc
    00-22-0E   # Indigo Security Co., Ltd.
    00-22-0F   # MoCA (Multimedia over Coax Alliance)
    00-22-10   # ARRIS Group, Inc.
    00-22-11   # Rohati Systems
    00-22-12   # CAI Networks, Inc.
    00-22-13   # PCI CORPORATION
    00-22-14   # RINNAI KOREA
    00-22-15   # ASUSTek COMPUTER INC.
    00-22-16   # SHIBAURA VENDING MACHINE CORPORATION
    00-22-17   # Neat Electronics
    00-22-18   # Verivue Inc.
    00-22-19   # Dell Inc.
    00-22-1A   # Audio Precision
    00-22-1B   # Morega Systems
    00-22-1C   # Private
    00-22-1D   # Freegene Technology LTD
    00-22-1E   # Media Devices Co., Ltd.
    00-22-1F   # eSang Technologies Co., Ltd.
    00-22-20   # Mitac Technology Corp
    00-22-21   # ITOH DENKI CO,LTD.
    00-22-22   # Schaffner Deutschland GmbH
    00-22-23   # TimeKeeping Systems, Inc.
    00-22-24   # Good Will Instrument Co., Ltd.
    00-22-25   # Thales Avionics Ltd
    00-22-26   # Avaak, Inc.
    00-22-27   # uv-electronic GmbH
    00-22-28   # Breeze Innovations Ltd.
    00-22-29   # Compumedics Ltd
    00-22-2A   # SoundEar A/S
    00-22-2B   # Nucomm, Inc.
    00-22-2C   # Ceton Corp
    00-22-2D   # SMC Networks Inc.
    00-22-2E   # maintech GmbH
    00-22-2F   # Open Grid Computing, Inc.
    00-22-30   # FutureLogic Inc.
    00-22-31   # SMT&C Co., Ltd.
    00-22-32   # Design Design Technology Ltd
    00-22-33   # ADB Broadband Italia
    00-22-34   # Corventis Inc.
    00-22-35   # Strukton Systems bv
    00-22-36   # VECTOR SP. Z O.O.
    00-22-37   # Shinhint Group
    00-22-38   # LOGIPLUS
    00-22-39   # Indiana Life Sciences Incorporated
    00-22-3A   # Cisco SPVTG
    00-22-3B   # Communication Networks, LLC
    00-22-3C   # RATIO Entwicklungen GmbH
    00-22-3D   # JumpGen Systems, LLC
    00-22-3E   # IRTrans GmbH
    00-22-3F   # NETGEAR
    00-22-40   # Universal Telecom S/A
    00-22-41   # Apple, Inc.
    00-22-42   # Alacron Inc.
    00-22-43   # AzureWave Technology Inc.
    00-22-44   # Chengdu Linkon Communications Device Co., Ltd
    00-22-45   # Leine & Linde AB
    00-22-46   # Evoc Intelligent Technology Co.,Ltd.
    00-22-47   # DAC ENGINEERING CO., LTD.
    00-22-48   # Microsoft Corporation
    00-22-49   # HOME MULTIENERGY SL
    00-22-4A   # RAYLASE AG
    00-22-4B   # AIRTECH TECHNOLOGIES, INC.
    00-22-4C   # Nintendo Co., Ltd.
    00-22-4D   # MITAC INTERNATIONAL CORP.
    00-22-4E   # SEEnergy Corp.
    00-22-4F   # Byzoro Networks Ltd.
    00-22-50   # Point Six Wireless, LLC
    00-22-51   # Lumasense Technologies
    00-22-52   # ZOLL Lifecor Corporation
    00-22-53   # Entorian Technologies
    00-22-54   # Bigelow Aerospace
    00-22-55   # Cisco Systems, Inc
    00-22-56   # Cisco Systems, Inc
    00-22-57   # 3COM EUROPE LTD
    00-22-58   # Taiyo Yuden Co., Ltd.
    00-22-59   # Guangzhou New Postcom Equipment Co.,Ltd.
    00-22-5A   # Garde Security AB
    00-22-5B   # Teradici Corporation
    00-22-5C   # Multimedia & Communication Technology
    00-22-5D   # Digicable Network India Pvt. Ltd.
    00-22-5E   # Uwin Technologies Co.,LTD
    00-22-5F   # Liteon Technology Corporation
    00-22-60   # AFREEY Inc.
    00-22-61   # Frontier Silicon Ltd
    00-22-62   # BEP Marine
    00-22-63   # Koos Technical Services, Inc.
    00-22-64   # Hewlett Packard
    00-22-65   # Nokia Danmark A/S
    00-22-66   # Nokia Danmark A/S
    00-22-67   # Nortel Networks
    00-22-68   # Hon Hai Precision Ind. Co.,Ltd.
    00-22-69   # Hon Hai Precision Ind. Co.,Ltd.
    00-22-6A   # Honeywell
    00-22-6B   # Cisco-Linksys, LLC
    00-22-6C   # LinkSprite Technologies, Inc.
    00-22-6D   # Shenzhen GIEC Electronics Co., Ltd.
    00-22-6E   # Gowell Electronic Limited
    00-22-6F   # 3onedata Technology Co. Ltd.
    00-22-70   # ABK North America, LLC
    00-22-71   # Jäger Computergesteuerte Meßtechnik GmbH.
    00-22-72   # American Micro-Fuel Device Corp.
    00-22-73   # Techway
    00-22-74   # FamilyPhone AB
    00-22-75   # Belkin International Inc.
    00-22-76   # Triple EYE B.V.
    00-22-77   # NEC Australia Pty Ltd
    00-22-78   # Shenzhen  Tongfang Multimedia  Technology Co.,Ltd.
    00-22-79   # Nippon Conlux Co., Ltd.
    00-22-7A   # Telecom Design
    00-22-7B   # Apogee Labs, Inc.
    00-22-7C   # Woori SMT Co.,ltd
    00-22-7D   # YE DATA INC.
    00-22-7E   # Chengdu 30Kaitian Communication Industry Co.Ltd
    00-22-7F   # Ruckus Wireless
    00-22-80   # A2B Electronics AB
    00-22-81   # Daintree Networks Pty
    00-22-82   # 8086 Consultancy
    00-22-83   # Juniper Networks
    00-22-84   # DESAY A&V SCIENCE AND TECHNOLOGY CO.,LTD
    00-22-85   # NOMUS COMM SYSTEMS
    00-22-86   # ASTRON
    00-22-87   # Titan Wireless LLC
    00-22-88   # Sagrad, Inc.
    00-22-89   # Optosecurity Inc.
    00-22-8A   # Teratronik elektronische systeme gmbh
    00-22-8B   # Kensington Computer Products Group
    00-22-8C   # Photon Europe GmbH
    00-22-8D   # GBS Laboratories LLC
    00-22-8E   # TV-NUMERIC
    00-22-8F   # CNRS
    00-22-90   # Cisco Systems, Inc
    00-22-91   # Cisco Systems, Inc
    00-22-92   # Cinetal
    00-22-93   # zte corporation
    00-22-94   # Kyocera Corporation
    00-22-95   # SGM Technology for lighting spa
    00-22-96   # LinoWave Corporation
    00-22-97   # XMOS Semiconductor
    00-22-98   # Sony Mobile Communications AB
    00-22-99   # SeaMicro Inc.
    00-22-9A   # Lastar, Inc.
    00-22-9B   # AverLogic Technologies, Inc.
    00-22-9C   # Verismo Networks Inc
    00-22-9D   # PYUNG-HWA IND.CO.,LTD
    00-22-9E   # Social Aid Research Co., Ltd.
    00-22-9F   # Sensys Traffic AB
    00-22-A0   # Delphi Corporation
    00-22-A1   # Huawei Symantec Technologies Co.,Ltd.
    00-22-A2   # Xtramus Technologies
    00-22-A3   # California Eastern Laboratories
    00-22-A4   # 2Wire Inc
    00-22-A5   # Texas Instruments
    00-22-A6   # Sony Computer Entertainment America
    00-22-A7   # Tyco Electronics AMP GmbH
    00-22-A8   # Ouman Oy
    00-22-A9   # LG Electronics Inc
    00-22-AA   # Nintendo Co., Ltd.
    00-22-AB   # Shenzhen Turbosight Technology Ltd
    00-22-AC   # Hangzhou Siyuan Tech. Co., Ltd
    00-22-AD   # TELESIS TECHNOLOGIES, INC.
    00-22-AE   # Mattel Inc.
    00-22-AF   # Safety Vision
    00-22-B0   # D-Link Corporation
    00-22-B1   # Elbit Systems
    00-22-B2   # 4RF Communications Ltd
    00-22-B3   # Sei S.p.A.
    00-22-B4   # ARRIS Group, Inc.
    00-22-B5   # NOVITA
    00-22-B6   # Superflow Technologies Group
    00-22-B7   # GSS Grundig SAT-Systems GmbH
    00-22-B8   # Norcott
    00-22-B9   # Analogix Seminconductor, Inc
    00-22-BA   # HUTH Elektronik Systeme GmbH
    00-22-BB   # beyerdynamic GmbH & Co. KG
    00-22-BC   # JDSU France SAS
    00-22-BD   # Cisco Systems, Inc
    00-22-BE   # Cisco Systems, Inc
    00-22-BF   # SieAmp Group of Companies
    00-22-C0   # Shenzhen Forcelink Electronic Co, Ltd
    00-22-C1   # Active Storage Inc.
    00-22-C2   # Proview Eletrônica do Brasil LTDA
    00-22-C3   # Zeeport Technology Inc.
    00-22-C4   # epro GmbH
    00-22-C5   # INFORSON Co,Ltd.
    00-22-C6   # Sutus Inc
    00-22-C7   # SEGGER Microcontroller GmbH & Co. KG
    00-22-C8   # Applied Instruments B.V.
    00-22-C9   # Lenord, Bauer & Co GmbH
    00-22-CA   # Anviz Biometric Tech. Co., Ltd.
    00-22-CB   # IONODES Inc.
    00-22-CC   # SciLog, Inc.
    00-22-CD   # Ared Technology Co., Ltd.
    00-22-CE   # Cisco SPVTG
    00-22-CF   # PLANEX Communications INC
    00-22-D0   # Polar Electro Oy
    00-22-D1   # Albrecht Jung GmbH & Co. KG
    00-22-D2   # All Earth Comércio de Eletrônicos LTDA.
    00-22-D3   # Hub-Tech
    00-22-D4   # ComWorth Co., Ltd.
    00-22-D5   # Eaton Corp. Electrical Group Data Center Solutions - Pulizzi
    00-22-D6   # Cypak AB
    00-22-D7   # Nintendo Co., Ltd.
    00-22-D8   # Shenzhen GST Security and Safety Technology Limited
    00-22-D9   # Fortex Industrial Ltd.
    00-22-DA   # ANATEK, LLC
    00-22-DB   # Translogic Corporation
    00-22-DC   # Vigil Health Solutions Inc.
    00-22-DD   # Protecta Electronics Ltd
    00-22-DE   # OPPO Digital, Inc.
    00-22-DF   # TAMUZ Monitors
    00-22-E0   # Atlantic Software Technologies S.r.L.
    00-22-E1   # ZORT Labs, LLC.
    00-22-E2   # WABTEC Transit Division
    00-22-E3   # Amerigon
    00-22-E4   # APASS TECHNOLOGY CO., LTD.
    00-22-E5   # Fisher-Rosemount Systems Inc.
    00-22-E6   # Intelligent Data
    00-22-E7   # WPS Parking Systems
    00-22-E8   # Applition Co., Ltd.
    00-22-E9   # ProVision Communications
    00-22-EA   # Rustelcom Inc.
    00-22-EB   # Data Respons A/S
    00-22-EC   # IDEALBT TECHNOLOGY CORPORATION
    00-22-ED   # TSI Power Corporation
    00-22-EE   # Algo Communication Products Ltd
    00-22-EF   # iWDL Technologies
    00-22-F0   # 3 Greens Aviation Limited
    00-22-F1   # Private
    00-22-F2   # SunPower Corp
    00-22-F3   # SHARP Corporation
    00-22-F4   # AMPAK Technology, Inc.
    00-22-F5   # Advanced Realtime Tracking GmbH
    00-22-F6   # Syracuse Research Corporation
    00-22-F7   # Conceptronic
    00-22-F8   # PIMA Electronic Systems Ltd.
    00-22-F9   # Pollin Electronic GmbH
    00-22-FA   # Intel Corporate
    00-22-FB   # Intel Corporate
    00-22-FC   # Nokia Danmark A/S
    00-22-FD   # Nokia Danmark A/S
    00-22-FE   # Advanced Illumination
    00-22-FF   # NIVIS LLC
    00-23-00   # Cayee Computer Ltd.
    00-23-01   # Witron Technology Limited
    00-23-02   # Cobalt Digital, Inc.
    00-23-03   # LITE-ON IT Corporation
    00-23-04   # Cisco Systems, Inc
    00-23-05   # Cisco Systems, Inc
    00-23-06   # ALPS ELECTRIC CO.,LTD.
    00-23-07   # FUTURE INNOVATION TECH CO.,LTD
    00-23-08   # Arcadyan Technology Corporation
    00-23-09   # Janam Technologies LLC
    00-23-0A   # ARBURG GmbH & Co KG
    00-23-0B   # ARRIS Group, Inc.
    00-23-0C   # CLOVER ELECTRONICS CO.,LTD.
    00-23-0D   # Nortel Networks
    00-23-0E   # Gorba AG
    00-23-0F   # Hirsch Electronics Corporation
    00-23-10   # LNC Technology Co., Ltd.
    00-23-11   # Gloscom Co., Ltd.
    00-23-12   # Apple, Inc.
    00-23-13   # Qool Technologies Ltd.
    00-23-14   # Intel Corporate
    00-23-15   # Intel Corporate
    00-23-16   # KISAN ELECTRONICS CO
    00-23-17   # Lasercraft Inc
    00-23-18   # Toshiba
    00-23-19   # Sielox LLC
    00-23-1A   # ITF Co., Ltd.
    00-23-1B   # Danaher Motion - Kollmorgen
    00-23-1C   # Fourier Systems Ltd.
    00-23-1D   # Deltacom Electronics Ltd
    00-23-1E   # Cezzer Multimedia Technologies
    00-23-1F   # Guangda Electronic & Telecommunication Technology Development Co., Ltd.
    00-23-20   # Nicira Networks
    00-23-21   # Avitech International Corp
    00-23-22   # KISS Teknical Solutions, Inc.
    00-23-23   # Zylin AS
    00-23-24   # G-PRO COMPUTER
    00-23-25   # IOLAN Holding
    00-23-26   # FUJITSU LIMITED
    00-23-27   # Shouyo Electronics CO., LTD
    00-23-28   # ALCON TELECOMMUNICATIONS CO., LTD.
    00-23-29   # DDRdrive LLC
    00-23-2A   # eonas IT-Beratung und -Entwicklung GmbH
    00-23-2B   # IRD A/S
    00-23-2C   # Senticare
    00-23-2D   # SandForce
    00-23-2E   # Kedah Electronics Engineering, LLC
    00-23-2F   # Advanced Card Systems Ltd.
    00-23-30   # DIZIPIA, INC.
    00-23-31   # Nintendo Co., Ltd.
    00-23-32   # Apple, Inc.
    00-23-33   # Cisco Systems, Inc
    00-23-34   # Cisco Systems, Inc
    00-23-35   # Linkflex Co.,Ltd
    00-23-36   # METEL s.r.o.
    00-23-37   # Global Star Solutions ULC
    00-23-38   # OJ-Electronics A/S
    00-23-39   # Samsung Electronics
    00-23-3A   # Samsung Electronics Co.,Ltd
    00-23-3B   # C-Matic Systems Ltd
    00-23-3C   # Alflex
    00-23-3D   # Novero holding B.V.
    00-23-3E   # Alcatel-Lucent-IPD
    00-23-3F   # Purechoice Inc
    00-23-40   # MiXTelematics
    00-23-41   # Siemens AB, Infrastructure & Cities, Building Technologies Division, IC BT SSP SP BA PR
    00-23-42   # Coffee Equipment Company
    00-23-43   # TEM AG
    00-23-44   # Objective Interface Systems, Inc.
    00-23-45   # Sony Mobile Communications AB
    00-23-46   # Vestac
    00-23-47   # ProCurve Networking by HP
    00-23-48   # Sagemcom Broadband SAS
    00-23-49   # Helmholtz Centre Berlin for Material and Energy
    00-23-4A   # Private
    00-23-4B   # Inyuan Technology Inc.
    00-23-4C   # KTC AB
    00-23-4D   # Hon Hai Precision Ind. Co.,Ltd.
    00-23-4E   # Hon Hai Precision Ind. Co.,Ltd.
    00-23-4F   # Luminous Power Technologies Pvt. Ltd.
    00-23-50   # LynTec
    00-23-51   # 2Wire Inc
    00-23-52   # DATASENSOR S.p.A.
    00-23-53   # F E T Elettronica snc
    00-23-54   # ASUSTek COMPUTER INC.
    00-23-55   # Kinco Automation(Shanghai) Ltd.
    00-23-56   # Packet Forensics LLC
    00-23-57   # Pitronot Technologies and Engineering P.T.E. Ltd.
    00-23-58   # SYSTEL SA
    00-23-59   # Benchmark Electronics ( Thailand ) Public Company Limited
    00-23-5A   # COMPAL INFORMATION (KUNSHAN) CO., LTD.
    00-23-5B   # Gulfstream
    00-23-5C   # Aprius, Inc.
    00-23-5D   # Cisco Systems, Inc
    00-23-5E   # Cisco Systems, Inc
    00-23-5F   # Silicon Micro Sensors GmbH
    00-23-60   # Lookit Technology Co., Ltd
    00-23-61   # Unigen Corporation
    00-23-62   # Goldline Controls
    00-23-63   # Zhuhai RaySharp Technology Co., Ltd.
    00-23-64   # Power Instruments Pte Ltd
    00-23-65   # ELKA-Elektronik GmbH
    00-23-66   # Beijing Siasun Electronic System Co.,Ltd.
    00-23-67   # UniControls a.s.
    00-23-68   # Zebra Technologies Inc
    00-23-69   # Cisco-Linksys, LLC
    00-23-6A   # SmartRG Inc
    00-23-6B   # Xembedded, Inc.
    00-23-6C   # Apple, Inc.
    00-23-6D   # ResMed Ltd
    00-23-6E   # Burster GmbH & Co KG
    00-23-6F   # DAQ System
    00-23-70   # Snell
    00-23-71   # SOAM Systel
    00-23-72   # MORE STAR INDUSTRIAL GROUP LIMITED
    00-23-73   # GridIron Systems, Inc.
    00-23-74   # ARRIS Group, Inc.
    00-23-75   # ARRIS Group, Inc.
    00-23-76   # HTC Corporation
    00-23-77   # Isotek Electronics Ltd
    00-23-78   # GN Netcom A/S
    00-23-79   # Union Business Machines Co. Ltd.
    00-23-7A   # RIM
    00-23-7B   # WHDI LLC
    00-23-7C   # NEOTION
    00-23-7D   # Hewlett Packard
    00-23-7E   # ELSTER GMBH
    00-23-7F   # PLANTRONICS, INC.
    00-23-80   # Nanoteq
    00-23-81   # Lengda Technology(Xiamen) Co.,Ltd.
    00-23-82   # Lih Rong Electronic Enterprise Co., Ltd.
    00-23-83   # InMage Systems Inc
    00-23-84   # GGH Engineering s.r.l.
    00-23-85   # ANTIPODE
    00-23-86   # Tour & Andersson AB
    00-23-87   # ThinkFlood, Inc.
    00-23-88   # V.T. Telematica S.p.a.
    00-23-89   # HANGZHOU H3C Technologies Co., Ltd.
    00-23-8A   # Ciena Corporation
    00-23-8B   # Quanta Computer Inc.
    00-23-8C   # Private
    00-23-8D   # Techno Design Co., Ltd.
    00-23-8E   # ADB Broadband Italia
    00-23-8F   # NIDEC COPAL CORPORATION
    00-23-90   # Algolware Corporation
    00-23-91   # Maxian
    00-23-92   # Proteus Industries Inc.
    00-23-93   # AJINEXTEK
    00-23-94   # Samjeon
    00-23-95   # ARRIS Group, Inc.
    00-23-96   # ANDES TECHNOLOGY CORPORATION
    00-23-97   # Westell Technologies Inc.
    00-23-98   # Vutlan sro
    00-23-99   # VD Division, Samsung Electronics Co.
    00-23-9A   # EasyData Hardware GmbH
    00-23-9B   # Elster Solutions, LLC
    00-23-9C   # Juniper Networks
    00-23-9D   # Mapower Electronics Co., Ltd
    00-23-9E   # Jiangsu Lemote Technology Corporation Limited
    00-23-9F   # Institut für Prüftechnik
    00-23-A0   # Hana CNS Co., LTD.
    00-23-A1   # Trend Electronics Ltd
    00-23-A2   # ARRIS Group, Inc.
    00-23-A3   # ARRIS Group, Inc.
    00-23-A4   # New Concepts Development Corp.
    00-23-A5   # SageTV, LLC
    00-23-A6   # E-Mon
    00-23-A7   # Redpine Signals, Inc.
    00-23-A8   # Marshall Electronics
    00-23-A9   # Beijing Detianquan Electromechanical Equipment Co., Ltd
    00-23-AA   # HFR, Inc.
    00-23-AB   # Cisco Systems, Inc
    00-23-AC   # Cisco Systems, Inc
    00-23-AD   # Xmark Corporation
    00-23-AE   # Dell Inc.
    00-23-AF   # ARRIS Group, Inc.
    00-23-B0   # COMXION Technology Inc.
    00-23-B1   # Longcheer Technology (Singapore) Pte Ltd
    00-23-B2   # Intelligent Mechatronic Systems Inc
    00-23-B3   # Lyyn AB
    00-23-B4   # Nokia Danmark A/S
    00-23-B5   # ORTANA LTD
    00-23-B6   # SECURITE COMMUNICATIONS / HONEYWELL
    00-23-B7   # Q-Light Co., Ltd.
    00-23-B8   # Sichuan Jiuzhou Electronic Technology Co.,Ltd
    00-23-B9   # EADS Deutschland GmbH
    00-23-BA   # Chroma
    00-23-BB   # Schmitt Industries
    00-23-BC   # EQ-SYS GmbH
    00-23-BD   # Digital Ally, Inc.
    00-23-BE   # Cisco SPVTG
    00-23-BF   # Mainpine, Inc.
    00-23-C0   # Broadway Networks
    00-23-C1   # Securitas Direct AB
    00-23-C2   # SAMSUNG Electronics. Co. LTD
    00-23-C3   # LogMeIn, Inc.
    00-23-C4   # Lux Lumen
    00-23-C5   # Radiation Safety and Control Services Inc
    00-23-C6   # SMC Corporation
    00-23-C7   # AVSystem
    00-23-C8   # TEAM-R
    00-23-C9   # Sichuan Tianyi Information Science & Technology Stock CO.,LTD
    00-23-CA   # Behind The Set, LLC
    00-23-CB   # Shenzhen Full-join Technology Co.,Ltd
    00-23-CC   # Nintendo Co., Ltd.
    00-23-CD   # TP-LINK TECHNOLOGIES CO.,LTD.
    00-23-CE   # KITA DENSHI CORPORATION
    00-23-CF   # CUMMINS-ALLISON CORP.
    00-23-D0   # Uniloc USA Inc.
    00-23-D1   # TRG
    00-23-D2   # Inhand Electronics, Inc.
    00-23-D3   # AirLink WiFi Networking Corp.
    00-23-D4   # Texas Instruments
    00-23-D5   # WAREMA electronic GmbH
    00-23-D6   # Samsung Electronics Co.,LTD
    00-23-D7   # Samsung Electronics
    00-23-D8   # Ball-It Oy
    00-23-D9   # Banner Engineering
    00-23-DA   # Industrial Computer Source (Deutschland)GmbH
    00-23-DB   # saxnet gmbh
    00-23-DC   # Benein, Inc
    00-23-DD   # ELGIN S.A.
    00-23-DE   # Ansync Inc.
    00-23-DF   # Apple, Inc.
    00-23-E0   # INO Therapeutics LLC
    00-23-E1   # Cavena Image Products AB
    00-23-E2   # SEA Signalisation
    00-23-E3   # Microtronic AG
    00-23-E4   # IPnect co. ltd.
    00-23-E5   # IPaXiom Networks
    00-23-E6   # Pirkus, Inc.
    00-23-E7   # Hinke A/S
    00-23-E8   # Demco Corp.
    00-23-E9   # F5 Networks, Inc.
    00-23-EA   # Cisco Systems, Inc
    00-23-EB   # Cisco Systems, Inc
    00-23-EC   # Algorithmix GmbH
    00-23-ED   # ARRIS Group, Inc.
    00-23-EE   # ARRIS Group, Inc.
    00-23-EF   # Zuend Systemtechnik AG
    00-23-F0   # Shanghai Jinghan Weighing Apparatus Co. Ltd.
    00-23-F1   # Sony Mobile Communications AB
    00-23-F2   # TVLogic
    00-23-F3   # Glocom, Inc.
    00-23-F4   # Masternaut
    00-23-F5   # WILO SE
    00-23-F6   # Softwell Technology Co., Ltd.
    00-23-F7   # Private
    00-23-F8   # ZyXEL Communications Corporation
    00-23-F9   # Double-Take Software, INC.
    00-23-FA   # RG Nets, Inc.
    00-23-FB   # IP Datatel, LLC.
    00-23-FC   # Ultra Stereo Labs, Inc
    00-23-FD   # AFT Atlas Fahrzeugtechnik GmbH
    00-23-FE   # Biodevices, SA
    00-23-FF   # Beijing HTTC Technology Ltd.
    00-24-00   # Nortel Networks
    00-24-01   # D-Link Corporation
    00-24-02   # Op-Tection GmbH
    00-24-03   # Nokia Danmark A/S
    00-24-04   # Nokia Danmark A/S
    00-24-05   # Dilog Nordic AB
    00-24-06   # Pointmobile
    00-24-07   # TELEM SAS
    00-24-08   # Pacific Biosciences
    00-24-09   # The Toro Company
    00-24-0A   # US Beverage Net
    00-24-0B   # Virtual Computer Inc.
    00-24-0C   # DELEC GmbH
    00-24-0D   # OnePath Networks LTD.
    00-24-0E   # Inventec Besta Co., Ltd.
    00-24-0F   # Ishii Tool & Engineering Corporation
    00-24-10   # NUETEQ Technology,Inc.
    00-24-11   # PharmaSmart LLC
    00-24-12   # Benign Technologies Co, Ltd.
    00-24-13   # Cisco Systems, Inc
    00-24-14   # Cisco Systems, Inc
    00-24-15   # Magnetic Autocontrol GmbH
    00-24-16   # Any Use
    00-24-17   # Thomson Telecom Belgium
    00-24-18   # Nextwave Semiconductor
    00-24-19   # Private
    00-24-1A   # Red Beetle Inc.
    00-24-1B   # iWOW Communications Pte Ltd
    00-24-1C   # FuGang Electronic (DG) Co.,Ltd
    00-24-1D   # GIGA-BYTE TECHNOLOGY CO.,LTD.
    00-24-1E   # Nintendo Co., Ltd.
    00-24-1F   # DCT-Delta GmbH
    00-24-20   # NetUP Inc.
    00-24-21   # MICRO-STAR INT'L CO., LTD.
    00-24-22   # Knapp Logistik Automation GmbH
    00-24-23   # AzureWave Technologies (Shanghai) Inc.
    00-24-24   # Axis Network Technology
    00-24-25   # Shenzhenshi chuangzhicheng Technology Co.,Ltd
    00-24-26   # NOHMI BOSAI LTD.
    00-24-27   # SSI COMPUTER CORP
    00-24-28   # EnergyICT
    00-24-29   # MK MASTER INC.
    00-24-2A   # Hittite Microwave Corporation
    00-24-2B   # Hon Hai Precision Ind. Co.,Ltd.
    00-24-2C   # Hon Hai Precision Ind. Co.,Ltd.
    00-24-2E   # Datastrip Inc.
    00-24-2F   # Micron
    00-24-30   # Ruby Tech Corp.
    00-24-31   # Uni-v co.,ltd
    00-24-32   # Neostar Technology Co.,LTD
    00-24-33   # ALPS ELECTRIC CO.,LTD.
    00-24-34   # Lectrosonics, Inc.
    00-24-35   # WIDE CORPORATION
    00-24-36   # Apple, Inc.
    00-24-37   # Motorola - BSG
    00-24-38   # Brocade Communications Systems, Inc.
    00-24-39   # Digital Barriers Advanced Technologies
    00-24-3A   # Ludl Electronic Products
    00-24-3B   # CSSI (S) Pte Ltd
    00-24-3C   # S.A.A.A.
    00-24-3D   # Emerson Appliance Motors and Controls
    00-24-3F   # Storwize, Inc.
    00-24-40   # Halo Monitoring, Inc.
    00-24-41   # Wanzl Metallwarenfabrik GmbH
    00-24-42   # Axona Limited
    00-24-43   # Nortel Networks
    00-24-44   # Nintendo Co., Ltd.
    00-24-45   # CommScope Canada Inc.
    00-24-46   # MMB Research Inc.
    00-24-47   # Kaztek Systems
    00-24-48   # SpiderCloud Wireless, Inc
    00-24-49   # Shen Zhen Lite Star Electronics Technology Co., Ltd
    00-24-4A   # Voyant International
    00-24-4B   # PERCEPTRON INC
    00-24-4C   # Solartron Metrology Ltd
    00-24-4D   # Hokkaido Electronics Corporation
    00-24-4E   # RadChips, Inc.
    00-24-4F   # Asantron Technologies Ltd.
    00-24-50   # Cisco Systems, Inc
    00-24-51   # Cisco Systems, Inc
    00-24-52   # Silicon Software GmbH
    00-24-53   # Initra d.o.o.
    00-24-54   # Samsung Electronics CO., LTD
    00-24-55   # MuLogic BV
    00-24-56   # 2Wire Inc
    00-24-58   # PA Bastion CC
    00-24-59   # ABB Automation products GmbH
    00-24-5A   # Nanjing Panda Electronics Company Limited
    00-24-5B   # RAIDON TECHNOLOGY, INC.
    00-24-5C   # Design-Com Technologies Pty. Ltd.
    00-24-5D   # Terberg besturingstechniek B.V.
    00-24-5E   # Hivision Co.,ltd
    00-24-5F   # Vine Telecom CO.,Ltd.
    00-24-60   # Giaval Science Development Co. Ltd.
    00-24-61   # Shin Wang Tech.
    00-24-62   # Rayzone Corporation
    00-24-63   # Phybridge Inc
    00-24-64   # Bridge Technologies Co AS
    00-24-65   # Elentec
    00-24-66   # Unitron nv
    00-24-67   # AOC International (Europe) GmbH
    00-24-68   # Sumavision Technologies Co.,Ltd
    00-24-69   # Smart Doorphones
    00-24-6A   # Solid Year Co., Ltd.
    00-24-6B   # Covia, Inc.
    00-24-6C   # Aruba Networks
    00-24-6D   # Weinzierl Engineering GmbH
    00-24-6E   # Phihong USA Corp.
    00-24-6F   # Onda Communication spa
    00-24-70   # AUROTECH ultrasound AS.
    00-24-71   # Fusion MultiSystems dba Fusion-io
    00-24-72   # ReDriven Power Inc.
    00-24-73   # 3COM EUROPE LTD
    00-24-74   # Autronica Fire And Securirty
    00-24-75   # Compass System(Embedded Dept.)
    00-24-76   # TAP.tv
    00-24-77   # Tibbo Technology
    00-24-78   # Mag Tech Electronics Co Limited
    00-24-79   # Optec Displays, Inc.
    00-24-7A   # FU YI CHENG Technology Co., Ltd.
    00-24-7B   # Actiontec Electronics, Inc
    00-24-7C   # Nokia Danmark A/S
    00-24-7D   # Nokia Danmark A/S
    00-24-7E   # Universal Global Scientific Industrial Co., Ltd
    00-24-7F   # Nortel Networks
    00-24-80   # Meteocontrol GmbH
    00-24-81   # Hewlett Packard
    00-24-82   # Ruckus Wireless
    00-24-83   # LG Electronics
    00-24-84   # Bang and Olufsen Medicom a/s
    00-24-85   # ConteXtream Ltd
    00-24-86   # DesignArt Networks
    00-24-87   # Blackboard Inc.
    00-24-88   # Centre For Development Of Telematics
    00-24-89   # Vodafone Omnitel N.V.
    00-24-8A   # Kaga Electronics Co., Ltd.
    00-24-8B   # HYBUS CO., LTD.
    00-24-8C   # ASUSTek COMPUTER INC.
    00-24-8D   # Sony Computer Entertainment Inc.
    00-24-8E   # Infoware ZRt.
    00-24-8F   # DO-MONIX
    00-24-90   # Samsung Electronics Co.,LTD
    00-24-91   # Samsung Electronics
    00-24-92   # Motorola, Broadband Solutions Group
    00-24-93   # ARRIS Group, Inc.
    00-24-94   # Shenzhen Baoxin Tech CO., Ltd.
    00-24-95   # ARRIS Group, Inc.
    00-24-96   # Ginzinger electronic systems
    00-24-97   # Cisco Systems, Inc
    00-24-98   # Cisco Systems, Inc
    00-24-99   # Aquila Technologies
    00-24-9A   # Beijing Zhongchuang Telecommunication Test Co., Ltd.
    00-24-9B   # Action Star Enterprise Co., Ltd.
    00-24-9C   # Bimeng Comunication System Co. Ltd
    00-24-9D   # NES Technology Inc.
    00-24-9E   # ADC-Elektronik GmbH
    00-24-9F   # RIM Testing Services
    00-24-A0   # ARRIS Group, Inc.
    00-24-A1   # ARRIS Group, Inc.
    00-24-A2   # Hong Kong Middleware Technology Limited
    00-24-A3   # Sonim Technologies Inc
    00-24-A4   # Siklu Communication
    00-24-A5   # BUFFALO.INC
    00-24-A6   # TELESTAR DIGITAL GmbH
    00-24-A7   # Advanced Video Communications Inc.
    00-24-A8   # ProCurve Networking by HP
    00-24-A9   # Ag Leader Technology
    00-24-AA   # Dycor Technologies Ltd.
    00-24-AB   # A7 Engineering, Inc.
    00-24-AC   # Hangzhou DPtech Technologies Co., Ltd.
    00-24-AD   # Adolf Thies Gmbh & Co. KG
    00-24-AE   # Morpho
    00-24-AF   # EchoStar Technologies
    00-24-B0   # ESAB AB
    00-24-B1   # Coulomb Technologies
    00-24-B2   # NETGEAR
    00-24-B3   # Graf-Syteco GmbH & Co. KG
    00-24-B4   # ESCATRONIC GmbH
    00-24-B5   # Nortel Networks
    00-24-B6   # Seagate Technology
    00-24-B7   # GridPoint, Inc.
    00-24-B8   # free alliance sdn bhd
    00-24-B9   # Wuhan Higheasy Electronic Technology Development Co.Ltd
    00-24-BA   # Texas Instruments
    00-24-BB   # CENTRAL Corporation
    00-24-BC   # HuRob Co.,Ltd
    00-24-BD   # Hainzl Industriesysteme GmbH
    00-24-BE   # Sony Corporation
    00-24-BF   # CIAT
    00-24-C0   # NTI COMODO INC
    00-24-C1   # ARRIS Group, Inc.
    00-24-C2   # Asumo Co.,Ltd.
    00-24-C3   # Cisco Systems, Inc
    00-24-C4   # Cisco Systems, Inc
    00-24-C5   # Meridian Audio Limited
    00-24-C6   # Hager Electro SAS
    00-24-C7   # Mobilarm Ltd
    00-24-C8   # Broadband Solutions Group
    00-24-C9   # Broadband Solutions Group
    00-24-CA   # Tobii Technology AB
    00-24-CB   # Autonet Mobile
    00-24-CC   # Fascinations Toys and Gifts, Inc.
    00-24-CD   # Willow Garage, Inc.
    00-24-CE   # Exeltech Inc
    00-24-CF   # Inscape Data Corporation
    00-24-D0   # Shenzhen SOGOOD Industry CO.,LTD.
    00-24-D1   # Thomson Inc.
    00-24-D2   # ASKEY COMPUTER CORP
    00-24-D3   # QUALICA Inc.
    00-24-D4   # FREEBOX SAS
    00-24-D5   # Winward Industrial Limited
    00-24-D6   # Intel Corporate
    00-24-D7   # Intel Corporate
    00-24-D8   # IlSung Precision
    00-24-D9   # BICOM, Inc.
    00-24-DA   # Innovar Systems Limited
    00-24-DB   # Alcohol Monitoring Systems
    00-24-DC   # Juniper Networks
    00-24-DD   # Centrak, Inc.
    00-24-DE   # GLOBAL Technology Inc.
    00-24-DF   # Digitalbox Europe GmbH
    00-24-E0   # DS Tech, LLC
    00-24-E1   # Convey Computer Corp.
    00-24-E2   # HASEGAWA ELECTRIC CO.,LTD.
    00-24-E3   # CAO Group
    00-24-E4   # Withings
    00-24-E5   # Seer Technology, Inc
    00-24-E6   # In Motion Technology Inc.
    00-24-E7   # Plaster Networks
    00-24-E8   # Dell Inc.
    00-24-E9   # Samsung Electronics Co., Ltd., Storage System Division
    00-24-EA   # iris-GmbH infrared & intelligent sensors
    00-24-EB   # ClearPath Networks, Inc.
    00-24-EC   # United Information Technology Co.,Ltd.
    00-24-ED   # YT Elec. Co,.Ltd.
    00-24-EE   # Wynmax Inc.
    00-24-EF   # Sony Mobile Communications AB
    00-24-F0   # Seanodes
    00-24-F1   # Shenzhen Fanhai Sanjiang Electronics Co., Ltd.
    00-24-F2   # Uniphone Telecommunication Co., Ltd.
    00-24-F3   # Nintendo Co., Ltd.
    00-24-F4   # Kaminario Technologies Ltd.
    00-24-F5   # NDS Surgical Imaging
    00-24-F6   # MIYOSHI ELECTRONICS CORPORATION
    00-24-F7   # Cisco Systems, Inc
    00-24-F8   # Technical Solutions Company Ltd.
    00-24-F9   # Cisco Systems, Inc
    00-24-FA   # Hilger u. Kern GMBH
    00-24-FB   # Private
    00-24-FC   # QuoPin Co., Ltd.
    00-24-FD   # Accedian Networks Inc
    00-24-FE   # AVM GmbH
    00-24-FF   # QLogic Corporation
    00-25-00   # Apple, Inc.
    00-25-01   # JSC Supertel
    00-25-02   # NaturalPoint
    00-25-03   # IBM Corp
    00-25-04   # Valiant Communications Limited
    00-25-05   # eks Engel GmbH & Co. KG
    00-25-06   # A.I. ANTITACCHEGGIO ITALIA SRL
    00-25-07   # ASTAK Inc.
    00-25-08   # Maquet Cardiopulmonary AG
    00-25-09   # SHARETRONIC Group LTD
    00-25-0A   # Security Expert Co. Ltd
    00-25-0B   # CENTROFACTOR  INC
    00-25-0C   # Enertrac
    00-25-0D   # GZT Telkom-Telmor sp. z o.o.
    00-25-0E   # gt german telematics gmbh
    00-25-0F   # On-Ramp Wireless, Inc.
    00-25-10   # Pico-Tesla Magnetic Therapies
    00-25-11   # ELITEGROUP COMPUTER SYSTEM CO., LTD.
    00-25-12   # zte corporation
    00-25-13   # CXP DIGITAL BV
    00-25-14   # PC Worth Int'l Co., Ltd.
    00-25-15   # SFR
    00-25-16   # Integrated Design Tools, Inc.
    00-25-17   # Venntis, LLC
    00-25-18   # Power PLUS Communications AG
    00-25-19   # Viaas Inc
    00-25-1A   # Psiber Data Systems Inc.
    00-25-1B   # Philips CareServant
    00-25-1C   # EDT
    00-25-1D   # DSA Encore, LLC
    00-25-1E   # ROTEL TECHNOLOGIES
    00-25-1F   # ZYNUS VISION INC.
    00-25-20   # SMA Railway Technology GmbH
    00-25-21   # Logitek Electronic Systems, Inc.
    00-25-22   # ASRock Incorporation
    00-25-23   # OCP Inc.
    00-25-24   # Lightcomm Technology Co., Ltd
    00-25-25   # CTERA Networks Ltd.
    00-25-26   # Genuine Technologies Co., Ltd.
    00-25-27   # Bitrode Corp.
    00-25-28   # Daido Signal Co., Ltd.
    00-25-29   # COMELIT GROUP S.P.A
    00-25-2A   # Chengdu GeeYa Technology Co.,LTD
    00-25-2B   # Stirling Energy Systems
    00-25-2C   # Entourage Systems, Inc.
    00-25-2D   # Kiryung Electronics
    00-25-2E   # Cisco SPVTG
    00-25-2F   # Energy, Inc.
    00-25-30   # Aetas Systems Inc.
    00-25-31   # Cloud Engines, Inc.
    00-25-32   # Digital Recorders
    00-25-33   # WITTENSTEIN AG
    00-25-35   # Minimax GmbH & Co KG
    00-25-36   # Oki Electric Industry Co., Ltd.
    00-25-37   # Runcom Technologies Ltd.
    00-25-38   # Samsung Electronics Co., Ltd., Memory Division
    00-25-39   # IfTA GmbH
    00-25-3A   # CEVA, Ltd.
    00-25-3B   # din Dietmar Nocker Facilitymanagement GmbH
    00-25-3C   # 2Wire Inc
    00-25-3D   # DRS Consolidated Controls
    00-25-3E   # Sensus Metering Systems
    00-25-40   # Quasar Technologies, Inc.
    00-25-41   # Maquet Critical Care AB
    00-25-42   # Pittasoft
    00-25-43   # MONEYTECH
    00-25-44   # LoJack Corporation
    00-25-45   # Cisco Systems, Inc
    00-25-46   # Cisco Systems, Inc
    00-25-47   # Nokia Danmark A/S
    00-25-48   # Nokia Danmark A/S
    00-25-49   # Jeorich Tech. Co.,Ltd.
    00-25-4A   # RingCube Technologies, Inc.
    00-25-4B   # Apple, Inc.
    00-25-4C   # Videon Central, Inc.
    00-25-4D   # Singapore Technologies Electronics Limited
    00-25-4E   # Vertex Wireless Co., Ltd.
    00-25-4F   # ELETTROLAB Srl
    00-25-50   # Riverbed Technology
    00-25-51   # SE-Elektronic GmbH
    00-25-52   # VXI CORPORATION
    00-25-53   # ADB Broadband Italia
    00-25-54   # Pixel8 Networks
    00-25-55   # Visonic Technologies 1993 Ltd
    00-25-56   # Hon Hai Precision Ind. Co.,Ltd.
    00-25-57   # BlackBerry RTS
    00-25-58   # MPEDIA
    00-25-59   # Syphan Technologies Ltd
    00-25-5A   # Tantalus Systems Corp.
    00-25-5B   # CoachComm, LLC
    00-25-5C   # NEC Corporation
    00-25-5D   # Morningstar Corporation
    00-25-5E   # Shanghai Dare Technologies Co.,Ltd.
    00-25-5F   # SenTec AG
    00-25-60   # Ibridge Networks & Communications Ltd.
    00-25-61   # ProCurve Networking by HP
    00-25-62   # interbro Co. Ltd.
    00-25-63   # Luxtera Inc
    00-25-64   # Dell Inc.
    00-25-65   # Vizimax Inc.
    00-25-66   # Samsung Electronics Co.,Ltd
    00-25-67   # Samsung Electronics
    00-25-68   # HUAWEI TECHNOLOGIES CO.,LTD
    00-25-69   # Sagemcom Broadband SAS
    00-25-6A   # inIT - Institut Industrial IT
    00-25-6B   # ATENIX E.E. s.r.l.
    00-25-6C   # Azimut Production Association JSC
    00-25-6D   # Broadband Forum
    00-25-6E   # Van Breda B.V.
    00-25-6F   # Dantherm Power
    00-25-70   # Eastern Communications Company Limited
    00-25-71   # Zhejiang Tianle Digital Electric Co.,Ltd
    00-25-72   # Nemo-Q International AB
    00-25-73   # ST Electronics (Info-Security) Pte Ltd
    00-25-74   # KUNIMI MEDIA DEVICE Co., Ltd.
    00-25-75   # FiberPlex Technologies, LLC
    00-25-76   # NELI TECHNOLOGIES
    00-25-77   # D-BOX Technologies
    00-25-78   # JSC Concern Sozvezdie
    00-25-79   # J & F Labs
    00-25-7A   # CAMCO Produktions- und Vertriebs-GmbH für  Beschallungs- und Beleuchtungsanlagen
    00-25-7B   # STJ  ELECTRONICS  PVT  LTD
    00-25-7C   # Huachentel Technology Development Co., Ltd
    00-25-7D   # PointRed Telecom Private Ltd.
    00-25-7E   # NEW POS Technology Limited
    00-25-7F   # CallTechSolution Co.,Ltd
    00-25-80   # Equipson S.A.
    00-25-81   # x-star networks Inc.
    00-25-82   # Maksat Technologies (P) Ltd
    00-25-83   # Cisco Systems, Inc
    00-25-84   # Cisco Systems, Inc
    00-25-85   # KOKUYO S&T Co., Ltd.
    00-25-86   # TP-LINK TECHNOLOGIES CO.,LTD.
    00-25-87   # Vitality, Inc.
    00-25-88   # Genie Industries, Inc.
    00-25-89   # Hills Industries Limited
    00-25-8A   # Pole/Zero Corporation
    00-25-8B   # Mellanox Technologies Ltd
    00-25-8C   # ESUS ELEKTRONIK SAN. VE DIS. TIC. LTD. STI.
    00-25-8D   # Haier
    00-25-8E   # The Weather Channel
    00-25-8F   # Trident Microsystems, Inc.
    00-25-90   # Super Micro Computer, Inc.
    00-25-91   # NEXTEK, Inc.
    00-25-92   # Guangzhou Shirui Electronic Co., Ltd
    00-25-93   # DatNet Informatikai Kft.
    00-25-94   # Eurodesign BG LTD
    00-25-95   # Northwest Signal Supply, Inc
    00-25-96   # GIGAVISION srl
    00-25-97   # Kalki Communication Technologies
    00-25-98   # Zhong Shan City Litai Electronic Industrial Co. Ltd
    00-25-99   # Hedon e.d. B.V.
    00-25-9A   # CEStronics GmbH
    00-25-9B   # Beijing PKUNITY Microsystems Technology Co., Ltd
    00-25-9C   # Cisco-Linksys, LLC
    00-25-9D   # Private
    00-25-9E   # HUAWEI TECHNOLOGIES CO.,LTD
    00-25-9F   # TechnoDigital Technologies GmbH
    00-25-A0   # Nintendo Co., Ltd.
    00-25-A1   # Enalasys
    00-25-A2   # Alta Definicion LINCEO S.L.
    00-25-A3   # Trimax Wireless, Inc.
    00-25-A4   # EuroDesign embedded technologies GmbH
    00-25-A5   # Walnut Media Network
    00-25-A6   # Central Network Solution Co., Ltd.
    00-25-A7   # Comverge, Inc.
    00-25-A8   # Kontron (BeiJing) Technology Co.,Ltd
    00-25-A9   # Shanghai Embedway Information Technologies Co.,Ltd
    00-25-AA   # Beijing Soul Technology Co.,Ltd.
    00-25-AB   # AIO LCD PC BU / TPV
    00-25-AC   # I-Tech corporation
    00-25-AD   # Manufacturing Resources International
    00-25-AE   # Microsoft Corporation
    00-25-AF   # COMFILE Technology
    00-25-B0   # Schmartz Inc
    00-25-B1   # Maya-Creation Corporation
    00-25-B2   # MBDA Deutschland GmbH
    00-25-B3   # Hewlett Packard
    00-25-B4   # Cisco Systems, Inc
    00-25-B5   # Cisco Systems, Inc
    00-25-B6   # Telecom FM
    00-25-B7   # Costar  electronics, inc.,
    00-25-B8   # Agile Communications, Inc.
    00-25-B9   # Cypress Solutions Inc
    00-25-BA   # Alcatel-Lucent IPD
    00-25-BB   # INNERINT Co., Ltd.
    00-25-BC   # Apple, Inc.
    00-25-BD   # Italdata Ingegneria dell'Idea S.p.A.
    00-25-BE   # Tektrap Systems Inc.
    00-25-BF   # Wireless Cables Inc.
    00-25-C0   # ZillionTV Corporation
    00-25-C1   # Nawoo Korea Corp.
    00-25-C2   # RingBell Co.,Ltd.
    00-25-C3   # Nortel Networks
    00-25-C4   # Ruckus Wireless
    00-25-C5   # Star Link Communication Pvt. Ltd.
    00-25-C6   # kasercorp, ltd
    00-25-C7   # altek Corporation
    00-25-C8   # S-Access GmbH
    00-25-C9   # SHENZHEN HUAPU DIGITAL CO., LTD
    00-25-CA   # LS Research, LLC
    00-25-CB   # Reiner SCT
    00-25-CC   # Mobile Communications Korea Incorporated
    00-25-CD   # Skylane Optics
    00-25-CE   # InnerSpace
    00-25-CF   # Nokia Danmark A/S
    00-25-D0   # Nokia Danmark A/S
    00-25-D1   # Eastern Asia Technology Limited
    00-25-D2   # InpegVision Co., Ltd
    00-25-D3   # AzureWave Technology Inc.
    00-25-D4   # Fortress Technologies
    00-25-D5   # Robonica (Pty) Ltd
    00-25-D6   # The Kroger Co.
    00-25-D7   # CEDO
    00-25-D8   # KOREA MAINTENANCE
    00-25-D9   # DataFab Systems Inc.
    00-25-DA   # Secura Key
    00-25-DB   # ATI Electronics(Shenzhen) Co., LTD
    00-25-DC   # Sumitomo Electric Industries,Ltd
    00-25-DD   # SUNNYTEK INFORMATION CO., LTD.
    00-25-DE   # Probits Co., LTD.
    00-25-DF   # Private
    00-25-E0   # CeedTec Sdn Bhd
    00-25-E1   # SHANGHAI SEEYOO ELECTRONIC & TECHNOLOGY CO., LTD
    00-25-E2   # Everspring Industry Co., Ltd.
    00-25-E3   # Hanshinit Inc.
    00-25-E4   # OMNI-WiFi, LLC
    00-25-E5   # LG Electronics Inc
    00-25-E6   # Belgian Monitoring Systems bvba
    00-25-E7   # Sony Mobile Communications AB
    00-25-E8   # Idaho Technology
    00-25-E9   # i-mate Development, Inc.
    00-25-EA   # Iphion BV
    00-25-EB   # Reutech Radar Systems (PTY) Ltd
    00-25-EC   # Humanware
    00-25-ED   # NuVo Technologies LLC
    00-25-EE   # Avtex Ltd
    00-25-EF   # I-TEC Co., Ltd.
    00-25-F0   # Suga Electronics Limited
    00-25-F1   # ARRIS Group, Inc.
    00-25-F2   # ARRIS Group, Inc.
    00-25-F3   # Nordwestdeutsche Zählerrevision
    00-25-F4   # KoCo Connector AG
    00-25-F5   # DVS Korea, Co., Ltd
    00-25-F6   # netTALK.com, Inc.
    00-25-F7   # Ansaldo STS USA
    00-25-F9   # GMK electronic design GmbH
    00-25-FA   # J&M Analytik AG
    00-25-FB   # Tunstall Healthcare A/S
    00-25-FC   # ENDA ENDUSTRIYEL ELEKTRONIK LTD. STI.
    00-25-FD   # OBR Centrum Techniki Morskiej S.A.
    00-25-FE   # Pilot Electronics Corporation
    00-25-FF   # CreNova Multimedia Co., Ltd
    00-26-00   # TEAC Australia Pty Ltd.
    00-26-01   # Cutera Inc
    00-26-02   # SMART Temps LLC
    00-26-03   # Shenzhen Wistar Technology Co., Ltd
    00-26-04   # Audio Processing Technology Ltd
    00-26-05   # CC Systems AB
    00-26-06   # RAUMFELD GmbH
    00-26-07   # Enabling Technology Pty Ltd
    00-26-08   # Apple, Inc.
    00-26-09   # Phyllis Co., Ltd.
    00-26-0A   # Cisco Systems, Inc
    00-26-0B   # Cisco Systems, Inc
    00-26-0C   # Dataram
    00-26-0D   # Mercury Systems, Inc.
    00-26-0E   # Ablaze Systems, LLC
    00-26-0F   # Linn Products Ltd
    00-26-10   # Apacewave Technologies
    00-26-11   # Licera AB
    00-26-12   # Space Exploration Technologies
    00-26-13   # Engel Axil S.L.
    00-26-14   # KTNF
    00-26-15   # Teracom Limited
    00-26-16   # Rosemount Inc.
    00-26-17   # OEM Worldwide
    00-26-18   # ASUSTek COMPUTER INC.
    00-26-19   # FRC
    00-26-1A   # Femtocomm System Technology Corp.
    00-26-1B   # LAUREL BANK MACHINES CO., LTD.
    00-26-1C   # NEOVIA INC.
    00-26-1D   # COP SECURITY SYSTEM CORP.
    00-26-1E   # QINGBANG ELEC(SZ) CO., LTD
    00-26-1F   # SAE Magnetics (H.K.) Ltd.
    00-26-20   # ISGUS GmbH
    00-26-21   # InteliCloud Technology Inc.
    00-26-22   # COMPAL INFORMATION (KUNSHAN) CO., LTD.
    00-26-23   # JRD Communication Inc
    00-26-24   # Thomson Inc.
    00-26-25   # MediaSputnik
    00-26-26   # Geophysical Survey Systems, Inc.
    00-26-27   # Truesell
    00-26-28   # companytec automação e controle ltda.
    00-26-29   # Juphoon System Software Inc.
    00-26-2A   # Proxense, LLC
    00-26-2B   # Wongs Electronics Co. Ltd.
    00-26-2C   # IKT Advanced Technologies s.r.o.
    00-26-2D   # Wistron Corporation
    00-26-2E   # Chengdu Jiuzhou Electronic Technology Inc
    00-26-2F   # HAMAMATSU TOA ELECTRONICS
    00-26-30   # ACOREL S.A.S
    00-26-31   # COMMTACT LTD
    00-26-32   # Instrumentation Technologies d.d.
    00-26-33   # MIR - Medical International Research
    00-26-34   # Infineta Systems, Inc
    00-26-35   # Bluetechnix GmbH
    00-26-36   # ARRIS Group, Inc.
    00-26-37   # Samsung Electro-Mechanics
    00-26-38   # Xia Men Joyatech Co., Ltd.
    00-26-39   # T.M. Electronics, Inc.
    00-26-3A   # Digitec Systems
    00-26-3B   # Onbnetech
    00-26-3C   # Bachmann Technology GmbH & Co. KG
    00-26-3D   # MIA Corporation
    00-26-3E   # Trapeze Networks
    00-26-3F   # LIOS Technology GmbH
    00-26-40   # Baustem Broadband Technologies, Ltd.
    00-26-41   # ARRIS Group, Inc.
    00-26-42   # ARRIS Group, Inc.
    00-26-43   # ALPS ELECTRIC CO.,LTD.
    00-26-44   # Thomson Telecom Belgium
    00-26-45   # Circontrol S.A.
    00-26-46   # SHENYANG TONGFANG MULTIMEDIA TECHNOLOGY COMPANY LIMITED
    00-26-47   # WFE TECHNOLOGY CORP.
    00-26-48   # Emitech Corp.
    00-26-4A   # Apple, Inc.
    00-26-4C   # Shanghai DigiVision Technology Co., Ltd.
    00-26-4D   # Arcadyan Technology Corporation
    00-26-4E   # Rail & Road Protec GmbH
    00-26-4F   # Krüger &Gothe GmbH
    00-26-50   # 2Wire Inc
    00-26-51   # Cisco Systems, Inc
    00-26-52   # Cisco Systems, Inc
    00-26-53   # DaySequerra Corporation
    00-26-54   # 3Com Corporation
    00-26-55   # Hewlett Packard
    00-26-56   # Sansonic Electronics USA
    00-26-57   # OOO NPP EKRA
    00-26-58   # T-Platforms (Cyprus) Limited
    00-26-59   # Nintendo Co., Ltd.
    00-26-5A   # D-Link Corporation
    00-26-5B   # Hitron Technologies. Inc
    00-26-5C   # Hon Hai Precision Ind. Co.,Ltd.
    00-26-5D   # Samsung Electronics
    00-26-5E   # Hon Hai Precision Ind. Co.,Ltd.
    00-26-5F   # Samsung Electronics Co.,Ltd
    00-26-60   # Logiways
    00-26-61   # Irumtek Co., Ltd.
    00-26-62   # Actiontec Electronics, Inc
    00-26-63   # Shenzhen Huitaiwei Tech. Ltd, co.
    00-26-64   # Core System Japan
    00-26-65   # ProtectedLogic Corporation
    00-26-66   # EFM Networks
    00-26-67   # CARECOM CO.,LTD.
    00-26-68   # Nokia Danmark A/S
    00-26-69   # Nokia Danmark A/S
    00-26-6A   # ESSENSIUM NV
    00-26-6B   # SHINE UNION ENTERPRISE LIMITED
    00-26-6C   # Inventec
    00-26-6D   # MobileAccess Networks
    00-26-6E   # Nissho-denki Co.,LTD.
    00-26-6F   # Coordiwise Technology Corp.
    00-26-70   # Cinch Connectors
    00-26-71   # AUTOVISION Co., Ltd
    00-26-72   # AAMP of America
    00-26-73   # RICOH COMPANY,LTD.
    00-26-74   # Electronic Solutions, Inc.
    00-26-75   # Aztech Electronics Pte Ltd
    00-26-76   # COMMidt AS
    00-26-77   # DEIF A/S
    00-26-78   # Logic Instrument SA
    00-26-79   # Euphonic Technologies, Inc.
    00-26-7A   # wuhan hongxin telecommunication technologies co.,ltd
    00-26-7B   # GSI Helmholtzzentrum für Schwerionenforschung GmbH
    00-26-7C   # Metz-Werke GmbH & Co KG
    00-26-7D   # A-Max Technology Macao Commercial Offshore Company Limited
    00-26-7E   # Parrot SA
    00-26-7F   # Zenterio AB
    00-26-80   # SIL3 Pty.Ltd
    00-26-81   # Interspiro AB
    00-26-82   # Gemtek Technology Co., Ltd.
    00-26-83   # Ajoho Enterprise Co., Ltd.
    00-26-84   # KISAN SYSTEM
    00-26-85   # Digital Innovation
    00-26-86   # Quantenna Communcations, Inc.
    00-26-87   # corega K.K
    00-26-88   # Juniper Networks
    00-26-89   # General Dynamics Robotic Systems
    00-26-8A   # Terrier SC Ltd
    00-26-8B   # Guangzhou Escene Computer Technology Limited
    00-26-8C   # StarLeaf Ltd.
    00-26-8D   # CellTel S.p.A.
    00-26-8E   # Alta Solutions, Inc.
    00-26-8F   # MTA SpA
    00-26-90   # I DO IT
    00-26-91   # Sagemcom Broadband SAS
    00-26-92   # Mitsubishi Electric Co.
    00-26-93   # QVidium Technologies, Inc.
    00-26-94   # Senscient Ltd
    00-26-95   # ZT Group Int'l Inc
    00-26-96   # NOOLIX Co., Ltd
    00-26-97   # Cheetah Technologies, L.P.
    00-26-98   # Cisco Systems, Inc
    00-26-99   # Cisco Systems, Inc
    00-26-9A   # Carina System Co., Ltd.
    00-26-9B   # SOKRAT Ltd.
    00-26-9C   # ITUS JAPAN CO. LTD
    00-26-9D   # M2Mnet Co., Ltd.
    00-26-9E   # Quanta Computer Inc
    00-26-9F   # Private
    00-26-A0   # moblic
    00-26-A1   # Megger
    00-26-A2   # Instrumentation Technology Systems
    00-26-A3   # FQ Ingenieria Electronica S.A.
    00-26-A4   # Novus Produtos Eletronicos Ltda
    00-26-A5   # MICROROBOT.CO.,LTD
    00-26-A6   # TRIXELL
    00-26-A7   # CONNECT SRL
    00-26-A8   # DAEHAP HYPER-TECH
    00-26-A9   # Strong Technologies Pty Ltd
    00-26-AA   # Kenmec Mechanical Engineering Co., Ltd.
    00-26-AB   # SEIKO EPSON CORPORATION
    00-26-AC   # Shanghai LUSTER Teraband photonic Co., Ltd.
    00-26-AD   # Arada Systems, Inc.
    00-26-AE   # Wireless Measurement Ltd
    00-26-AF   # Duelco A/S
    00-26-B0   # Apple, Inc.
    00-26-B1   # Navis Auto Motive Systems, Inc.
    00-26-B2   # Setrix GmbH
    00-26-B3   # Thales Communications Inc
    00-26-B4   # Ford Motor Company
    00-26-B5   # ICOMM Tele Ltd
    00-26-B6   # ASKEY COMPUTER CORP
    00-26-B7   # Kingston Technology Company, Inc.
    00-26-B8   # Actiontec Electronics, Inc
    00-26-B9   # Dell Inc.
    00-26-BA   # ARRIS Group, Inc.
    00-26-BB   # Apple, Inc.
    00-26-BC   # General Jack Technology Ltd.
    00-26-BD   # JTEC Card & Communication Co., Ltd.
    00-26-BE   # Schoonderbeek Elektronica Systemen B.V.
    00-26-BF   # ShenZhen Temobi Science&Tech Development Co.,Ltd
    00-26-C0   # EnergyHub
    00-26-C1   # ARTRAY CO., LTD.
    00-26-C2   # SCDI Co. LTD
    00-26-C3   # Insightek Corp.
    00-26-C4   # Cadmos microsystems S.r.l.
    00-26-C5   # Guangdong Gosun Telecommunications Co.,Ltd
    00-26-C6   # Intel Corporate
    00-26-C7   # Intel Corporate
    00-26-C8   # System Sensor
    00-26-C9   # Proventix Systems, Inc.
    00-26-CA   # Cisco Systems, Inc
    00-26-CB   # Cisco Systems, Inc
    00-26-CC   # Nokia Danmark A/S
    00-26-CD   # PurpleComm, Inc.
    00-26-CE   # Kozumi USA Corp.
    00-26-CF   # DEKA R&D
    00-26-D0   # Semihalf
    00-26-D1   # S Squared Innovations Inc.
    00-26-D2   # Pcube Systems, Inc.
    00-26-D3   # Zeno Information System
    00-26-D4   # IRCA SpA
    00-26-D5   # Ory Solucoes em Comercio de Informatica Ltda.
    00-26-D6   # Ningbo Andy Optoelectronic Co., Ltd.
    00-26-D7   # KM Electornic Technology Co., Ltd.
    00-26-D8   # Magic Point Inc.
    00-26-D9   # Pace plc
    00-26-DA   # Universal Media Corporation /Slovakia/ s.r.o.
    00-26-DB   # Ionics EMS Inc.
    00-26-DC   # Optical Systems Design
    00-26-DD   # Fival Science & Technology Co.,Ltd.
    00-26-DE   # FDI MATELEC
    00-26-DF   # TaiDoc Technology Corp.
    00-26-E0   # ASITEQ
    00-26-E1   # Stanford University, OpenFlow Group
    00-26-E2   # LG Electronics
    00-26-E3   # DTI
    00-26-E4   # Canal +
    00-26-E5   # AEG Power Solutions
    00-26-E6   # Visionhitech Co., Ltd.
    00-26-E7   # Shanghai ONLAN Communication Tech. Co., Ltd.
    00-26-E8   # Murata Manufacturing Co., Ltd.
    00-26-E9   # SP Corp
    00-26-EA   # Cheerchip Electronic Technology (ShangHai) Co., Ltd.
    00-26-EB   # Advanced Spectrum Technology Co., Ltd.
    00-26-EC   # Legrand Home Systems, Inc
    00-26-ED   # zte corporation
    00-26-EE   # TKM GmbH
    00-26-EF   # Technology Advancement Group, Inc.
    00-26-F0   # cTrixs International GmbH.
    00-26-F1   # ProCurve Networking by HP
    00-26-F2   # NETGEAR
    00-26-F3   # SMC Networks
    00-26-F4   # Nesslab
    00-26-F5   # XRPLUS Inc.
    00-26-F6   # Military Communication Institute
    00-26-F7   # Infosys Technologies Ltd.
    00-26-F8   # Golden Highway Industry Development Co., Ltd.
    00-26-F9   # S.E.M. srl
    00-26-FA   # BandRich Inc.
    00-26-FB   # AirDio Wireless, Inc.
    00-26-FC   # AcSiP Technology Corp.
    00-26-FD   # Interactive Intelligence
    00-26-FE   # MKD Technology Inc.
    00-26-FF   # BlackBerry RTS
    00-27-00   # Shenzhen Siglent Technology Co., Ltd.
    00-27-01   # INCOstartec GmbH
    00-27-02   # SolarEdge Technologies
    00-27-03   # Testech Electronics Pte Ltd
    00-27-04   # Accelerated Concepts, Inc
    00-27-05   # Sectronic
    00-27-06   # YOISYS
    00-27-07   # Lift Complex DS, JSC
    00-27-08   # Nordiag ASA
    00-27-09   # Nintendo Co., Ltd.
    00-27-0A   # IEE S.A.
    00-27-0B   # Adura Technologies
    00-27-0C   # Cisco Systems, Inc
    00-27-0D   # Cisco Systems, Inc
    00-27-0E   # Intel Corporate
    00-27-0F   # Envisionnovation Inc
    00-27-10   # Intel Corporate
    00-27-11   # LanPro Inc
    00-27-12   # MaxVision LLC
    00-27-13   # Universal Global Scientific Industrial Co., Ltd.
    00-27-14   # Grainmustards, Co,ltd.
    00-27-15   # Rebound Telecom. Co., Ltd
    00-27-16   # Adachi-Syokai Co., Ltd.
    00-27-17   # CE Digital(Zhenjiang)Co.,Ltd
    00-27-18   # Suzhou NEW SEAUNION Video Technology Co.,Ltd
    00-27-19   # TP-LINK TECHNOLOGIES CO.,LTD.
    00-27-1A   # Geenovo Technology Ltd.
    00-27-1B   # Alec Sicherheitssysteme GmbH
    00-27-1C   # MERCURY CORPORATION
    00-27-1D   # Comba Telecom Systems (China) Ltd.
    00-27-1E   # Xagyl Communications
    00-27-1F   # MIPRO Electronics Co., Ltd
    00-27-20   # NEW-SOL COM
    00-27-21   # Shenzhen Baoan Fenda Industrial Co., Ltd
    00-27-22   # Ubiquiti Networks
    00-27-F8   # Brocade Communications Systems, Inc.
    00-29-26   # Applied Optoelectronics, Inc Taiwan Branch
    00-2A-6A   # Cisco Systems, Inc
    00-2A-AF   # LARsys-Automation GmbH
    00-2D-76   # TITECH GmbH
    00-30-00   # ALLWELL TECHNOLOGY CORP.
    00-30-01   # SMP
    00-30-02   # Expand Networks
    00-30-03   # Phasys Ltd.
    00-30-04   # LEADTEK RESEARCH INC.
    00-30-05   # Fujitsu Siemens Computers
    00-30-06   # SUPERPOWER COMPUTER
    00-30-07   # OPTI, INC.
    00-30-08   # AVIO DIGITAL, INC.
    00-30-09   # Tachion Networks, Inc.
    00-30-0A   # Aztech Electronics Pte Ltd
    00-30-0B   # mPHASE Technologies, Inc.
    00-30-0C   # CONGRUENCY, LTD.
    00-30-0D   # MMC Technology, Inc.
    00-30-0E   # Klotz Digital AG
    00-30-0F   # IMT - Information Management T
    00-30-10   # VISIONETICS INTERNATIONAL
    00-30-11   # HMS Industrial Networks
    00-30-12   # DIGITAL ENGINEERING LTD.
    00-30-13   # NEC Corporation
    00-30-14   # DIVIO, INC.
    00-30-15   # CP CLARE CORP.
    00-30-16   # ISHIDA CO., LTD.
    00-30-17   # BlueArc UK Ltd
    00-30-18   # Jetway Information Co., Ltd.
    00-30-19   # Cisco Systems, Inc
    00-30-1A   # SMARTBRIDGES PTE. LTD.
    00-30-1B   # SHUTTLE, INC.
    00-30-1C   # ALTVATER AIRDATA SYSTEMS
    00-30-1D   # SKYSTREAM, INC.
    00-30-1E   # 3COM EUROPE LTD.
    00-30-1F   # OPTICAL NETWORKS, INC.
    00-30-20   # TSI, Inc..
    00-30-21   # HSING TECH. ENTERPRISE CO.,LTD
    00-30-22   # Fong Kai Industrial Co., Ltd.
    00-30-23   # COGENT COMPUTER SYSTEMS, INC.
    00-30-24   # Cisco Systems, Inc
    00-30-25   # CHECKOUT COMPUTER SYSTEMS, LTD
    00-30-26   # HeiTel Digital Video GmbH
    00-30-27   # KERBANGO, INC.
    00-30-28   # FASE Saldatura srl
    00-30-29   # OPICOM
    00-30-2A   # SOUTHERN INFORMATION
    00-30-2B   # INALP NETWORKS, INC.
    00-30-2C   # SYLANTRO SYSTEMS CORPORATION
    00-30-2D   # QUANTUM BRIDGE COMMUNICATIONS
    00-30-2E   # Hoft & Wessel AG
    00-30-2F   # GE Aviation System
    00-30-30   # HARMONIX CORPORATION
    00-30-31   # LIGHTWAVE COMMUNICATIONS, INC.
    00-30-32   # MagicRam, Inc.
    00-30-33   # ORIENT TELECOM CO., LTD.
    00-30-34   # SET ENGINEERING
    00-30-35   # Corning Incorporated
    00-30-36   # RMP ELEKTRONIKSYSTEME GMBH
    00-30-37   # Packard Bell Nec Services
    00-30-38   # XCP, INC.
    00-30-39   # SOFTBOOK PRESS
    00-30-3A   # MAATEL
    00-30-3B   # PowerCom Technology
    00-30-3C   # ONNTO CORP.
    00-30-3D   # IVA CORPORATION
    00-30-3E   # Radcom Ltd.
    00-30-3F   # TurboComm Tech Inc.
    00-30-40   # Cisco Systems, Inc
    00-30-41   # SAEJIN T & M CO., LTD.
    00-30-42   # DeTeWe-Deutsche Telephonwerke
    00-30-43   # IDREAM TECHNOLOGIES, PTE. LTD.
    00-30-44   # CradlePoint, Inc
    00-30-45   # Village Networks, Inc. (VNI)
    00-30-46   # Controlled Electronic Manageme
    00-30-47   # NISSEI ELECTRIC CO., LTD.
    00-30-48   # Supermicro Computer, Inc.
    00-30-49   # BRYANT TECHNOLOGY, LTD.
    00-30-4A   # Fraunhofer IPMS
    00-30-4B   # ORBACOM SYSTEMS, INC.
    00-30-4C   # APPIAN COMMUNICATIONS, INC.
    00-30-4D   # ESI
    00-30-4E   # BUSTEC PRODUCTION LTD.
    00-30-4F   # PLANET Technology Corporation
    00-30-50   # Versa Technology
    00-30-51   # ORBIT AVIONIC & COMMUNICATION
    00-30-52   # ELASTIC NETWORKS
    00-30-53   # Basler AG
    00-30-54   # CASTLENET TECHNOLOGY, INC.
    00-30-55   # Renesas Technology America, Inc.
    00-30-56   # Beck IPC GmbH
    00-30-57   # QTelNet, Inc.
    00-30-58   # API MOTION
    00-30-59   # KONTRON COMPACT COMPUTERS AG
    00-30-5A   # TELGEN CORPORATION
    00-30-5B   # Toko Inc.
    00-30-5C   # SMAR Laboratories Corp.
    00-30-5D   # DIGITRA SYSTEMS, INC.
    00-30-5E   # Abelko Innovation
    00-30-5F   # Hasselblad
    00-30-60   # Powerfile, Inc.
    00-30-61   # MobyTEL
    00-30-62   # IP Video Networks Inc
    00-30-63   # SANTERA SYSTEMS, INC.
    00-30-64   # ADLINK TECHNOLOGY, INC.
    00-30-65   # Apple, Inc.
    00-30-66   # RFM
    00-30-67   # BIOSTAR Microtech Int'l Corp.
    00-30-68   # CYBERNETICS TECH. CO., LTD.
    00-30-69   # IMPACCT TECHNOLOGY CORP.
    00-30-6A   # PENTA MEDIA CO., LTD.
    00-30-6B   # CMOS SYSTEMS, INC.
    00-30-6C   # Hitex Holding GmbH
    00-30-6D   # LUCENT TECHNOLOGIES
    00-30-6E   # Hewlett Packard
    00-30-6F   # SEYEON TECH. CO., LTD.
    00-30-70   # 1Net Corporation
    00-30-71   # Cisco Systems, Inc
    00-30-72   # Intellibyte Inc.
    00-30-73   # International Microsystems, In
    00-30-74   # EQUIINET LTD.
    00-30-75   # ADTECH
    00-30-76   # Akamba Corporation
    00-30-77   # ONPREM NETWORKS
    00-30-78   # Cisco Systems, Inc
    00-30-79   # CQOS, INC.
    00-30-7A   # Advanced Technology & Systems
    00-30-7B   # Cisco Systems, Inc
    00-30-7C   # ADID SA
    00-30-7D   # GRE AMERICA, INC.
    00-30-7E   # Redflex Communication Systems
    00-30-7F   # IRLAN LTD.
    00-30-80   # Cisco Systems, Inc
    00-30-81   # ALTOS C&C
    00-30-82   # TAIHAN ELECTRIC WIRE CO., LTD.
    00-30-83   # Ivron Systems
    00-30-84   # ALLIED TELESYN INTERNAIONAL
    00-30-85   # Cisco Systems, Inc
    00-30-86   # Transistor Devices, Inc.
    00-30-87   # VEGA GRIESHABER KG
    00-30-88   # Ericsson
    00-30-89   # Spectrapoint Wireless, LLC
    00-30-8A   # NICOTRA SISTEMI S.P.A
    00-30-8B   # Brix Networks
    00-30-8C   # Quantum Corporation
    00-30-8D   # Pinnacle Systems, Inc.
    00-30-8E   # CROSS MATCH TECHNOLOGIES, INC.
    00-30-8F   # MICRILOR, Inc.
    00-30-90   # CYRA TECHNOLOGIES, INC.
    00-30-91   # TAIWAN FIRST LINE ELEC. CORP.
    00-30-92   # ModuNORM GmbH
    00-30-93   # Sonnet Technologies, Inc
    00-30-94   # Cisco Systems, Inc
    00-30-95   # Procomp Informatics, Ltd.
    00-30-96   # Cisco Systems, Inc
    00-30-97   # AB Regin
    00-30-98   # Global Converging Technologies
    00-30-99   # BOENIG UND KALLENBACH OHG
    00-30-9A   # ASTRO TERRA CORP.
    00-30-9B   # Smartware
    00-30-9C   # Timing Applications, Inc.
    00-30-9D   # Nimble Microsystems, Inc.
    00-30-9E   # WORKBIT CORPORATION.
    00-30-9F   # AMBER NETWORKS
    00-30-A0   # TYCO SUBMARINE SYSTEMS, LTD.
    00-30-A1   # WEBGATE Inc.
    00-30-A2   # Lightner Engineering
    00-30-A3   # Cisco Systems, Inc
    00-30-A4   # Woodwind Communications System
    00-30-A5   # ACTIVE POWER
    00-30-A6   # VIANET TECHNOLOGIES, LTD.
    00-30-A7   # SCHWEITZER ENGINEERING
    00-30-A8   # OL'E COMMUNICATIONS, INC.
    00-30-A9   # Netiverse, Inc.
    00-30-AA   # AXUS MICROSYSTEMS, INC.
    00-30-AB   # DELTA NETWORKS, INC.
    00-30-AC   # Systeme Lauer GmbH & Co., Ltd.
    00-30-AD   # SHANGHAI COMMUNICATION
    00-30-AE   # Times N System, Inc.
    00-30-AF   # Honeywell GmbH
    00-30-B0   # Convergenet Technologies
    00-30-B1   # TrunkNet
    00-30-B2   # L-3 Sonoma EO
    00-30-B3   # San Valley Systems, Inc.
    00-30-B4   # INTERSIL CORP.
    00-30-B5   # Tadiran Microwave Networks
    00-30-B6   # Cisco Systems, Inc
    00-30-B7   # Teletrol Systems, Inc.
    00-30-B8   # RiverDelta Networks
    00-30-B9   # ECTEL
    00-30-BA   # AC&T SYSTEM CO., LTD.
    00-30-BB   # CacheFlow, Inc.
    00-30-BC   # Optronic AG
    00-30-BD   # BELKIN COMPONENTS
    00-30-BE   # City-Net Technology, Inc.
    00-30-BF   # MULTIDATA GMBH
    00-30-C0   # Lara Technology, Inc.
    00-30-C1   # Hewlett Packard
    00-30-C2   # COMONE
    00-30-C3   # FLUECKIGER ELEKTRONIK AG
    00-30-C4   # Canon Imaging Systems Inc.
    00-30-C5   # CADENCE DESIGN SYSTEMS, INC.
    00-30-C6   # CONTROL SOLUTIONS, INC.
    00-30-C7   # Macromate Corp.
    00-30-C8   # GAD LINE, LTD.
    00-30-C9   # LuxN, N
    00-30-CA   # Discovery Com
    00-30-CB   # OMNI FLOW COMPUTERS, INC.
    00-30-CC   # Tenor Networks, Inc.
    00-30-CD   # CONEXANT SYSTEMS, INC.
    00-30-CE   # Zaffire
    00-30-CF   # TWO TECHNOLOGIES, INC.
    00-30-D0   # Tellabs
    00-30-D1   # INOVA CORPORATION
    00-30-D2   # WIN TECHNOLOGIES, CO., LTD.
    00-30-D3   # Agilent Technologies, Inc.
    00-30-D4   # AAE Systems, Inc.
    00-30-D5   # DResearch GmbH
    00-30-D6   # MSC VERTRIEBS GMBH
    00-30-D7   # Innovative Systems, L.L.C.
    00-30-D8   # SITEK
    00-30-D9   # DATACORE SOFTWARE CORP.
    00-30-DA   # Comtrend Corporation
    00-30-DB   # Mindready Solutions, Inc.
    00-30-DC   # RIGHTECH CORPORATION
    00-30-DD   # INDIGITA CORPORATION
    00-30-DE   # WAGO Kontakttechnik GmbH
    00-30-DF   # KB/TEL TELECOMUNICACIONES
    00-30-E0   # OXFORD SEMICONDUCTOR LTD.
    00-30-E1   # Network Equipment Technologies, Inc.
    00-30-E2   # GARNET SYSTEMS CO., LTD.
    00-30-E3   # SEDONA NETWORKS CORP.
    00-30-E4   # CHIYODA SYSTEM RIKEN
    00-30-E5   # Amper Datos S.A.
    00-30-E6   # Draeger Medical Systems, Inc.
    00-30-E7   # CNF MOBILE SOLUTIONS, INC.
    00-30-E8   # ENSIM CORP.
    00-30-E9   # GMA COMMUNICATION MANUFACT'G
    00-30-EA   # TeraForce Technology Corporation
    00-30-EB   # TURBONET COMMUNICATIONS, INC.
    00-30-EC   # BORGARDT
    00-30-ED   # Expert Magnetics Corp.
    00-30-EE   # DSG Technology, Inc.
    00-30-EF   # NEON TECHNOLOGY, INC.
    00-30-F0   # Uniform Industrial Corp.
    00-30-F1   # Accton Technology Corp
    00-30-F2   # Cisco Systems, Inc
    00-30-F3   # At Work Computers
    00-30-F4   # STARDOT TECHNOLOGIES
    00-30-F5   # Wild Lab. Ltd.
    00-30-F6   # SECURELOGIX CORPORATION
    00-30-F7   # RAMIX INC.
    00-30-F8   # Dynapro Systems, Inc.
    00-30-F9   # Sollae Systems Co., Ltd.
    00-30-FA   # TELICA, INC.
    00-30-FB   # AZS Technology AG
    00-30-FC   # Terawave Communications, Inc.
    00-30-FD   # INTEGRATED SYSTEMS DESIGN
    00-30-FE   # DSA GmbH
    00-30-FF   # DataFab Systems Inc.
    00-31-46   # Juniper Networks
    00-32-3A   # so-logic
    00-33-6C   # SynapSense Corporation
    00-34-F1   # Radicom Research, Inc.
    00-34-FE   # HUAWEI TECHNOLOGIES CO.,LTD
    00-35-1A   # Cisco Systems, Inc
    00-35-32   # Electro-Metrics Corporation
    00-35-60   # Rosen Aviation
    00-36-76   # Pace plc
    00-36-F8   # Conti Temic microelectronic GmbH
    00-36-FE   # SuperVision
    00-37-6D   # Murata Manufacturing Co., Ltd.
    00-37-B7   # Sagemcom Broadband SAS
    00-3A-98   # Cisco Systems, Inc
    00-3A-99   # Cisco Systems, Inc
    00-3A-9A   # Cisco Systems, Inc
    00-3A-9B   # Cisco Systems, Inc
    00-3A-9C   # Cisco Systems, Inc
    00-3A-9D   # NEC Platforms, Ltd.
    00-3A-AF   # BlueBit Ltd.
    00-3C-C5   # WONWOO Engineering Co., Ltd
    00-3D-41   # Hatteland Computer AS
    00-3E-E1   # Apple, Inc.
    00-40-00   # PCI COMPONENTES DA AMZONIA LTD
    00-40-01   # Zero One Technology Co. Ltd.
    00-40-02   # PERLE SYSTEMS LIMITED
    00-40-03   # Emerson Process Management Power & Water Solutions, Inc.
    00-40-04   # ICM CO. LTD.
    00-40-05   # ANI COMMUNICATIONS INC.
    00-40-06   # SAMPO TECHNOLOGY CORPORATION
    00-40-07   # TELMAT INFORMATIQUE
    00-40-08   # A PLUS INFO CORPORATION
    00-40-09   # TACHIBANA TECTRON CO., LTD.
    00-40-0A   # PIVOTAL TECHNOLOGIES, INC.
    00-40-0B   # Cisco Systems, Inc
    00-40-0C   # GENERAL MICRO SYSTEMS, INC.
    00-40-0D   # LANNET DATA COMMUNICATIONS,LTD
    00-40-0E   # MEMOTEC, INC.
    00-40-0F   # DATACOM TECHNOLOGIES
    00-40-10   # SONIC SYSTEMS, INC.
    00-40-11   # ANDOVER CONTROLS CORPORATION
    00-40-12   # WINDATA, INC.
    00-40-13   # NTT DATA COMM. SYSTEMS CORP.
    00-40-14   # COMSOFT GMBH
    00-40-15   # ASCOM INFRASYS AG
    00-40-16   # ADC - Global Connectivity Solutions Division
    00-40-17   # Silex Technology America
    00-40-18   # ADOBE SYSTEMS, INC.
    00-40-19   # AEON SYSTEMS, INC.
    00-40-1A   # FUJI ELECTRIC CO., LTD.
    00-40-1B   # PRINTER SYSTEMS CORP.
    00-40-1C   # AST RESEARCH, INC.
    00-40-1D   # INVISIBLE SOFTWARE, INC.
    00-40-1E   # ICC
    00-40-1F   # COLORGRAPH LTD
    00-40-20   # CommScope Inc
    00-40-21   # RASTER GRAPHICS
    00-40-22   # KLEVER COMPUTERS, INC.
    00-40-23   # LOGIC CORPORATION
    00-40-24   # COMPAC INC.
    00-40-25   # MOLECULAR DYNAMICS
    00-40-26   # BUFFALO.INC
    00-40-27   # SMC MASSACHUSETTS, INC.
    00-40-28   # NETCOMM LIMITED
    00-40-29   # Compex
    00-40-2A   # Canoga Perkins Corporation
    00-40-2B   # TRIGEM COMPUTER, INC.
    00-40-2C   # ISIS DISTRIBUTED SYSTEMS, INC.
    00-40-2D   # HARRIS ADACOM CORPORATION
    00-40-2E   # PRECISION SOFTWARE, INC.
    00-40-2F   # XLNT DESIGNS INC.
    00-40-30   # GK COMPUTER
    00-40-31   # KOKUSAI ELECTRIC CO., LTD
    00-40-32   # DIGITAL COMMUNICATIONS
    00-40-33   # ADDTRON TECHNOLOGY CO., LTD.
    00-40-34   # BUSTEK CORPORATION
    00-40-35   # OPCOM
    00-40-36   # Zoom Telephonics, Inc
    00-40-37   # SEA-ILAN, INC.
    00-40-38   # TALENT ELECTRIC INCORPORATED
    00-40-39   # OPTEC DAIICHI DENKO CO., LTD.
    00-40-3A   # IMPACT TECHNOLOGIES
    00-40-3B   # SYNERJET INTERNATIONAL CORP.
    00-40-3C   # FORKS, INC.
    00-40-3D   # Teradata Corporation
    00-40-3E   # RASTER OPS CORPORATION
    00-40-3F   # SSANGYONG COMPUTER SYSTEMS
    00-40-40   # RING ACCESS, INC.
    00-40-41   # FUJIKURA LTD.
    00-40-42   # N.A.T. GMBH
    00-40-43   # Nokia Siemens Networks GmbH & Co. KG.
    00-40-44   # QNIX COMPUTER CO., LTD.
    00-40-45   # TWINHEAD CORPORATION
    00-40-46   # UDC RESEARCH LIMITED
    00-40-47   # WIND RIVER SYSTEMS
    00-40-48   # SMD INFORMATICA S.A.
    00-40-49   # Roche Diagnostics International Ltd.
    00-40-4A   # WEST AUSTRALIAN DEPARTMENT
    00-40-4B   # MAPLE COMPUTER SYSTEMS
    00-40-4C   # HYPERTEC PTY LTD.
    00-40-4D   # TELECOMMUNICATIONS TECHNIQUES
    00-40-4E   # FLUENT, INC.
    00-40-4F   # SPACE & NAVAL WARFARE SYSTEMS
    00-40-50   # IRONICS, INCORPORATED
    00-40-51   # GRACILIS, INC.
    00-40-52   # STAR TECHNOLOGIES, INC.
    00-40-53   # AMPRO COMPUTERS
    00-40-54   # CONNECTION MACHINES SERVICES
    00-40-55   # METRONIX GMBH
    00-40-56   # MCM JAPAN LTD.
    00-40-57   # LOCKHEED - SANDERS
    00-40-58   # KRONOS, INC.
    00-40-59   # YOSHIDA KOGYO K. K.
    00-40-5A   # GOLDSTAR INFORMATION & COMM.
    00-40-5B   # FUNASSET LIMITED
    00-40-5C   # FUTURE SYSTEMS, INC.
    00-40-5D   # STAR-TEK, INC.
    00-40-5E   # NORTH HILLS ISRAEL
    00-40-5F   # AFE COMPUTERS LTD.
    00-40-60   # COMENDEC LTD
    00-40-61   # DATATECH ENTERPRISES CO., LTD.
    00-40-62   # E-SYSTEMS, INC./GARLAND DIV.
    00-40-63   # VIA TECHNOLOGIES, INC.
    00-40-64   # KLA INSTRUMENTS CORPORATION
    00-40-65   # GTE SPACENET
    00-40-66   # Hitachi Metals, Ltd.
    00-40-67   # OMNIBYTE CORPORATION
    00-40-68   # EXTENDED SYSTEMS
    00-40-69   # LEMCOM SYSTEMS, INC.
    00-40-6A   # KENTEK INFORMATION SYSTEMS,INC
    00-40-6B   # SYSGEN
    00-40-6C   # COPERNIQUE
    00-40-6D   # LANCO, INC.
    00-40-6E   # COROLLARY, INC.
    00-40-6F   # SYNC RESEARCH INC.
    00-40-70   # INTERWARE CO., LTD.
    00-40-71   # ATM COMPUTER GMBH
    00-40-72   # Applied Innovation Inc.
    00-40-73   # BASS ASSOCIATES
    00-40-74   # CABLE AND WIRELESS
    00-40-75   # Tattile SRL
    00-40-76   # Sun Conversion Technologies
    00-40-77   # MAXTON TECHNOLOGY CORPORATION
    00-40-78   # WEARNES AUTOMATION PTE LTD
    00-40-79   # JUKO MANUFACTURE COMPANY, LTD.
    00-40-7A   # SOCIETE D'EXPLOITATION DU CNIT
    00-40-7B   # SCIENTIFIC ATLANTA
    00-40-7C   # QUME CORPORATION
    00-40-7D   # EXTENSION TECHNOLOGY CORP.
    00-40-7E   # EVERGREEN SYSTEMS, INC.
    00-40-7F   # FLIR Systems
    00-40-80   # ATHENIX CORPORATION
    00-40-81   # MANNESMANN SCANGRAPHIC GMBH
    00-40-82   # LABORATORY EQUIPMENT CORP.
    00-40-83   # TDA INDUSTRIA DE PRODUTOS
    00-40-84   # HONEYWELL ACS
    00-40-85   # SAAB INSTRUMENTS AB
    00-40-86   # MICHELS & KLEBERHOFF COMPUTER
    00-40-87   # UBITREX CORPORATION
    00-40-88   # MOBIUS TECHNOLOGIES, INC.
    00-40-89   # MEIDENSHA CORPORATION
    00-40-8A   # TPS TELEPROCESSING SYS. GMBH
    00-40-8B   # RAYLAN CORPORATION
    00-40-8C   # AXIS COMMUNICATIONS AB
    00-40-8D   # THE GOODYEAR TIRE & RUBBER CO.
    00-40-8E   # Tattile SRL
    00-40-8F   # WM-DATA MINFO AB
    00-40-90   # ANSEL COMMUNICATIONS
    00-40-91   # PROCOMP INDUSTRIA ELETRONICA
    00-40-92   # ASP COMPUTER PRODUCTS, INC.
    00-40-93   # PAXDATA NETWORKS LTD.
    00-40-94   # SHOGRAPHICS, INC.
    00-40-95   # R.P.T. INTERGROUPS INT'L LTD.
    00-40-96   # Cisco Systems, Inc
    00-40-97   # DATEX DIVISION OF
    00-40-98   # DRESSLER GMBH & CO.
    00-40-99   # NEWGEN SYSTEMS CORP.
    00-40-9A   # NETWORK EXPRESS, INC.
    00-40-9B   # HAL COMPUTER SYSTEMS INC.
    00-40-9C   # TRANSWARE
    00-40-9D   # DIGIBOARD, INC.
    00-40-9E   # CONCURRENT TECHNOLOGIES  LTD.
    00-40-9F   # Telco Systems, Inc.
    00-40-A0   # GOLDSTAR CO., LTD.
    00-40-A1   # ERGO COMPUTING
    00-40-A2   # KINGSTAR TECHNOLOGY INC.
    00-40-A3   # MICROUNITY SYSTEMS ENGINEERING
    00-40-A4   # ROSE ELECTRONICS
    00-40-A5   # CLINICOMP INTL.
    00-40-A6   # Cray, Inc.
    00-40-A7   # ITAUTEC PHILCO S.A.
    00-40-A8   # IMF INTERNATIONAL LTD.
    00-40-A9   # DATACOM INC.
    00-40-AA   # Metso Automation
    00-40-AB   # ROLAND DG CORPORATION
    00-40-AC   # SUPER WORKSTATION, INC.
    00-40-AD   # SMA REGELSYSTEME GMBH
    00-40-AE   # DELTA CONTROLS, INC.
    00-40-AF   # DIGITAL PRODUCTS, INC.
    00-40-B0   # BYTEX CORPORATION, ENGINEERING
    00-40-B1   # CODONICS INC.
    00-40-B2   # SYSTEMFORSCHUNG
    00-40-B3   # ParTech Inc.
    00-40-B4   # NEXTCOM K.K.
    00-40-B5   # VIDEO TECHNOLOGY COMPUTERS LTD
    00-40-B6   # COMPUTERM  CORPORATION
    00-40-B7   # STEALTH COMPUTER SYSTEMS
    00-40-B8   # IDEA ASSOCIATES
    00-40-B9   # MACQ ELECTRONIQUE SA
    00-40-BA   # ALLIANT COMPUTER SYSTEMS CORP.
    00-40-BB   # GOLDSTAR CABLE CO., LTD.
    00-40-BC   # ALGORITHMICS LTD.
    00-40-BD   # STARLIGHT NETWORKS, INC.
    00-40-BE   # BOEING DEFENSE & SPACE
    00-40-BF   # CHANNEL SYSTEMS INTERN'L INC.
    00-40-C0   # VISTA CONTROLS CORPORATION
    00-40-C1   # BIZERBA-WERKE WILHEIM KRAUT
    00-40-C2   # APPLIED COMPUTING DEVICES
    00-40-C3   # FISCHER AND PORTER CO.
    00-40-C4   # KINKEI SYSTEM CORPORATION
    00-40-C5   # MICOM COMMUNICATIONS INC.
    00-40-C6   # FIBERNET RESEARCH, INC.
    00-40-C7   # RUBY TECH CORPORATION
    00-40-C8   # MILAN TECHNOLOGY CORPORATION
    00-40-C9   # NCUBE
    00-40-CA   # FIRST INTERNAT'L COMPUTER, INC
    00-40-CB   # LANWAN TECHNOLOGIES
    00-40-CC   # SILCOM MANUF'G TECHNOLOGY INC.
    00-40-CD   # TERA MICROSYSTEMS, INC.
    00-40-CE   # NET-SOURCE, INC.
    00-40-CF   # STRAWBERRY TREE, INC.
    00-40-D0   # MITAC INTERNATIONAL CORP.
    00-40-D1   # FUKUDA DENSHI CO., LTD.
    00-40-D2   # PAGINE CORPORATION
    00-40-D3   # KIMPSION INTERNATIONAL CORP.
    00-40-D4   # GAGE TALKER CORP.
    00-40-D5   # Sartorius Mechatronics T&H GmbH
    00-40-D6   # LOCAMATION B.V.
    00-40-D7   # STUDIO GEN INC.
    00-40-D8   # OCEAN OFFICE AUTOMATION LTD.
    00-40-D9   # AMERICAN MEGATRENDS INC.
    00-40-DA   # TELSPEC LTD
    00-40-DB   # ADVANCED TECHNICAL SOLUTIONS
    00-40-DC   # TRITEC ELECTRONIC GMBH
    00-40-DD   # HONG TECHNOLOGIES
    00-40-DE   # Elsag Datamat spa
    00-40-DF   # DIGALOG SYSTEMS, INC.
    00-40-E0   # ATOMWIDE LTD.
    00-40-E1   # MARNER INTERNATIONAL, INC.
    00-40-E2   # MESA RIDGE TECHNOLOGIES, INC.
    00-40-E3   # QUIN SYSTEMS LTD
    00-40-E4   # E-M TECHNOLOGY, INC.
    00-40-E5   # SYBUS CORPORATION
    00-40-E6   # C.A.E.N.
    00-40-E7   # ARNOS INSTRUMENTS & COMPUTER
    00-40-E8   # CHARLES RIVER DATA SYSTEMS,INC
    00-40-E9   # ACCORD SYSTEMS, INC.
    00-40-EA   # PLAIN TREE SYSTEMS INC
    00-40-EB   # MARTIN MARIETTA CORPORATION
    00-40-EC   # MIKASA SYSTEM ENGINEERING
    00-40-ED   # NETWORK CONTROLS INT'NATL INC.
    00-40-EE   # OPTIMEM
    00-40-EF   # HYPERCOM, INC.
    00-40-F0   # MicroBrain,Inc.
    00-40-F1   # CHUO ELECTRONICS CO., LTD.
    00-40-F2   # JANICH & KLASS COMPUTERTECHNIK
    00-40-F3   # NETCOR
    00-40-F4   # CAMEO COMMUNICATIONS, INC.
    00-40-F5   # OEM ENGINES
    00-40-F6   # KATRON COMPUTERS INC.
    00-40-F7   # Polaroid Corporation
    00-40-F8   # SYSTEMHAUS DISCOM
    00-40-F9   # COMBINET
    00-40-FA   # MICROBOARDS, INC.
    00-40-FB   # CASCADE COMMUNICATIONS
    00-40-FC   # IBR COMPUTER TECHNIK GMBH
    00-40-FD   # LXE
    00-40-FE   # SYMPLEX COMMUNICATIONS
    00-40-FF   # TELEBIT CORPORATION
    00-41-B4   # Wuxi Zhongxing Optoelectronics Technology Co.,Ltd.
    00-41-D2   # Cisco Systems, Inc
    00-42-52   # RLX Technologies
    00-43-FF   # KETRON S.R.L.
    00-45-01   # Versus Technology, Inc.
    00-46-4B   # HUAWEI TECHNOLOGIES CO.,LTD
    00-4D-32   # Andon Health Co.,Ltd.
    00-50-00   # NEXO COMMUNICATIONS, INC.
    00-50-01   # YAMASHITA SYSTEMS CORP.
    00-50-02   # OMNISEC AG
    00-50-03   # Xrite Inc
    00-50-04   # 3COM CORPORATION
    00-50-06   # TAC AB
    00-50-07   # SIEMENS TELECOMMUNICATION SYSTEMS LIMITED
    00-50-08   # TIVA MICROCOMPUTER CORP. (TMC)
    00-50-09   # PHILIPS BROADBAND NETWORKS
    00-50-0A   # IRIS TECHNOLOGIES, INC.
    00-50-0B   # Cisco Systems, Inc
    00-50-0C   # e-Tek Labs, Inc.
    00-50-0D   # SATORI ELECTORIC CO., LTD.
    00-50-0E   # CHROMATIS NETWORKS, INC.
    00-50-0F   # Cisco Systems, Inc
    00-50-10   # NovaNET Learning, Inc.
    00-50-12   # CBL - GMBH
    00-50-13   # Chaparral Network Storage
    00-50-14   # Cisco Systems, Inc
    00-50-15   # BRIGHT STAR ENGINEERING
    00-50-16   # SST/WOODHEAD INDUSTRIES
    00-50-17   # RSR S.R.L.
    00-50-18   # AMIT, Inc.
    00-50-19   # SPRING TIDE NETWORKS, INC.
    00-50-1A   # IQinVision
    00-50-1B   # ABL CANADA, INC.
    00-50-1C   # JATOM SYSTEMS, INC.
    00-50-1E   # Grass Valley, A Belden Brand
    00-50-1F   # MRG SYSTEMS, LTD.
    00-50-20   # MEDIASTAR CO., LTD.
    00-50-21   # EIS INTERNATIONAL, INC.
    00-50-22   # ZONET TECHNOLOGY, INC.
    00-50-23   # PG DESIGN ELECTRONICS, INC.
    00-50-24   # NAVIC SYSTEMS, INC.
    00-50-26   # COSYSTEMS, INC.
    00-50-27   # GENICOM CORPORATION
    00-50-28   # AVAL COMMUNICATIONS
    00-50-29   # 1394 PRINTER WORKING GROUP
    00-50-2A   # Cisco Systems, Inc
    00-50-2B   # GENRAD LTD.
    00-50-2C   # SOYO COMPUTER, INC.
    00-50-2D   # ACCEL, INC.
    00-50-2E   # CAMBEX CORPORATION
    00-50-2F   # TollBridge Technologies, Inc.
    00-50-30   # FUTURE PLUS SYSTEMS
    00-50-31   # AEROFLEX LABORATORIES, INC.
    00-50-32   # PICAZO COMMUNICATIONS, INC.
    00-50-33   # MAYAN NETWORKS
    00-50-36   # NETCAM, LTD.
    00-50-37   # KOGA ELECTRONICS CO.
    00-50-38   # DAIN TELECOM CO., LTD.
    00-50-39   # MARINER NETWORKS
    00-50-3A   # DATONG ELECTRONICS LTD.
    00-50-3B   # MEDIAFIRE CORPORATION
    00-50-3C   # TSINGHUA NOVEL ELECTRONICS
    00-50-3E   # Cisco Systems, Inc
    00-50-3F   # ANCHOR GAMES
    00-50-40   # Panasonic Electric Works Co., Ltd.
    00-50-41   # Coretronic Corporation
    00-50-42   # SCI MANUFACTURING SINGAPORE PTE, LTD.
    00-50-43   # MARVELL SEMICONDUCTOR, INC.
    00-50-44   # ASACA CORPORATION
    00-50-45   # RIOWORKS SOLUTIONS, INC.
    00-50-46   # MENICX INTERNATIONAL CO., LTD.
    00-50-47   # Private
    00-50-48   # INFOLIBRIA
    00-50-49   # Arbor Networks Inc
    00-50-4A   # ELTECO A.S.
    00-50-4B   # BARCONET N.V.
    00-50-4C   # Galil Motion Control
    00-50-4D   # Tokyo Electron Device Limited
    00-50-4E   # SIERRA MONITOR CORP.
    00-50-4F   # OLENCOM ELECTRONICS
    00-50-50   # Cisco Systems, Inc
    00-50-51   # IWATSU ELECTRIC CO., LTD.
    00-50-52   # TIARA NETWORKS, INC.
    00-50-53   # Cisco Systems, Inc
    00-50-54   # Cisco Systems, Inc
    00-50-55   # DOMS A/S
    00-50-56   # VMware, Inc.
    00-50-57   # BROADBAND ACCESS SYSTEMS
    00-50-58   # Sangoma Technologies
    00-50-59   # iBAHN
    00-50-5A   # NETWORK ALCHEMY, INC.
    00-50-5B   # KAWASAKI LSI U.S.A., INC.
    00-50-5C   # TUNDO CORPORATION
    00-50-5E   # DIGITEK MICROLOGIC S.A.
    00-50-5F   # BRAND INNOVATORS
    00-50-60   # TANDBERG TELECOM AS
    00-50-62   # KOUWELL ELECTRONICS CORP.  **
    00-50-63   # OY COMSEL SYSTEM AB
    00-50-64   # CAE ELECTRONICS
    00-50-65   # TDK-Lambda Corporation
    00-50-66   # AtecoM GmbH advanced telecomunication modules
    00-50-67   # AEROCOMM, INC.
    00-50-68   # ELECTRONIC INDUSTRIES ASSOCIATION
    00-50-69   # PixStream Incorporated
    00-50-6A   # EDEVA, INC.
    00-50-6B   # SPX-ATEG
    00-50-6C   # Beijer Electronics Products AB
    00-50-6D   # VIDEOJET SYSTEMS
    00-50-6E   # CORDER ENGINEERING CORPORATION
    00-50-6F   # G-CONNECT
    00-50-70   # CHAINTECH COMPUTER CO., LTD.
    00-50-71   # AIWA CO., LTD.
    00-50-72   # CORVIS CORPORATION
    00-50-73   # Cisco Systems, Inc
    00-50-74   # ADVANCED HI-TECH CORP.
    00-50-75   # KESTREL SOLUTIONS
    00-50-76   # IBM Corp
    00-50-77   # PROLIFIC TECHNOLOGY, INC.
    00-50-78   # MEGATON HOUSE, LTD.
    00-50-79   # Private
    00-50-7A   # XPEED, INC.
    00-50-7B   # MERLOT COMMUNICATIONS
    00-50-7C   # VIDEOCON AG
    00-50-7D   # IFP
    00-50-7E   # NEWER TECHNOLOGY
    00-50-7F   # DrayTek Corp.
    00-50-80   # Cisco Systems, Inc
    00-50-81   # MURATA MACHINERY, LTD.
    00-50-82   # FORESSON CORPORATION
    00-50-83   # GILBARCO, INC.
    00-50-84   # ATL PRODUCTS
    00-50-86   # TELKOM SA, LTD.
    00-50-87   # TERASAKI ELECTRIC CO., LTD.
    00-50-88   # AMANO CORPORATION
    00-50-89   # SAFETY MANAGEMENT SYSTEMS
    00-50-8B   # Hewlett Packard
    00-50-8C   # RSI SYSTEMS
    00-50-8D   # ABIT COMPUTER CORPORATION
    00-50-8E   # OPTIMATION, INC.
    00-50-8F   # ASITA TECHNOLOGIES INT'L LTD.
    00-50-90   # DCTRI
    00-50-91   # NETACCESS, INC.
    00-50-92   # Rigaku Corporation Osaka Plant
    00-50-93   # BOEING
    00-50-94   # Pace plc
    00-50-95   # PERACOM NETWORKS
    00-50-96   # SALIX TECHNOLOGIES, INC.
    00-50-97   # MMC-EMBEDDED COMPUTERTECHNIK GmbH
    00-50-98   # GLOBALOOP, LTD.
    00-50-99   # 3COM EUROPE, LTD.
    00-50-9A   # TAG ELECTRONIC SYSTEMS
    00-50-9B   # SWITCHCORE AB
    00-50-9C   # BETA RESEARCH
    00-50-9D   # THE INDUSTREE B.V.
    00-50-9E   # Les Technologies SoftAcoustik Inc.
    00-50-9F   # HORIZON COMPUTER
    00-50-A0   # DELTA COMPUTER SYSTEMS, INC.
    00-50-A1   # CARLO GAVAZZI, INC.
    00-50-A2   # Cisco Systems, Inc
    00-50-A3   # TransMedia Communications, Inc.
    00-50-A4   # IO TECH, INC.
    00-50-A5   # CAPITOL BUSINESS SYSTEMS, LTD.
    00-50-A6   # OPTRONICS
    00-50-A7   # Cisco Systems, Inc
    00-50-A8   # OpenCon Systems, Inc.
    00-50-A9   # MOLDAT WIRELESS TECHNOLGIES
    00-50-AA   # KONICA MINOLTA HOLDINGS, INC.
    00-50-AB   # NALTEC, Inc.
    00-50-AC   # MAPLE COMPUTER CORPORATION
    00-50-AD   # CommUnique Wireless Corp.
    00-50-AE   # FDK Co., Ltd
    00-50-AF   # INTERGON, INC.
    00-50-B0   # TECHNOLOGY ATLANTA CORPORATION
    00-50-B1   # GIDDINGS & LEWIS
    00-50-B2   # BRODEL GmbH
    00-50-B3   # VOICEBOARD CORPORATION
    00-50-B4   # SATCHWELL CONTROL SYSTEMS, LTD
    00-50-B5   # FICHET-BAUCHE
    00-50-B6   # GOOD WAY IND. CO., LTD.
    00-50-B7   # BOSER TECHNOLOGY CO., LTD.
    00-50-B8   # INOVA COMPUTERS GMBH & CO. KG
    00-50-B9   # XITRON TECHNOLOGIES, INC.
    00-50-BA   # D-Link Corporation
    00-50-BB   # CMS TECHNOLOGIES
    00-50-BC   # HAMMER STORAGE SOLUTIONS
    00-50-BD   # Cisco Systems, Inc
    00-50-BE   # FAST MULTIMEDIA AG
    00-50-BF   # Metalligence Technology Corp.
    00-50-C0   # GATAN, INC.
    00-50-C1   # GEMFLEX NETWORKS, LTD.
    00-50-C2   # IEEE Registration Authority
    00-50-C4   # IMD
    00-50-C5   # ADS Technologies, Inc
    00-50-C6   # LOOP TELECOMMUNICATION INTERNATIONAL, INC.
    00-50-C7   # Private
    00-50-C8   # Addonics Technologies, Inc.
    00-50-C9   # MASPRO DENKOH CORP.
    00-50-CA   # NET TO NET TECHNOLOGIES
    00-50-CB   # JETTER
    00-50-CC   # XYRATEX
    00-50-CD   # DIGIANSWER A/S
    00-50-CE   # LG INTERNATIONAL CORP.
    00-50-CF   # VANLINK COMMUNICATION TECHNOLOGY RESEARCH INSTITUTE
    00-50-D0   # MINERVA SYSTEMS
    00-50-D1   # Cisco Systems, Inc
    00-50-D2   # CMC Electronics Inc
    00-50-D3   # DIGITAL AUDIO PROCESSING PTY. LTD.
    00-50-D4   # JOOHONG INFORMATION &
    00-50-D5   # AD SYSTEMS CORP.
    00-50-D6   # ATLAS COPCO TOOLS AB
    00-50-D7   # TELSTRAT
    00-50-D8   # UNICORN COMPUTER CORP.
    00-50-D9   # ENGETRON-ENGENHARIA ELETRONICA IND. e COM. LTDA
    00-50-DA   # 3COM CORPORATION
    00-50-DB   # CONTEMPORARY CONTROL
    00-50-DC   # TAS TELEFONBAU A. SCHWABE GMBH & CO. KG
    00-50-DD   # SERRA SOLDADURA, S.A.
    00-50-DE   # SIGNUM SYSTEMS CORP.
    00-50-DF   # AirFiber, Inc.
    00-50-E1   # NS TECH ELECTRONICS SDN BHD
    00-50-E2   # Cisco Systems, Inc
    00-50-E3   # ARRIS Group, Inc.
    00-50-E4   # Apple, Inc.
    00-50-E6   # HAKUSAN CORPORATION
    00-50-E7   # PARADISE INNOVATIONS (ASIA)
    00-50-E8   # NOMADIX INC.
    00-50-EA   # XEL COMMUNICATIONS, INC.
    00-50-EB   # ALPHA-TOP CORPORATION
    00-50-EC   # OLICOM A/S
    00-50-ED   # ANDA NETWORKS
    00-50-EE   # TEK DIGITEL CORPORATION
    00-50-EF   # SPE Systemhaus GmbH
    00-50-F0   # Cisco Systems, Inc
    00-50-F1   # Intel Corporation
    00-50-F2   # MICROSOFT CORP.
    00-50-F3   # GLOBAL NET INFORMATION CO., Ltd.
    00-50-F4   # SIGMATEK GMBH & CO. KG
    00-50-F6   # PAN-INTERNATIONAL INDUSTRIAL CORP.
    00-50-F7   # VENTURE MANUFACTURING (SINGAPORE) LTD.
    00-50-F8   # ENTREGA TECHNOLOGIES, INC.
    00-50-F9   # Sensormatic Electronics LLC
    00-50-FA   # OXTEL, LTD.
    00-50-FB   # VSK ELECTRONICS
    00-50-FC   # EDIMAX TECHNOLOGY CO., LTD.
    00-50-FD   # VISIONCOMM CO., LTD.
    00-50-FE   # PCTVnet ASA
    00-50-FF   # HAKKO ELECTRONICS CO., LTD.
    00-52-18   # Wuxi Keboda Electron Co.Ltd
    00-54-AF   # Continental Automotive Systems Inc.
    00-54-BD   # Swelaser AB
    00-55-DA   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    00-56-CD   # Apple, Inc.
    00-57-D2   # Cisco Systems, Inc
    00-59-07   # LenovoEMC Products USA, LLC
    00-59-AC   # KPN. B.V.
    00-5A-39   # SHENZHEN FAST TECHNOLOGIES CO.,LTD
    00-5C-B1   # Gospell DIGITAL TECHNOLOGY CO., LTD
    00-5D-03   # Xilinx, Inc
    00-60-00   # XYCOM INC.
    00-60-01   # InnoSys, Inc.
    00-60-02   # SCREEN SUBTITLING SYSTEMS, LTD
    00-60-03   # TERAOKA WEIGH SYSTEM PTE, LTD.
    00-60-04   # COMPUTADORES MODULARES SA
    00-60-05   # FEEDBACK DATA LTD.
    00-60-06   # SOTEC CO., LTD
    00-60-07   # ACRES GAMING, INC.
    00-60-08   # 3COM CORPORATION
    00-60-09   # Cisco Systems, Inc
    00-60-0A   # SORD COMPUTER CORPORATION
    00-60-0B   # LOGWARE GmbH
    00-60-0C   # Eurotech Inc.
    00-60-0D   # Digital Logic GmbH
    00-60-0E   # WAVENET INTERNATIONAL, INC.
    00-60-0F   # WESTELL, INC.
    00-60-10   # NETWORK MACHINES, INC.
    00-60-11   # CRYSTAL SEMICONDUCTOR CORP.
    00-60-12   # POWER COMPUTING CORPORATION
    00-60-13   # NETSTAL MASCHINEN AG
    00-60-14   # EDEC CO., LTD.
    00-60-15   # NET2NET CORPORATION
    00-60-16   # CLARIION
    00-60-17   # TOKIMEC INC.
    00-60-18   # STELLAR ONE CORPORATION
    00-60-19   # Roche Diagnostics
    00-60-1A   # KEITHLEY INSTRUMENTS
    00-60-1B   # MESA ELECTRONICS
    00-60-1C   # TELXON CORPORATION
    00-60-1D   # LUCENT TECHNOLOGIES
    00-60-1E   # SOFTLAB, INC.
    00-60-1F   # STALLION TECHNOLOGIES
    00-60-20   # PIVOTAL NETWORKING, INC.
    00-60-21   # DSC CORPORATION
    00-60-22   # VICOM SYSTEMS, INC.
    00-60-23   # PERICOM SEMICONDUCTOR CORP.
    00-60-24   # GRADIENT TECHNOLOGIES, INC.
    00-60-25   # ACTIVE IMAGING PLC
    00-60-26   # VIKING Modular Solutions
    00-60-27   # Superior Modular Products
    00-60-28   # MACROVISION CORPORATION
    00-60-29   # CARY PERIPHERALS INC.
    00-60-2A   # SYMICRON COMPUTER COMMUNICATIONS, LTD.
    00-60-2B   # PEAK AUDIO
    00-60-2C   # LINX Data Terminals, Inc.
    00-60-2D   # ALERTON TECHNOLOGIES, INC.
    00-60-2E   # CYCLADES CORPORATION
    00-60-2F   # Cisco Systems, Inc
    00-60-30   # VILLAGE TRONIC ENTWICKLUNG
    00-60-31   # HRK SYSTEMS
    00-60-32   # I-CUBE, INC.
    00-60-33   # ACUITY IMAGING, INC.
    00-60-34   # ROBERT BOSCH GmbH
    00-60-35   # DALLAS SEMICONDUCTOR, INC.
    00-60-36   # AIT Austrian Institute of Technology GmbH
    00-60-37   # NXP Semiconductors
    00-60-38   # Nortel Networks
    00-60-39   # SanCom Technology, Inc.
    00-60-3A   # QUICK CONTROLS LTD.
    00-60-3B   # AMTEC spa
    00-60-3C   # HAGIWARA SYS-COM CO., LTD.
    00-60-3D   # 3CX
    00-60-3E   # Cisco Systems, Inc
    00-60-3F   # PATAPSCO DESIGNS
    00-60-40   # NETRO CORP.
    00-60-41   # Yokogawa Electric Corporation
    00-60-42   # TKS (USA), INC.
    00-60-43   # iDirect, INC.
    00-60-44   # LITTON/POLY-SCIENTIFIC
    00-60-45   # PATHLIGHT TECHNOLOGIES
    00-60-46   # VMETRO, INC.
    00-60-47   # Cisco Systems, Inc
    00-60-48   # EMC CORPORATION
    00-60-49   # VINA TECHNOLOGIES
    00-60-4A   # SAIC IDEAS GROUP
    00-60-4B   # Safe-com GmbH & Co. KG
    00-60-4C   # Sagemcom Broadband SAS
    00-60-4D   # MMC NETWORKS, INC.
    00-60-4E   # CYCLE COMPUTER CORPORATION, INC.
    00-60-4F   # Tattile SRL
    00-60-50   # INTERNIX INC.
    00-60-51   # QUALITY SEMICONDUCTOR
    00-60-52   # PERIPHERALS ENTERPRISE CO., Ltd.
    00-60-53   # TOYODA MACHINE WORKS, LTD.
    00-60-54   # CONTROLWARE GMBH
    00-60-55   # CORNELL UNIVERSITY
    00-60-56   # NETWORK TOOLS, INC.
    00-60-57   # Murata Manufacturing Co., Ltd.
    00-60-58   # COPPER MOUNTAIN COMMUNICATIONS, INC.
    00-60-59   # TECHNICAL COMMUNICATIONS CORP.
    00-60-5A   # CELCORE, INC.
    00-60-5B   # IntraServer Technology, Inc.
    00-60-5C   # Cisco Systems, Inc
    00-60-5D   # SCANIVALVE CORP.
    00-60-5E   # LIBERTY TECHNOLOGY NETWORKING
    00-60-5F   # NIPPON UNISOFT CORPORATION
    00-60-60   # Data Innovations North America
    00-60-61   # WHISTLE COMMUNICATIONS CORP.
    00-60-62   # TELESYNC, INC.
    00-60-63   # PSION DACOM PLC.
    00-60-64   # NETCOMM LIMITED
    00-60-65   # BERNECKER & RAINER INDUSTRIE-ELEKTRONIC GmbH
    00-60-66   # LACROIX Trafic
    00-60-67   # ACER NETXUS INC.
    00-60-68   # Dialogic Corporation
    00-60-69   # Brocade Communications Systems, Inc.
    00-60-6A   # MITSUBISHI WIRELESS COMMUNICATIONS. INC.
    00-60-6B   # Synclayer Inc.
    00-60-6C   # ARESCOM
    00-60-6D   # DIGITAL EQUIPMENT CORP.
    00-60-6E   # DAVICOM SEMICONDUCTOR, INC.
    00-60-6F   # CLARION CORPORATION OF AMERICA
    00-60-70   # Cisco Systems, Inc
    00-60-71   # MIDAS LAB, INC.
    00-60-72   # VXL INSTRUMENTS, LIMITED
    00-60-73   # REDCREEK COMMUNICATIONS, INC.
    00-60-74   # QSC AUDIO PRODUCTS
    00-60-75   # PENTEK, INC.
    00-60-76   # SCHLUMBERGER TECHNOLOGIES RETAIL PETROLEUM SYSTEMS
    00-60-77   # PRISA NETWORKS
    00-60-78   # POWER MEASUREMENT LTD.
    00-60-79   # Mainstream Data, Inc.
    00-60-7A   # DVS GMBH
    00-60-7B   # FORE SYSTEMS, INC.
    00-60-7C   # WaveAccess, Ltd.
    00-60-7D   # SENTIENT NETWORKS INC.
    00-60-7E   # GIGALABS, INC.
    00-60-7F   # AURORA TECHNOLOGIES, INC.
    00-60-80   # MICROTRONIX DATACOM LTD.
    00-60-81   # TV/COM INTERNATIONAL
    00-60-82   # NOVALINK TECHNOLOGIES, INC.
    00-60-83   # Cisco Systems, Inc
    00-60-84   # DIGITAL VIDEO
    00-60-85   # Storage Concepts
    00-60-86   # LOGIC REPLACEMENT TECH. LTD.
    00-60-87   # KANSAI ELECTRIC CO., LTD.
    00-60-88   # WHITE MOUNTAIN DSP, INC.
    00-60-89   # XATA
    00-60-8A   # CITADEL COMPUTER
    00-60-8B   # ConferTech International
    00-60-8C   # 3COM CORPORATION
    00-60-8D   # UNIPULSE CORP.
    00-60-8E   # HE ELECTRONICS, TECHNOLOGIE & SYSTEMTECHNIK GmbH
    00-60-8F   # TEKRAM TECHNOLOGY CO., LTD.
    00-60-90   # Artiza Networks Inc
    00-60-91   # FIRST PACIFIC NETWORKS, INC.
    00-60-92   # MICRO/SYS, INC.
    00-60-93   # VARIAN
    00-60-94   # IBM Corp
    00-60-95   # ACCU-TIME SYSTEMS, INC.
    00-60-96   # T.S. MICROTECH INC.
    00-60-97   # 3COM CORPORATION
    00-60-98   # HT COMMUNICATIONS
    00-60-99   # SBE, Inc.
    00-60-9A   # NJK TECHNO CO.
    00-60-9B   # ASTRO-MED, INC.
    00-60-9C   # Perkin-Elmer Incorporated
    00-60-9D   # PMI FOOD EQUIPMENT GROUP
    00-60-9E   # ASC X3 - INFORMATION TECHNOLOGY STANDARDS SECRETARIATS
    00-60-9F   # PHAST CORPORATION
    00-60-A0   # SWITCHED NETWORK TECHNOLOGIES, INC.
    00-60-A1   # VPNet, Inc.
    00-60-A2   # NIHON UNISYS LIMITED CO.
    00-60-A3   # CONTINUUM TECHNOLOGY CORP.
    00-60-A4   # GEW Technologies (PTY)Ltd
    00-60-A5   # PERFORMANCE TELECOM CORP.
    00-60-A6   # PARTICLE MEASURING SYSTEMS
    00-60-A7   # MICROSENS GmbH & CO. KG
    00-60-A8   # TIDOMAT AB
    00-60-A9   # GESYTEC MBH
    00-60-AA   # INTELLIGENT DEVICES INC. (IDI)
    00-60-AB   # LARSCOM INCORPORATED
    00-60-AC   # RESILIENCE CORPORATION
    00-60-AD   # MegaChips Corporation
    00-60-AE   # TRIO INFORMATION SYSTEMS AB
    00-60-AF   # PACIFIC MICRO DATA, INC.
    00-60-B0   # Hewlett Packard
    00-60-B1   # INPUT/OUTPUT, INC.
    00-60-B2   # PROCESS CONTROL CORP.
    00-60-B3   # Z-COM, INC.
    00-60-B4   # GLENAYRE R&D INC.
    00-60-B5   # KEBA GmbH
    00-60-B6   # LAND COMPUTER CO., LTD.
    00-60-B7   # CHANNELMATIC, INC.
    00-60-B8   # CORELIS Inc.
    00-60-B9   # NEC Platforms, Ltd
    00-60-BA   # SAHARA NETWORKS, INC.
    00-60-BB   # Cabletron Systems, Inc.
    00-60-BC   # KeunYoung Electronics & Communication Co., Ltd.
    00-60-BD   # HUBBELL-PULSECOM
    00-60-BE   # WEBTRONICS
    00-60-BF   # MACRAIGOR SYSTEMS, INC.
    00-60-C0   # Nera Networks AS
    00-60-C1   # WaveSpan Corporation
    00-60-C2   # MPL AG
    00-60-C3   # NETVISION CORPORATION
    00-60-C4   # SOLITON SYSTEMS K.K.
    00-60-C5   # ANCOT CORP.
    00-60-C6   # DCS AG
    00-60-C7   # AMATI COMMUNICATIONS CORP.
    00-60-C8   # KUKA WELDING SYSTEMS & ROBOTS
    00-60-C9   # ControlNet, Inc.
    00-60-CA   # HARMONIC SYSTEMS INCORPORATED
    00-60-CB   # HITACHI ZOSEN CORPORATION
    00-60-CC   # EMTRAK, INCORPORATED
    00-60-CD   # VideoServer, Inc.
    00-60-CE   # ACCLAIM COMMUNICATIONS
    00-60-CF   # ALTEON NETWORKS, INC.
    00-60-D0   # SNMP RESEARCH INCORPORATED
    00-60-D1   # CASCADE COMMUNICATIONS
    00-60-D2   # LUCENT TECHNOLOGIES TAIWAN TELECOMMUNICATIONS CO., LTD.
    00-60-D3   # AT&T
    00-60-D4   # ELDAT COMMUNICATION LTD.
    00-60-D5   # MIYACHI TECHNOS CORP.
    00-60-D6   # NovAtel Wireless Technologies Ltd.
    00-60-D7   # ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE (EPFL)
    00-60-D8   # ELMIC SYSTEMS, INC.
    00-60-D9   # TRANSYS NETWORKS INC.
    00-60-DA   # Red Lion Controls, LP
    00-60-DB   # NTP ELEKTRONIK A/S
    00-60-DC   # NEC Magnus Communications,Ltd.
    00-60-DD   # MYRICOM, INC.
    00-60-DE   # Kayser-Threde GmbH
    00-60-DF   # Brocade Communications Systems, Inc.
    00-60-E0   # AXIOM TECHNOLOGY CO., LTD.
    00-60-E1   # ORCKIT COMMUNICATIONS LTD.
    00-60-E2   # QUEST ENGINEERING & DEVELOPMENT
    00-60-E3   # ARBIN INSTRUMENTS
    00-60-E4   # COMPUSERVE, INC.
    00-60-E5   # FUJI AUTOMATION CO., LTD.
    00-60-E6   # SHOMITI SYSTEMS INCORPORATED
    00-60-E7   # RANDATA
    00-60-E8   # HITACHI COMPUTER PRODUCTS (AMERICA), INC.
    00-60-E9   # ATOP TECHNOLOGIES, INC.
    00-60-EA   # StreamLogic
    00-60-EB   # FOURTHTRACK SYSTEMS
    00-60-EC   # HERMARY OPTO ELECTRONICS INC.
    00-60-ED   # RICARDO TEST AUTOMATION LTD.
    00-60-EE   # APOLLO
    00-60-EF   # FLYTECH TECHNOLOGY CO., LTD.
    00-60-F0   # JOHNSON & JOHNSON MEDICAL, INC
    00-60-F1   # EXP COMPUTER, INC.
    00-60-F2   # LASERGRAPHICS, INC.
    00-60-F3   # Performance Analysis Broadband, Spirent plc
    00-60-F4   # ADVANCED COMPUTER SOLUTIONS, Inc.
    00-60-F5   # ICON WEST, INC.
    00-60-F6   # NEXTEST COMMUNICATIONS PRODUCTS, INC.
    00-60-F7   # DATAFUSION SYSTEMS
    00-60-F8   # Loran International Technologies Inc.
    00-60-F9   # DIAMOND LANE COMMUNICATIONS
    00-60-FA   # EDUCATIONAL TECHNOLOGY RESOURCES, INC.
    00-60-FB   # PACKETEER, INC.
    00-60-FC   # CONSERVATION THROUGH INNOVATION LTD.
    00-60-FD   # NetICs, Inc.
    00-60-FE   # LYNX SYSTEM DEVELOPERS, INC.
    00-60-FF   # QuVis, Inc.
    00-61-71   # Apple, Inc.
    00-64-40   # Cisco Systems, Inc
    00-64-A6   # Maquet CardioVascular
    00-66-4B   # HUAWEI TECHNOLOGIES CO.,LTD
    00-6B-8E   # Shanghai Feixun Communication Co.,Ltd.
    00-6B-9E   # VIZIO Inc
    00-6B-A0   # SHENZHEN UNIVERSAL INTELLISYS PTE LTD
    00-6C-FD   # Sichuan Changhong Electric Ltd.
    00-6D-52   # Apple, Inc.
    00-6D-FB   # Vutrix Technologies Ltd
    00-70-B0   # M/A-COM INC. COMPANIES
    00-70-B3   # DATA RECALL LTD.
    00-71-C2   # PEGATRON CORPORATION
    00-71-CC   # Hon Hai Precision Ind. Co.,Ltd.
    00-73-8D   # Shenzhen TINNO Mobile Technology Corp.
    00-73-E0   # Samsung Electronics Co.,Ltd
    00-75-32   # INID BV
    00-75-E1   # Ampt, LLC
    00-78-9E   # Sagemcom Broadband SAS
    00-78-CD   # Ignition Design Labs
    00-7D-FA   # Volkswagen Group of America
    00-7E-56   # China Dragon Technology Limited
    00-7F-28   # Actiontec Electronics, Inc
    00-80-00   # MULTITECH SYSTEMS, INC.
    00-80-01   # PERIPHONICS CORPORATION
    00-80-02   # SATELCOM (UK) LTD
    00-80-03   # HYTEC ELECTRONICS LTD.
    00-80-04   # ANTLOW COMMUNICATIONS, LTD.
    00-80-05   # CACTUS COMPUTER INC.
    00-80-06   # COMPUADD CORPORATION
    00-80-07   # DLOG NC-SYSTEME
    00-80-08   # DYNATECH COMPUTER SYSTEMS
    00-80-09   # JUPITER SYSTEMS, INC.
    00-80-0A   # JAPAN COMPUTER CORP.
    00-80-0B   # CSK CORPORATION
    00-80-0C   # VIDECOM LIMITED
    00-80-0D   # VOSSWINKEL F.U.
    00-80-0E   # ATLANTIX CORPORATION
    00-80-0F   # STANDARD MICROSYSTEMS
    00-80-10   # COMMODORE INTERNATIONAL
    00-80-11   # DIGITAL SYSTEMS INT'L. INC.
    00-80-12   # INTEGRATED MEASUREMENT SYSTEMS
    00-80-13   # THOMAS-CONRAD CORPORATION
    00-80-14   # ESPRIT SYSTEMS
    00-80-15   # SEIKO SYSTEMS, INC.
    00-80-16   # WANDEL AND GOLTERMANN
    00-80-17   # PFU LIMITED
    00-80-18   # KOBE STEEL, LTD.
    00-80-19   # DAYNA COMMUNICATIONS, INC.
    00-80-1A   # BELL ATLANTIC
    00-80-1B   # KODIAK TECHNOLOGY
    00-80-1C   # NEWPORT SYSTEMS SOLUTIONS
    00-80-1D   # INTEGRATED INFERENCE MACHINES
    00-80-1E   # XINETRON, INC.
    00-80-1F   # KRUPP ATLAS ELECTRONIK GMBH
    00-80-20   # NETWORK PRODUCTS
    00-80-21   # Alcatel Canada Inc.
    00-80-22   # SCAN-OPTICS
    00-80-23   # INTEGRATED BUSINESS NETWORKS
    00-80-24   # KALPANA, INC.
    00-80-25   # STOLLMANN GMBH
    00-80-26   # NETWORK PRODUCTS CORPORATION
    00-80-27   # ADAPTIVE SYSTEMS, INC.
    00-80-28   # TRADPOST (HK) LTD
    00-80-29   # EAGLE TECHNOLOGY, INC.
    00-80-2A   # TEST SYSTEMS & SIMULATIONS INC
    00-80-2B   # INTEGRATED MARKETING CO
    00-80-2C   # THE SAGE GROUP PLC
    00-80-2D   # XYLOGICS INC
    00-80-2E   # CASTLE ROCK COMPUTING
    00-80-2F   # NATIONAL INSTRUMENTS CORP.
    00-80-30   # NEXUS ELECTRONICS
    00-80-31   # BASYS, CORP.
    00-80-32   # ACCESS CO., LTD.
    00-80-33   # EMS Aviation, Inc.
    00-80-34   # SMT GOUPIL
    00-80-35   # TECHNOLOGY WORKS, INC.
    00-80-36   # REFLEX MANUFACTURING SYSTEMS
    00-80-37   # Ericsson Group
    00-80-38   # DATA RESEARCH & APPLICATIONS
    00-80-39   # ALCATEL STC AUSTRALIA
    00-80-3A   # VARITYPER, INC.
    00-80-3B   # APT COMMUNICATIONS, INC.
    00-80-3C   # TVS ELECTRONICS LTD
    00-80-3D   # SURIGIKEN CO.,  LTD.
    00-80-3E   # SYNERNETICS
    00-80-3F   # TATUNG COMPANY
    00-80-40   # JOHN FLUKE MANUFACTURING CO.
    00-80-41   # VEB KOMBINAT ROBOTRON
    00-80-42   # Artesyn Embedded Technologies
    00-80-43   # NETWORLD, INC.
    00-80-44   # SYSTECH COMPUTER CORP.
    00-80-45   # MATSUSHITA ELECTRIC IND. CO
    00-80-46   # Tattile SRL
    00-80-47   # IN-NET CORP.
    00-80-48   # COMPEX INCORPORATED
    00-80-49   # NISSIN ELECTRIC CO., LTD.
    00-80-4A   # PRO-LOG
    00-80-4B   # EAGLE TECHNOLOGIES PTY.LTD.
    00-80-4C   # CONTEC CO., LTD.
    00-80-4D   # CYCLONE MICROSYSTEMS, INC.
    00-80-4E   # APEX COMPUTER COMPANY
    00-80-4F   # DAIKIN INDUSTRIES, LTD.
    00-80-50   # ZIATECH CORPORATION
    00-80-51   # FIBERMUX
    00-80-52   # TECHNICALLY ELITE CONCEPTS
    00-80-53   # INTELLICOM, INC.
    00-80-54   # FRONTIER TECHNOLOGIES CORP.
    00-80-55   # FERMILAB
    00-80-56   # SPHINX Electronics GmbH & Co KG
    00-80-57   # ADSOFT, LTD.
    00-80-58   # PRINTER SYSTEMS CORPORATION
    00-80-59   # STANLEY ELECTRIC CO., LTD
    00-80-5A   # TULIP COMPUTERS INTERNAT'L B.V
    00-80-5B   # CONDOR SYSTEMS, INC.
    00-80-5C   # AGILIS CORPORATION
    00-80-5D   # CANSTAR
    00-80-5E   # LSI LOGIC CORPORATION
    00-80-5F   # Hewlett Packard
    00-80-60   # NETWORK INTERFACE CORPORATION
    00-80-61   # LITTON SYSTEMS, INC.
    00-80-62   # INTERFACE  CO.
    00-80-63   # Hirschmann Automation and Control GmbH
    00-80-64   # WYSE TECHNOLOGY LLC
    00-80-65   # CYBERGRAPHIC SYSTEMS PTY LTD.
    00-80-66   # ARCOM CONTROL SYSTEMS, LTD.
    00-80-67   # SQUARE D COMPANY
    00-80-68   # YAMATECH SCIENTIFIC LTD.
    00-80-69   # COMPUTONE SYSTEMS
    00-80-6A   # ERI (EMPAC RESEARCH INC.)
    00-80-6B   # SCHMID TELECOMMUNICATION
    00-80-6C   # CEGELEC PROJECTS LTD
    00-80-6D   # CENTURY SYSTEMS CORP.
    00-80-6E   # NIPPON STEEL CORPORATION
    00-80-6F   # ONELAN LTD.
    00-80-70   # COMPUTADORAS MICRON
    00-80-71   # SAI TECHNOLOGY
    00-80-72   # MICROPLEX SYSTEMS LTD.
    00-80-73   # DWB ASSOCIATES
    00-80-74   # FISHER CONTROLS
    00-80-75   # PARSYTEC GMBH
    00-80-76   # MCNC
    00-80-77   # Brother industries, LTD.
    00-80-78   # PRACTICAL PERIPHERALS, INC.
    00-80-79   # MICROBUS DESIGNS LTD.
    00-80-7A   # AITECH SYSTEMS LTD.
    00-80-7B   # ARTEL COMMUNICATIONS CORP.
    00-80-7C   # FIBERCOM, INC.
    00-80-7D   # EQUINOX SYSTEMS INC.
    00-80-7E   # SOUTHERN PACIFIC LTD.
    00-80-7F   # DY-4 INCORPORATED
    00-80-80   # DATAMEDIA CORPORATION
    00-80-81   # KENDALL SQUARE RESEARCH CORP.
    00-80-82   # PEP MODULAR COMPUTERS GMBH
    00-80-83   # AMDAHL
    00-80-84   # THE CLOUD INC.
    00-80-85   # H-THREE SYSTEMS CORPORATION
    00-80-86   # COMPUTER GENERATION INC.
    00-80-87   # OKI ELECTRIC INDUSTRY CO., LTD
    00-80-88   # VICTOR COMPANY OF JAPAN, LTD.
    00-80-89   # TECNETICS (PTY) LTD.
    00-80-8A   # SUMMIT MICROSYSTEMS CORP.
    00-80-8B   # DACOLL LIMITED
    00-80-8C   # NetScout Systems, Inc.
    00-80-8D   # WESTCOAST TECHNOLOGY B.V.
    00-80-8E   # RADSTONE TECHNOLOGY
    00-80-8F   # C. ITOH ELECTRONICS, INC.
    00-80-90   # MICROTEK INTERNATIONAL, INC.
    00-80-91   # TOKYO ELECTRIC CO.,LTD
    00-80-92   # Silex Technology, Inc.
    00-80-93   # XYRON CORPORATION
    00-80-94   # ALFA LAVAL AUTOMATION AB
    00-80-95   # BASIC MERTON HANDELSGES.M.B.H.
    00-80-96   # HUMAN DESIGNED SYSTEMS, INC.
    00-80-97   # CENTRALP AUTOMATISMES
    00-80-98   # TDK CORPORATION
    00-80-99   # Eaton Industries GmbH
    00-80-9A   # NOVUS NETWORKS LTD
    00-80-9B   # JUSTSYSTEM CORPORATION
    00-80-9C   # LUXCOM, INC.
    00-80-9D   # Commscraft Ltd.
    00-80-9E   # DATUS GMBH
    00-80-9F   # ALE International
    00-80-A0   # Hewlett Packard
    00-80-A1   # MICROTEST, INC.
    00-80-A2   # CREATIVE ELECTRONIC SYSTEMS
    00-80-A3   # Lantronix
    00-80-A4   # LIBERTY ELECTRONICS
    00-80-A5   # SPEED INTERNATIONAL
    00-80-A6   # REPUBLIC TECHNOLOGY, INC.
    00-80-A7   # Honeywell International Inc
    00-80-A8   # VITACOM CORPORATION
    00-80-A9   # CLEARPOINT RESEARCH
    00-80-AA   # MAXPEED
    00-80-AB   # DUKANE NETWORK INTEGRATION
    00-80-AC   # IMLOGIX, DIVISION OF GENESYS
    00-80-AD   # CNET TECHNOLOGY, INC.
    00-80-AE   # HUGHES NETWORK SYSTEMS
    00-80-AF   # ALLUMER CO., LTD.
    00-80-B0   # ADVANCED INFORMATION
    00-80-B1   # SOFTCOM A/S
    00-80-B2   # NETWORK EQUIPMENT TECHNOLOGIES
    00-80-B3   # AVAL DATA CORPORATION
    00-80-B4   # SOPHIA SYSTEMS
    00-80-B5   # UNITED NETWORKS INC.
    00-80-B6   # THEMIS COMPUTER
    00-80-B7   # STELLAR COMPUTER
    00-80-B8   # DMG MORI B.U.G. CO., LTD.
    00-80-B9   # ARCHE TECHNOLIGIES INC.
    00-80-BA   # SPECIALIX (ASIA) PTE, LTD
    00-80-BB   # HUGHES LAN SYSTEMS
    00-80-BC   # HITACHI ENGINEERING CO., LTD
    00-80-BD   # THE FURUKAWA ELECTRIC CO., LTD
    00-80-BE   # ARIES RESEARCH
    00-80-BF   # TAKAOKA ELECTRIC MFG. CO. LTD.
    00-80-C0   # PENRIL DATACOMM
    00-80-C1   # LANEX CORPORATION
    00-80-C2   # IEEE 802.1
    00-80-C3   # BICC INFORMATION SYSTEMS & SVC
    00-80-C4   # DOCUMENT TECHNOLOGIES, INC.
    00-80-C5   # NOVELLCO DE MEXICO
    00-80-C6   # NATIONAL DATACOMM CORPORATION
    00-80-C7   # XIRCOM
    00-80-C8   # D-LINK SYSTEMS, INC.
    00-80-C9   # ALBERTA MICROELECTRONIC CENTRE
    00-80-CA   # NETCOM RESEARCH INCORPORATED
    00-80-CB   # FALCO DATA PRODUCTS
    00-80-CC   # MICROWAVE BYPASS SYSTEMS
    00-80-CD   # MICRONICS COMPUTER, INC.
    00-80-CE   # BROADCAST TELEVISION SYSTEMS
    00-80-CF   # EMBEDDED PERFORMANCE INC.
    00-80-D0   # COMPUTER PERIPHERALS, INC.
    00-80-D1   # KIMTRON CORPORATION
    00-80-D2   # SHINNIHONDENKO CO., LTD.
    00-80-D3   # SHIVA CORP.
    00-80-D4   # CHASE RESEARCH LTD.
    00-80-D5   # CADRE TECHNOLOGIES
    00-80-D6   # NUVOTECH, INC.
    00-80-D7   # Fantum Engineering
    00-80-D8   # NETWORK PERIPHERALS INC.
    00-80-D9   # EMK Elektronik GmbH & Co. KG
    00-80-DA   # Bruel & Kjaer Sound & Vibration Measurement A/S
    00-80-DB   # GRAPHON CORPORATION
    00-80-DC   # PICKER INTERNATIONAL
    00-80-DD   # GMX INC/GIMIX
    00-80-DE   # GIPSI S.A.
    00-80-DF   # ADC CODENOLL TECHNOLOGY CORP.
    00-80-E0   # XTP SYSTEMS, INC.
    00-80-E1   # STMicroelectronics SRL
    00-80-E2   # T.D.I. CO., LTD.
    00-80-E3   # CORAL NETWORK CORPORATION
    00-80-E4   # NORTHWEST DIGITAL SYSTEMS, INC
    00-80-E5   # NetApp
    00-80-E6   # PEER NETWORKS, INC.
    00-80-E7   # LYNWOOD SCIENTIFIC DEV. LTD.
    00-80-E8   # CUMULUS CORPORATIION
    00-80-E9   # Madge Ltd.
    00-80-EA   # ADVA Optical Networking Ltd.
    00-80-EB   # COMPCONTROL B.V.
    00-80-EC   # SUPERCOMPUTING SOLUTIONS, INC.
    00-80-ED   # IQ TECHNOLOGIES, INC.
    00-80-EE   # THOMSON CSF
    00-80-EF   # RATIONAL
    00-80-F0   # Panasonic Communications Co., Ltd.
    00-80-F1   # OPUS SYSTEMS
    00-80-F2   # RAYCOM SYSTEMS INC
    00-80-F3   # SUN ELECTRONICS CORP.
    00-80-F4   # TELEMECANIQUE ELECTRIQUE
    00-80-F5   # Quantel Ltd
    00-80-F6   # SYNERGY MICROSYSTEMS
    00-80-F7   # ZENITH ELECTRONICS
    00-80-F8   # MIZAR, INC.
    00-80-F9   # HEURIKON CORPORATION
    00-80-FA   # RWT GMBH
    00-80-FB   # BVM LIMITED
    00-80-FC   # AVATAR CORPORATION
    00-80-FD   # EXSCEED CORPRATION
    00-80-FE   # AZURE TECHNOLOGIES, INC.
    00-80-FF   # SOC. DE TELEINFORMATIQUE RTC
    00-84-ED   # Private
    00-86-A0   # Private
    00-88-65   # Apple, Inc.
    00-8B-43   # RFTECH
    00-8C-10   # Black Box Corp.
    00-8C-54   # ADB Broadband Italia
    00-8C-FA   # Inventec Corporation
    00-8D-4E   # CJSC NII STT
    00-8D-DA   # Link One Co., Ltd.
    00-8E-F2   # NETGEAR
    00-90-00   # DIAMOND MULTIMEDIA
    00-90-01   # NISHIMU ELECTRONICS INDUSTRIES CO., LTD.
    00-90-02   # ALLGON AB
    00-90-03   # APLIO
    00-90-04   # 3COM EUROPE LTD.
    00-90-05   # PROTECH SYSTEMS CO., LTD.
    00-90-06   # HAMAMATSU PHOTONICS K.K.
    00-90-07   # DOMEX TECHNOLOGY CORP.
    00-90-08   # HanA Systems Inc.
    00-90-09   # I Controls, Inc.
    00-90-0A   # PROTON ELECTRONIC INDUSTRIAL CO., LTD.
    00-90-0B   # LANNER ELECTRONICS, INC.
    00-90-0C   # Cisco Systems, Inc
    00-90-0D   # Overland Storage Inc.
    00-90-0E   # HANDLINK TECHNOLOGIES, INC.
    00-90-0F   # KAWASAKI HEAVY INDUSTRIES, LTD
    00-90-10   # SIMULATION LABORATORIES, INC.
    00-90-11   # WAVTrace, Inc.
    00-90-12   # GLOBESPAN SEMICONDUCTOR, INC.
    00-90-13   # SAMSAN CORP.
    00-90-14   # ROTORK INSTRUMENTS, LTD.
    00-90-15   # CENTIGRAM COMMUNICATIONS CORP.
    00-90-16   # ZAC
    00-90-17   # Zypcom, Inc
    00-90-18   # ITO ELECTRIC INDUSTRY CO, LTD.
    00-90-19   # HERMES ELECTRONICS CO., LTD.
    00-90-1A   # UNISPHERE SOLUTIONS
    00-90-1B   # DIGITAL CONTROLS
    00-90-1C   # mps Software Gmbh
    00-90-1D   # PEC (NZ) LTD.
    00-90-1E   # Selesta Ingegneria S.p.A.
    00-90-1F   # ADTEC PRODUCTIONS, INC.
    00-90-20   # PHILIPS ANALYTICAL X-RAY B.V.
    00-90-21   # Cisco Systems, Inc
    00-90-22   # IVEX
    00-90-23   # ZILOG INC.
    00-90-24   # PIPELINKS, INC.
    00-90-25   # BAE Systems Australia (Electronic Systems) Pty Ltd
    00-90-26   # ADVANCED SWITCHING COMMUNICATIONS, INC.
    00-90-27   # Intel Corporation
    00-90-28   # NIPPON SIGNAL CO., LTD.
    00-90-29   # CRYPTO AG
    00-90-2A   # COMMUNICATION DEVICES, INC.
    00-90-2B   # Cisco Systems, Inc
    00-90-2C   # DATA & CONTROL EQUIPMENT LTD.
    00-90-2D   # DATA ELECTRONICS (AUST.) PTY, LTD.
    00-90-2E   # NAMCO LIMITED
    00-90-2F   # NETCORE SYSTEMS, INC.
    00-90-30   # HONEYWELL-DATING
    00-90-31   # MYSTICOM, LTD.
    00-90-32   # PELCOMBE GROUP LTD.
    00-90-33   # INNOVAPHONE AG
    00-90-34   # IMAGIC, INC.
    00-90-35   # ALPHA TELECOM, INC.
    00-90-36   # ens, inc.
    00-90-37   # ACUCOMM, INC.
    00-90-38   # FOUNTAIN TECHNOLOGIES, INC.
    00-90-39   # SHASTA NETWORKS
    00-90-3A   # NIHON MEDIA TOOL INC.
    00-90-3B   # TriEMS Research Lab, Inc.
    00-90-3C   # ATLANTIC NETWORK SYSTEMS
    00-90-3D   # BIOPAC SYSTEMS, INC.
    00-90-3E   # N.V. PHILIPS INDUSTRIAL ACTIVITIES
    00-90-3F   # AZTEC RADIOMEDIA
    00-90-40   # Siemens Network Convergence LLC
    00-90-41   # APPLIED DIGITAL ACCESS
    00-90-42   # ECCS, Inc.
    00-90-43   # Tattile SRL
    00-90-44   # ASSURED DIGITAL, INC.
    00-90-45   # Marconi Communications
    00-90-46   # DEXDYNE, LTD.
    00-90-47   # GIGA FAST E. LTD.
    00-90-48   # ZEAL CORPORATION
    00-90-49   # ENTRIDIA CORPORATION
    00-90-4A   # CONCUR SYSTEM TECHNOLOGIES
    00-90-4B   # Gemtek Technology Co., Ltd.
    00-90-4C   # Epigram, Inc.
    00-90-4D   # SPEC S.A.
    00-90-4E   # DELEM BV
    00-90-4F   # ABB POWER T&D COMPANY, INC.
    00-90-50   # Teleste Corporation
    00-90-51   # ULTIMATE TECHNOLOGY CORP.
    00-90-52   # SELCOM ELETTRONICA S.R.L.
    00-90-53   # DAEWOO ELECTRONICS CO., LTD.
    00-90-54   # INNOVATIVE SEMICONDUCTORS, INC
    00-90-55   # PARKER HANNIFIN CORPORATION COMPUMOTOR DIVISION
    00-90-56   # TELESTREAM, INC.
    00-90-57   # AANetcom, Inc.
    00-90-58   # Ultra Electronics Ltd., Command and Control Systems
    00-90-59   # TELECOM DEVICE K.K.
    00-90-5A   # DEARBORN GROUP, INC.
    00-90-5B   # RAYMOND AND LAE ENGINEERING
    00-90-5C   # EDMI
    00-90-5D   # NETCOM SICHERHEITSTECHNIK GMBH
    00-90-5E   # RAULAND-BORG CORPORATION
    00-90-5F   # Cisco Systems, Inc
    00-90-60   # SYSTEM CREATE CORP.
    00-90-61   # PACIFIC RESEARCH & ENGINEERING CORPORATION
    00-90-62   # ICP VORTEX COMPUTERSYSTEME GmbH
    00-90-63   # COHERENT COMMUNICATIONS SYSTEMS CORPORATION
    00-90-64   # Thomson Inc.
    00-90-65   # FINISAR CORPORATION
    00-90-66   # Troika Networks, Inc.
    00-90-67   # WalkAbout Computers, Inc.
    00-90-68   # DVT CORP.
    00-90-69   # Juniper Networks
    00-90-6A   # TURNSTONE SYSTEMS, INC.
    00-90-6B   # APPLIED RESOURCES, INC.
    00-90-6C   # Sartorius Hamburg GmbH
    00-90-6D   # Cisco Systems, Inc
    00-90-6E   # PRAXON, INC.
    00-90-6F   # Cisco Systems, Inc
    00-90-70   # NEO NETWORKS, INC.
    00-90-71   # Applied Innovation Inc.
    00-90-72   # SIMRAD AS
    00-90-73   # GAIO TECHNOLOGY
    00-90-74   # ARGON NETWORKS, INC.
    00-90-75   # NEC DO BRASIL S.A.
    00-90-76   # FMT AIRCRAFT GATE SUPPORT SYSTEMS AB
    00-90-77   # ADVANCED FIBRE COMMUNICATIONS
    00-90-78   # MER TELEMANAGEMENT SOLUTIONS, LTD.
    00-90-79   # ClearOne, Inc.
    00-90-7A   # Spectralink, Inc
    00-90-7B   # E-TECH, INC.
    00-90-7C   # DIGITALCAST, INC.
    00-90-7D   # Lake Communications
    00-90-7E   # VETRONIX CORP.
    00-90-7F   # WatchGuard Technologies, Inc.
    00-90-80   # NOT LIMITED, INC.
    00-90-81   # ALOHA NETWORKS, INC.
    00-90-82   # FORCE INSTITUTE
    00-90-83   # TURBO COMMUNICATION, INC.
    00-90-84   # ATECH SYSTEM
    00-90-85   # GOLDEN ENTERPRISES, INC.
    00-90-86   # Cisco Systems, Inc
    00-90-87   # ITIS
    00-90-88   # BAXALL SECURITY LTD.
    00-90-89   # SOFTCOM MICROSYSTEMS, INC.
    00-90-8A   # BAYLY COMMUNICATIONS, INC.
    00-90-8B   # Tattile SRL
    00-90-8C   # ETREND ELECTRONICS, INC.
    00-90-8D   # VICKERS ELECTRONICS SYSTEMS
    00-90-8E   # Nortel Networks Broadband Access
    00-90-8F   # AUDIO CODES LTD.
    00-90-90   # I-BUS
    00-90-91   # DigitalScape, Inc.
    00-90-92   # Cisco Systems, Inc
    00-90-93   # NANAO CORPORATION
    00-90-94   # OSPREY TECHNOLOGIES, INC.
    00-90-95   # UNIVERSAL AVIONICS
    00-90-96   # ASKEY COMPUTER CORP
    00-90-97   # Sycamore Networks
    00-90-98   # SBC DESIGNS, INC.
    00-90-99   # ALLIED TELESIS, K.K.
    00-90-9A   # ONE WORLD SYSTEMS, INC.
    00-90-9B   # MARKEM-IMAJE
    00-90-9C   # ARRIS Group, Inc.
    00-90-9D   # NovaTech Process Solutions, LLC
    00-90-9E   # Critical IO, LLC
    00-90-9F   # DIGI-DATA CORPORATION
    00-90-A0   # 8X8 INC.
    00-90-A1   # Flying Pig Systems/High End Systems Inc.
    00-90-A2   # CyberTAN Technology Inc.
    00-90-A3   # Corecess Inc.
    00-90-A4   # ALTIGA NETWORKS
    00-90-A5   # SPECTRA LOGIC
    00-90-A6   # Cisco Systems, Inc
    00-90-A7   # CLIENTEC CORPORATION
    00-90-A8   # NineTiles Networks, Ltd.
    00-90-A9   # WESTERN DIGITAL
    00-90-AA   # INDIGO ACTIVE VISION SYSTEMS LIMITED
    00-90-AB   # Cisco Systems, Inc
    00-90-AC   # OPTIVISION, INC.
    00-90-AD   # ASPECT ELECTRONICS, INC.
    00-90-AE   # ITALTEL S.p.A.
    00-90-AF   # J. MORITA MFG. CORP.
    00-90-B0   # VADEM
    00-90-B1   # Cisco Systems, Inc
    00-90-B2   # AVICI SYSTEMS INC.
    00-90-B3   # AGRANAT SYSTEMS
    00-90-B4   # WILLOWBROOK TECHNOLOGIES
    00-90-B5   # NIKON CORPORATION
    00-90-B6   # FIBEX SYSTEMS
    00-90-B7   # DIGITAL LIGHTWAVE, INC.
    00-90-B8   # ROHDE & SCHWARZ GMBH & CO. KG
    00-90-B9   # BERAN INSTRUMENTS LTD.
    00-90-BA   # VALID NETWORKS, INC.
    00-90-BB   # TAINET COMMUNICATION SYSTEM Corp.
    00-90-BC   # TELEMANN CO., LTD.
    00-90-BD   # OMNIA COMMUNICATIONS, INC.
    00-90-BE   # IBC/INTEGRATED BUSINESS COMPUTERS
    00-90-BF   # Cisco Systems, Inc
    00-90-C0   # K.J. LAW ENGINEERS, INC.
    00-90-C1   # Peco II, Inc.
    00-90-C2   # JK microsystems, Inc.
    00-90-C3   # TOPIC SEMICONDUCTOR CORP.
    00-90-C4   # JAVELIN SYSTEMS, INC.
    00-90-C5   # INTERNET MAGIC, INC.
    00-90-C6   # OPTIM SYSTEMS, INC.
    00-90-C7   # ICOM INC.
    00-90-C8   # WAVERIDER COMMUNICATIONS (CANADA) INC.
    00-90-C9   # DPAC Technologies
    00-90-CA   # ACCORD VIDEO TELECOMMUNICATIONS, LTD.
    00-90-CB   # Wireless OnLine, Inc.
    00-90-CC   # Planex Communications
    00-90-CD   # ENT-EMPRESA NACIONAL DE TELECOMMUNICACOES, S.A.
    00-90-CE   # TETRA GmbH
    00-90-CF   # NORTEL
    00-90-D0   # Thomson Telecom Belgium
    00-90-D1   # LEICHU ENTERPRISE CO., LTD.
    00-90-D2   # ARTEL VIDEO SYSTEMS
    00-90-D3   # GIESECKE & DEVRIENT GmbH
    00-90-D4   # BindView Development Corp.
    00-90-D5   # EUPHONIX, INC.
    00-90-D6   # Crystal Group, Inc.
    00-90-D7   # NetBoost Corp.
    00-90-D8   # WHITECROSS SYSTEMS
    00-90-D9   # Cisco Systems, Inc
    00-90-DA   # DYNARC, INC.
    00-90-DB   # NEXT LEVEL COMMUNICATIONS
    00-90-DC   # TECO INFORMATION SYSTEMS
    00-90-DD   # MIHARU COMMUNICATIONS Inc
    00-90-DE   # CARDKEY SYSTEMS, INC.
    00-90-DF   # MITSUBISHI CHEMICAL AMERICA, INC.
    00-90-E0   # SYSTRAN CORP.
    00-90-E1   # TELENA S.P.A.
    00-90-E2   # DISTRIBUTED PROCESSING TECHNOLOGY
    00-90-E3   # AVEX ELECTRONICS INC.
    00-90-E4   # NEC AMERICA, INC.
    00-90-E5   # TEKNEMA, INC.
    00-90-E6   # ALi Corporation
    00-90-E7   # HORSCH ELEKTRONIK AG
    00-90-E8   # MOXA TECHNOLOGIES CORP., LTD.
    00-90-E9   # JANZ COMPUTER AG
    00-90-EA   # ALPHA TECHNOLOGIES, INC.
    00-90-EB   # SENTRY TELECOM SYSTEMS
    00-90-EC   # PYRESCOM
    00-90-ED   # CENTRAL SYSTEM RESEARCH CO., LTD.
    00-90-EE   # PERSONAL COMMUNICATIONS TECHNOLOGIES
    00-90-EF   # INTEGRIX, INC.
    00-90-F0   # Harmonic Video Systems Ltd.
    00-90-F1   # DOT HILL SYSTEMS CORPORATION
    00-90-F2   # Cisco Systems, Inc
    00-90-F3   # ASPECT COMMUNICATIONS
    00-90-F4   # LIGHTNING INSTRUMENTATION
    00-90-F5   # CLEVO CO.
    00-90-F6   # ESCALATE NETWORKS, INC.
    00-90-F7   # NBASE COMMUNICATIONS LTD.
    00-90-F8   # MEDIATRIX TELECOM
    00-90-F9   # LEITCH
    00-90-FA   # Emulex Corporation
    00-90-FB   # PORTWELL, INC.
    00-90-FC   # NETWORK COMPUTING DEVICES
    00-90-FD   # CopperCom, Inc.
    00-90-FE   # ELECOM CO., LTD.  (LANEED DIV.)
    00-90-FF   # TELLUS TECHNOLOGY INC.
    00-91-D6   # Crystal Group, Inc.
    00-91-FA   # Synapse Product Development
    00-92-FA   # SHENZHEN WISKY TECHNOLOGY CO.,LTD
    00-93-63   # Uni-Link Technology Co., Ltd.
    00-95-69   # LSD Science and Technology Co.,Ltd.
    00-97-FF   # Heimann Sensor GmbH
    00-9A-CD   # HUAWEI TECHNOLOGIES CO.,LTD
    00-9C-02   # Hewlett Packard
    00-9D-8E   # CARDIAC RECORDERS, INC.
    00-9E-C8   # Xiaomi Communications Co Ltd
    00-A0-00   # CENTILLION NETWORKS, INC.
    00-A0-01   # DRS Signal Solutions
    00-A0-02   # LEEDS & NORTHRUP AUSTRALIA PTY LTD
    00-A0-03   # Siemens Switzerland Ltd., I B T HVP
    00-A0-04   # NETPOWER, INC.
    00-A0-05   # DANIEL INSTRUMENTS, LTD.
    00-A0-06   # IMAGE DATA PROCESSING SYSTEM GROUP
    00-A0-07   # APEXX TECHNOLOGY, INC.
    00-A0-08   # NETCORP
    00-A0-09   # WHITETREE NETWORK
    00-A0-0A   # Airspan
    00-A0-0B   # COMPUTEX CO., LTD.
    00-A0-0C   # KINGMAX TECHNOLOGY, INC.
    00-A0-0D   # THE PANDA PROJECT
    00-A0-0E   # VISUAL NETWORKS, INC.
    00-A0-0F   # Broadband Technologies
    00-A0-10   # SYSLOGIC DATENTECHNIK AG
    00-A0-11   # MUTOH INDUSTRIES LTD.
    00-A0-12   # Telco Systems, Inc.
    00-A0-13   # TELTREND LTD.
    00-A0-14   # CSIR
    00-A0-15   # WYLE
    00-A0-16   # MICROPOLIS CORP.
    00-A0-17   # J B M CORPORATION
    00-A0-18   # CREATIVE CONTROLLERS, INC.
    00-A0-19   # NEBULA CONSULTANTS, INC.
    00-A0-1A   # BINAR ELEKTRONIK AB
    00-A0-1B   # PREMISYS COMMUNICATIONS, INC.
    00-A0-1C   # NASCENT NETWORKS CORPORATION
    00-A0-1D   # Red Lion Controls, LP
    00-A0-1E   # EST CORPORATION
    00-A0-1F   # TRICORD SYSTEMS, INC.
    00-A0-20   # CITICORP/TTI
    00-A0-21   # General Dynamics
    00-A0-22   # CENTRE FOR DEVELOPMENT OF ADVANCED COMPUTING
    00-A0-23   # APPLIED CREATIVE TECHNOLOGY, INC.
    00-A0-24   # 3COM CORPORATION
    00-A0-25   # REDCOM LABS INC.
    00-A0-26   # TELDAT, S.A.
    00-A0-27   # FIREPOWER SYSTEMS, INC.
    00-A0-28   # CONNER PERIPHERALS
    00-A0-29   # COULTER CORPORATION
    00-A0-2A   # TRANCELL SYSTEMS
    00-A0-2B   # TRANSITIONS RESEARCH CORP.
    00-A0-2C   # interWAVE Communications
    00-A0-2D   # 1394 Trade Association
    00-A0-2E   # BRAND COMMUNICATIONS, LTD.
    00-A0-2F   # ADB Broadband Italia
    00-A0-30   # CAPTOR NV/SA
    00-A0-31   # HAZELTINE CORPORATION, MS 1-17
    00-A0-32   # GES SINGAPORE PTE. LTD.
    00-A0-33   # imc MeBsysteme GmbH
    00-A0-34   # AXEL
    00-A0-35   # CYLINK CORPORATION
    00-A0-36   # APPLIED NETWORK TECHNOLOGY
    00-A0-37   # Mindray DS USA, Inc.
    00-A0-38   # EMAIL ELECTRONICS
    00-A0-39   # ROSS TECHNOLOGY, INC.
    00-A0-3A   # KUBOTEK CORPORATION
    00-A0-3B   # TOSHIN ELECTRIC CO., LTD.
    00-A0-3C   # EG&G NUCLEAR INSTRUMENTS
    00-A0-3D   # OPTO-22
    00-A0-3E   # ATM FORUM
    00-A0-3F   # COMPUTER SOCIETY MICROPROCESSOR & MICROPROCESSOR STANDARDS C
    00-A0-40   # Apple, Inc.
    00-A0-41   # INFICON
    00-A0-42   # SPUR PRODUCTS CORP.
    00-A0-43   # AMERICAN TECHNOLOGY LABS, INC.
    00-A0-44   # NTT IT CO., LTD.
    00-A0-45   # PHOENIX CONTACT GMBH & CO.
    00-A0-46   # SCITEX CORP. LTD.
    00-A0-47   # INTEGRATED FITNESS CORP.
    00-A0-48   # QUESTECH, LTD.
    00-A0-49   # DIGITECH INDUSTRIES, INC.
    00-A0-4A   # NISSHIN ELECTRIC CO., LTD.
    00-A0-4B   # TFL LAN INC.
    00-A0-4C   # INNOVATIVE SYSTEMS & TECHNOLOGIES, INC.
    00-A0-4D   # EDA INSTRUMENTS, INC.
    00-A0-4E   # VOELKER TECHNOLOGIES, INC.
    00-A0-4F   # AMERITEC CORP.
    00-A0-50   # CYPRESS SEMICONDUCTOR
    00-A0-51   # ANGIA COMMUNICATIONS. INC.
    00-A0-52   # STANILITE ELECTRONICS PTY. LTD
    00-A0-53   # COMPACT DEVICES, INC.
    00-A0-54   # Private
    00-A0-55   # Data Device Corporation
    00-A0-56   # MICROPROSS
    00-A0-57   # LANCOM Systems GmbH
    00-A0-58   # GLORY, LTD.
    00-A0-59   # HAMILTON HALLMARK
    00-A0-5A   # KOFAX IMAGE PRODUCTS
    00-A0-5B   # MARQUIP, INC.
    00-A0-5C   # INVENTORY CONVERSION, INC./
    00-A0-5D   # CS COMPUTER SYSTEME GmbH
    00-A0-5E   # MYRIAD LOGIC INC.
    00-A0-5F   # BTG Electronics Design BV
    00-A0-60   # ACER PERIPHERALS, INC.
    00-A0-61   # PURITAN BENNETT
    00-A0-62   # AES PRODATA
    00-A0-63   # JRL SYSTEMS, INC.
    00-A0-64   # KVB/ANALECT
    00-A0-65   # Symantec Corporation
    00-A0-66   # ISA CO., LTD.
    00-A0-67   # NETWORK SERVICES GROUP
    00-A0-68   # BHP LIMITED
    00-A0-69   # Symmetricom, Inc.
    00-A0-6A   # Verilink Corporation
    00-A0-6B   # DMS DORSCH MIKROSYSTEM GMBH
    00-A0-6C   # SHINDENGEN ELECTRIC MFG. CO., LTD.
    00-A0-6D   # MANNESMANN TALLY CORPORATION
    00-A0-6E   # AUSTRON, INC.
    00-A0-6F   # THE APPCON GROUP, INC.
    00-A0-70   # COASTCOM
    00-A0-71   # VIDEO LOTTERY TECHNOLOGIES,INC
    00-A0-72   # OVATION SYSTEMS LTD.
    00-A0-73   # COM21, INC.
    00-A0-74   # PERCEPTION TECHNOLOGY
    00-A0-75   # MICRON TECHNOLOGY, INC.
    00-A0-76   # CARDWARE LAB, INC.
    00-A0-77   # FUJITSU NEXION, INC.
    00-A0-78   # Marconi Communications
    00-A0-79   # ALPS ELECTRIC (USA), INC.
    00-A0-7A   # ADVANCED PERIPHERALS TECHNOLOGIES, INC.
    00-A0-7B   # DAWN COMPUTER INCORPORATION
    00-A0-7C   # TONYANG NYLON CO., LTD.
    00-A0-7D   # SEEQ TECHNOLOGY, INC.
    00-A0-7E   # AVID TECHNOLOGY, INC.
    00-A0-7F   # GSM-SYNTEL, LTD.
    00-A0-80   # Tattile SRL
    00-A0-81   # ALCATEL DATA NETWORKS
    00-A0-82   # NKT ELEKTRONIK A/S
    00-A0-83   # ASIMMPHONY TURKEY
    00-A0-84   # Dataplex Pty Ltd
    00-A0-85   # Private
    00-A0-86   # AMBER WAVE SYSTEMS, INC.
    00-A0-87   # Microsemi Corporation
    00-A0-88   # ESSENTIAL COMMUNICATIONS
    00-A0-89   # XPOINT TECHNOLOGIES, INC.
    00-A0-8A   # BROOKTROUT TECHNOLOGY, INC.
    00-A0-8B   # ASTON ELECTRONIC DESIGNS LTD.
    00-A0-8C   # MultiMedia LANs, Inc.
    00-A0-8D   # JACOMO CORPORATION
    00-A0-8E   # Check Point Software Technologies
    00-A0-8F   # DESKNET SYSTEMS, INC.
    00-A0-90   # TimeStep Corporation
    00-A0-91   # APPLICOM INTERNATIONAL
    00-A0-92   # H. BOLLMANN MANUFACTURERS, LTD
    00-A0-93   # B/E AEROSPACE, Inc.
    00-A0-94   # COMSAT CORPORATION
    00-A0-95   # ACACIA NETWORKS, INC.
    00-A0-96   # MITSUMI ELECTRIC CO., LTD.
    00-A0-97   # JC INFORMATION SYSTEMS
    00-A0-98   # NetApp
    00-A0-99   # K-NET LTD.
    00-A0-9A   # NIHON KOHDEN AMERICA
    00-A0-9B   # QPSX COMMUNICATIONS, LTD.
    00-A0-9C   # Xyplex, Inc.
    00-A0-9D   # JOHNATHON FREEMAN TECHNOLOGIES
    00-A0-9E   # ICTV
    00-A0-9F   # COMMVISION CORP.
    00-A0-A0   # COMPACT DATA, LTD.
    00-A0-A1   # EPIC DATA INC.
    00-A0-A2   # DIGICOM S.P.A.
    00-A0-A3   # RELIABLE POWER METERS
    00-A0-A4   # MICROS SYSTEMS, INC.
    00-A0-A5   # TEKNOR MICROSYSTEME, INC.
    00-A0-A6   # M.I. SYSTEMS, K.K.
    00-A0-A7   # VORAX CORPORATION
    00-A0-A8   # RENEX CORPORATION
    00-A0-A9   # NAVTEL COMMUNICATIONS INC.
    00-A0-AA   # SPACELABS MEDICAL
    00-A0-AB   # NETCS INFORMATIONSTECHNIK GMBH
    00-A0-AC   # GILAT SATELLITE NETWORKS, LTD.
    00-A0-AD   # MARCONI SPA
    00-A0-AE   # NUCOM SYSTEMS, INC.
    00-A0-AF   # WMS INDUSTRIES
    00-A0-B0   # I-O DATA DEVICE, INC.
    00-A0-B1   # FIRST VIRTUAL CORPORATION
    00-A0-B2   # SHIMA SEIKI
    00-A0-B3   # ZYKRONIX
    00-A0-B4   # TEXAS MICROSYSTEMS, INC.
    00-A0-B5   # 3H TECHNOLOGY
    00-A0-B6   # SANRITZ AUTOMATION CO., LTD.
    00-A0-B7   # CORDANT, INC.
    00-A0-B8   # SYMBIOS LOGIC INC.
    00-A0-B9   # EAGLE TECHNOLOGY, INC.
    00-A0-BA   # PATTON ELECTRONICS CO.
    00-A0-BB   # HILAN GMBH
    00-A0-BC   # VIASAT, INCORPORATED
    00-A0-BD   # I-TECH CORP.
    00-A0-BE   # INTEGRATED CIRCUIT SYSTEMS, INC. COMMUNICATIONS GROUP
    00-A0-BF   # WIRELESS DATA GROUP MOTOROLA
    00-A0-C0   # DIGITAL LINK CORP.
    00-A0-C1   # ORTIVUS MEDICAL AB
    00-A0-C2   # R.A. SYSTEMS CO., LTD.
    00-A0-C3   # UNICOMPUTER GMBH
    00-A0-C4   # CRISTIE ELECTRONICS LTD.
    00-A0-C5   # ZyXEL Communications Corporation
    00-A0-C6   # QUALCOMM INCORPORATED
    00-A0-C7   # TADIRAN TELECOMMUNICATIONS
    00-A0-C8   # ADTRAN INC.
    00-A0-C9   # Intel Corporation
    00-A0-CA   # FUJITSU DENSO LTD.
    00-A0-CB   # ARK TELECOMMUNICATIONS, INC.
    00-A0-CC   # LITE-ON COMMUNICATIONS, INC.
    00-A0-CD   # DR. JOHANNES HEIDENHAIN GmbH
    00-A0-CE   # Ecessa
    00-A0-CF   # SOTAS, INC.
    00-A0-D0   # TEN X TECHNOLOGY, INC.
    00-A0-D1   # INVENTEC CORPORATION
    00-A0-D2   # ALLIED TELESIS INTERNATIONAL CORPORATION
    00-A0-D3   # INSTEM COMPUTER SYSTEMS, LTD.
    00-A0-D4   # RADIOLAN,  INC.
    00-A0-D5   # SIERRA WIRELESS INC.
    00-A0-D6   # SBE, Inc.
    00-A0-D7   # KASTEN CHASE APPLIED RESEARCH
    00-A0-D8   # SPECTRA - TEK
    00-A0-D9   # CONVEX COMPUTER CORPORATION
    00-A0-DA   # INTEGRATED SYSTEMS Technology, Inc.
    00-A0-DB   # FISHER & PAYKEL PRODUCTION
    00-A0-DC   # O.N. ELECTRONIC CO., LTD.
    00-A0-DD   # AZONIX CORPORATION
    00-A0-DE   # YAMAHA CORPORATION
    00-A0-DF   # STS TECHNOLOGIES, INC.
    00-A0-E0   # TENNYSON TECHNOLOGIES PTY LTD
    00-A0-E1   # WESTPORT RESEARCH ASSOCIATES, INC.
    00-A0-E2   # Keisokugiken Corporation
    00-A0-E3   # XKL SYSTEMS CORP.
    00-A0-E4   # OPTIQUEST
    00-A0-E5   # NHC COMMUNICATIONS
    00-A0-E6   # DIALOGIC CORPORATION
    00-A0-E7   # CENTRAL DATA CORPORATION
    00-A0-E8   # REUTERS HOLDINGS PLC
    00-A0-E9   # ELECTRONIC RETAILING SYSTEMS INTERNATIONAL
    00-A0-EA   # ETHERCOM CORP.
    00-A0-EB   # Encore Networks, Inc.
    00-A0-EC   # TRANSMITTON LTD.
    00-A0-ED   # Brooks Automation, Inc.
    00-A0-EE   # NASHOBA NETWORKS
    00-A0-EF   # LUCIDATA LTD.
    00-A0-F0   # TORONTO MICROELECTRONICS INC.
    00-A0-F1   # MTI
    00-A0-F2   # INFOTEK COMMUNICATIONS, INC.
    00-A0-F3   # STAUBLI
    00-A0-F4   # GE
    00-A0-F5   # RADGUARD LTD.
    00-A0-F6   # AutoGas Systems Inc.
    00-A0-F7   # V.I COMPUTER CORP.
    00-A0-F8   # Zebra Technologies Inc
    00-A0-F9   # BINTEC COMMUNICATIONS GMBH
    00-A0-FA   # Marconi Communication GmbH
    00-A0-FB   # TORAY ENGINEERING CO., LTD.
    00-A0-FC   # IMAGE SCIENCES, INC.
    00-A0-FD   # SCITEX DIGITAL PRINTING, INC.
    00-A0-FE   # BOSTON TECHNOLOGY, INC.
    00-A0-FF   # TELLABS OPERATIONS, INC.
    00-A1-DE   # ShenZhen ShiHua Technology CO.,LTD
    00-A2-DA   # INAT GmbH
    00-A2-F5   # Guangzhou Yuanyun Network Technology Co.,Ltd
    00-A2-FF   # abatec group AG
    00-A5-09   # WigWag Inc.
    00-A7-84   # ITX security
    00-AA-00   # Intel Corporation
    00-AA-01   # Intel Corporation
    00-AA-02   # Intel Corporation
    00-AA-3C   # OLIVETTI TELECOM SPA (OLTECO)
    00-AA-70   # LG Electronics
    00-AC-E0   # ARRIS Group, Inc.
    00-AE-FA   # Murata Manufacturing Co., Ltd.
    00-AF-1F   # Cisco Systems, Inc
    00-B0-09   # Grass Valley, A Belden Brand
    00-B0-17   # InfoGear Technology Corp.
    00-B0-19   # UTC CCS
    00-B0-1C   # Westport Technologies
    00-B0-1E   # Rantic Labs, Inc.
    00-B0-2A   # ORSYS GmbH
    00-B0-2D   # ViaGate Technologies, Inc.
    00-B0-33   # OAO Izhevskiy radiozavod
    00-B0-3B   # HiQ Networks
    00-B0-48   # Marconi Communications Inc.
    00-B0-4A   # Cisco Systems, Inc
    00-B0-52   # Atheros Communications
    00-B0-64   # Cisco Systems, Inc
    00-B0-69   # Honewell Oy
    00-B0-6D   # Jones Futurex Inc.
    00-B0-80   # Mannesmann Ipulsys B.V.
    00-B0-86   # LocSoft Limited
    00-B0-8E   # Cisco Systems, Inc
    00-B0-91   # Transmeta Corp.
    00-B0-94   # Alaris, Inc.
    00-B0-9A   # Morrow Technologies Corp.
    00-B0-9D   # Point Grey Research Inc.
    00-B0-AC   # SIAE-Microelettronica S.p.A.
    00-B0-AE   # Symmetricom
    00-B0-B3   # Xstreamis PLC
    00-B0-C2   # Cisco Systems, Inc
    00-B0-C7   # Tellabs Operations, Inc.
    00-B0-CE   # TECHNOLOGY RESCUE
    00-B0-D0   # Dell Inc.
    00-B0-DB   # Nextcell, Inc.
    00-B0-DF   # Starboard Storage Systems
    00-B0-E7   # British Federal Ltd.
    00-B0-EC   # EACEM
    00-B0-EE   # Ajile Systems, Inc.
    00-B0-F0   # CALY NETWORKS
    00-B0-F5   # NetWorth Technologies, Inc.
    00-B3-38   # Kontron Design Manufacturing Services (M) Sdn. Bhd
    00-B3-42   # MacroSAN Technologies Co., Ltd.
    00-B5-6D   # David Electronics Co., LTD.
    00-B5-D6   # Omnibit Inc.
    00-B7-8D   # Nanjing Shining Electric Automation Co., Ltd
    00-B9-F6   # Shenzhen Super Rich Electronics Co.,Ltd
    00-BA-C0   # Biometric Access Company
    00-BB-01   # OCTOTHORPE CORP.
    00-BB-3A   # Private
    00-BB-8E   # HME Co., Ltd.
    00-BB-F0   # UNGERMANN-BASS INC.
    00-BD-27   # Exar Corp.
    00-BD-3A   # Nokia Corporation
    00-BF-15   # Genetec Inc.
    00-C0-00   # LANOPTICS, LTD.
    00-C0-01   # DIATEK PATIENT MANAGMENT
    00-C0-02   # SERCOMM CORPORATION
    00-C0-03   # GLOBALNET COMMUNICATIONS
    00-C0-04   # JAPAN BUSINESS COMPUTER CO.LTD
    00-C0-05   # LIVINGSTON ENTERPRISES, INC.
    00-C0-06   # NIPPON AVIONICS CO., LTD.
    00-C0-07   # PINNACLE DATA SYSTEMS, INC.
    00-C0-08   # SECO SRL
    00-C0-09   # KT TECHNOLOGY (S) PTE LTD
    00-C0-0A   # MICRO CRAFT
    00-C0-0B   # NORCONTROL A.S.
    00-C0-0C   # RELIA TECHNOLGIES
    00-C0-0D   # ADVANCED LOGIC RESEARCH, INC.
    00-C0-0E   # PSITECH, INC.
    00-C0-0F   # QUANTUM SOFTWARE SYSTEMS LTD.
    00-C0-10   # HIRAKAWA HEWTECH CORP.
    00-C0-11   # INTERACTIVE COMPUTING DEVICES
    00-C0-12   # NETSPAN CORPORATION
    00-C0-13   # NETRIX
    00-C0-14   # TELEMATICS CALABASAS INT'L,INC
    00-C0-15   # NEW MEDIA CORPORATION
    00-C0-16   # ELECTRONIC THEATRE CONTROLS
    00-C0-17   # Fluke Corporation
    00-C0-18   # LANART CORPORATION
    00-C0-19   # LEAP TECHNOLOGY, INC.
    00-C0-1A   # COROMETRICS MEDICAL SYSTEMS
    00-C0-1B   # SOCKET COMMUNICATIONS, INC.
    00-C0-1C   # INTERLINK COMMUNICATIONS LTD.
    00-C0-1D   # GRAND JUNCTION NETWORKS, INC.
    00-C0-1E   # LA FRANCAISE DES JEUX
    00-C0-1F   # S.E.R.C.E.L.
    00-C0-20   # ARCO ELECTRONIC, CONTROL LTD.
    00-C0-21   # NETEXPRESS
    00-C0-22   # LASERMASTER TECHNOLOGIES, INC.
    00-C0-23   # TUTANKHAMON ELECTRONICS
    00-C0-24   # EDEN SISTEMAS DE COMPUTACAO SA
    00-C0-25   # DATAPRODUCTS CORPORATION
    00-C0-26   # LANS TECHNOLOGY CO., LTD.
    00-C0-27   # CIPHER SYSTEMS, INC.
    00-C0-28   # JASCO CORPORATION
    00-C0-29   # Nexans Deutschland GmbH - ANS
    00-C0-2A   # OHKURA ELECTRIC CO., LTD.
    00-C0-2B   # GERLOFF GESELLSCHAFT FUR
    00-C0-2C   # CENTRUM COMMUNICATIONS, INC.
    00-C0-2D   # FUJI PHOTO FILM CO., LTD.
    00-C0-2E   # NETWIZ
    00-C0-2F   # OKUMA CORPORATION
    00-C0-30   # INTEGRATED ENGINEERING B. V.
    00-C0-31   # DESIGN RESEARCH SYSTEMS, INC.
    00-C0-32   # I-CUBED LIMITED
    00-C0-33   # TELEBIT COMMUNICATIONS APS
    00-C0-34   # TRANSACTION NETWORK
    00-C0-35   # QUINTAR COMPANY
    00-C0-36   # RAYTECH ELECTRONIC CORP.
    00-C0-37   # DYNATEM
    00-C0-38   # RASTER IMAGE PROCESSING SYSTEM
    00-C0-39   # Teridian Semiconductor Corporation
    00-C0-3A   # MEN-MIKRO ELEKTRONIK GMBH
    00-C0-3B   # MULTIACCESS COMPUTING CORP.
    00-C0-3C   # TOWER TECH S.R.L.
    00-C0-3D   # WIESEMANN & THEIS GMBH
    00-C0-3E   # FA. GEBR. HELLER GMBH
    00-C0-3F   # STORES AUTOMATED SYSTEMS, INC.
    00-C0-40   # ECCI
    00-C0-41   # DIGITAL TRANSMISSION SYSTEMS
    00-C0-42   # DATALUX CORP.
    00-C0-43   # STRATACOM
    00-C0-44   # EMCOM CORPORATION
    00-C0-45   # ISOLATION SYSTEMS, LTD.
    00-C0-46   # Blue Chip Technology Ltd
    00-C0-47   # UNIMICRO SYSTEMS, INC.
    00-C0-48   # BAY TECHNICAL ASSOCIATES
    00-C0-49   # U.S. ROBOTICS, INC.
    00-C0-4A   # GROUP 2000 AG
    00-C0-4B   # CREATIVE MICROSYSTEMS
    00-C0-4C   # DEPARTMENT OF FOREIGN AFFAIRS
    00-C0-4D   # MITEC, INC.
    00-C0-4E   # COMTROL CORPORATION
    00-C0-4F   # Dell Inc.
    00-C0-50   # TOYO DENKI SEIZO K.K.
    00-C0-51   # ADVANCED INTEGRATION RESEARCH
    00-C0-52   # BURR-BROWN
    00-C0-53   # Aspect Software Inc.
    00-C0-54   # NETWORK PERIPHERALS, LTD.
    00-C0-55   # MODULAR COMPUTING TECHNOLOGIES
    00-C0-56   # SOMELEC
    00-C0-57   # MYCO ELECTRONICS
    00-C0-58   # DATAEXPERT CORP.
    00-C0-59   # DENSO CORPORATION
    00-C0-5A   # SEMAPHORE COMMUNICATIONS CORP.
    00-C0-5B   # NETWORKS NORTHWEST, INC.
    00-C0-5C   # ELONEX PLC
    00-C0-5D   # L&N TECHNOLOGIES
    00-C0-5E   # VARI-LITE, INC.
    00-C0-5F   # FINE-PAL COMPANY LIMITED
    00-C0-60   # ID SCANDINAVIA AS
    00-C0-61   # SOLECTEK CORPORATION
    00-C0-62   # IMPULSE TECHNOLOGY
    00-C0-63   # MORNING STAR TECHNOLOGIES, INC
    00-C0-64   # GENERAL DATACOMM IND. INC.
    00-C0-65   # SCOPE COMMUNICATIONS, INC.
    00-C0-66   # DOCUPOINT, INC.
    00-C0-67   # UNITED BARCODE INDUSTRIES
    00-C0-68   # HME Clear-Com LTD.
    00-C0-69   # Axxcelera Broadband Wireless
    00-C0-6A   # ZAHNER-ELEKTRIK GMBH & CO. KG
    00-C0-6B   # OSI PLUS CORPORATION
    00-C0-6C   # SVEC COMPUTER CORP.
    00-C0-6D   # BOCA RESEARCH, INC.
    00-C0-6E   # HAFT TECHNOLOGY, INC.
    00-C0-6F   # KOMATSU LTD.
    00-C0-70   # SECTRA SECURE-TRANSMISSION AB
    00-C0-71   # AREANEX COMMUNICATIONS, INC.
    00-C0-72   # KNX LTD.
    00-C0-73   # XEDIA CORPORATION
    00-C0-74   # TOYODA AUTOMATIC LOOM
    00-C0-75   # XANTE CORPORATION
    00-C0-76   # I-DATA INTERNATIONAL A-S
    00-C0-77   # DAEWOO TELECOM LTD.
    00-C0-78   # COMPUTER SYSTEMS ENGINEERING
    00-C0-79   # FONSYS CO.,LTD.
    00-C0-7A   # PRIVA B.V.
    00-C0-7B   # ASCEND COMMUNICATIONS, INC.
    00-C0-7C   # HIGHTECH INFORMATION
    00-C0-7D   # RISC DEVELOPMENTS LTD.
    00-C0-7E   # KUBOTA CORPORATION ELECTRONIC
    00-C0-7F   # NUPON COMPUTING CORP.
    00-C0-80   # NETSTAR, INC.
    00-C0-81   # METRODATA LTD.
    00-C0-82   # MOORE PRODUCTS CO.
    00-C0-83   # TRACE MOUNTAIN PRODUCTS, INC.
    00-C0-84   # DATA LINK CORP. LTD.
    00-C0-85   # ELECTRONICS FOR IMAGING, INC.
    00-C0-86   # THE LYNK CORPORATION
    00-C0-87   # UUNET TECHNOLOGIES, INC.
    00-C0-88   # EKF ELEKTRONIK GMBH
    00-C0-89   # TELINDUS DISTRIBUTION
    00-C0-8A   # Lauterbach GmbH
    00-C0-8B   # RISQ MODULAR SYSTEMS, INC.
    00-C0-8C   # PERFORMANCE TECHNOLOGIES, INC.
    00-C0-8D   # TRONIX PRODUCT DEVELOPMENT
    00-C0-8E   # NETWORK INFORMATION TECHNOLOGY
    00-C0-8F   # Panasonic Electric Works Co., Ltd.
    00-C0-90   # PRAIM S.R.L.
    00-C0-91   # JABIL CIRCUIT, INC.
    00-C0-92   # MENNEN MEDICAL INC.
    00-C0-93   # ALTA RESEARCH CORP.
    00-C0-94   # VMX INC.
    00-C0-95   # ZNYX
    00-C0-96   # TAMURA CORPORATION
    00-C0-97   # ARCHIPEL SA
    00-C0-98   # CHUNTEX ELECTRONIC CO., LTD.
    00-C0-99   # YOSHIKI INDUSTRIAL CO.,LTD.
    00-C0-9A   # PHOTONICS CORPORATION
    00-C0-9B   # RELIANCE COMM/TEC, R-TEC
    00-C0-9C   # HIOKI E.E. CORPORATION
    00-C0-9D   # DISTRIBUTED SYSTEMS INT'L, INC
    00-C0-9E   # CACHE COMPUTERS, INC.
    00-C0-9F   # QUANTA COMPUTER, INC.
    00-C0-A0   # ADVANCE MICRO RESEARCH, INC.
    00-C0-A1   # TOKYO DENSHI SEKEI CO.
    00-C0-A2   # INTERMEDIUM A/S
    00-C0-A3   # DUAL ENTERPRISES CORPORATION
    00-C0-A4   # UNIGRAF OY
    00-C0-A5   # DICKENS DATA SYSTEMS
    00-C0-A6   # EXICOM AUSTRALIA PTY. LTD
    00-C0-A7   # SEEL LTD.
    00-C0-A8   # GVC CORPORATION
    00-C0-A9   # BARRON MCCANN LTD.
    00-C0-AA   # SILICON VALLEY COMPUTER
    00-C0-AB   # Telco Systems, Inc.
    00-C0-AC   # GAMBIT COMPUTER COMMUNICATIONS
    00-C0-AD   # MARBEN COMMUNICATION SYSTEMS
    00-C0-AE   # TOWERCOM CO. INC. DBA PC HOUSE
    00-C0-AF   # TEKLOGIX INC.
    00-C0-B0   # GCC TECHNOLOGIES,INC.
    00-C0-B1   # GENIUS NET CO.
    00-C0-B2   # NORAND CORPORATION
    00-C0-B3   # COMSTAT DATACOMM CORPORATION
    00-C0-B4   # MYSON TECHNOLOGY, INC.
    00-C0-B5   # CORPORATE NETWORK SYSTEMS,INC.
    00-C0-B6   # Overland Storage, Inc.
    00-C0-B7   # AMERICAN POWER CONVERSION CORP
    00-C0-B8   # FRASER'S HILL LTD.
    00-C0-B9   # FUNK SOFTWARE, INC.
    00-C0-BA   # NETVANTAGE
    00-C0-BB   # FORVAL CREATIVE, INC.
    00-C0-BC   # TELECOM AUSTRALIA/CSSC
    00-C0-BD   # INEX TECHNOLOGIES, INC.
    00-C0-BE   # ALCATEL - SEL
    00-C0-BF   # TECHNOLOGY CONCEPTS, LTD.
    00-C0-C0   # SHORE MICROSYSTEMS, INC.
    00-C0-C1   # QUAD/GRAPHICS, INC.
    00-C0-C2   # INFINITE NETWORKS LTD.
    00-C0-C3   # ACUSON COMPUTED SONOGRAPHY
    00-C0-C4   # COMPUTER OPERATIONAL
    00-C0-C5   # SID INFORMATICA
    00-C0-C6   # PERSONAL MEDIA CORP.
    00-C0-C7   # SPARKTRUM MICROSYSTEMS, INC.
    00-C0-C8   # MICRO BYTE PTY. LTD.
    00-C0-C9   # ELSAG BAILEY PROCESS
    00-C0-CA   # ALFA, INC.
    00-C0-CB   # CONTROL TECHNOLOGY CORPORATION
    00-C0-CC   # TELESCIENCES CO SYSTEMS, INC.
    00-C0-CD   # COMELTA, S.A.
    00-C0-CE   # CEI SYSTEMS & ENGINEERING PTE
    00-C0-CF   # IMATRAN VOIMA OY
    00-C0-D0   # RATOC SYSTEM INC.
    00-C0-D1   # COMTREE TECHNOLOGY CORPORATION
    00-C0-D2   # SYNTELLECT, INC.
    00-C0-D3   # OLYMPUS IMAGE SYSTEMS, INC.
    00-C0-D4   # AXON NETWORKS, INC.
    00-C0-D5   # Werbeagentur Jürgen Siebert
    00-C0-D6   # J1 SYSTEMS, INC.
    00-C0-D7   # TAIWAN TRADING CENTER DBA
    00-C0-D8   # UNIVERSAL DATA SYSTEMS
    00-C0-D9   # QUINTE NETWORK CONFIDENTIALITY
    00-C0-DA   # NICE SYSTEMS LTD.
    00-C0-DB   # IPC CORPORATION (PTE) LTD.
    00-C0-DC   # EOS TECHNOLOGIES, INC.
    00-C0-DD   # QLogic Corporation
    00-C0-DE   # ZCOMM, INC.
    00-C0-DF   # KYE Systems Corp.
    00-C0-E0   # DSC COMMUNICATION CORP.
    00-C0-E1   # SONIC SOLUTIONS
    00-C0-E2   # CALCOMP, INC.
    00-C0-E3   # OSITECH COMMUNICATIONS, INC.
    00-C0-E4   # SIEMENS BUILDING
    00-C0-E5   # GESPAC, S.A.
    00-C0-E6   # Verilink Corporation
    00-C0-E7   # FIBERDATA AB
    00-C0-E8   # PLEXCOM, INC.
    00-C0-E9   # OAK SOLUTIONS, LTD.
    00-C0-EA   # ARRAY TECHNOLOGY LTD.
    00-C0-EB   # SEH COMPUTERTECHNIK GMBH
    00-C0-EC   # DAUPHIN TECHNOLOGY
    00-C0-ED   # US ARMY ELECTRONIC
    00-C0-EE   # KYOCERA CORPORATION
    00-C0-EF   # ABIT CORPORATION
    00-C0-F0   # KINGSTON TECHNOLOGY CORP.
    00-C0-F1   # SHINKO ELECTRIC CO., LTD.
    00-C0-F2   # TRANSITION NETWORKS
    00-C0-F3   # NETWORK COMMUNICATIONS CORP.
    00-C0-F4   # INTERLINK SYSTEM CO., LTD.
    00-C0-F5   # METACOMP, INC.
    00-C0-F6   # CELAN TECHNOLOGY INC.
    00-C0-F7   # ENGAGE COMMUNICATION, INC.
    00-C0-F8   # ABOUT COMPUTING INC.
    00-C0-F9   # Artesyn Embedded Technologies
    00-C0-FA   # CANARY COMMUNICATIONS, INC.
    00-C0-FB   # ADVANCED TECHNOLOGY LABS
    00-C0-FC   # ELASTIC REALITY, INC.
    00-C0-FD   # PROSUM
    00-C0-FE   # APTEC COMPUTER SYSTEMS, INC.
    00-C0-FF   # DOT HILL SYSTEMS CORPORATION
    00-C1-4F   # DDL Co,.ltd.
    00-C2-C6   # Intel Corporate
    00-C5-DB   # Datatech Sistemas Digitales Avanzados SL
    00-C6-10   # Apple, Inc.
    00-CB-00   # Private
    00-CB-BD   # Cambridge Broadband Networks Ltd.
    00-CD-90   # MAS Elektronik AG
    00-CD-FE   # Apple, Inc.
    00-CF-1C   # Communication Machinery Corporation
    00-D0-00   # FERRAN SCIENTIFIC, INC.
    00-D0-01   # VST TECHNOLOGIES, INC.
    00-D0-02   # DITECH CORPORATION
    00-D0-03   # COMDA ENTERPRISES CORP.
    00-D0-04   # PENTACOM LTD.
    00-D0-05   # ZHS ZEITMANAGEMENTSYSTEME
    00-D0-06   # Cisco Systems, Inc
    00-D0-07   # MIC ASSOCIATES, INC.
    00-D0-08   # MACTELL CORPORATION
    00-D0-09   # HSING TECH. ENTERPRISE CO. LTD
    00-D0-0A   # LANACCESS TELECOM S.A.
    00-D0-0B   # RHK TECHNOLOGY, INC.
    00-D0-0C   # SNIJDER MICRO SYSTEMS
    00-D0-0D   # MICROMERITICS INSTRUMENT
    00-D0-0E   # PLURIS, INC.
    00-D0-0F   # SPEECH DESIGN GMBH
    00-D0-10   # CONVERGENT NETWORKS, INC.
    00-D0-11   # PRISM VIDEO, INC.
    00-D0-12   # GATEWORKS CORP.
    00-D0-13   # PRIMEX AEROSPACE COMPANY
    00-D0-14   # ROOT, INC.
    00-D0-15   # UNIVEX MICROTECHNOLOGY CORP.
    00-D0-16   # SCM MICROSYSTEMS, INC.
    00-D0-17   # SYNTECH INFORMATION CO., LTD.
    00-D0-18   # QWES. COM, INC.
    00-D0-19   # DAINIPPON SCREEN CORPORATE
    00-D0-1A   # URMET  TLC S.P.A.
    00-D0-1B   # MIMAKI ENGINEERING CO., LTD.
    00-D0-1C   # SBS TECHNOLOGIES,
    00-D0-1D   # FURUNO ELECTRIC CO., LTD.
    00-D0-1E   # PINGTEL CORP.
    00-D0-1F   # Senetas Security
    00-D0-20   # AIM SYSTEM, INC.
    00-D0-21   # REGENT ELECTRONICS CORP.
    00-D0-22   # INCREDIBLE TECHNOLOGIES, INC.
    00-D0-23   # INFORTREND TECHNOLOGY, INC.
    00-D0-24   # Cognex Corporation
    00-D0-25   # XROSSTECH, INC.
    00-D0-26   # HIRSCHMANN AUSTRIA GMBH
    00-D0-27   # APPLIED AUTOMATION, INC.
    00-D0-28   # Harmonic, Inc
    00-D0-29   # WAKEFERN FOOD CORPORATION
    00-D0-2A   # Voxent Systems Ltd.
    00-D0-2B   # JETCELL, INC.
    00-D0-2C   # CAMPBELL SCIENTIFIC, INC.
    00-D0-2D   # ADEMCO
    00-D0-2E   # COMMUNICATION AUTOMATION CORP.
    00-D0-2F   # VLSI TECHNOLOGY INC.
    00-D0-30   # Safetran Systems Corp
    00-D0-31   # INDUSTRIAL LOGIC CORPORATION
    00-D0-32   # YANO ELECTRIC CO., LTD.
    00-D0-33   # DALIAN DAXIAN NETWORK
    00-D0-34   # ORMEC SYSTEMS CORP.
    00-D0-35   # BEHAVIOR TECH. COMPUTER CORP.
    00-D0-36   # TECHNOLOGY ATLANTA CORP.
    00-D0-37   # Pace France
    00-D0-38   # FIVEMERE, LTD.
    00-D0-39   # UTILICOM, INC.
    00-D0-3A   # ZONEWORX, INC.
    00-D0-3B   # VISION PRODUCTS PTY. LTD.
    00-D0-3C   # Vieo, Inc.
    00-D0-3D   # GALILEO TECHNOLOGY, LTD.
    00-D0-3E   # ROCKETCHIPS, INC.
    00-D0-3F   # AMERICAN COMMUNICATION
    00-D0-40   # SYSMATE CO., LTD.
    00-D0-41   # AMIGO TECHNOLOGY CO., LTD.
    00-D0-42   # MAHLO GMBH & CO. UG
    00-D0-43   # ZONAL RETAIL DATA SYSTEMS
    00-D0-44   # ALIDIAN NETWORKS, INC.
    00-D0-45   # KVASER AB
    00-D0-46   # DOLBY LABORATORIES, INC.
    00-D0-47   # XN TECHNOLOGIES
    00-D0-48   # ECTON, INC.
    00-D0-49   # IMPRESSTEK CO., LTD.
    00-D0-4A   # PRESENCE TECHNOLOGY GMBH
    00-D0-4B   # LA CIE GROUP S.A.
    00-D0-4C   # EUROTEL TELECOM LTD.
    00-D0-4D   # DIV OF RESEARCH & STATISTICS
    00-D0-4E   # LOGIBAG
    00-D0-4F   # BITRONICS, INC.
    00-D0-50   # ISKRATEL
    00-D0-51   # O2 MICRO, INC.
    00-D0-52   # ASCEND COMMUNICATIONS, INC.
    00-D0-53   # CONNECTED SYSTEMS
    00-D0-54   # SAS INSTITUTE INC.
    00-D0-55   # KATHREIN-WERKE KG
    00-D0-56   # SOMAT CORPORATION
    00-D0-57   # ULTRAK, INC.
    00-D0-58   # Cisco Systems, Inc
    00-D0-59   # AMBIT MICROSYSTEMS CORP.
    00-D0-5A   # SYMBIONICS, LTD.
    00-D0-5B   # ACROLOOP MOTION CONTROL
    00-D0-5C   # KATHREIN TechnoTrend GmbH
    00-D0-5D   # INTELLIWORXX, INC.
    00-D0-5E   # STRATABEAM TECHNOLOGY, INC.
    00-D0-5F   # VALCOM, INC.
    00-D0-60   # Panasonic Europe Ltd.
    00-D0-61   # TREMON ENTERPRISES CO., LTD.
    00-D0-62   # DIGIGRAM
    00-D0-63   # Cisco Systems, Inc
    00-D0-64   # MULTITEL
    00-D0-65   # TOKO ELECTRIC
    00-D0-66   # WINTRISS ENGINEERING CORP.
    00-D0-67   # CAMPIO COMMUNICATIONS
    00-D0-68   # IWILL CORPORATION
    00-D0-69   # TECHNOLOGIC SYSTEMS
    00-D0-6A   # LINKUP SYSTEMS CORPORATION
    00-D0-6B   # SR TELECOM INC.
    00-D0-6C   # SHAREWAVE, INC.
    00-D0-6D   # ACRISON, INC.
    00-D0-6E   # TRENDVIEW RECORDERS LTD.
    00-D0-6F   # KMC CONTROLS
    00-D0-70   # LONG WELL ELECTRONICS CORP.
    00-D0-71   # ECHELON CORP.
    00-D0-72   # BROADLOGIC
    00-D0-73   # ACN ADVANCED COMMUNICATIONS
    00-D0-74   # TAQUA SYSTEMS, INC.
    00-D0-75   # ALARIS MEDICAL SYSTEMS, INC.
    00-D0-76   # Bank of America
    00-D0-77   # LUCENT TECHNOLOGIES
    00-D0-78   # Eltex of Sweden AB
    00-D0-79   # Cisco Systems, Inc
    00-D0-7A   # AMAQUEST COMPUTER CORP.
    00-D0-7B   # COMCAM INTERNATIONAL INC
    00-D0-7C   # KOYO ELECTRONICS INC. CO.,LTD.
    00-D0-7D   # COSINE COMMUNICATIONS
    00-D0-7E   # KEYCORP LTD.
    00-D0-7F   # STRATEGY & TECHNOLOGY, LIMITED
    00-D0-80   # EXABYTE CORPORATION
    00-D0-81   # RTD Embedded Technologies, Inc.
    00-D0-82   # IOWAVE INC.
    00-D0-83   # INVERTEX, INC.
    00-D0-84   # NEXCOMM SYSTEMS, INC.
    00-D0-85   # OTIS ELEVATOR COMPANY
    00-D0-86   # FOVEON, INC.
    00-D0-87   # MICROFIRST INC.
    00-D0-88   # ARRIS Group, Inc.
    00-D0-89   # DYNACOLOR, INC.
    00-D0-8A   # PHOTRON USA
    00-D0-8B   # ADVA Optical Networking Ltd.
    00-D0-8C   # GENOA TECHNOLOGY, INC.
    00-D0-8D   # PHOENIX GROUP, INC.
    00-D0-8E   # Grass Valley, A Belden Brand
    00-D0-8F   # ARDENT TECHNOLOGIES, INC.
    00-D0-90   # Cisco Systems, Inc
    00-D0-91   # SMARTSAN SYSTEMS, INC.
    00-D0-92   # GLENAYRE WESTERN MULTIPLEX
    00-D0-93   # TQ - COMPONENTS GMBH
    00-D0-94   # Seeion Control LLC
    00-D0-95   # Alcatel-Lucent, Enterprise Business Group
    00-D0-96   # 3COM EUROPE LTD.
    00-D0-97   # Cisco Systems, Inc
    00-D0-98   # Photon Dynamics Canada Inc.
    00-D0-99   # Elcard Wireless Systems Oy
    00-D0-9A   # FILANET CORPORATION
    00-D0-9B   # SPECTEL LTD.
    00-D0-9C   # KAPADIA COMMUNICATIONS
    00-D0-9D   # VERIS INDUSTRIES
    00-D0-9E   # 2Wire Inc
    00-D0-9F   # NOVTEK TEST SYSTEMS
    00-D0-A0   # MIPS DENMARK
    00-D0-A1   # OSKAR VIERLING GMBH + CO. KG
    00-D0-A2   # INTEGRATED DEVICE
    00-D0-A3   # VOCAL DATA, INC.
    00-D0-A4   # ALANTRO COMMUNICATIONS
    00-D0-A5   # AMERICAN ARIUM
    00-D0-A6   # LANBIRD TECHNOLOGY CO., LTD.
    00-D0-A7   # TOKYO SOKKI KENKYUJO CO., LTD.
    00-D0-A8   # NETWORK ENGINES, INC.
    00-D0-A9   # SHINANO KENSHI CO., LTD.
    00-D0-AA   # CHASE COMMUNICATIONS
    00-D0-AB   # DELTAKABEL TELECOM CV
    00-D0-AC   # Commscope, Inc
    00-D0-AD   # TL INDUSTRIES
    00-D0-AE   # ORESIS COMMUNICATIONS, INC.
    00-D0-AF   # CUTLER-HAMMER, INC.
    00-D0-B0   # BITSWITCH LTD.
    00-D0-B1   # OMEGA ELECTRONICS SA
    00-D0-B2   # XIOTECH CORPORATION
    00-D0-B3   # DRS Technologies Canada Ltd
    00-D0-B4   # KATSUJIMA CO., LTD.
    00-D0-B5   # IPricot formerly DotCom
    00-D0-B6   # CRESCENT NETWORKS, INC.
    00-D0-B7   # Intel Corporation
    00-D0-B8   # Iomega Corporation
    00-D0-B9   # MICROTEK INTERNATIONAL, INC.
    00-D0-BA   # Cisco Systems, Inc
    00-D0-BB   # Cisco Systems, Inc
    00-D0-BC   # Cisco Systems, Inc
    00-D0-BD   # Lattice Semiconductor Corp. (LPA)
    00-D0-BE   # EMUTEC INC.
    00-D0-BF   # PIVOTAL TECHNOLOGIES
    00-D0-C0   # Cisco Systems, Inc
    00-D0-C1   # HARMONIC DATA SYSTEMS, LTD.
    00-D0-C2   # BALTHAZAR TECHNOLOGY AB
    00-D0-C3   # VIVID TECHNOLOGY PTE, LTD.
    00-D0-C4   # TERATECH CORPORATION
    00-D0-C5   # COMPUTATIONAL SYSTEMS, INC.
    00-D0-C6   # THOMAS & BETTS CORP.
    00-D0-C7   # PATHWAY, INC.
    00-D0-C8   # Prevas A/S
    00-D0-C9   # ADVANTECH CO., LTD.
    00-D0-CA   # Intrinsyc Software International Inc.
    00-D0-CB   # DASAN CO., LTD.
    00-D0-CC   # TECHNOLOGIES LYRE INC.
    00-D0-CD   # ATAN TECHNOLOGY INC.
    00-D0-CE   # ASYST ELECTRONIC
    00-D0-CF   # MORETON BAY
    00-D0-D0   # ZHONGXING TELECOM LTD.
    00-D0-D1   # Sycamore Networks
    00-D0-D2   # EPILOG CORPORATION
    00-D0-D3   # Cisco Systems, Inc
    00-D0-D4   # V-BITS, INC.
    00-D0-D5   # GRUNDIG AG
    00-D0-D6   # AETHRA TELECOMUNICAZIONI
    00-D0-D7   # B2C2, INC.
    00-D0-D8   # 3Com Corporation
    00-D0-D9   # DEDICATED MICROCOMPUTERS
    00-D0-DA   # TAICOM DATA SYSTEMS CO., LTD.
    00-D0-DB   # MCQUAY INTERNATIONAL
    00-D0-DC   # MODULAR MINING SYSTEMS, INC.
    00-D0-DD   # SUNRISE TELECOM, INC.
    00-D0-DE   # PHILIPS MULTIMEDIA NETWORK
    00-D0-DF   # KUZUMI ELECTRONICS, INC.
    00-D0-E0   # DOOIN ELECTRONICS CO.
    00-D0-E1   # AVIONITEK ISRAEL INC.
    00-D0-E2   # MRT MICRO, INC.
    00-D0-E3   # ELE-CHEM ENGINEERING CO., LTD.
    00-D0-E4   # Cisco Systems, Inc
    00-D0-E5   # SOLIDUM SYSTEMS CORP.
    00-D0-E6   # IBOND INC.
    00-D0-E7   # VCON TELECOMMUNICATION LTD.
    00-D0-E8   # MAC SYSTEM CO., LTD.
    00-D0-E9   # Advantage Century Telecommunication Corp.
    00-D0-EA   # NEXTONE COMMUNICATIONS, INC.
    00-D0-EB   # LIGHTERA NETWORKS, INC.
    00-D0-EC   # NAKAYO TELECOMMUNICATIONS,INC
    00-D0-ED   # XIOX
    00-D0-EE   # DICTAPHONE CORPORATION
    00-D0-EF   # IGT
    00-D0-F0   # CONVISION TECHNOLOGY GMBH
    00-D0-F1   # SEGA ENTERPRISES, LTD.
    00-D0-F2   # MONTEREY NETWORKS
    00-D0-F3   # SOLARI DI UDINE SPA
    00-D0-F4   # CARINTHIAN TECH INSTITUTE
    00-D0-F5   # ORANGE MICRO, INC.
    00-D0-F6   # Alcatel Canada
    00-D0-F7   # NEXT NETS CORPORATION
    00-D0-F8   # FUJIAN STAR TERMINAL
    00-D0-F9   # ACUTE COMMUNICATIONS CORP.
    00-D0-FA   # Thales e-Security Ltd.
    00-D0-FB   # TEK MICROSYSTEMS, INCORPORATED
    00-D0-FC   # GRANITE MICROSYSTEMS
    00-D0-FD   # OPTIMA TELE.COM, INC.
    00-D0-FE   # ASTRAL POINT
    00-D0-FF   # Cisco Systems, Inc
    00-D1-1C   # ACETEL
    00-D3-8D   # Hotel Technology Next Generation
    00-D6-32   # GE Energy
    00-D9-D1   # Sony Computer Entertainment Inc.
    00-DA-55   # Cisco Systems, Inc
    00-DB-1E   # Albedo Telecom SL
    00-DB-45   # THAMWAY CO.,LTD.
    00-DB-DF   # Intel Corporate
    00-DD-00   # UNGERMANN-BASS INC.
    00-DD-01   # UNGERMANN-BASS INC.
    00-DD-02   # UNGERMANN-BASS INC.
    00-DD-03   # UNGERMANN-BASS INC.
    00-DD-04   # UNGERMANN-BASS INC.
    00-DD-05   # UNGERMANN-BASS INC.
    00-DD-06   # UNGERMANN-BASS INC.
    00-DD-07   # UNGERMANN-BASS INC.
    00-DD-08   # UNGERMANN-BASS INC.
    00-DD-09   # UNGERMANN-BASS INC.
    00-DD-0A   # UNGERMANN-BASS INC.
    00-DD-0B   # UNGERMANN-BASS INC.
    00-DD-0C   # UNGERMANN-BASS INC.
    00-DD-0D   # UNGERMANN-BASS INC.
    00-DD-0E   # UNGERMANN-BASS INC.
    00-DD-0F   # UNGERMANN-BASS INC.
    00-DE-FB   # Cisco Systems, Inc
    00-E0-00   # FUJITSU LIMITED
    00-E0-01   # STRAND LIGHTING LIMITED
    00-E0-02   # CROSSROADS SYSTEMS, INC.
    00-E0-03   # NOKIA WIRELESS BUSINESS COMMUN
    00-E0-04   # PMC-SIERRA, INC.
    00-E0-05   # TECHNICAL CORP.
    00-E0-06   # SILICON INTEGRATED SYS. CORP.
    00-E0-07   # Avaya ECS Ltd
    00-E0-08   # AMAZING CONTROLS! INC.
    00-E0-09   # MARATHON TECHNOLOGIES CORP.
    00-E0-0A   # DIBA, INC.
    00-E0-0B   # ROOFTOP COMMUNICATIONS CORP.
    00-E0-0C   # MOTOROLA
    00-E0-0D   # RADIANT SYSTEMS
    00-E0-0E   # AVALON IMAGING SYSTEMS, INC.
    00-E0-0F   # SHANGHAI BAUD DATA
    00-E0-10   # HESS SB-AUTOMATENBAU GmbH
    00-E0-11   # Uniden Corporation
    00-E0-12   # PLUTO TECHNOLOGIES INTERNATIONAL INC.
    00-E0-13   # EASTERN ELECTRONIC CO., LTD.
    00-E0-14   # Cisco Systems, Inc
    00-E0-15   # HEIWA CORPORATION
    00-E0-16   # RAPID CITY COMMUNICATIONS
    00-E0-17   # EXXACT GmbH
    00-E0-18   # ASUSTek COMPUTER INC.
    00-E0-19   # ING. GIORDANO ELETTRONICA
    00-E0-1A   # COMTEC SYSTEMS. CO., LTD.
    00-E0-1B   # SPHERE COMMUNICATIONS, INC.
    00-E0-1C   # Cradlepoint, Inc
    00-E0-1D   # WebTV NETWORKS, INC.
    00-E0-1E   # Cisco Systems, Inc
    00-E0-1F   # AVIDIA Systems, Inc.
    00-E0-20   # TECNOMEN OY
    00-E0-21   # FREEGATE CORP.
    00-E0-22   # Analog Devices Inc.
    00-E0-23   # TELRAD
    00-E0-24   # GADZOOX NETWORKS
    00-E0-25   # dit Co., Ltd.
    00-E0-26   # Redlake MASD LLC
    00-E0-27   # DUX, INC.
    00-E0-28   # APTIX CORPORATION
    00-E0-29   # STANDARD MICROSYSTEMS CORP.
    00-E0-2A   # TANDBERG TELEVISION AS
    00-E0-2B   # EXTREME NETWORKS
    00-E0-2C   # AST COMPUTER
    00-E0-2D   # InnoMediaLogic, Inc.
    00-E0-2E   # SPC ELECTRONICS CORPORATION
    00-E0-2F   # MCNS HOLDINGS, L.P.
    00-E0-30   # MELITA INTERNATIONAL CORP.
    00-E0-31   # HAGIWARA ELECTRIC CO., LTD.
    00-E0-32   # MISYS FINANCIAL SYSTEMS, LTD.
    00-E0-33   # E.E.P.D. GmbH
    00-E0-34   # Cisco Systems, Inc
    00-E0-35   # Artesyn Embedded Technologies
    00-E0-36   # PIONEER CORPORATION
    00-E0-37   # CENTURY CORPORATION
    00-E0-38   # PROXIMA CORPORATION
    00-E0-39   # PARADYNE CORP.
    00-E0-3A   # Cabletron Systems, Inc.
    00-E0-3B   # PROMINET CORPORATION
    00-E0-3C   # AdvanSys
    00-E0-3D   # FOCON ELECTRONIC SYSTEMS A/S
    00-E0-3E   # ALFATECH, INC.
    00-E0-3F   # JATON CORPORATION
    00-E0-40   # DeskStation Technology, Inc.
    00-E0-41   # CSPI
    00-E0-42   # Pacom Systems Ltd.
    00-E0-43   # VitalCom
    00-E0-44   # LSICS CORPORATION
    00-E0-45   # TOUCHWAVE, INC.
    00-E0-46   # BENTLY NEVADA CORP.
    00-E0-47   # InFocus Corporation
    00-E0-48   # SDL COMMUNICATIONS, INC.
    00-E0-49   # MICROWI ELECTRONIC GmbH
    00-E0-4A   # ZX Technologies, Inc
    00-E0-4B   # JUMP INDUSTRIELLE COMPUTERTECHNIK GmbH
    00-E0-4C   # REALTEK SEMICONDUCTOR CORP.
    00-E0-4D   # INTERNET INITIATIVE JAPAN, INC
    00-E0-4E   # SANYO DENKI CO., LTD.
    00-E0-4F   # Cisco Systems, Inc
    00-E0-50   # EXECUTONE INFORMATION SYSTEMS, INC.
    00-E0-51   # TALX CORPORATION
    00-E0-52   # Brocade Communications Systems, Inc.
    00-E0-53   # CELLPORT LABS, INC.
    00-E0-54   # KODAI HITEC CO., LTD.
    00-E0-55   # INGENIERIA ELECTRONICA COMERCIAL INELCOM S.A.
    00-E0-56   # HOLONTECH CORPORATION
    00-E0-57   # HAN MICROTELECOM. CO., LTD.
    00-E0-58   # PHASE ONE DENMARK A/S
    00-E0-59   # CONTROLLED ENVIRONMENTS, LTD.
    00-E0-5A   # GALEA NETWORK SECURITY
    00-E0-5B   # WEST END SYSTEMS CORP.
    00-E0-5C   # Panasonic Healthcare Co., Ltd.
    00-E0-5D   # UNITEC CO., LTD.
    00-E0-5E   # JAPAN AVIATION ELECTRONICS INDUSTRY, LTD.
    00-E0-5F   # e-Net, Inc.
    00-E0-60   # SHERWOOD
    00-E0-61   # EdgePoint Networks, Inc.
    00-E0-62   # HOST ENGINEERING
    00-E0-63   # Cabletron Systems, Inc.
    00-E0-64   # SAMSUNG ELECTRONICS
    00-E0-65   # OPTICAL ACCESS INTERNATIONAL
    00-E0-66   # ProMax Systems, Inc.
    00-E0-67   # eac AUTOMATION-CONSULTING GmbH
    00-E0-68   # MERRIMAC SYSTEMS INC.
    00-E0-69   # JAYCOR
    00-E0-6A   # KAPSCH AG
    00-E0-6B   # W&G SPECIAL PRODUCTS
    00-E0-6C   # Ultra Electronics Limited (AEP Networks)
    00-E0-6D   # COMPUWARE CORPORATION
    00-E0-6E   # FAR SYSTEMS S.p.A.
    00-E0-6F   # ARRIS Group, Inc.
    00-E0-70   # DH TECHNOLOGY
    00-E0-71   # EPIS MICROCOMPUTER
    00-E0-72   # LYNK
    00-E0-73   # NATIONAL AMUSEMENT NETWORK, INC.
    00-E0-74   # TIERNAN COMMUNICATIONS, INC.
    00-E0-75   # Verilink Corporation
    00-E0-76   # DEVELOPMENT CONCEPTS, INC.
    00-E0-77   # WEBGEAR, INC.
    00-E0-78   # BERKELEY NETWORKS
    00-E0-79   # A.T.N.R.
    00-E0-7A   # MIKRODIDAKT AB
    00-E0-7B   # BAY NETWORKS
    00-E0-7C   # METTLER-TOLEDO, INC.
    00-E0-7D   # NETRONIX, INC.
    00-E0-7E   # WALT DISNEY IMAGINEERING
    00-E0-7F   # LOGISTISTEM s.r.l.
    00-E0-80   # CONTROL RESOURCES CORPORATION
    00-E0-81   # TYAN COMPUTER CORP.
    00-E0-82   # ANERMA
    00-E0-83   # JATO TECHNOLOGIES, INC.
    00-E0-84   # COMPULITE R&D
    00-E0-85   # GLOBAL MAINTECH, INC.
    00-E0-86   # Emerson Network Power, Avocent Division
    00-E0-87   # LeCroy - Networking Productions Division
    00-E0-88   # LTX-Credence CORPORATION
    00-E0-89   # ION Networks, Inc.
    00-E0-8A   # GEC AVERY, LTD.
    00-E0-8B   # QLogic Corp.
    00-E0-8C   # NEOPARADIGM LABS, INC.
    00-E0-8D   # PRESSURE SYSTEMS, INC.
    00-E0-8E   # UTSTARCOM
    00-E0-8F   # Cisco Systems, Inc
    00-E0-90   # BECKMAN LAB. AUTOMATION DIV.
    00-E0-91   # LG ELECTRONICS, INC.
    00-E0-92   # ADMTEK INCORPORATED
    00-E0-93   # ACKFIN NETWORKS
    00-E0-94   # OSAI SRL
    00-E0-95   # ADVANCED-VISION TECHNOLGIES CORP.
    00-E0-96   # SHIMADZU CORPORATION
    00-E0-97   # CARRIER ACCESS CORPORATION
    00-E0-98   # AboCom
    00-E0-99   # SAMSON AG
    00-E0-9A   # Positron Inc.
    00-E0-9B   # ENGAGE NETWORKS, INC.
    00-E0-9C   # MII
    00-E0-9D   # SARNOFF CORPORATION
    00-E0-9E   # QUANTUM CORPORATION
    00-E0-9F   # PIXEL VISION
    00-E0-A0   # WILTRON CO.
    00-E0-A1   # HIMA PAUL HILDEBRANDT GmbH Co. KG
    00-E0-A2   # MICROSLATE INC.
    00-E0-A3   # Cisco Systems, Inc
    00-E0-A4   # ESAOTE S.p.A.
    00-E0-A5   # ComCore Semiconductor, Inc.
    00-E0-A6   # TELOGY NETWORKS, INC.
    00-E0-A7   # IPC INFORMATION SYSTEMS, INC.
    00-E0-A8   # SAT GmbH & Co.
    00-E0-A9   # FUNAI ELECTRIC CO., LTD.
    00-E0-AA   # ELECTROSONIC LTD.
    00-E0-AB   # DIMAT S.A.
    00-E0-AC   # MIDSCO, INC.
    00-E0-AD   # EES TECHNOLOGY, LTD.
    00-E0-AE   # XAQTI CORPORATION
    00-E0-AF   # GENERAL DYNAMICS INFORMATION SYSTEMS
    00-E0-B0   # Cisco Systems, Inc
    00-E0-B1   # Alcatel-Lucent, Enterprise Business Group
    00-E0-B2   # TELMAX COMMUNICATIONS CORP.
    00-E0-B3   # EtherWAN Systems, Inc.
    00-E0-B4   # TECHNO SCOPE CO., LTD.
    00-E0-B5   # ARDENT COMMUNICATIONS CORP.
    00-E0-B6   # Entrada Networks
    00-E0-B7   # PI GROUP, LTD.
    00-E0-B8   # GATEWAY 2000
    00-E0-B9   # BYAS SYSTEMS
    00-E0-BA   # BERGHOF AUTOMATIONSTECHNIK GmbH
    00-E0-BB   # NBX CORPORATION
    00-E0-BC   # SYMON COMMUNICATIONS, INC.
    00-E0-BD   # INTERFACE SYSTEMS, INC.
    00-E0-BE   # GENROCO INTERNATIONAL, INC.
    00-E0-BF   # TORRENT NETWORKING TECHNOLOGIES CORP.
    00-E0-C0   # SEIWA ELECTRIC MFG. CO., LTD.
    00-E0-C1   # MEMOREX TELEX JAPAN, LTD.
    00-E0-C2   # NECSY S.p.A.
    00-E0-C3   # SAKAI SYSTEM DEVELOPMENT CORP.
    00-E0-C4   # HORNER ELECTRIC, INC.
    00-E0-C5   # BCOM ELECTRONICS INC.
    00-E0-C6   # LINK2IT, L.L.C.
    00-E0-C7   # EUROTECH SRL
    00-E0-C8   # VIRTUAL ACCESS, LTD.
    00-E0-C9   # AutomatedLogic Corporation
    00-E0-CA   # BEST DATA PRODUCTS
    00-E0-CB   # RESON, INC.
    00-E0-CC   # HERO SYSTEMS, LTD.
    00-E0-CD   # SAAB SENSIS CORPORATION
    00-E0-CE   # ARN
    00-E0-CF   # INTEGRATED DEVICE TECHNOLOGY, INC.
    00-E0-D0   # NETSPEED, INC.
    00-E0-D1   # TELSIS LIMITED
    00-E0-D2   # VERSANET COMMUNICATIONS, INC.
    00-E0-D3   # DATENTECHNIK GmbH
    00-E0-D4   # EXCELLENT COMPUTER
    00-E0-D5   # Emulex Corporation
    00-E0-D6   # COMPUTER & COMMUNICATION RESEARCH LAB.
    00-E0-D7   # SUNSHINE ELECTRONICS, INC.
    00-E0-D8   # LANBit Computer, Inc.
    00-E0-D9   # TAZMO CO., LTD.
    00-E0-DA   # Alcatel North America ESD
    00-E0-DB   # ViaVideo Communications, Inc.
    00-E0-DC   # NEXWARE CORP.
    00-E0-DD   # ZENITH ELECTRONICS CORPORATION
    00-E0-DE   # DATAX NV
    00-E0-DF   # KEYMILE GmbH
    00-E0-E0   # SI ELECTRONICS, LTD.
    00-E0-E1   # G2 NETWORKS, INC.
    00-E0-E2   # INNOVA CORP.
    00-E0-E3   # SK-ELEKTRONIK GMBH
    00-E0-E4   # FANUC ROBOTICS NORTH AMERICA, Inc.
    00-E0-E5   # CINCO NETWORKS, INC.
    00-E0-E6   # INCAA DATACOM B.V.
    00-E0-E7   # RAYTHEON E-SYSTEMS, INC.
    00-E0-E8   # GRETACODER Data Systems AG
    00-E0-E9   # DATA LABS, INC.
    00-E0-EA   # INNOVAT COMMUNICATIONS, INC.
    00-E0-EB   # DIGICOM SYSTEMS, INCORPORATED
    00-E0-EC   # CELESTICA INC.
    00-E0-ED   # SILICOM, LTD.
    00-E0-EE   # MAREL HF
    00-E0-EF   # DIONEX
    00-E0-F0   # ABLER TECHNOLOGY, INC.
    00-E0-F1   # THAT CORPORATION
    00-E0-F2   # ARLOTTO COMNET, INC.
    00-E0-F3   # WebSprint Communications, Inc.
    00-E0-F4   # INSIDE Technology A/S
    00-E0-F5   # TELES AG
    00-E0-F6   # DECISION EUROPE
    00-E0-F7   # Cisco Systems, Inc
    00-E0-F8   # DICNA CONTROL AB
    00-E0-F9   # Cisco Systems, Inc
    00-E0-FA   # TRL TECHNOLOGY, LTD.
    00-E0-FB   # LEIGHTRONIX, INC.
    00-E0-FC   # HUAWEI TECHNOLOGIES CO.,LTD
    00-E0-FD   # A-TREND TECHNOLOGY CO., LTD.
    00-E0-FE   # Cisco Systems, Inc
    00-E0-FF   # SECURITY DYNAMICS TECHNOLOGIES, Inc.
    00-E1-6D   # Cisco Systems, Inc
    00-E1-75   # AK-Systems Ltd
    00-E3-B2   # Samsung Electronics Co.,Ltd
    00-E6-66   # ARIMA Communications Corp.
    00-E6-D3   # NIXDORF COMPUTER CORP.
    00-E6-E8   # Netzin Technology Corporation,.Ltd.
    00-E8-AB   # Meggitt Training Systems, Inc.
    00-EB-2D   # Sony Mobile Communications AB
    00-EE-BD   # HTC Corporation
    00-F0-51   # KWB Gmbh
    00-F2-8B   # Cisco Systems, Inc
    00-F3-DB   # WOO Sports
    00-F4-03   # Orbis Systems Oy
    00-F4-6F   # Samsung Electronics Co.,Ltd
    00-F4-B9   # Apple, Inc.
    00-F7-6F   # Apple, Inc.
    00-F8-1C   # HUAWEI TECHNOLOGIES CO.,LTD
    00-F8-60   # PT. Panggung Electric Citrabuana
    00-F8-71   # DGS Denmark A/S
    00-FA-3B   # CLOOS ELECTRONIC GMBH
    00-FC-58   # WebSilicon Ltd.
    00-FC-70   # Intrepid Control Systems, Inc.
    00-FC-8D   # Hitron Technologies. Inc
    00-FD-4C   # NEVATEC
    00-FE-C8   # Cisco Systems, Inc
    02-07-01   # RACAL-DATACOM
    02-1C-7C   # PERQ SYSTEMS CORPORATION
    02-60-86   # LOGIC REPLACEMENT TECH. LTD.
    02-60-8C   # 3COM CORPORATION
    02-70-01   # RACAL-DATACOM
    02-70-B0   # M/A-COM INC. COMPANIES
    02-70-B3   # DATA RECALL LTD.
    02-9D-8E   # CARDIAC RECORDERS, INC.
    02-AA-3C   # OLIVETTI TELECOMM SPA (OLTECO)
    02-BB-01   # OCTOTHORPE CORP.
    02-C0-8C   # 3COM CORPORATION
    02-CF-1C   # Communication Machinery Corporation
    02-E6-D3   # NIXDORF COMPUTER CORPORATION
    04-02-1F   # HUAWEI TECHNOLOGIES CO.,LTD
    04-0A-83   # Alcatel-Lucent
    04-0A-E0   # XMIT AG COMPUTER NETWORKS
    04-0C-CE   # Apple, Inc.
    04-0E-C2   # ViewSonic Mobile China Limited
    04-15-52   # Apple, Inc.
    04-18-0F   # Samsung Electronics Co.,Ltd
    04-18-B6   # Private
    04-18-D6   # Ubiquiti Networks
    04-1A-04   # WaveIP
    04-1B-94   # Host Mobility AB
    04-1B-BA   # Samsung Electronics Co.,Ltd
    04-1D-10   # Dream Ware Inc.
    04-1E-64   # Apple, Inc.
    04-1E-7A   # DSPWorks
    04-20-9A   # Panasonic AVC Networks Company
    04-21-4C   # Insight Energy Ventures LLC
    04-22-34   # Wireless Standard Extensions
    04-26-05   # GFR Gesellschaft für Regelungstechnik und Energieeinsparung mbH
    04-26-65   # Apple, Inc.
    04-2B-BB   # PicoCELA, Inc.
    04-2F-56   # ATOCS (Shenzhen) LTD
    04-32-F4   # Partron
    04-36-04   # Gyeyoung I&T
    04-3D-98   # ChongQing QingJia Electronics CO.,LTD
    04-41-69   # GoPro
    04-44-A1   # TELECON GALICIA,S.A.
    04-46-65   # Murata Manufacturing Co., Ltd.
    04-48-9A   # Apple, Inc.
    04-4A-50   # Ramaxel Technology (Shenzhen) limited company
    04-4B-ED   # Apple, Inc.
    04-4B-FF   # GuangZhou Hedy Digital Technology Co., Ltd
    04-4C-EF   # Fujian Sanao Technology Co.,Ltd
    04-4E-06   # Ericsson AB
    04-4F-8B   # Adapteva, Inc.
    04-4F-AA   # Ruckus Wireless
    04-52-F3   # Apple, Inc.
    04-53-D5   # Sysorex Global Holdings
    04-54-53   # Apple, Inc.
    04-55-CA   # BriView (Xiamen) Corp.
    04-57-2F   # Sertel Electronics UK Ltd
    04-58-6F   # Sichuan Whayer information industry Co.,LTD
    04-5A-95   # Nokia Corporation
    04-5C-06   # Zmodo Technology Corporation
    04-5C-8E   # gosund GROUP CO.,LTD
    04-5D-56   # camtron industrial inc.
    04-5F-A7   # Shenzhen Yichen Technology Development Co.,LTD
    04-61-69   # MEDIA GLOBAL LINKS CO., LTD.
    04-62-73   # Cisco Systems, Inc
    04-62-D7   # ALSTOM HYDRO FRANCE
    04-63-E0   # Nome Oy
    04-67-85   # scemtec Hard- und Software fuer Mess- und Steuerungstechnik GmbH
    04-69-F8   # Apple, Inc.
    04-6C-9D   # Cisco Systems, Inc
    04-6D-42   # Bryston Ltd.
    04-6E-49   # TaiYear Electronic Technology (Suzhou) Co., Ltd
    04-70-BC   # Globalstar Inc.
    04-74-A1   # Aligera Equipamentos Digitais Ltda
    04-75-F5   # CSST
    04-76-6E   # ALPS ELECTRIC CO.,LTD.
    04-78-63   # Shanghai MXCHIP Information Technology Co., Ltd.
    04-7D-50   # Shenzhen Kang Ying Technology Co.Ltd.
    04-7D-7B   # Quanta Computer Inc.
    04-7E-4A   # moobox CO., Ltd.
    04-81-AE   # Clack Corporation
    04-84-8A   # 7INOVA TECHNOLOGY LIMITED
    04-88-8C   # Eifelwerk Butler Systeme GmbH
    04-88-E2   # Beats Electronics LLC
    04-8A-15   # Avaya Inc
    04-8B-42   # Skspruce Technology Limited
    04-8C-03   # ThinPAD Technology (Shenzhen)CO.,LTD
    04-8D-38   # Netcore Technology Inc.
    04-92-EE   # iway AG
    04-94-A1   # CATCH THE WIND INC
    04-96-45   # WUXI SKY CHIP INTERCONNECTION TECHNOLOGY CO.,LTD.
    04-98-F3   # ALPS ELECTRIC CO.,LTD.
    04-99-E6   # Shenzhen Yoostar Technology Co., Ltd
    04-9B-9C   # Eadingcore  Intelligent Technology Co., Ltd.
    04-9C-62   # BMT Medical Technology s.r.o.
    04-9F-06   # Smobile Co., Ltd.
    04-9F-81   # Netscout Systems, Inc.
    04-A1-51   # NETGEAR
    04-A3-F3   # Emicon
    04-A8-2A   # Nokia Corporation
    04-B3-B6   # Seamap (UK) Ltd
    04-B4-66   # BSP Co., Ltd.
    04-BD-70   # HUAWEI TECHNOLOGIES CO.,LTD
    04-BD-88   # Aruba Networks
    04-BF-6D   # ZyXEL Communications Corporation
    04-BF-A8   # ISB Corporation
    04-C0-5B   # Tigo Energy
    04-C0-6F   # HUAWEI TECHNOLOGIES CO.,LTD
    04-C0-9C   # Tellabs Inc.
    04-C1-B9   # Fiberhome Telecommunication Tech.Co.,Ltd.
    04-C2-3E   # HTC Corporation
    04-C5-A4   # Cisco Systems, Inc
    04-C8-80   # Samtec Inc
    04-C9-91   # Phistek INC.
    04-C9-D9   # EchoStar Technologies Corp
    04-CB-1D   # Traka plc
    04-CE-14   # Wilocity LTD.
    04-CF-25   # MANYCOLORS, INC.
    04-D4-37   # ZNV
    04-D7-83   # Y&H E&C Co.,LTD.
    04-DA-D2   # Cisco Systems, Inc
    04-DB-56   # Apple, Inc.
    04-DB-8A   # Suntech International Ltd.
    04-DD-4C   # Velocytech
    04-DE-DB   # Rockport Networks Inc
    04-DF-69   # Car Connectivity Consortium
    04-E0-C4   # TRIUMPH-ADLER AG
    04-E1-C8   # IMS Soluções em Energia Ltda.
    04-E2-F8   # AEP Ticketing solutions srl
    04-E4-51   # Texas Instruments
    04-E5-36   # Apple, Inc.
    04-E5-48   # Cohda Wireless Pty Ltd
    04-E6-62   # Acroname Inc.
    04-E6-76   # AMPAK Technology, Inc.
    04-E9-E5   # PJRC.COM, LLC
    04-EE-91   # x-fabric GmbH
    04-F0-21   # Compex Systems Pte Ltd
    04-F1-3E   # Apple, Inc.
    04-F1-7D   # Tarana Wireless
    04-F4-BC   # Xena Networks
    04-F7-E4   # Apple, Inc.
    04-F8-C2   # Flaircomm Microelectronics, Inc.
    04-F9-38   # HUAWEI TECHNOLOGIES CO.,LTD
    04-FE-31   # Samsung Electronics Co.,Ltd
    04-FE-7F   # Cisco Systems, Inc
    04-FE-8D   # HUAWEI TECHNOLOGIES CO.,LTD
    04-FF-51   # NOVAMEDIA INNOVISION SP. Z O.O.
    08-00-01   # COMPUTERVISION CORPORATION
    08-00-02   # BRIDGE COMMUNICATIONS INC.
    08-00-03   # ADVANCED COMPUTER COMM.
    08-00-04   # CROMEMCO INCORPORATED
    08-00-05   # SYMBOLICS INC.
    08-00-06   # SIEMENS AG
    08-00-07   # Apple, Inc.
    08-00-08   # BOLT BERANEK AND NEWMAN INC.
    08-00-09   # Hewlett Packard
    08-00-0A   # NESTAR SYSTEMS INCORPORATED
    08-00-0B   # UNISYS CORPORATION
    08-00-0C   # MIKLYN DEVELOPMENT CO.
    08-00-0D   # INTERNATIONAL COMPUTERS LTD.
    08-00-0E   # NCR CORPORATION
    08-00-0F   # MITEL CORPORATION
    08-00-11   # TEKTRONIX INC.
    08-00-12   # BELL ATLANTIC INTEGRATED SYST.
    08-00-13   # Exxon
    08-00-14   # EXCELAN
    08-00-15   # STC BUSINESS SYSTEMS
    08-00-16   # BARRISTER INFO SYS CORP
    08-00-17   # NATIONAL SEMICONDUCTOR
    08-00-18   # PIRELLI FOCOM NETWORKS
    08-00-19   # GENERAL ELECTRIC CORPORATION
    08-00-1A   # TIARA/ 10NET
    08-00-1B   # EMC Corporation
    08-00-1C   # KDD-KOKUSAI DEBNSIN DENWA CO.
    08-00-1D   # ABLE COMMUNICATIONS INC.
    08-00-1E   # APOLLO COMPUTER INC.
    08-00-1F   # SHARP CORPORATION
    08-00-20   # Oracle Corporation
    08-00-21   # 3M COMPANY
    08-00-22   # NBI INC.
    08-00-23   # Panasonic Communications Co., Ltd.
    08-00-24   # 10NET COMMUNICATIONS/DCA
    08-00-25   # CONTROL DATA
    08-00-26   # NORSK DATA A.S.
    08-00-27   # Cadmus Computer Systems
    08-00-28   # Texas Instruments
    08-00-29   # Megatek Corporation
    08-00-2A   # MOSAIC TECHNOLOGIES INC.
    08-00-2B   # DIGITAL EQUIPMENT CORPORATION
    08-00-2C   # BRITTON LEE INC.
    08-00-2D   # LAN-TEC INC.
    08-00-2E   # METAPHOR COMPUTER SYSTEMS
    08-00-2F   # PRIME COMPUTER INC.
    08-00-30   # CERN
    08-00-30   # NETWORK RESEARCH CORPORATION
    08-00-30   # ROYAL MELBOURNE INST OF TECH
    08-00-31   # LITTLE MACHINES INC.
    08-00-32   # TIGAN INCORPORATED
    08-00-33   # BAUSCH & LOMB
    08-00-34   # FILENET CORPORATION
    08-00-35   # MICROFIVE CORPORATION
    08-00-36   # INTERGRAPH CORPORATION
    08-00-37   # FUJI-XEROX CO. LTD.
    08-00-38   # BULL S.A.S.
    08-00-39   # SPIDER SYSTEMS LIMITED
    08-00-3A   # ORCATECH INC.
    08-00-3B   # TORUS SYSTEMS LIMITED
    08-00-3C   # SCHLUMBERGER WELL SERVICES
    08-00-3D   # CADNETIX CORPORATIONS
    08-00-3E   # CODEX CORPORATION
    08-00-3F   # FRED KOSCHARA ENTERPRISES
    08-00-40   # FERRANTI COMPUTER SYS. LIMITED
    08-00-41   # RACAL-MILGO INFORMATION SYS..
    08-00-42   # JAPAN MACNICS CORP.
    08-00-43   # PIXEL COMPUTER INC.
    08-00-44   # DAVID SYSTEMS INC.
    08-00-45   # CONCURRENT COMPUTER CORP.
    08-00-46   # Sony Corporation
    08-00-47   # SEQUENT COMPUTER SYSTEMS INC.
    08-00-48   # EUROTHERM GAUGING SYSTEMS
    08-00-49   # UNIVATION
    08-00-4A   # BANYAN SYSTEMS INC.
    08-00-4B   # Planning Research Corp.
    08-00-4C   # HYDRA COMPUTER SYSTEMS INC.
    08-00-4D   # CORVUS SYSTEMS INC.
    08-00-4E   # 3COM EUROPE LTD.
    08-00-4F   # CYGNET SYSTEMS
    08-00-50   # DAISY SYSTEMS CORP.
    08-00-51   # EXPERDATA
    08-00-52   # INSYSTEC
    08-00-53   # MIDDLE EAST TECH. UNIVERSITY
    08-00-55   # STANFORD TELECOMM. INC.
    08-00-56   # STANFORD LINEAR ACCEL. CENTER
    08-00-57   # Evans & Sutherland
    08-00-58   # SYSTEMS CONCEPTS
    08-00-59   # A/S MYCRON
    08-00-5A   # IBM Corp
    08-00-5B   # VTA TECHNOLOGIES INC.
    08-00-5C   # FOUR PHASE SYSTEMS
    08-00-5D   # GOULD INC.
    08-00-5E   # COUNTERPOINT COMPUTER INC.
    08-00-5F   # SABER TECHNOLOGY CORP.
    08-00-60   # INDUSTRIAL NETWORKING INC.
    08-00-61   # JAROGATE LTD.
    08-00-62   # General Dynamics
    08-00-63   # PLESSEY
    08-00-64   # Sitasys AG
    08-00-65   # GENRAD INC.
    08-00-66   # AGFA CORPORATION
    08-00-67   # ComDesign
    08-00-68   # RIDGE COMPUTERS
    08-00-69   # SILICON GRAPHICS INC.
    08-00-6A   # ATT BELL LABORATORIES
    08-00-6B   # ACCEL TECHNOLOGIES INC.
    08-00-6C   # SUNTEK TECHNOLOGY INT'L
    08-00-6D   # WHITECHAPEL COMPUTER WORKS
    08-00-6E   # MASSCOMP
    08-00-6F   # PHILIPS APELDOORN B.V.
    08-00-70   # MITSUBISHI ELECTRIC CORP.
    08-00-71   # MATRA (DSIE)
    08-00-72   # XEROX CORP UNIV GRANT PROGRAM
    08-00-73   # TECMAR INC.
    08-00-74   # CASIO COMPUTER CO. LTD.
    08-00-75   # DANSK DATA ELECTRONIK
    08-00-76   # PC LAN TECHNOLOGIES
    08-00-77   # TSL COMMUNICATIONS LTD.
    08-00-78   # ACCELL CORPORATION
    08-00-79   # THE DROID WORKS
    08-00-7A   # INDATA
    08-00-7B   # SANYO ELECTRIC CO. LTD.
    08-00-7C   # VITALINK COMMUNICATIONS CORP.
    08-00-7E   # AMALGAMATED WIRELESS(AUS) LTD
    08-00-7F   # CARNEGIE-MELLON UNIVERSITY
    08-00-80   # AES DATA INC.
    08-00-81   # ASTECH INC.
    08-00-82   # VERITAS SOFTWARE
    08-00-83   # Seiko Instruments Inc.
    08-00-84   # TOMEN ELECTRONICS CORP.
    08-00-85   # ELXSI
    08-00-86   # KONICA MINOLTA HOLDINGS, INC.
    08-00-87   # XYPLEX
    08-00-88   # Brocade Communications Systems, Inc.
    08-00-89   # Kinetics
    08-00-8A   # PerfTech, Inc.
    08-00-8B   # PYRAMID TECHNOLOGY CORP.
    08-00-8C   # NETWORK RESEARCH CORPORATION
    08-00-8D   # XYVISION INC.
    08-00-8E   # Tandem Computers
    08-00-8F   # CHIPCOM CORPORATION
    08-00-90   # SONOMA SYSTEMS
    08-03-71   # KRG CORPORATE
    08-05-81   # Roku, Inc.
    08-05-CD   # DongGuang EnMai Electronic Product Co.Ltd.
    08-08-C2   # Samsung Electronics
    08-08-EA   # AMSC
    08-09-B6   # Masimo Corp
    08-0A-4E   # Planet Bingo® — 3rd Rock Gaming®
    08-0C-0B   # SysMik GmbH Dresden
    08-0C-C9   # Mission Technology Group, dba Magma
    08-0D-84   # GECO, Inc.
    08-0E-A8   # Velex s.r.l.
    08-0F-FA   # KSP INC.
    08-11-5E   # Bitel Co., Ltd.
    08-11-96   # Intel Corporate
    08-14-43   # UNIBRAIN S.A.
    08-16-51   # SHENZHEN SEA STAR TECHNOLOGY CO.,LTD
    08-17-35   # Cisco Systems, Inc
    08-17-F4   # IBM Corp
    08-18-1A   # zte corporation
    08-18-4C   # A. S. Thomas, Inc.
    08-19-A6   # HUAWEI TECHNOLOGIES CO.,LTD
    08-1D-FB   # Shanghai Mexon Communication Technology Co.,Ltd
    08-1F-3F   # WondaLink Inc.
    08-1F-EB   # BinCube
    08-1F-F3   # Cisco Systems, Inc
    08-21-EF   # Samsung Electronics Co.,Ltd
    08-25-22   # ADVANSEE
    08-27-19   # APS systems/electronic AG
    08-2A-D0   # SRD Innovations Inc.
    08-2C-B0   # Network Instruments
    08-2E-5F   # Hewlett Packard
    08-35-71   # CASwell INC.
    08-37-3D   # Samsung Electronics Co.,Ltd
    08-37-9C   # Topaz Co. LTD.
    08-38-A5   # Funkwerk plettac electronic GmbH
    08-3A-5C   # Junilab, Inc.
    08-3A-B8   # Shinoda Plasma Co., Ltd.
    08-3D-88   # Samsung Electronics Co.,Ltd
    08-3E-0C   # ARRIS Group, Inc.
    08-3E-8E   # Hon Hai Precision Ind. Co.,Ltd.
    08-3F-3E   # WSH GmbH
    08-3F-76   # Intellian Technologies, Inc.
    08-40-27   # Gridstore Inc.
    08-46-56   # VEO-LABS
    08-48-2C   # Raycore Taiwan Co., LTD.
    08-4E-1C   # H2A Systems, LLC
    08-4E-BF   # Broad Net Mux Corporation
    08-51-2E   # Orion Diagnostica Oy
    08-52-40   # EbV Elektronikbau- und Vertriebs GmbH
    08-57-00   # TP-LINK TECHNOLOGIES CO.,LTD.
    08-5A-E0   # Recovision Technology Co., Ltd.
    08-5B-0E   # Fortinet, Inc.
    08-5D-DD   # Mercury Corporation
    08-60-6E   # ASUSTek COMPUTER INC.
    08-62-66   # ASUSTek COMPUTER INC.
    08-63-61   # HUAWEI TECHNOLOGIES CO.,LTD
    08-66-98   # Apple, Inc.
    08-68-D0   # Japan System Design
    08-68-EA   # EITO ELECTRONICS CO., LTD.
    08-6D-F2   # Shenzhen MIMOWAVE Technology Co.,Ltd
    08-70-45   # Apple, Inc.
    08-74-02   # Apple, Inc.
    08-74-F6   # Winterhalter Gastronom GmbH
    08-75-72   # Obelux Oy
    08-76-18   # ViE Technologies Sdn. Bhd.
    08-76-95   # Auto Industrial Co., Ltd.
    08-76-FF   # Thomson Telecom Belgium
    08-79-99   # AIM GmbH
    08-7A-4C   # HUAWEI TECHNOLOGIES CO.,LTD
    08-7B-AA   # SVYAZKOMPLEKTSERVICE, LLC
    08-7C-BE   # Quintic Corp.
    08-7D-21   # Altasec technology corporation
    08-80-39   # Cisco SPVTG
    08-81-BC   # HongKong Ipro Technology Co., Limited
    08-81-F4   # Juniper Networks
    08-86-3B   # Belkin International Inc.
    08-8C-2C   # Samsung Electronics Co.,Ltd
    08-8D-C8   # Ryowa Electronics Co.,Ltd
    08-8E-4F   # SF Software Solutions
    08-8F-2C   # Hills Sound Vision & Lighting
    08-94-EF   # Wistron Infocomm (Zhongshan) Corporation
    08-95-2A   # Technicolor CH USA
    08-96-D7   # AVM GmbH
    08-97-58   # Shenzhen Strong Rising Electronics Co.,Ltd DongGuan Subsidiary
    08-9B-4B   # iKuai Networks
    08-9E-01   # QUANTA COMPUTER INC.
    08-9F-97   # LEROY AUTOMATION
    08-A1-2B   # ShenZhen EZL Technology Co., Ltd
    08-A5-C8   # Sunnovo International Limited
    08-A9-5A   # AzureWave Technology Inc.
    08-AC-A5   # Benu Video, Inc.
    08-AF-78   # Totus Solutions, Inc.
    08-B2-A3   # Cynny Italia S.r.L.
    08-B4-CF   # Abicom International
    08-B7-38   # Lite-On Technogy Corp.
    08-B7-EC   # Wireless Seismic
    08-BB-CC   # AK-NORD EDV VERTRIEBSGES. mbH
    08-BD-43   # NETGEAR
    08-BE-09   # Astrol Electronic AG
    08-CA-45   # Toyou Feiji Electronics Co., Ltd.
    08-CC-68   # Cisco Systems, Inc
    08-CD-9B   # samtec automotive electronics & software GmbH
    08-D0-9F   # Cisco Systems, Inc
    08-D0-B7   # HISENSE ELECTRIC CO.,LTD.
    08-D2-9A   # Proformatique
    08-D3-4B   # Techman Electronics (Changshu) Co., Ltd.
    08-D4-0C   # Intel Corporate
    08-D4-2B   # Samsung Electronics
    08-D5-C0   # Seers Technology Co., Ltd
    08-D8-33   # Shenzhen RF Technology Co,.Ltd
    08-DF-1F   # Bose Corporation
    08-E5-DA   # NANJING FUJITSU COMPUTER PRODUCTS CO.,LTD.
    08-E6-72   # JEBSEE ELECTRONICS CO.,LTD.
    08-E8-4F   # HUAWEI TECHNOLOGIES CO.,LTD
    08-EA-44   # Aerohive Networks Inc.
    08-EB-29   # Jiangsu Huitong Group Co.,Ltd.
    08-EB-74   # HUMAX Co., Ltd.
    08-EB-ED   # World Elite Technology Co.,LTD
    08-EC-A9   # Samsung Electronics Co.,Ltd
    08-ED-B9   # Hon Hai Precision Ind. Co.,Ltd.
    08-EE-8B   # Samsung Electronics Co.,Ltd
    08-EF-3B   # MCS Logic Inc.
    08-EF-AB   # SAYME WIRELESS SENSOR NETWORK
    08-F1-B7   # Towerstream Corpration
    08-F2-F4   # Net One Partners Co.,Ltd.
    08-F6-F8   # GET Engineering
    08-F7-28   # GLOBO Multimedia Sp. z o.o. Sp.k.
    08-FA-E0   # Fohhn Audio AG
    08-FC-52   # OpenXS BV
    08-FC-88   # Samsung Electronics Co.,Ltd
    08-FD-0E   # Samsung Electronics Co.,Ltd
    0C-04-00   # Jantar d.o.o.
    0C-05-35   # Juniper Systems
    0C-11-05   # Ringslink (Xiamen) Network Communication Technologies Co., Ltd
    0C-11-67   # Cisco Systems, Inc
    0C-12-62   # zte corporation
    0C-13-0B   # Uniqoteq Ltd.
    0C-14-20   # Samsung Electronics Co.,Ltd
    0C-15-39   # Apple, Inc.
    0C-15-C5   # SDTEC Co., Ltd.
    0C-17-F1   # TELECSYS
    0C-19-1F   # Inform Electronik
    0C-1A-10   # Acoustic Stream
    0C-1D-AF   # Xiaomi Communications Co Ltd
    0C-1D-C2   # SeAH Networks
    0C-20-26   # noax Technologies AG
    0C-27-24   # Cisco Systems, Inc
    0C-27-55   # Valuable Techologies Limited
    0C-2A-69   # electric imp, incorporated
    0C-2A-E7   # Beijing General Research Institute of Mining and Metallurgy
    0C-2D-89   # QiiQ Communications Inc.
    0C-30-21   # Apple, Inc.
    0C-37-DC   # HUAWEI TECHNOLOGIES CO.,LTD
    0C-38-3E   # Fanvil Technology Co., Ltd.
    0C-39-56   # Observator instruments
    0C-3C-65   # Dome Imaging Inc
    0C-3E-9F   # Apple, Inc.
    0C-41-3E   # Microsoft Corporation
    0C-45-BA   # HUAWEI TECHNOLOGIES CO.,LTD
    0C-46-9D   # MS Sedco
    0C-47-3D   # Hitron Technologies. Inc
    0C-47-C9   # Amazon Technologies Inc.
    0C-48-85   # LG Electronics
    0C-4C-39   # MitraStar Technology Corp.
    0C-4D-E9   # Apple, Inc.
    0C-4F-5A   # ASA-RT s.r.l.
    0C-51-F7   # CHAUVIN ARNOUX
    0C-54-A5   # PEGATRON CORPORATION
    0C-54-B9   # Alcatel-Lucent
    0C-55-21   # Axiros GmbH
    0C-56-5C   # HyBroad Vision (Hong Kong) Technology Co Ltd
    0C-57-EB   # Mueller Systems
    0C-5A-19   # Axtion Sdn Bhd
    0C-5C-D8   # DOLI Elektronik GmbH
    0C-60-76   # Hon Hai Precision Ind. Co.,Ltd.
    0C-61-27   # Actiontec Electronics, Inc
    0C-63-FC   # Nanjing Signway Technology Co., Ltd
    0C-68-03   # Cisco Systems, Inc
    0C-6A-E6   # Stanley Security Solutions
    0C-6E-4F   # PrimeVOLT Co., Ltd.
    0C-6F-9C   # Shaw Communications Inc.
    0C-71-5D   # Samsung Electronics Co.,Ltd
    0C-72-2C   # TP-LINK TECHNOLOGIES CO.,LTD.
    0C-74-C2   # Apple, Inc.
    0C-75-23   # BEIJING GEHUA CATV NETWORK CO.,LTD
    0C-75-6C   # Anaren Microwave, Inc.
    0C-75-BD   # Cisco Systems, Inc
    0C-77-1A   # Apple, Inc.
    0C-7D-7C   # Kexiang Information Technology Co, Ltd.
    0C-81-12   # Private
    0C-82-30   # SHENZHEN MAGNUS TECHNOLOGIES CO.,LTD
    0C-82-68   # TP-LINK TECHNOLOGIES CO.,LTD.
    0C-82-6A   # Wuhan Huagong Genuine Optics Technology Co., Ltd
    0C-84-11   # A.O. Smith Water Products
    0C-84-84   # Zenovia Electronics Inc.
    0C-84-DC   # Hon Hai Precision Ind. Co.,Ltd.
    0C-85-25   # Cisco Systems, Inc
    0C-86-10   # Juniper Networks
    0C-89-10   # Samsung Electronics Co.,Ltd
    0C-8B-FD   # Intel Corporate
    0C-8C-8F   # Kamo Technology Limited
    0C-8C-DC   # Suunto Oy
    0C-8D-98   # TOP EIGHT IND CORP
    0C-91-60   # Hui Zhou Gaoshengda Technology Co.,LTD
    0C-92-4E   # Rice Lake Weighing Systems
    0C-93-01   # PT. Prasimax Inovasi Teknologi
    0C-93-FB   # BNS Solutions
    0C-96-BF   # HUAWEI TECHNOLOGIES CO.,LTD
    0C-9B-13   # Shanghai Magic Mobile Telecommunication Co.Ltd.
    0C-9D-56   # Consort Controls Ltd
    0C-9E-91   # Sankosha Corporation
    0C-A1-38   # Blinq Wireless Inc.
    0C-A2-F4   # Chameleon Technology (UK) Limited
    0C-A4-02   # Alcatel Lucent IPD
    0C-A4-2A   # OB Telecom Electronic Technology Co., Ltd
    0C-A6-94   # Sunitec Enterprise Co.,Ltd
    0C-AC-05   # Unitend Technologies Inc.
    0C-AF-5A   # GENUS POWER INFRASTRUCTURES LIMITED
    0C-B3-19   # Samsung Electronics Co.,Ltd
    0C-B4-EF   # Digience Co.,Ltd.
    0C-B5-DE   # Alcatel Lucent
    0C-BC-9F   # Apple, Inc.
    0C-BD-51   # TCT Mobile Limited
    0C-BF-15   # Genetec Inc.
    0C-C0-C0   # MAGNETI MARELLI SISTEMAS ELECTRONICOS MEXICO
    0C-C3-A7   # Meritec
    0C-C4-7A   # Super Micro Computer, Inc.
    0C-C4-7E   # EUCAST Co., Ltd.
    0C-C6-55   # Wuxi YSTen Technology Co.,Ltd.
    0C-C6-6A   # Nokia Corporation
    0C-C6-AC   # DAGS
    0C-C7-31   # Currant, Inc.
    0C-C8-1F   # Summer Infant, Inc.
    0C-C9-C6   # Samwin Hong Kong Limited
    0C-CB-8D   # ASCO Numatics GmbH
    0C-CC-26   # Airenetworks
    0C-CD-D3   # EASTRIVER TECHNOLOGY CO., LTD.
    0C-CD-FB   # EDIC Systems Inc.
    0C-CF-D1   # SPRINGWAVE Co., Ltd
    0C-D2-92   # Intel Corporate
    0C-D2-B5   # Binatone Telecommunication Pvt. Ltd
    0C-D5-02   # Westell
    0C-D6-96   # Amimon Ltd
    0C-D6-BD   # HUAWEI TECHNOLOGIES CO.,LTD
    0C-D7-46   # Apple, Inc.
    0C-D7-C2   # Axium Technologies, Inc.
    0C-D9-96   # Cisco Systems, Inc
    0C-D9-C1   # Visteon Corporation
    0C-DA-41   # Hangzhou H3C Technologies Co., Limited
    0C-DC-CC   # Inala Technologies
    0C-DD-EF   # Nokia Corporation
    0C-DF-A4   # Samsung Electronics Co.,Ltd
    0C-E0-E4   # PLANTRONICS, INC.
    0C-E5-D3   # DH electronics GmbH
    0C-E7-09   # Fox Crypto B.V.
    0C-E7-25   # Microsoft Corporation
    0C-E8-2F   # Bonfiglioli Vectron GmbH
    0C-E9-36   # ELIMOS srl
    0C-EE-E6   # Hon Hai Precision Ind. Co.,Ltd.
    0C-EF-7C   # AnaCom Inc
    0C-EF-AF   # IEEE Registration Authority
    0C-F0-19   # Malgn Technology Co., Ltd.
    0C-F0-B4   # Globalsat International Technology Ltd
    0C-F3-61   # Java Information
    0C-F3-EE   # EM Microelectronic
    0C-F4-05   # Beijing Signalway Technologies Co.,Ltd
    0C-F5-A4   # Cisco Systems, Inc
    0C-F8-93   # ARRIS Group, Inc.
    0C-F9-C0   # BSkyB Ltd
    0C-FC-83   # Airoha Technology Corp.,
    0C-FD-37   # SUSE Linux GmbH
    0C-FE-45   # Sony Computer Entertainment Inc.
    10-00-00   # Private
    10-00-5A   # IBM Corp
    10-00-E8   # NATIONAL SEMICONDUCTOR
    10-00-FD   # LaonPeople
    10-01-CA   # Ashley Butterworth
    10-02-B5   # Intel Corporate
    10-05-B1   # ARRIS Group, Inc.
    10-05-CA   # Cisco Systems, Inc
    10-07-23   # IEEE Registration Authority
    10-08-B1   # Hon Hai Precision Ind. Co.,Ltd.
    10-09-0C   # Janome Sewing Machine Co., Ltd.
    10-0B-A9   # Intel Corporate
    10-0C-24   # pomdevices, LLC
    10-0D-2F   # Online Security Pty. Ltd.
    10-0D-32   # Embedian, Inc.
    10-0D-7F   # NETGEAR
    10-0E-2B   # NEC CASIO Mobile Communications
    10-0E-7E   # Juniper Networks
    10-0F-18   # Fu Gang Electronic(KunShan)CO.,LTD
    10-10-B6   # McCain Inc
    10-12-12   # Vivo International Corporation Pty Ltd
    10-12-18   # Korins Inc.
    10-12-48   # ITG, Inc.
    10-13-EE   # Justec International Technology INC.
    10-18-9E   # Elmo Motion Control
    10-1B-54   # HUAWEI TECHNOLOGIES CO.,LTD
    10-1C-0C   # Apple, Inc.
    10-1D-51   # ON-Q LLC dba ON-Q Mesh Networks
    10-1D-C0   # Samsung Electronics Co.,Ltd
    10-1F-74   # Hewlett Packard
    10-22-79   # ZeroDesktop, Inc.
    10-27-BE   # TVIP
    10-28-31   # Morion Inc.
    10-2A-B3   # Xiaomi Communications Co Ltd
    10-2C-83   # XIMEA
    10-2D-96   # Looxcie Inc.
    10-2E-AF   # Texas Instruments
    10-2F-6B   # Microsoft Corporation
    10-30-47   # Samsung Electronics Co.,Ltd
    10-33-78   # FLECTRON Co., LTD
    10-37-11   # Simlink AS
    10-3B-59   # Samsung Electronics Co.,Ltd
    10-3D-EA   # HFC Technology (Beijing) Ltd. Co.
    10-40-F3   # Apple, Inc.
    10-41-7F   # Apple, Inc.
    10-43-69   # Soundmax Electronic Limited
    10-44-5A   # Shaanxi Hitech Electronic Co., LTD
    10-45-BE   # Norphonic AS
    10-45-F8   # LNT-Automation GmbH
    10-47-80   # HUAWEI TECHNOLOGIES CO.,LTD
    10-48-B1   # Beijing Duokan Technology Limited
    10-4A-7D   # Intel Corporate
    10-4B-46   # Mitsubishi Electric Corporation
    10-4D-77   # Innovative Computer Engineering
    10-4E-07   # Shanghai Genvision Industries Co.,Ltd
    10-4F-A8   # Sony Computer Entertainment Inc.
    10-51-72   # HUAWEI TECHNOLOGIES CO.,LTD
    10-56-CA   # Peplink International Ltd.
    10-5C-3B   # Perma-Pipe, Inc.
    10-5C-BF   # DuroByte Inc
    10-5F-06   # Actiontec Electronics, Inc
    10-5F-49   # Cisco SPVTG
    10-60-4B   # Hewlett Packard
    10-62-C9   # Adatis GmbH & Co. KG
    10-64-E2   # ADFweb.com s.r.l.
    10-65-A3   # Core Brands LLC
    10-65-CF   # IQSIM
    10-66-82   # NEC Platforms, Ltd.
    10-68-3F   # LG Electronics
    10-6F-3F   # BUFFALO.INC
    10-6F-EF   # Ad-Sol Nissin Corp
    10-71-F9   # Cloud Telecomputers, LLC
    10-76-8A   # EoCell
    10-77-B1   # Samsung Electronics Co.,Ltd
    10-78-5B   # Actiontec Electronics, Inc
    10-78-73   # Shenzhen Jinkeyi Communication Co., Ltd.
    10-78-CE   # Hanvit SI, Inc.
    10-78-D2   # ELITEGROUP COMPUTER SYSTEM CO., LTD.
    10-7A-86   # U&U ENGINEERING INC.
    10-7B-EF   # ZyXEL Communications Corporation
    10-83-D2   # Microseven Systems, LLC
    10-86-8C   # ARRIS Group, Inc.
    10-88-0F   # Daruma Telecomunicações e Informática S.A.
    10-88-CE   # Fiberhome Telecommunication Tech.Co.,Ltd.
    10-8A-1B   # RAONIX Inc.
    10-8C-CF   # Cisco Systems, Inc
    10-92-66   # Samsung Electronics Co.,Ltd
    10-93-E9   # Apple, Inc.
    10-98-36   # Dell Inc.
    10-9A-B9   # Tosibox Oy
    10-9A-DD   # Apple, Inc.
    10-9F-A9   # Actiontec Electronics, Inc
    10-A1-3B   # FUJIKURA RUBBER LTD.
    10-A5-D0   # Murata Manufacturing Co., Ltd.
    10-A6-59   # Mobile Create Co.,Ltd.
    10-A7-43   # SK Mtek Limited
    10-A9-32   # Beijing Cyber Cloud Technology Co. ,Ltd.
    10-AE-60   # Private
    10-AF-78   # Shenzhen ATUE Technology Co., Ltd
    10-B2-6B   # base Co.,Ltd.
    10-B7-13   # Private
    10-B7-F6   # Plastoform Industries Ltd.
    10-B9-FE   # Lika srl
    10-BA-A5   # GANA I&C CO., LTD
    10-BD-18   # Cisco Systems, Inc
    10-BF-48   # ASUSTek COMPUTER INC.
    10-C0-7C   # Blu-ray Disc Association
    10-C2-BA   # UTT Co., Ltd.
    10-C3-7B   # ASUSTek COMPUTER INC.
    10-C5-86   # BIO SOUND LAB CO., LTD.
    10-C6-1F   # HUAWEI TECHNOLOGIES CO.,LTD
    10-C6-7E   # SHENZHEN JUCHIN TECHNOLOGY CO., LTD
    10-C6-FC   # Garmin International
    10-C7-3F   # Midas Klark Teknik Ltd
    10-CA-81   # PRECIA
    10-CC-1B   # Liverock technologies,INC
    10-CC-DB   # AXIMUM PRODUITS ELECTRONIQUES
    10-CD-AE   # Avaya Inc
    10-D1-DC   # INSTAR Deutschland GmbH
    10-D3-8A   # Samsung Electronics Co.,Ltd
    10-D5-42   # Samsung Electronics Co.,Ltd
    10-DD-B1   # Apple, Inc.
    10-DD-F4   # Maxway Electronics CO.,LTD
    10-DE-E4   # automationNEXT GmbH
    10-DF-8B   # Shenzhen CareDear Communication Technology Co.,Ltd
    10-E2-D5   # Qi Hardware Inc.
    10-E3-C7   # Seohwa Telecom
    10-E4-AF   # APR, LLC
    10-E6-AE   # Source Technologies, LLC
    10-E8-78   # Alcatel-Lucent
    10-E8-EE   # PhaseSpace
    10-EA-59   # Cisco SPVTG
    10-EE-D9   # Canoga Perkins Corporation
    10-F3-11   # Cisco Systems, Inc
    10-F3-DB   # Gridco Systems, Inc.
    10-F4-9A   # T3 Innovation
    10-F6-81   # vivo Mobile Communication Co., Ltd.
    10-F9-6F   # LG Electronics
    10-F9-EE   # Nokia Corporation
    10-FA-CE   # Reacheng Communication Technology Co.,Ltd
    10-FB-F0   # KangSheng LTD.
    10-FC-54   # Shany Electronic Co., Ltd.
    10-FE-ED   # TP-LINK TECHNOLOGIES CO.,LTD.
    11-00-AA   # Private
    11-11-11   # Private
    14-02-EC   # Hewlett Packard Enterprise
    14-04-67   # SNK Technologies Co.,Ltd.
    14-07-08   # Private
    14-07-E0   # Abrantix AG
    14-0C-76   # FREEBOX SAS
    14-0D-4F   # Flextronics International
    14-10-9F   # Apple, Inc.
    14-13-30   # Anakreon UK LLP
    14-13-57   # ATP Electronics, Inc.
    14-14-4B   # FUJIAN STAR-NET COMMUNICATION CO.,LTD
    14-15-7C   # TOKYO COSMOS ELECTRIC CO.,LTD.
    14-18-77   # Dell Inc.
    14-1A-51   # Treetech Sistemas Digitais
    14-1A-A3   # Motorola Mobility LLC, a Lenovo Company
    14-1B-BD   # Volex Inc.
    14-1B-F0   # Intellimedia Systems Ltd
    14-1F-BA   # IEEE Registration Authority
    14-22-DB   # eero inc.
    14-23-D7   # EUTRONIX CO., LTD.
    14-29-71   # NEMOA ELECTRONICS (HK) CO. LTD
    14-2B-D2   # Armtel Ltd.
    14-2B-D6   # Guangdong Appscomm Co.,Ltd
    14-2D-27   # Hon Hai Precision Ind. Co.,Ltd.
    14-2D-8B   # Incipio Technologies, Inc
    14-2D-F5   # Amphitech
    14-30-7A   # Avermetrics
    14-30-C6   # Motorola Mobility LLC, a Lenovo Company
    14-32-D1   # Samsung Electronics Co.,Ltd
    14-35-8B   # Mediabridge Products, LLC.
    14-35-B3   # Future Designs, Inc.
    14-36-05   # Nokia Corporation
    14-36-C6   # Lenovo Mobile Communication Technology Ltd.
    14-37-3B   # PROCOM Systems
    14-3A-EA   # Dynapower Company LLC
    14-3D-F2   # Beijing Shidai Hongyuan Network Communication Co.,Ltd
    14-3E-60   # Alcatel-Lucent
    14-3E-BF   # zte corporation
    14-41-46   # Honeywell (China) Co., LTD
    14-41-E2   # Monaco Enterprises, Inc.
    14-43-19   # Creative&Link Technology Limited
    14-46-E4   # AVISTEL
    14-48-8B   # Shenzhen Doov Technology Co.,Ltd
    14-49-78   # Digital Control Incorporated
    14-49-E0   # Samsung Electro Mechanics co.,LTD.
    14-4C-1A   # Max Communication GmbH
    14-54-12   # Entis Co., Ltd.
    14-56-45   # Savitech Corp.
    14-58-D0   # Hewlett Packard
    14-5A-05   # Apple, Inc.
    14-5A-83   # Logi-D inc
    14-5B-D1   # ARRIS Group, Inc.
    14-60-80   # zte corporation
    14-63-08   # JABIL CIRCUIT (SHANGHAI) LTD.
    14-6A-0B   # Cypress Electronics Limited
    14-6B-72   # Shenzhen Fortune Ship Technology Co., Ltd.
    14-6E-0A   # Private
    14-73-73   # TUBITAK UEKAE
    14-74-11   # RIM
    14-75-90   # TP-LINK TECHNOLOGIES CO.,LTD.
    14-7D-B3   # JOA TELECOM.CO.,LTD
    14-7D-C5   # Murata Manufacturing Co., Ltd.
    14-82-5B   # Hefei Radio Communication Technology Co., Ltd
    14-86-92   # TP-LINK TECHNOLOGIES CO.,LTD.
    14-89-3E   # VIXTEL TECHNOLOGIES LIMTED
    14-89-FD   # Samsung Electronics
    14-8A-70   # ADS GmbH
    14-8F-21   # Garmin International
    14-8F-C6   # Apple, Inc.
    14-90-90   # KongTop industrial(shen zhen)CO.,LTD
    14-91-82   # Belkin International Inc.
    14-94-48   # BLU CASTLE S.A.
    14-99-E2   # Apple, Inc.
    14-9A-10   # Microsoft Corporation
    14-9F-E8   # Lenovo Mobile Communication Technology Ltd.
    14-A3-64   # Samsung Electronics Co.,Ltd
    14-A6-2C   # S.M. Dezac S.A.
    14-A8-6B   # ShenZhen Telacom Science&Technology Co., Ltd
    14-A9-E3   # MST CORPORATION
    14-AB-F0   # ARRIS Group, Inc.
    14-AE-DB   # VTech Telecommunications Ltd.
    14-B1-26   # Industrial Software Co
    14-B1-C8   # InfiniWing, Inc.
    14-B3-70   # Gigaset Digital Technology (Shenzhen) Co., Ltd.
    14-B4-84   # Samsung Electronics Co.,Ltd
    14-B7-3D   # ARCHEAN Technologies
    14-B9-68   # HUAWEI TECHNOLOGIES CO.,LTD
    14-BB-6E   # Samsung Electronics Co.,Ltd
    14-C0-89   # DUNE HD LTD
    14-C1-26   # Nokia Corporation
    14-C2-1D   # Sabtech Industries
    14-C3-C2   # K.A. Schmersal GmbH & Co. KG
    14-CC-20   # TP-LINK TECHNOLOGIES CO.,LTD.
    14-CF-8D   # OHSUNG ELECTRONICS CO., LTD.
    14-CF-92   # TP-LINK TECHNOLOGIES CO.,LTD.
    14-CF-E2   # ARRIS Group, Inc.
    14-D4-FE   # Pace plc
    14-D6-4D   # D-Link International
    14-D7-6E   # CONCH ELECTRONIC Co.,Ltd
    14-DA-E9   # ASUSTek COMPUTER INC.
    14-DB-85   # S NET MEDIA
    14-DD-A9   # ASUSTek COMPUTER INC.
    14-E4-EC   # mLogic LLC
    14-E6-E4   # TP-LINK TECHNOLOGIES CO.,LTD.
    14-EB-33   # BSMediasoft Co., Ltd.
    14-ED-A5   # Wächter GmbH Sicherheitssysteme
    14-ED-E4   # Kaiam Corporation
    14-EE-9D   # AirNav Systems LLC
    14-F0-C5   # Xtremio Ltd.
    14-F2-8E   # ShenYang ZhongKe-Allwin Technology Co.LTD
    14-F4-2A   # Samsung Electronics
    14-F6-5A   # Xiaomi Communications Co Ltd
    14-F8-93   # Wuhan FiberHome Digital Technology Co.,Ltd.
    14-FE-AF   # SAGITTAR LIMITED
    14-FE-B5   # Dell Inc.
    18-00-2D   # Sony Mobile Communications AB
    18-00-DB   # Fitbit Inc.
    18-01-7D   # Harbin Arteor technology co., LTD
    18-01-E3   # Bittium Wireless Ltd
    18-03-73   # Dell Inc.
    18-03-FA   # IBT Interfaces
    18-06-75   # DILAX Intelcom GmbH
    18-0B-52   # Nanotron Technologies GmbH
    18-0C-14   # iSonea Limited
    18-0C-77   # Westinghouse Electric Company, LLC
    18-0C-AC   # CANON INC.
    18-10-4E   # CEDINT-UPM
    18-14-20   # TEB SAS
    18-14-56   # Nokia Corporation
    18-16-C9   # Samsung Electronics Co.,Ltd
    18-17-14   # DAEWOOIS
    18-17-25   # Cameo Communications, Inc.
    18-19-3F   # Tamtron Oy
    18-1B-EB   # Actiontec Electronics, Inc
    18-1E-78   # Sagemcom Broadband SAS
    18-1E-B0   # Samsung Electronics Co.,Ltd
    18-20-12   # Aztech Associates Inc.
    18-20-32   # Apple, Inc.
    18-20-A6   # Sage Co., Ltd.
    18-22-7E   # Samsung Electronics Co.,Ltd
    18-26-66   # Samsung Electronics Co.,Ltd
    18-28-61   # AirTies Wireless Netowrks
    18-2A-7B   # Nintendo Co., Ltd.
    18-2B-05   # 8D Technologies
    18-2C-91   # Concept Development, Inc.
    18-30-09   # Woojin Industrial Systems Co., Ltd.
    18-32-A2   # LAON TECHNOLOGY CO., LTD.
    18-33-9D   # Cisco Systems, Inc
    18-34-51   # Apple, Inc.
    18-36-FC   # Elecsys International Corporation
    18-38-25   # Wuhan Lingjiu High-tech Co.,Ltd.
    18-38-64   # CAP-TECH INTERNATIONAL CO., LTD.
    18-39-19   # Unicoi Systems
    18-3A-2D   # Samsung Electronics Co.,Ltd
    18-3B-D2   # BYD Precision Manufacture Company Ltd.
    18-3D-A2   # Intel Corporate
    18-3F-47   # Samsung Electronics Co.,Ltd
    18-42-1D   # Private
    18-42-2F   # Alcatel Lucent
    18-44-62   # Riava Networks, Inc.
    18-44-E6   # zte corporation
    18-46-17   # Samsung Electronics
    18-48-D8   # Fastback Networks
    18-4A-6F   # Alcatel-Lucent Shanghai Bell Co., Ltd
    18-4E-94   # MESSOA TECHNOLOGIES INC.
    18-4F-32   # Hon Hai Precision Ind. Co.,Ltd.
    18-52-53   # Pixord Corporation
    18-53-E0   # Hanyang Digitech Co.Ltd
    18-55-0F   # Cisco SPVTG
    18-59-33   # Cisco SPVTG
    18-59-36   # Xiaomi Communications Co Ltd
    18-5A-E8   # Zenotech.Co.,Ltd
    18-5D-9A   # BobjGear LLC
    18-5E-0F   # Intel Corporate
    18-62-2C   # Sagemcom Broadband SAS
    18-64-72   # Aruba Networks
    18-65-71   # Top Victory Electronics (Taiwan) Co., Ltd.
    18-66-E3   # Veros Systems, Inc.
    18-67-3F   # Hanover Displays Limited
    18-67-51   # KOMEG Industrielle Messtechnik GmbH
    18-67-B0   # Samsung Electronics Co.,Ltd
    18-68-6A   # zte corporation
    18-68-82   # Beward R&D Co., Ltd.
    18-6D-99   # Adanis Inc.
    18-71-17   # eta plus electronic gmbh
    18-79-A2   # GMJ ELECTRIC LIMITED
    18-7A-93   # AMICCOM Electronics Corporation
    18-7C-81   # Valeo Vision Systems
    18-7E-D5   # shenzhen kaism technology Co. Ltd
    18-80-CE   # Barberry Solutions Ltd
    18-80-F5   # Alcatel-Lucent Shanghai Bell Co., Ltd
    18-82-19   # Alibaba Cloud Computing Ltd.
    18-83-31   # Samsung Electronics Co.,Ltd
    18-83-BF   # Arcadyan Technology Corporation
    18-84-10   # CoreTrust Inc.
    18-86-3A   # DIGITAL ART SYSTEM
    18-86-AC   # Nokia Danmark A/S
    18-87-96   # HTC Corporation
    18-88-57   # Beijing Jinhong Xi-Dian Information Technology Corp.
    18-89-5B   # Samsung Electronics Co.,Ltd
    18-89-DF   # CerebrEX Inc.
    18-8B-45   # Cisco Systems, Inc
    18-8B-9D   # Cisco Systems, Inc
    18-8E-D5   # TP Vision Belgium N.V. - innovation site Brugge
    18-8E-F9   # G2C Co. Ltd.
    18-92-2C   # Virtual Instruments
    18-97-FF   # TechFaith Wireless Technology Limited
    18-9A-67   # CSE-Servelec Limited
    18-9C-5D   # Cisco Systems, Inc
    18-9E-FC   # Apple, Inc.
    18-A3-E8   # Fiberhome Telecommunication Tech.Co.,Ltd.
    18-A6-F7   # TP-LINK TECHNOLOGIES CO.,LTD.
    18-A9-05   # Hewlett Packard
    18-A9-58   # PROVISION THAI CO., LTD.
    18-A9-9B   # Dell Inc.
    18-AA-45   # Fon Technology
    18-AB-F5   # Ultra Electronics - Electrics
    18-AD-4D   # Polostar Technology Corporation
    18-AE-BB   # Siemens Convergence Creators GmbH&Co.KG
    18-AF-61   # Apple, Inc.
    18-AF-8F   # Apple, Inc.
    18-AF-9F   # DIGITRONIC Automationsanlagen GmbH
    18-B1-69   # Sonicwall
    18-B2-09   # Torrey Pines Logic, Inc
    18-B3-BA   # Netlogic AB
    18-B4-30   # Nest Labs Inc.
    18-B5-91   # I-Storm
    18-B7-9E   # Invoxia
    18-BD-AD   # L-TECH CORPORATION
    18-C0-86   # Broadcom
    18-C4-51   # Tucson Embedded Systems
    18-C5-8A   # HUAWEI TECHNOLOGIES CO.,LTD
    18-C8-E7   # Shenzhen Hualistone Technology Co.,Ltd
    18-CC-23   # Philio Technology Corporation
    18-CF-5E   # Liteon Technology Corporation
    18-D0-71   # DASAN CO., LTD.
    18-D5-B6   # SMG Holdings LLC
    18-D6-6A   # Inmarsat
    18-D6-CF   # Kurth Electronic GmbH
    18-D9-49   # Qvis Labs, LLC
    18-DC-56   # Yulong Computer Telecommunication Scientific(shenzhen)Co.,Lt
    18-E2-88   # STT Condigi
    18-E2-C2   # Samsung Electronics
    18-E3-BC   # TCT mobile ltd
    18-E7-28   # Cisco Systems, Inc
    18-E7-F4   # Apple, Inc.
    18-E8-0F   # Viking Electronics Inc.
    18-E8-DD   # MODULETEK
    18-EE-69   # Apple, Inc.
    18-EF-63   # Cisco Systems, Inc
    18-F1-45   # NetComm Wireless Limited
    18-F4-6A   # Hon Hai Precision Ind. Co.,Ltd.
    18-F6-43   # Apple, Inc.
    18-F6-50   # Multimedia Pacific Limited
    18-F8-7A   # i3 International Inc.
    18-FA-6F   # ISC applied systems corp
    18-FB-7B   # Dell Inc.
    18-FC-9F   # Changhe Electronics Co., Ltd.
    18-FE-34   # Espressif Inc.
    18-FF-0F   # Intel Corporate
    18-FF-2E   # Shenzhen Rui Ying Da Technology Co., Ltd
    1C-06-56   # IDY Corporation
    1C-08-C1   # Lg Innotek
    1C-0B-52   # EPICOM S.A
    1C-0F-CF   # Sypro Optics GmbH
    1C-11-E1   # Wartsila Finland Oy
    1C-12-9D   # IEEE PES PSRC/SUB
    1C-14-48   # ARRIS Group, Inc.
    1C-14-B3   # Pinyon Technologies
    1C-17-D3   # Cisco Systems, Inc
    1C-18-4A   # ShenZhen RicherLink Technologies Co.,LTD
    1C-19-DE   # eyevis GmbH
    1C-1A-C0   # Apple, Inc.
    1C-1B-68   # ARRIS Group, Inc.
    1C-1C-FD   # Dalian Hi-Think Computer Technology, Corp
    1C-1D-67   # HUAWEI TECHNOLOGIES CO.,LTD
    1C-1D-86   # Cisco Systems, Inc
    1C-21-D1   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    1C-23-4F   # EDMI  Europe Ltd
    1C-33-4D   # ITS Telecom
    1C-34-77   # Innovation Wireless
    1C-35-F1   # NEW Lift Neue Elektronische Wege Steuerungsbau GmbH
    1C-37-BF   # Cloudium Systems Ltd.
    1C-39-47   # COMPAL INFORMATION (KUNSHAN) CO., LTD.
    1C-3A-4F   # AccuSpec Electronics, LLC
    1C-3D-E7   # Sigma Koki Co.,Ltd.
    1C-3E-84   # Hon Hai Precision Ind. Co.,Ltd.
    1C-40-24   # Dell Inc.
    1C-41-58   # Gemalto M2M GmbH
    1C-43-EC   # JAPAN CIRCUIT CO.,LTD
    1C-44-19   # TP-LINK TECHNOLOGIES CO.,LTD.
    1C-45-93   # Texas Instruments
    1C-48-40   # IMS Messsysteme GmbH
    1C-48-F9   # GN Netcom A/S
    1C-49-7B   # Gemtek Technology Co., Ltd.
    1C-4A-F7   # AMON INC
    1C-4B-B9   # SMG ENTERPRISE, LLC
    1C-4B-D6   # AzureWave Technology Inc.
    1C-51-B5   # Techaya LTD
    1C-52-16   # DONGGUAN HELE ELECTRONICS CO., LTD
    1C-52-D6   # FLAT DISPLAY TECHNOLOGY CORPORATION
    1C-56-FE   # Motorola Mobility LLC, a Lenovo Company
    1C-5A-3E   # Samsung Eletronics Co., Ltd (Visual Display Divison)
    1C-5A-6B   # Philips Electronics Nederland BV
    1C-5C-55   # PRIMA Cinema, Inc
    1C-5C-60   # Shenzhen Belzon Technology Co.,LTD.
    1C-5C-F2   # Apple, Inc.
    1C-5F-FF   # Beijing Ereneben Information Technology Co.,Ltd Shenzhen Branch
    1C-60-DE   # SHENZHEN MERCURY COMMUNICATION TECHNOLOGIES CO.,LTD.
    1C-62-B8   # Samsung Electronics Co.,Ltd
    1C-63-B7   # OpenProducts 237 AB
    1C-65-9D   # Liteon Technology Corporation
    1C-66-6D   # Hon Hai Precision Ind. Co.,Ltd.
    1C-66-AA   # Samsung Electronics
    1C-69-A5   # BlackBerry RTS
    1C-6A-7A   # Cisco Systems, Inc
    1C-6B-CA   # Mitsunami Co., Ltd.
    1C-6E-4C   # Logistic Service & Engineering Co.,Ltd
    1C-6F-65   # GIGA-BYTE TECHNOLOGY CO.,LTD.
    1C-75-08   # COMPAL INFORMATION (KUNSHAN) CO., LTD.
    1C-76-CA   # Terasic Technologies Inc.
    1C-78-39   # Shenzhen Tencent Computer System Co., Ltd.
    1C-7B-21   # Sony Mobile Communications AB
    1C-7C-11   # EID
    1C-7C-45   # Vitek Industrial Video Products, Inc.
    1C-7C-C7   # Coriant GmbH
    1C-7D-22   # Fuji Xerox Co., Ltd.
    1C-7E-51   # 3bumen.com
    1C-7E-E5   # D-Link International
    1C-83-41   # Hefei Bitland Information Technology Co.Ltd
    1C-83-B0   # Linked IP GmbH
    1C-84-64   # FORMOSA WIRELESS COMMUNICATION CORP.
    1C-86-AD   # MCT CO., LTD.
    1C-87-2C   # ASUSTek COMPUTER INC.
    1C-8E-5C   # HUAWEI TECHNOLOGIES CO.,LTD
    1C-8E-8E   # DB Communication & Systems Co., ltd.
    1C-8F-8A   # Phase Motion Control SpA
    1C-91-79   # Integrated System Technologies Ltd
    1C-94-92   # RUAG Schweiz AG
    1C-95-5D   # I-LAX ELECTRONICS INC.
    1C-95-9F   # Veethree Electronics And Marine LLC
    1C-96-5A   # Weifang goertek Electronics CO.,LTD
    1C-97-3D   # PRICOM Design
    1C-99-4C   # Murata Manufacturing Co., Ltd.
    1C-9C-26   # Zoovel Technologies
    1C-9E-46   # Apple, Inc.
    1C-9E-CB   # Beijing Nari Smartchip Microelectronics Company Limited
    1C-A2-B1   # ruwido austria gmbh
    1C-A5-32   # Shenzhen Gongjin Electronics Co.,Ltd
    1C-A7-70   # SHENZHEN CHUANGWEI-RGB ELECTRONICS CO.,LTD
    1C-AA-07   # Cisco Systems, Inc
    1C-AB-01   # Innovolt
    1C-AB-A7   # Apple, Inc.
    1C-AD-D1   # Bosung Electronics Co., Ltd.
    1C-AF-05   # Samsung Electronics Co.,Ltd
    1C-AF-F7   # D-Link International
    1C-B0-94   # HTC Corporation
    1C-B1-7F   # NEC Platforms, Ltd.
    1C-B2-43   # TDC A/S
    1C-B7-2C   # ASUSTek COMPUTER INC.
    1C-BA-8C   # Texas Instruments
    1C-BB-A8   # OJSC Ufimskiy Zavod Promsvyaz
    1C-BD-0E   # Amplified Engineering Pty Ltd
    1C-BD-B9   # D-Link International
    1C-C1-1A   # Wavetronix
    1C-C1-DE   # Hewlett Packard
    1C-C3-16   # MileSight Technology Co., Ltd.
    1C-C5-86   # Absolute Acoustics
    1C-C6-3C   # Arcadyan Technology Corporation
    1C-C7-2D   # Shenzhen Huapu Digital CO.,Ltd
    1C-CA-E3   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    1C-CB-99   # TCT mobile ltd
    1C-CD-E5   # Shanghai Wind Technologies Co.,Ltd
    1C-D4-0C   # Kriwan Industrie-Elektronik GmbH
    1C-DE-A7   # Cisco Systems, Inc
    1C-DF-0F   # Cisco Systems, Inc
    1C-E1-65   # Marshal Corporation
    1C-E1-92   # Qisda Corporation
    1C-E2-CC   # Texas Instruments
    1C-E6-2B   # Apple, Inc.
    1C-E6-C7   # Cisco Systems, Inc
    1C-E8-5D   # Cisco Systems, Inc
    1C-EE-E8   # Ilshin Elecom
    1C-F0-3E   # Wearhaus Inc.
    1C-F0-61   # SCAPS GmbH
    1C-F4-CA   # Private
    1C-F5-E7   # Turtle Industry Co., Ltd.
    1C-FA-68   # TP-LINK TECHNOLOGIES CO.,LTD.
    1C-FC-BB   # Realfiction ApS
    1C-FE-A7   # IDentytech Solutins Ltd.
    20-01-4F   # Linea Research Ltd
    20-02-AF   # Murata Manufacturing Co., Ltd.
    20-05-05   # RADMAX COMMUNICATION PRIVATE LIMITED
    20-05-E8   # OOO InProMedia
    20-08-ED   # HUAWEI TECHNOLOGIES CO.,LTD
    20-0A-5E   # Xiangshan Giant Eagle Technology Developing co.,LTD
    20-0B-C7   # HUAWEI TECHNOLOGIES CO.,LTD
    20-0C-C8   # NETGEAR
    20-0E-95   # IEC – TC9 WG43
    20-10-7A   # Gemtek Technology Co., Ltd.
    20-12-57   # Most Lucky Trading Ltd
    20-12-D5   # Scientech Materials Corporation
    20-13-E0   # Samsung Electronics Co.,Ltd
    20-16-D8   # Liteon Technology Corporation
    20-18-0E   # Shenzhen Sunchip Technology Co., Ltd
    20-1A-06   # COMPAL INFORMATION (KUNSHAN) CO., LTD.
    20-1D-03   # Elatec GmbH
    20-21-A5   # LG Electronics Inc
    20-25-64   # PEGATRON CORPORATION
    20-25-98   # Teleview
    20-28-BC   # Visionscape Co,. Ltd.
    20-2B-C1   # HUAWEI TECHNOLOGIES CO.,LTD
    20-2C-B7   # Kong Yue Electronics & Information Industry (Xinhui) Ltd.
    20-31-EB   # HDSN
    20-37-06   # Cisco Systems, Inc
    20-37-BC   # Kuipers Electronic Engineering BV
    20-3A-07   # Cisco Systems, Inc
    20-3D-66   # ARRIS Group, Inc.
    20-40-05   # feno GmbH
    20-41-5A   # Smarteh d.o.o.
    20-44-3A   # Schneider Electric Asia Pacific Ltd
    20-46-A1   # VECOW Co., Ltd
    20-46-F9   # Advanced Network Devices (dba:AND)
    20-47-47   # Dell Inc.
    20-4A-AA   # Hanscan Spain S.A.
    20-4C-6D   # Hugo Brennenstuhl Gmbh & Co. KG.
    20-4C-9E   # Cisco Systems, Inc
    20-4E-6B   # Axxana(israel) ltd
    20-4E-71   # Juniper Networks
    20-4E-7F   # NETGEAR
    20-53-CA   # Risk Technology Ltd
    20-54-76   # Sony Mobile Communications AB
    20-55-31   # Samsung Electronics Co.,Ltd
    20-55-32   # Gotech International Technology Limited
    20-57-21   # Salix Technology CO., Ltd.
    20-59-A0   # Paragon Technologies Inc.
    20-5A-00   # Coval
    20-5B-2A   # Private
    20-5B-5E   # Shenzhen Wonhe Technology Co., Ltd
    20-5C-FA   # Yangzhou ChangLian Network Technology Co,ltd.
    20-62-74   # Microsoft Corporation
    20-63-5F   # Abeeway
    20-64-32   # SAMSUNG ELECTRO MECHANICS CO.,LTD.
    20-67-B1   # Pluto inc.
    20-68-9D   # Liteon Technology Corporation
    20-6A-8A   # Wistron InfoComm Manufacturing(Kunshan)Co.,Ltd.
    20-6A-FF   # Atlas Elektronik UK Limited
    20-6E-9C   # Samsung Electronics Co.,Ltd
    20-6F-EC   # Braemac CA LLC
    20-73-55   # ARRIS Group, Inc.
    20-74-CF   # Shenzhen Voxtech Co.,Ltd
    20-76-00   # Actiontec Electronics, Inc
    20-76-8F   # Apple, Inc.
    20-76-93   # Lenovo (Beijing) Limited.
    20-78-F0   # Apple, Inc.
    20-7C-8F   # Quanta Microsystems,Inc.
    20-7D-74   # Apple, Inc.
    20-82-C0   # Xiaomi Communications Co Ltd
    20-85-8C   # Assa
    20-87-AC   # AES motomation
    20-89-6F   # Fiberhome Telecommunication Technologies Co.,LTD
    20-89-84   # COMPAL INFORMATION (KUNSHAN) CO., LTD.
    20-89-86   # zte corporation
    20-90-6F   # Shenzhen Tencent Computer System Co., Ltd.
    20-91-48   # Texas Instruments
    20-91-8A   # PROFALUX
    20-91-D9   # I'M SPA
    20-93-4D   # FUJIAN STAR-NET COMMUNICATION CO.,LTD
    20-9A-E9   # Volacomm Co., Ltd
    20-9B-A5   # JIAXING GLEAD Electronics Co.,Ltd
    20-9B-CD   # Apple, Inc.
    20-A2-E4   # Apple, Inc.
    20-A2-E7   # Lee-Dickens Ltd
    20-A7-83   # miControl GmbH
    20-A7-87   # Bointec Taiwan Corporation Limited
    20-A9-9B   # Microsoft Corporation
    20-AA-25   # IP-NET LLC
    20-AA-4B   # Cisco-Linksys, LLC
    20-B0-F7   # Enclustra GmbH
    20-B3-99   # Enterasys
    20-B5-C6   # Mimosa Networks
    20-B7-C0   # OMICRON electronics GmbH
    20-BB-76   # COL GIOVANNI PAOLO SpA
    20-BB-C0   # Cisco Systems, Inc
    20-BB-C6   # Jabil Circuit Hungary Ltd.
    20-BF-DB   # DVL
    20-C0-6D   # SHENZHEN SPACETEK TECHNOLOGY CO.,LTD
    20-C1-AF   # i Wit Digital Co., Limited
    20-C3-8F   # Texas Instruments
    20-C3-A4   # RetailNext
    20-C6-0D   # Shanghai annijie Information technology Co.,LTD
    20-C6-EB   # Panasonic Corporation AVC Networks Company
    20-C8-B3   # SHENZHEN BUL-TECH CO.,LTD.
    20-C9-D0   # Apple, Inc.
    20-CD-39   # Texas Instruments
    20-CE-C4   # Peraso Technologies
    20-CF-30   # ASUSTek COMPUTER INC.
    20-D1-60   # Private
    20-D2-1F   # Wincal Technology Corp.
    20-D3-90   # Samsung Electronics Co.,Ltd
    20-D5-AB   # Korea Infocom Co.,Ltd.
    20-D5-BF   # Samsung Eletronics Co., Ltd
    20-D6-07   # Nokia Corporation
    20-D7-5A   # Posh Mobile Limited
    20-D9-06   # Iota, Inc.
    20-DC-93   # Cheetah Hi-Tech, Inc.
    20-DC-E6   # TP-LINK TECHNOLOGIES CO.,LTD.
    20-DF-3F   # Nanjing SAC Power Grid Automation Co., Ltd.
    20-E4-07   # Spark srl
    20-E5-2A   # NETGEAR
    20-E5-64   # ARRIS Group, Inc.
    20-E7-91   # Siemens Healthcare Diagnostics, Inc
    20-EA-C7   # SHENZHEN RIOPINE ELECTRONICS CO., LTD
    20-ED-74   # Ability enterprise co.,Ltd.
    20-EE-C6   # Elefirst Science & Tech Co ., ltd
    20-F0-02   # MTData Developments Pty. Ltd.
    20-F3-A3   # HUAWEI TECHNOLOGIES CO.,LTD
    20-F4-1B   # Shenzhen Bilian electronic CO.,LTD
    20-F5-10   # Codex Digital Limited
    20-F8-5E   # Delta Electronics
    20-FA-BB   # Cambridge Executive Limited
    20-FD-F1   # 3COM EUROPE LTD
    20-FE-CD   # System In Frontier Inc.
    20-FE-DB   # M2M Solution S.A.S.
    24-00-BA   # HUAWEI TECHNOLOGIES CO.,LTD
    24-01-C7   # Cisco Systems, Inc
    24-05-0F   # MTN Electronic Co. Ltd
    24-05-F5   # Integrated Device Technology (Malaysia) Sdn. Bhd.
    24-09-17   # Devlin Electronics Limited
    24-09-95   # HUAWEI TECHNOLOGIES CO.,LTD
    24-0A-11   # TCT Mobile Limited
    24-0A-64   # AzureWave Technology Inc.
    24-0B-0A   # Palo Alto Networks
    24-0B-2A   # Viettel Group
    24-0B-B1   # KOSTAL Industrie Elektrik GmbH
    24-10-64   # Shenzhen Ecsino Tecnical Co. Ltd
    24-11-25   # Hutek Co., Ltd.
    24-11-48   # Entropix, LLC
    24-11-D0   # Chongqing Ehs Science and Technology Development Co.,Ltd.
    24-1A-8C   # Squarehead Technology AS
    24-1B-13   # Shanghai Nutshell Electronic Co., Ltd.
    24-1B-44   # Hangzhou Tuners Electronics Co., Ltd
    24-1C-04   # SHENZHEN JEHE TECHNOLOGY DEVELOPMENT CO., LTD.
    24-1E-EB   # Apple, Inc.
    24-1F-2C   # Calsys, Inc.
    24-1F-A0   # HUAWEI TECHNOLOGIES CO.,LTD
    24-21-AB   # Sony Mobile Communications AB
    24-24-0E   # Apple, Inc.
    24-26-42   # SHARP Corporation.
    24-2F-FA   # Toshiba Global Commerce Solutions
    24-31-84   # SHARP Corporation
    24-33-6C   # Private
    24-35-CC   # Zhongshan Scinan Internet of Things Co.,Ltd.
    24-37-4C   # Cisco SPVTG
    24-37-EF   # EMC Electronic Media Communication SA
    24-3C-20   # Dynamode Group
    24-42-BC   # Alinco,incorporated
    24-45-97   # GEMUE Gebr. Mueller Apparatebau
    24-47-0E   # PentronicAB
    24-49-7B   # Innovative Converged Devices Inc
    24-4B-03   # Samsung Electronics Co.,Ltd
    24-4B-81   # Samsung Electronics Co.,Ltd
    24-4F-1D   # iRule LLC
    24-5B-F0   # Liteon, Inc.
    24-5F-DF   # KYOCERA Corporation
    24-60-81   # razberi technologies
    24-62-78   # sysmocom - systems for mobile communications GmbH
    24-64-EF   # CYG SUNRI CO.,LTD.
    24-65-11   # AVM GmbH
    24-69-3E   # innodisk Corporation
    24-69-4A   # Jasmine Systems Inc.
    24-69-68   # TP-LINK TECHNOLOGIES CO.,LTD.
    24-69-A5   # HUAWEI TECHNOLOGIES CO.,LTD
    24-6A-AB   # IT-IS International
    24-6C-8A   # YUKAI Engineering
    24-6E-96   # Dell Inc.
    24-71-89   # Texas Instruments
    24-72-60   # IOTTECH Corp
    24-76-56   # Shanghai Net Miles Fiber Optics Technology Co., LTD.
    24-76-7D   # Cisco SPVTG
    24-77-03   # Intel Corporate
    24-7C-4C   # Herman Miller
    24-7F-3C   # HUAWEI TECHNOLOGIES CO.,LTD
    24-80-00   # Westcontrol AS
    24-81-AA   # KSH International Co., Ltd.
    24-82-8A   # Prowave Technologies Ltd.
    24-86-F4   # Ctek, Inc.
    24-87-07   # SEnergy Corporation
    24-93-CA   # Voxtronic Technology Computer-Systeme GmbH
    24-94-42   # OPEN ROAD SOLUTIONS , INC.
    24-95-04   # SFR
    24-97-ED   # Techvision Intelligent Technology Limited
    24-9E-AB   # HUAWEI TECHNOLOGIES CO.,LTD
    24-A0-74   # Apple, Inc.
    24-A2-E1   # Apple, Inc.
    24-A4-2C   # KOUKAAM a.s.
    24-A4-3C   # Ubiquiti Networks, INC
    24-A4-95   # Thales Canada Inc.
    24-A8-7D   # Panasonic Automotive Systems Asia Pacific(Thailand)Co.,Ltd.
    24-A9-37   # PURE Storage
    24-AB-81   # Apple, Inc.
    24-AF-4A   # Alcatel-Lucent-IPD
    24-AF-54   # NEXGEN Mediatech Inc.
    24-B0-A9   # Shanghai Mobiletek Communication Ltd.
    24-B6-57   # Cisco Systems, Inc
    24-B6-B8   # FRIEM SPA
    24-B6-FD   # Dell Inc.
    24-B8-8C   # Crenus Co.,Ltd.
    24-B8-D2   # Opzoon Technology Co.,Ltd.
    24-BA-13   # RISO KAGAKU CORPORATION
    24-BA-30   # Technical Consumer Products, Inc.
    24-BB-C1   # Absolute Analysis
    24-BC-82   # Dali Wireless, Inc.
    24-BE-05   # Hewlett Packard
    24-BF-74   # Private
    24-C0-B3   # RSF
    24-C6-96   # Samsung Electronics Co.,Ltd
    24-C8-48   # mywerk system GmbH
    24-C8-6E   # Chaney Instrument Co.
    24-C9-A1   # Ruckus Wireless
    24-C9-DE   # Genoray
    24-CB-E7   # MYK, Inc.
    24-CF-21   # Shenzhen State Micro Technology Co., Ltd
    24-D1-3F   # MEXUS CO.,LTD
    24-D2-CC   # SmartDrive Systems Inc.
    24-D9-21   # Avaya Inc
    24-DA-11   # NO NDA Inc
    24-DA-9B   # Motorola Mobility LLC, a Lenovo Company
    24-DA-B6   # Sistemas de Gestión Energética S.A. de C.V
    24-DB-AC   # HUAWEI TECHNOLOGIES CO.,LTD
    24-DB-AD   # ShopperTrak RCT Corporation
    24-DB-ED   # Samsung Electronics Co.,Ltd
    24-DE-C6   # Aruba Networks
    24-DF-6A   # HUAWEI TECHNOLOGIES CO.,LTD
    24-E2-71   # Qingdao Hisense Communications Co.,Ltd
    24-E3-14   # Apple, Inc.
    24-E5-AA   # Philips Oral Healthcare, Inc.
    24-E6-BA   # JSC Zavod im. Kozitsky
    24-E9-B3   # Cisco Systems, Inc
    24-EA-40   # Systeme Helmholz GmbH
    24-EB-65   # SAET I.S. S.r.l.
    24-EC-99   # ASKEY COMPUTER CORP
    24-EC-D6   # CSG Science & Technology Co.,Ltd.Hefei
    24-EE-3A   # Chengdu Yingji Electronic Hi-tech Co Ltd
    24-F0-FF   # GHT Co., Ltd.
    24-F2-DD   # Radiant Zemax LLC
    24-F5-AA   # Samsung Electronics Co.,Ltd
    24-FD-52   # Liteon Technology Corporation
    24-FD-5B   # SmartThings, Inc.
    28-04-E0   # FERMAX ELECTRONICA S.A.U.
    28-06-1E   # NINGBO GLOBAL USEFUL ELECTRIC CO.,LTD
    28-06-8D   # ITL, LLC
    28-0B-5C   # Apple, Inc.
    28-0C-B8   # Mikrosay Yazilim ve Elektronik A.S.
    28-0D-FC   # Sony Computer Entertainment Inc.
    28-0E-8B   # Beijing Spirit Technology Development Co., Ltd.
    28-10-1B   # MagnaCom
    28-10-7B   # D-Link International
    28-14-71   # Lantis co., LTD.
    28-16-2E   # 2Wire Inc
    28-17-CE   # Omnisense Ltd
    28-18-78   # Microsoft Corporation
    28-18-FD   # Aditya Infotech Ltd.
    28-22-46   # Beijing Sinoix Communication Co., LTD
    28-26-A6   # PBR electronics GmbH
    28-27-BF   # Samsung Electronics Co.,Ltd
    28-28-5D   # ZyXEL Communications Corporation
    28-29-CC   # Corsa Technology Incorporated
    28-29-D9   # GlobalBeiMing technology (Beijing)Co. Ltd
    28-2C-B2   # TP-LINK TECHNOLOGIES CO.,LTD.
    28-31-52   # HUAWEI TECHNOLOGIES CO.,LTD
    28-32-C5   # HUMAX Co., Ltd.
    28-34-10   # Enigma Diagnostics Limited
    28-34-A2   # Cisco Systems, Inc
    28-37-13   # Shenzhen 3Nod Digital Technology Co., Ltd.
    28-37-37   # Apple, Inc.
    28-38-CF   # Gen2wave
    28-39-E7   # Preceno Technology Pte.Ltd.
    28-3B-96   # Cool Control LTD
    28-3C-E4   # HUAWEI TECHNOLOGIES CO.,LTD
    28-40-1A   # C8 MediSensors, Inc.
    28-41-21   # OptiSense Network, LLC
    28-44-30   # GenesisTechnical Systems (UK) Ltd
    28-47-AA   # Nokia Corporation
    28-48-46   # GridCentric Inc.
    28-4C-53   # Intune Networks
    28-4D-92   # Luminator
    28-4E-D7   # OutSmart Power Systems, Inc.
    28-4F-CE   # Liaoning Wontel Science and Technology Development Co.,Ltd.
    28-51-32   # Shenzhen Prayfly Technology Co.,Ltd
    28-52-E0   # Layon international Electronic & Telecom Co.,Ltd
    28-56-5A   # Hon Hai Precision Ind. Co.,Ltd.
    28-57-67   # Echostar Technologies Corp
    28-57-BE   # Hangzhou Hikvision Digital Technology Co.,Ltd.
    28-5A-EB   # Apple, Inc.
    28-5F-DB   # HUAWEI TECHNOLOGIES CO.,LTD
    28-60-46   # Lantech Communications Global, Inc.
    28-60-94   # CAPELEC
    28-63-36   # Siemens AG - Industrial Automation - EWA
    28-65-6B   # Keystone Microtech Corporation
    28-6A-B8   # Apple, Inc.
    28-6A-BA   # Apple, Inc.
    28-6D-97   # SAMJIN Co., Ltd.
    28-6E-D4   # HUAWEI TECHNOLOGIES CO.,LTD
    28-71-84   # Spire Payments
    28-72-C5   # Smartmatic Corp
    28-72-F0   # ATHENA
    28-76-10   # IgniteNet
    28-76-CD   # Funshion Online Technologies Co.,Ltd
    28-79-94   # Realplay Digital Technology(Shenzhen) Co.,Ltd
    28-7C-DB   # Hefei  Toycloud Technology Co.,ltd
    28-80-23   # Hewlett Packard
    28-84-FA   # SHARP Corporation
    28-85-2D   # Touch Networks
    28-89-15   # CashGuard Sverige AB
    28-8A-1C   # Juniper Networks
    28-91-D0   # Stage Tec Entwicklungsgesellschaft für professionelle Audiotechnik mbH
    28-92-4A   # Hewlett Packard
    28-93-FE   # Cisco Systems, Inc
    28-94-0F   # Cisco Systems, Inc
    28-94-AF   # Samhwa Telecom
    28-98-7B   # Samsung Electronics Co.,Ltd
    28-9A-4B   # SteelSeries ApS
    28-9A-FA   # TCT Mobile Limited
    28-9E-DF   # Danfoss Turbocor Compressors, Inc
    28-A0-2B   # Apple, Inc.
    28-A1-83   # ALPS ELECTRIC CO.,LTD.
    28-A1-86   # enblink
    28-A1-92   # GERP Solution
    28-A1-EB   # ETEK TECHNOLOGY (SHENZHEN) CO.,LTD
    28-A2-41   # exlar corp
    28-A5-74   # Miller Electric Mfg. Co.
    28-A5-EE   # Shenzhen SDGI CATV Co., Ltd
    28-AF-0A   # Sirius XM Radio Inc
    28-B0-CC   # Xenya d.o.o.
    28-B2-BD   # Intel Corporate
    28-B3-AB   # Genmark Automation
    28-B9-D9   # Radisys Corporation
    28-BA-18   # NextNav, LLC
    28-BA-B5   # Samsung Electronics Co.,Ltd
    28-BB-59   # RNET Technologies, Inc.
    28-BC-18   # SourcingOverseas Co. Ltd
    28-BC-56   # EMAC, Inc.
    28-BE-9B   # Technicolor USA Inc.
    28-C0-DA   # Juniper Networks
    28-C2-DD   # AzureWave Technology Inc.
    28-C6-71   # Yota Devices OY
    28-C6-8E   # NETGEAR
    28-C7-18   # Altierre
    28-C7-CE   # Cisco Systems, Inc
    28-C8-25   # DellKing Industrial Co., Ltd
    28-C8-7A   # Pace plc
    28-C9-14   # Taimag Corporation
    28-CB-EB   # One
    28-CC-01   # Samsung Electronics Co.,Ltd
    28-CC-FF   # Corporacion Empresarial Altra SL
    28-CD-1C   # Espotel Oy
    28-CD-4C   # Individual Computers GmbH
    28-CD-9C   # Shenzhen Dynamax Software Development Co.,Ltd.
    28-CF-DA   # Apple, Inc.
    28-CF-E9   # Apple, Inc.
    28-D1-AF   # Nokia Corporation
    28-D2-44   # LCFC(HeFei) Electronics Technology Co., Ltd.
    28-D5-76   # Premier Wireless, Inc.
    28-D9-3E   # Telecor Inc.
    28-D9-8A   # Hangzhou Konke Technology Co.,Ltd.
    28-D9-97   # Yuduan Mobile Co., Ltd.
    28-DB-81   # Shanghai Guao Electronic Technology Co., Ltd
    28-DE-F6   # bioMerieux Inc.
    28-E0-2C   # Apple, Inc.
    28-E1-4C   # Apple, Inc.
    28-E2-97   # Shanghai InfoTM Microelectronics Co.,Ltd.
    28-E3-1F   # Xiaomi Communications Co Ltd
    28-E3-47   # Liteon Technology Corporation
    28-E4-76   # Pi-Coral
    28-E6-08   # Tokheim
    28-E6-E9   # SIS Sat Internet Services GmbH
    28-E7-94   # Microtime Computer Inc.
    28-E7-CF   # Apple, Inc.
    28-ED-58   # JAG Jakob AG
    28-ED-6A   # Apple, Inc.
    28-EE-2C   # Frontline Test Equipment
    28-EF-01   # Private
    28-F0-76   # Apple, Inc.
    28-F3-58   # 2C - Trifonov & Co
    28-F5-32   # ADD-Engineering BV
    28-F6-06   # Syes srl
    28-FA-A0   # vivo Mobile Communication Co., Ltd.
    28-FB-D3   # Ragentek Technology Group
    28-FC-51   # The Electric Controller and Manufacturing Co., LLC
    28-FC-F6   # Shenzhen Xin KingBrand enterprises Co.,Ltd
    28-FD-80   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    2C-00-2C   # UNOWHY
    2C-00-33   # EControls, LLC
    2C-00-F7   # XOS
    2C-01-0B   # NASCENT Technology, LLC - RemKon
    2C-06-23   # Win Leader Inc.
    2C-07-3C   # DEVLINE LIMITED
    2C-08-1C   # OVH
    2C-08-8C   # HUMAX Co., Ltd.
    2C-10-C1   # Nintendo Co., Ltd.
    2C-18-AE   # Trend Electronics Co., Ltd.
    2C-19-84   # IDN Telecom, Inc.
    2C-1A-31   # Electronics Company Limited
    2C-1B-C8   # Hunan Topview Network System CO.,LTD
    2C-1E-EA   # AERODEV
    2C-1F-23   # Apple, Inc.
    2C-21-72   # Juniper Networks
    2C-22-8B   # CTR SRL
    2C-23-3A   # Hewlett Packard
    2C-24-5F   # Babolat VS
    2C-26-5F   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    2C-26-C5   # zte corporation
    2C-27-D7   # Hewlett Packard
    2C-28-2D   # BBK COMMUNICATIAO TECHNOLOGY CO.,LTD.
    2C-29-97   # Microsoft Corporation
    2C-2D-48   # bct electronic GesmbH
    2C-30-33   # NETGEAR
    2C-30-68   # Pantech Co.,Ltd
    2C-33-7A   # Hon Hai Precision Ind. Co.,Ltd.
    2C-34-27   # ERCO & GENER
    2C-35-57   # ELLIY Power CO..Ltd
    2C-36-A0   # Capisco Limited
    2C-36-F8   # Cisco Systems, Inc
    2C-37-31   # ShenZhen Yifang Digital Technology Co.,LTD
    2C-37-96   # CYBO CO.,LTD.
    2C-39-96   # Sagemcom Broadband SAS
    2C-39-C1   # Ciena Corporation
    2C-3A-28   # Fagor Electrónica
    2C-3B-FD   # Netstor Technology Co., Ltd.
    2C-3E-CF   # Cisco Systems, Inc
    2C-3F-38   # Cisco Systems, Inc
    2C-3F-3E   # Alge-Timing GmbH
    2C-41-38   # Hewlett Packard
    2C-44-01   # Samsung Electronics Co.,Ltd
    2C-44-1B   # Spectrum Medical Limited
    2C-44-FD   # Hewlett Packard
    2C-4D-79   # GoerTek Inc.
    2C-50-89   # Shenzhen Kaixuan Visual Technology Co.,Limited
    2C-53-4A   # Shenzhen Winyao Electronic Limited
    2C-54-2D   # Cisco Systems, Inc
    2C-54-CF   # LG Electronics
    2C-55-3C   # Gainspeed, Inc.
    2C-56-DC   # ASUSTek COMPUTER INC.
    2C-59-E5   # Hewlett Packard
    2C-5A-05   # Nokia Corporation
    2C-5A-A3   # PROMATE ELECTRONIC CO.LTD
    2C-5B-B8   # GUANGDONG OPPO MOBILE TELECOMMUNICATIONS CORP.,LTD
    2C-5B-E1   # Centripetal Networks, Inc
    2C-5D-93   # Ruckus Wireless
    2C-5F-F3   # Pertronic Industries
    2C-60-0C   # QUANTA COMPUTER INC.
    2C-62-5A   # Finest Security Systems Co., Ltd
    2C-62-89   # Regenersis (Glenrothes) Ltd
    2C-67-98   # InTalTech Ltd.
    2C-67-FB   # ShenZhen Zhengjili Electronics Co., LTD
    2C-69-BA   # RF Controls, LLC
    2C-6A-6F   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    2C-6B-F5   # Juniper Networks
    2C-6E-85   # Intel Corporate
    2C-71-55   # HiveMotion
    2C-72-C3   # Soundmatters
    2C-75-0F   # Shanghai Dongzhou-Lawton Communication Technology Co. Ltd.
    2C-76-8A   # Hewlett Packard
    2C-7B-5A   # Milper Ltd
    2C-7B-84   # OOO Petr Telegin
    2C-7E-CF   # Onzo Ltd
    2C-80-65   # HARTING Inc. of North America
    2C-81-58   # Hon Hai Precision Ind. Co.,Ltd.
    2C-8A-72   # HTC Corporation
    2C-8B-F2   # Hitachi Metals America Ltd
    2C-91-27   # Eintechno Corporation
    2C-92-2C   # Kishu Giken Kogyou Company Ltd,.
    2C-94-64   # Cincoze Co., Ltd.
    2C-95-7F   # zte corporation
    2C-97-17   # I.C.Y. B.V.
    2C-9A-A4   # NGI SpA
    2C-9E-5F   # ARRIS Group, Inc.
    2C-9E-FC   # CANON INC.
    2C-A1-57   # acromate, Inc.
    2C-A2-B4   # Fortify Technologies, LLC
    2C-A3-0E   # POWER DRAGON DEVELOPMENT LIMITED
    2C-A5-39   # Parallel Wireless, Inc
    2C-A7-80   # True Technologies Inc.
    2C-A8-35   # RIM
    2C-AB-00   # HUAWEI TECHNOLOGIES CO.,LTD
    2C-AB-25   # Shenzhen Gongjin Electronics Co.,Ltd
    2C-AB-A4   # Cisco SPVTG
    2C-AD-13   # SHENZHEN ZHILU TECHNOLOGY CO.,LTD
    2C-AE-2B   # Samsung Electronics Co.,Ltd
    2C-B0-5D   # NETGEAR
    2C-B0-DF   # Soliton Technologies Pvt Ltd
    2C-B4-3A   # Apple, Inc.
    2C-B6-93   # Radware
    2C-B6-9D   # RED Digital Cinema
    2C-BE-08   # Apple, Inc.
    2C-BE-97   # Ingenieurbuero Bickele und Buehler GmbH
    2C-C2-60   # Ravello Systems
    2C-C5-48   # IAdea Corporation
    2C-C5-D3   # Ruckus Wireless
    2C-CC-15   # Nokia Corporation
    2C-CD-27   # Precor Inc
    2C-CD-43   # Summit Technology Group
    2C-CD-69   # Aqavi.com
    2C-CF-58   # HUAWEI TECHNOLOGIES CO.,LTD
    2C-D0-5A   # Liteon Technology Corporation
    2C-D1-41   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    2C-D1-DA   # Sanjole, Inc.
    2C-D2-E7   # Nokia Corporation
    2C-D4-44   # FUJITSU LIMITED
    2C-DD-0C   # Discovergy GmbH
    2C-DD-A3   # Point Grey Research Inc.
    2C-E2-A8   # DeviceDesign
    2C-E4-12   # Sagemcom Broadband SAS
    2C-E6-CC   # Ruckus Wireless
    2C-E8-71   # Alert Metalguard ApS
    2C-ED-EB   # Alpheus Digital Company Limited
    2C-EE-26   # Petroleum Geo-Services
    2C-F0-EE   # Apple, Inc.
    2C-F2-03   # EMKO ELEKTRONIK SAN VE TIC AS
    2C-F4-C5   # Avaya Inc
    2C-F7-F1   # Seeed Technology Inc.
    2C-FA-A2   # Alcatel-Lucent
    2C-FC-E4   # CTEK Sweden AB
    2C-FD-37   # Blue Calypso, Inc.
    2C-FF-65   # Oki Electric Industry Co., Ltd.
    30-05-5C   # Brother industries, LTD.
    30-0B-9C   # Delta Mobile Systems, Inc.
    30-0C-23   # zte corporation
    30-0D-2A   # Zhejiang Wellcom Technology Co.,Ltd.
    30-0D-43   # Microsoft Mobile Oy
    30-0E-D5   # Hon Hai Precision Ind. Co.,Ltd.
    30-0E-E3   # Aquantia Corporation
    30-10-B3   # Liteon Technology Corporation
    30-10-E4   # Apple, Inc.
    30-14-2D   # Piciorgros GmbH
    30-14-4A   # Wistron Neweb Corp.
    30-15-18   # Ubiquitous Communication Co. ltd.
    30-16-8D   # ProLon
    30-17-C8   # Sony Mobile Communications AB
    30-18-CF   # DEOS control systems GmbH
    30-19-66   # Samsung Electronics Co.,Ltd
    30-1A-28   # Mako Networks Ltd
    30-21-5B   # Shenzhen Ostar Display Electronic Co.,Ltd
    30-29-BE   # Shanghai MRDcom Co.,Ltd
    30-2D-E8   # JDA, LLC (JDA Systems)
    30-32-94   # W-IE-NE-R Plein & Baus GmbH
    30-32-D4   # Hanilstm Co., Ltd.
    30-33-35   # Boosty
    30-37-A6   # Cisco Systems, Inc
    30-38-55   # Nokia Corporation
    30-39-26   # Sony Mobile Communications AB
    30-39-55   # Shenzhen Jinhengjia Electronic Co., Ltd.
    30-39-F2   # ADB Broadband Italia
    30-3A-64   # Intel Corporate
    30-3D-08   # GLINTT TES S.A.
    30-3E-AD   # Sonavox Canada Inc
    30-41-74   # ALTEC LANSING LLC
    30-42-25   # BURG-WÄCHTER KG
    30-44-49   # PLATH GmbH
    30-44-87   # Hefei Radio Communication Technology Co., Ltd
    30-46-9A   # NETGEAR
    30-49-3B   # Nanjing Z-Com Wireless Co.,Ltd
    30-4C-7E   # Panasonic Electric Works Automation Controls Techno Co.,Ltd.
    30-4E-C3   # Tianjin Techua Technology Co., Ltd.
    30-51-F8   # BYK-Gardner GmbH
    30-52-5A   # NST Co., LTD
    30-52-CB   # Liteon Technology Corporation
    30-55-ED   # Trex Network LLC
    30-57-AC   # IRLAB LTD.
    30-59-5B   # streamnow AG
    30-59-B7   # Microsoft
    30-5A-3A   # ASUSTek COMPUTER INC.
    30-5D-38   # Beissbarth
    30-60-23   # ARRIS Group, Inc.
    30-61-12   # PAV GmbH
    30-61-18   # Paradom Inc.
    30-63-6B   # Apple, Inc.
    30-65-EC   # Wistron (ChongQing)
    30-68-8C   # Reach Technology Inc.
    30-69-4B   # RIM
    30-6C-BE   # Skymotion Technology (HK) Limited
    30-6E-5C   # Validus Technologies
    30-71-B2   # Hangzhou Prevail Optoelectronic Equipment Co.,LTD.
    30-73-50   # Inpeco SA
    30-75-12   # Sony Mobile Communications AB
    30-76-6F   # LG Electronics
    30-77-CB   # Maike Industry(Shenzhen)CO.,LTD
    30-78-6B   # TIANJIN Golden Pentagon Electronics Co., Ltd.
    30-78-C2   # Innowireless, Co. Ltd.
    30-7C-30   # RIM
    30-7C-5E   # Juniper Networks
    30-7C-B2   # ANOV FRANCE
    30-7E-CB   # SFR
    30-85-A9   # ASUSTek COMPUTER INC.
    30-87-30   # HUAWEI TECHNOLOGIES CO.,LTD
    30-89-99   # Guangdong East Power Co.,
    30-89-D3   # HONGKONG UCLOUDLINK NETWORK TECHNOLOGY LIMITED
    30-8C-FB   # Dropcam
    30-8D-99   # Hewlett Packard
    30-90-AB   # Apple, Inc.
    30-91-8F   # Technicolor
    30-92-F6   # SHANGHAI SUNMON COMMUNICATION TECHNOGY CO.,LTD
    30-95-E3   # SHANGHAI SIMCOM LIMITED
    30-9B-AD   # BBK Electronics Corp., Ltd.,
    30-A2-20   # ARG Telecom
    30-A2-43   # Shenzhen Prifox Innovation Technology Co., Ltd.
    30-A8-DB   # Sony Mobile Communications AB
    30-AA-BD   # Shanghai Reallytek Information Technology Co.,Ltd
    30-AE-7B   # Deqing Dusun Electron CO., LTD
    30-AE-F6   # Radio Mobile Access
    30-B2-16   # Hytec Geraetebau GmbH
    30-B3-A2   # Shenzhen Heguang Measurement & Control Technology Co.,Ltd
    30-B5-C2   # TP-LINK TECHNOLOGIES CO.,LTD.
    30-B5-F1   # Aitexin Technology Co., Ltd
    30-C7-50   # MIC Technology Group
    30-C7-AE   # Samsung Electronics Co.,Ltd
    30-C8-2A   # Wi-Next s.r.l.
    30-CB-F8   # Samsung Electronics Co.,Ltd
    30-CD-A7   # Samsung Electronics ITS, Printer division
    30-D1-7E   # HUAWEI TECHNOLOGIES CO.,LTD
    30-D3-2D   # devolo AG
    30-D3-57   # Logosol, Inc.
    30-D4-6A   # Autosales Incorporated
    30-D5-87   # Samsung Electronics Co.,Ltd
    30-D6-C9   # Samsung Electronics Co.,Ltd
    30-DE-86   # Cedac Software S.r.l.
    30-E0-90   # Linctronix Ltd,
    30-E4-8E   # Vodafone UK
    30-E4-DB   # Cisco Systems, Inc
    30-EB-25   # INTEK DIGITAL
    30-EF-D1   # Alstom Strongwish (Shenzhen) Co., Ltd.
    30-F3-1D   # zte corporation
    30-F3-35   # HUAWEI TECHNOLOGIES CO.,LTD
    30-F3-3A   # +plugg srl
    30-F4-2F   # ESP
    30-F7-0D   # Cisco Systems, Inc
    30-F7-72   # Hon Hai Precision Ind. Co.,Ltd.
    30-F7-C5   # Apple, Inc.
    30-F7-D7   # Thread Technology Co., Ltd
    30-F9-ED   # Sony Corporation
    30-FA-B7   # Tunai Creative
    30-FD-11   # MACROTECH (USA) INC.
    30-FF-F6   # HangZhou KuoHeng Technology Co.,ltd
    34-00-A3   # HUAWEI TECHNOLOGIES CO.,LTD
    34-02-86   # Intel Corporate
    34-02-9B   # CloudBerry Technologies Private Limited
    34-07-FB   # Ericsson AB
    34-08-04   # D-Link Corporation
    34-0A-22   # TOP-ACCESS ELECTRONICS CO LTD
    34-0A-FF   # Qingdao Hisense Communications Co.,Ltd
    34-0B-40   # MIOS ELETTRONICA SRL
    34-0C-ED   # Moduel AB
    34-12-98   # Apple, Inc.
    34-13-A8   # Mediplan Limited
    34-13-E8   # Intel Corporate
    34-14-5F   # Samsung Electronics Co.,Ltd
    34-15-9E   # Apple, Inc.
    34-17-EB   # Dell Inc.
    34-1A-4C   # SHENZHEN WEIBU ELECTRONICS CO.,LTD.
    34-1B-22   # Grandbeing Technology Co., Ltd
    34-21-09   # Jensen Scandinavia AS
    34-23-87   # Hon Hai Precision Ind. Co.,Ltd.
    34-23-BA   # Samsung Electro Mechanics co.,LTD.
    34-25-5D   # Shenzhen Loadcom Technology Co.,Ltd
    34-26-06   # CarePredict, Inc.
    34-28-F0   # ATN International Limited
    34-29-EA   # MCD ELECTRONICS SP. Z O.O.
    34-2F-6E   # Anywire corporation
    34-31-11   # Samsung Electronics Co.,Ltd
    34-31-C4   # AVM GmbH
    34-36-3B   # Apple, Inc.
    34-37-59   # zte corporation
    34-38-AF   # Inlab Software GmbH
    34-3D-98   # JinQianMao Technology Co.,Ltd.
    34-40-B5   # IBM
    34-46-6F   # HiTEM Engineering
    34-4B-3D   # Fiberhome Telecommunication Tech.Co.,Ltd.
    34-4B-50   # zte corporation
    34-4C-A4   # amazipoint technology Ltd.
    34-4D-EA   # zte corporation
    34-4D-F7   # LG Electronics
    34-4F-3F   # IO-Power Technology Co., Ltd.
    34-4F-5C   # R&amp;M AG
    34-4F-69   # EKINOPS SAS
    34-51-AA   # JID GLOBAL
    34-51-C9   # Apple, Inc.
    34-5B-11   # EVI HEAT AB
    34-5C-40   # Cargt Holdings LLC
    34-5D-10   # Wytek
    34-61-78   # The Boeing Company
    34-62-88   # Cisco Systems, Inc
    34-64-A9   # Hewlett Packard
    34-68-4A   # Teraworks Co., Ltd.
    34-68-95   # Hon Hai Precision Ind. Co.,Ltd.
    34-69-87   # zte corporation
    34-6B-D3   # HUAWEI TECHNOLOGIES CO.,LTD
    34-6C-0F   # Pramod Telecom Pvt. Ltd
    34-6E-8A   # Ecosense
    34-6F-90   # Cisco Systems, Inc
    34-6F-92   # White Rodgers Division
    34-75-C7   # Avaya Inc
    34-76-C5   # I-O DATA DEVICE, INC.
    34-78-77   # O-NET Communications(Shenzhen) Limited
    34-7A-60   # Pace plc
    34-7E-39   # Nokia Danmark A/S
    34-80-B3   # Xiaomi Communications Co Ltd
    34-81-37   # UNICARD SA
    34-81-C4   # AVM GmbH
    34-81-F4   # SST Taiwan Ltd.
    34-82-DE   # Kiio Inc
    34-83-02   # iFORCOM Co., Ltd
    34-84-46   # Ericsson AB
    34-86-2A   # Heinz Lackmann GmbH & Co KG
    34-87-3D   # Quectel Wireless Solution Co.,Ltd.
    34-88-5D   # Logitech Far East
    34-8A-AE   # Sagemcom Broadband SAS
    34-95-DB   # Logitec Corporation
    34-97-FB   # ADVANCED RF TECHNOLOGIES INC
    34-99-6F   # VPI Engineering
    34-99-D7   # Universal Flow Monitors, Inc.
    34-9A-0D   # ZBD Displays Ltd
    34-9B-5B   # Maquet GmbH
    34-9D-90   # Heinzmann GmbH & CO. KG
    34-9E-34   # Evervictory Electronic Co.Ltd
    34-A1-83   # AWare, Inc
    34-A3-95   # Apple, Inc.
    34-A3-BF   # Terewave. Inc.
    34-A5-5D   # TECHNOSOFT INTERNATIONAL SRL
    34-A5-E1   # Sensorist ApS
    34-A6-8C   # Shine Profit Development Limited
    34-A7-09   # Trevil srl
    34-A7-BA   # Fischer International Systems Corporation
    34-A8-43   # KYOCERA Display Corporation
    34-A8-4E   # Cisco Systems, Inc
    34-AA-8B   # Samsung Electronics Co.,Ltd
    34-AA-99   # Alcatel-Lucent
    34-AA-EE   # Mikrovisatos Servisas UAB
    34-AB-37   # Apple, Inc.
    34-AD-E4   # Shanghai Chint Power Systems Co., Ltd.
    34-AF-2C   # Nintendo Co., Ltd.
    34-B1-F7   # Texas Instruments
    34-B5-71   # PLDS
    34-B7-FD   # Guangzhou Younghead Electronic Technology Co.,Ltd
    34-BA-51   # Se-Kure Controls, Inc.
    34-BA-75   # Tembo Systems, Inc.
    34-BA-9A   # Asiatelco Technologies Co.
    34-BB-1F   # BlackBerry RTS
    34-BB-26   # Motorola Mobility LLC, a Lenovo Company
    34-BC-A6   # Beijing Ding Qing Technology, Ltd.
    34-BD-C8   # Cisco Systems, Inc
    34-BD-F9   # Shanghai WDK Industrial Co.,Ltd.
    34-BD-FA   # Cisco SPVTG
    34-BE-00   # Samsung Electronics Co.,Ltd
    34-BF-90   # Fiberhome Telecommunication Tech.Co.,Ltd.
    34-C0-59   # Apple, Inc.
    34-C3-AC   # Samsung Electronics
    34-C3-D2   # FN-LINK TECHNOLOGY LIMITED
    34-C5-D0   # Hagleitner Hygiene International GmbH
    34-C6-9A   # Enecsys Ltd
    34-C7-31   # ALPS ELECTRIC CO.,LTD.
    34-C8-03   # Nokia Corporation
    34-C9-9D   # EIDOLON COMMUNICATIONS TECHNOLOGY CO. LTD.
    34-C9-F0   # LM Technologies Ltd
    34-CC-28   # Nexpring Co. LTD.,
    34-CD-6D   # CommSky Technologies
    34-CD-BE   # HUAWEI TECHNOLOGIES CO.,LTD
    34-CE-94   # Parsec (Pty) Ltd
    34-D0-9B   # MobilMAX Technology Inc.
    34-D2-C4   # RENA GmbH Print Systeme
    34-D7-B4   # Tributary Systems, Inc.
    34-DB-FD   # Cisco Systems, Inc
    34-DE-1A   # Intel Corporate
    34-DE-34   # zte corporation
    34-DF-2A   # Fujikon Industrial Co.,Limited
    34-E0-CF   # zte corporation
    34-E0-D7   # DONGGUAN QISHENG ELECTRONICS INDUSTRIAL CO., LTD
    34-E2-FD   # Apple, Inc.
    34-E4-2A   # Automatic Bar Controls Inc.
    34-E6-AD   # Intel Corporate
    34-E6-D7   # Dell Inc.
    34-EF-44   # 2Wire Inc
    34-EF-8B   # NTT Communications Corporation
    34-F0-CA   # Shenzhen Linghangyuan Digital Technology Co.,Ltd.
    34-F3-9B   # WizLAN Ltd.
    34-F6-2D   # SHARP Corporation
    34-F6-D2   # Panasonic Taiwan Co.,Ltd.
    34-F9-68   # ATEK Products, LLC
    34-FA-40   # Guangzhou Robustel Technologies Co., Limited
    34-FC-6F   # ALCEA
    34-FC-EF   # LG Electronics
    38-01-95   # Samsung Electronics Co.,Ltd
    38-01-97   # TSST Global,Inc
    38-05-46   # Foctek Photonics, Inc.
    38-06-B4   # A.D.C. GmbH
    38-08-FD   # Silca Spa
    38-09-A4   # Firefly Integrations
    38-0A-0A   # Sky-City Communication and Electronics Limited Company
    38-0A-94   # Samsung Electronics Co.,Ltd
    38-0A-AB   # Formlabs
    38-0B-40   # Samsung Electronics Co.,Ltd
    38-0D-D4   # Primax Electronics LTD.
    38-0E-7B   # V.P.S. Thai Co., Ltd
    38-0F-4A   # Apple, Inc.
    38-0F-E4   # Dedicated Network Partners Oy
    38-16-D1   # Samsung Electronics Co.,Ltd
    38-17-66   # PROMZAKAZ LTD.
    38-19-2F   # Nokia Corporation
    38-1C-1A   # Cisco Systems, Inc
    38-1C-23   # Hilan Technology CO.,LTD
    38-1C-4A   # SIMCom Wireless Solutions Co.,Ltd.
    38-20-56   # Cisco Systems, Inc
    38-21-87   # Midea Group Co., Ltd.
    38-22-9D   # ADB Broadband Italia
    38-22-D6   # H3C Technologies Co., Limited
    38-26-2B   # UTran Technology
    38-26-CD   # ANDTEK
    38-28-EA   # Fujian Netcom Technology Co., LTD
    38-29-DD   # ONvocal Inc
    38-2B-78   # ECO PLUGS ENTERPRISE CO., LTD
    38-2C-4A   # ASUSTek COMPUTER INC.
    38-2D-D1   # Samsung Electronics Co.,Ltd
    38-2D-E8   # Samsung Electronics Co.,Ltd
    38-31-AC   # WEG
    38-3B-C8   # 2Wire Inc
    38-3F-10   # DBL Technology Ltd.
    38-42-33   # Wildeboer Bauteile GmbH
    38-42-A6   # Ingenieurbuero Stahlkopf
    38-43-69   # Patrol Products Consortium LLC
    38-45-8C   # MyCloud Technology corporation
    38-46-08   # zte corporation
    38-48-4C   # Apple, Inc.
    38-4B-76   # AIRTAME ApS
    38-4C-90   # ARRIS Group, Inc.
    38-4F-F0   # AzureWave Technology Inc.
    38-52-1A   # Alcatel-Lucent 7705
    38-58-0C   # Panaccess Systems GmbH
    38-59-F8   # MindMade Sp. z o.o.
    38-59-F9   # Hon Hai Precision Ind. Co.,Ltd.
    38-5A-A8   # Beijing Zhongdun Security Technology Development Co.
    38-5F-66   # Cisco SPVTG
    38-5F-C3   # Yu Jeong System, Co.Ltd
    38-60-77   # PEGATRON CORPORATION
    38-63-BB   # Hewlett Packard
    38-63-F6   # 3NOD MULTIMEDIA(SHENZHEN)CO.,LTD
    38-66-45   # OOSIC Technology CO.,Ltd
    38-67-93   # Asia Optical Co., Inc.
    38-6B-BB   # ARRIS Group, Inc.
    38-6C-9B   # Ivy Biomedical
    38-6E-21   # Wasion Group Ltd.
    38-71-DE   # Apple, Inc.
    38-72-C0   # Comtrend Corporation
    38-7B-47   # AKELA, Inc.
    38-83-45   # TP-LINK TECHNOLOGIES CO.,LTD.
    38-86-02   # Flexoptix GmbH
    38-89-DC   # Opticon Sensors Europe B.V.
    38-8A-B7   # ITC Networks
    38-8E-E7   # Fanhattan LLC
    38-91-D5   # Hangzhou H3C Technologies Co., Limited
    38-91-FB   # Xenox Holding BV
    38-94-96   # Samsung Electronics Co.,Ltd
    38-95-92   # Beijing Tendyron Corporation
    38-97-D6   # Hangzhou H3C Technologies Co., Limited
    38-98-D8   # MERITECH CO.,LTD
    38-9F-83   # OTN Systems N.V.
    38-A5-3C   # COMECER Netherlands
    38-A5-B6   # SHENZHEN MEGMEET ELECTRICAL CO.,LTD
    38-A8-51   # Moog, Ing
    38-A8-6B   # Orga BV
    38-A9-5F   # Actifio Inc
    38-AA-3C   # SAMSUNG ELECTRO-MECHANICS
    38-B1-2D   # Sonotronic Nagel GmbH
    38-B1-DB   # Hon Hai Precision Ind. Co.,Ltd.
    38-B5-4D   # Apple, Inc.
    38-B5-BD   # E.G.O. Elektro-Ger
    38-B7-25   # Wistron Infocomm (Zhongshan) Corporation
    38-B7-4D   # Fijowave Limited
    38-B8-EB   # IEEE Registration Authority
    38-BB-23   # OzVision America LLC
    38-BB-3C   # Avaya Inc
    38-BC-1A   # Meizu technology co.,ltd
    38-BF-2F   # Espec Corp.
    38-BF-33   # NEC CASIO Mobile Communications
    38-C0-96   # ALPS ELECTRIC CO.,LTD.
    38-C7-0A   # WiFiSong
    38-C7-BA   # CS Services Co.,Ltd.
    38-C8-5C   # Cisco SPVTG
    38-C9-86   # Apple, Inc.
    38-C9-A9   # SMART High Reliability Solutions, Inc.
    38-CA-97   # Contour Design LLC
    38-CA-DA   # Apple, Inc.
    38-D1-35   # EasyIO Corporation Sdn. Bhd.
    38-D4-0B   # Samsung Electronics Co.,Ltd
    38-D8-2F   # zte corporation
    38-DB-BB   # Sunbow Telecom Co., Ltd.
    38-DE-60   # Mohlenhoff GmbH
    38-E0-8E   # Mitsubishi Electric Corporation
    38-E3-C5   # Taicang T&W Electronics
    38-E5-95   # Shenzhen Gongjin Electronics Co.,Ltd
    38-E7-D8   # HTC Corporation
    38-E8-DF   # b gmbh medien + datenbanken
    38-E9-8C   # Reco S.p.A.
    38-EA-A7   # Hewlett Packard
    38-EC-11   # Novatek Microelectronics Corp.
    38-EC-E4   # Samsung Electronics
    38-ED-18   # Cisco Systems, Inc
    38-EE-9D   # Anedo Ltd.
    38-F0-98   # Vapor Stone Rail Systems
    38-F0-C8   # Livestream
    38-F2-3E   # Microsoft Mobile Oy
    38-F3-3F   # TATSUNO CORPORATION
    38-F5-57   # JOLATA, INC.
    38-F5-97   # home2net GmbH
    38-F7-08   # National Resource Management, Inc.
    38-F8-89   # HUAWEI TECHNOLOGIES CO.,LTD
    38-F8-B7   # V2COM PARTICIPACOES S.A.
    38-FA-CA   # Skyworth Digital Technology(Shenzhen) Co.,Ltd
    38-FE-C5   # Ellips B.V.
    38-FF-36   # Ruckus Wireless
    3C-02-B1   # Creation Technologies LP
    3C-04-BF   # PRAVIS SYSTEMS Co.Ltd.,
    3C-05-AB   # Product Creation Studio
    3C-07-54   # Apple, Inc.
    3C-07-71   # Sony Computer Entertainment Inc.
    3C-08-1E   # Beijing Yupont Electric Power Technology Co.,Ltd
    3C-08-F6   # Cisco Systems, Inc
    3C-09-6D   # Powerhouse Dynamics
    3C-0C-48   # Servergy, Inc.
    3C-0E-23   # Cisco Systems, Inc
    3C-0F-C1   # KBC Networks
    3C-10-40   # daesung network
    3C-10-6F   # ALBAHITH TECHNOLOGIES
    3C-15-C2   # Apple, Inc.
    3C-15-EA   # TESCOM CO., LTD.
    3C-18-9F   # Nokia Corporation
    3C-18-A0   # Luxshare Precision Industry Co.,Ltd.
    3C-19-15   # GFI Chrono Time
    3C-19-7D   # Ericsson AB
    3C-1A-0F   # ClearSky Data
    3C-1A-57   # Cardiopulmonary Corp
    3C-1A-79   # Huayuan Technology CO.,LTD
    3C-1C-BE   # JADAK LLC
    3C-1E-04   # D-Link International
    3C-1E-13   # HANGZHOU SUNRISE TECHNOLOGY CO., LTD
    3C-25-D7   # Nokia Corporation
    3C-26-D5   # Sotera Wireless
    3C-27-63   # SLE quality engineering GmbH & Co. KG
    3C-2C-94   # 杭州德澜科技有限公司（HangZhou Delan Technology Co.,Ltd）
    3C-2D-B7   # Texas Instruments
    3C-2F-3A   # SFORZATO Corp.
    3C-30-0C   # Dewar Electronics Pty Ltd
    3C-31-78   # Qolsys Inc.
    3C-33-00   # Shenzhen Bilian electronic CO.,LTD
    3C-35-56   # Cognitec Systems GmbH
    3C-36-3D   # Nokia Corporation
    3C-36-E4   # ARRIS Group, Inc.
    3C-38-88   # ConnectQuest, llc
    3C-39-C3   # JW Electronics Co., Ltd.
    3C-39-E7   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    3C-3A-73   # Avaya Inc
    3C-40-4F   # Guangdong Pisen Electronics Co. Ltd.
    3C-43-8E   # ARRIS Group, Inc.
    3C-46-D8   # TP-LINK TECHNOLOGIES CO.,LTD.
    3C-47-11   # HUAWEI TECHNOLOGIES CO.,LTD
    3C-49-37   # ASSMANN Electronic GmbH
    3C-4A-92   # Hewlett Packard
    3C-4C-69   # Infinity System S.L.
    3C-4E-47   # Etronic A/S
    3C-57-BD   # Kessler Crane Inc.
    3C-57-D5   # FiveCo
    3C-59-1E   # TCL King Electrical Appliances (Huizhou) Co., Ltd
    3C-5A-37   # Samsung Electronics
    3C-5A-B4   # Google, Inc.
    3C-5C-C3   # Shenzhen First Blue Chip Technology Ltd
    3C-5E-C3   # Cisco Systems, Inc
    3C-5F-01   # Synerchip Co., Ltd.
    3C-61-04   # Juniper Networks
    3C-62-00   # Samsung electronics CO., LTD
    3C-62-78   # SHENZHEN JETNET TECHNOLOGY CO.,LTD.
    3C-67-16   # Lily Robotics
    3C-67-2C   # Sciovid Inc.
    3C-6A-7D   # Niigata Power Systems Co., Ltd.
    3C-6A-9D   # Dexatek Technology LTD.
    3C-6E-63   # Mitron OY
    3C-6F-45   # Fiberpro Inc.
    3C-6F-F7   # EnTek Systems, Inc.
    3C-70-59   # MakerBot Industries
    3C-74-37   # RIM
    3C-75-4A   # ARRIS Group, Inc.
    3C-77-E6   # Hon Hai Precision Ind. Co.,Ltd.
    3C-78-73   # Airsonics
    3C-7A-8A   # ARRIS Group, Inc.
    3C-7D-B1   # Texas Instruments
    3C-81-D8   # Sagemcom Broadband SAS
    3C-83-1E   # CKD Corporation
    3C-83-75   # Microsoft Corporation
    3C-83-B5   # Advance Vision Electronics Co. Ltd.
    3C-86-A8   # Sangshin elecom .co,, LTD
    3C-89-70   # Neosfar
    3C-89-A6   # KAPELSE
    3C-8A-B0   # Juniper Networks
    3C-8A-E5   # Tensun Information Technology(Hangzhou) Co.,LTD
    3C-8B-FE   # Samsung Electronics
    3C-8C-40   # Hangzhou H3C Technologies Co., Limited
    3C-8C-F8   # TRENDnet, Inc.
    3C-90-66   # SmartRG, Inc.
    3C-91-2B   # Vexata Inc
    3C-91-57   # Hangzhou Yulong Conmunication Co.,Ltd
    3C-91-74   # ALONG COMMUNICATION TECHNOLOGY
    3C-94-D5   # Juniper Networks
    3C-97-0E   # Wistron InfoComm(Kunshan)Co.,Ltd.
    3C-97-7E   # IPS Technology Limited
    3C-98-BF   # Quest Controls, Inc.
    3C-99-F7   # Lansentechnology AB
    3C-9F-81   # Shenzhen CATIC Bit Communications Technology Co.,Ltd
    3C-A1-0D   # Samsung Electronics Co.,Ltd
    3C-A3-15   # Bless Information & Communications Co., Ltd
    3C-A3-1A   # Oilfind International LLC
    3C-A3-48   # vivo Mobile Communication Co., Ltd.
    3C-A7-2B   # MRV Communications (Networks) LTD
    3C-A8-2A   # Hewlett Packard
    3C-A9-F4   # Intel Corporate
    3C-AA-3F   # iKey, Ltd.
    3C-AB-8E   # Apple, Inc.
    3C-AE-69   # ESA Elektroschaltanlagen Grimma GmbH
    3C-B1-5B   # Avaya Inc
    3C-B1-7F   # Wattwatchers Pty Ld
    3C-B7-2B   # PLUMgrid Inc
    3C-B7-92   # Hitachi Maxell, Ltd., Optronics Division
    3C-B8-7A   # Private
    3C-B9-A6   # Belden Deutschland GmbH
    3C-BB-73   # Shenzhen Xinguodu Technology Co., Ltd.
    3C-BB-FD   # Samsung Electronics Co.,Ltd
    3C-BD-D8   # LG ELECTRONICS INC
    3C-BE-E1   # NIKON CORPORATION
    3C-C0-C6   # d&b audiotechnik GmbH
    3C-C1-2C   # AES Corporation
    3C-C1-F6   # Melange Systems Pvt. Ltd.
    3C-C2-43   # Nokia Corporation
    3C-C2-E1   # XINHUA CONTROL ENGINEERING CO.,LTD
    3C-C9-9E   # Huiyang Technology Co., Ltd
    3C-CA-87   # Iders Incorporated
    3C-CB-7C   # TCT mobile ltd
    3C-CD-5A   # Technische Alternative GmbH
    3C-CD-93   # LG ELECTRONICS INC
    3C-CE-15   # Mercedes-Benz USA, LLC
    3C-CE-73   # Cisco Systems, Inc
    3C-CF-5B   # ICOMM HK LIMITED
    3C-D0-F8   # Apple, Inc.
    3C-D1-6E   # Telepower Communication Co., Ltd
    3C-D4-D6   # WirelessWERX, Inc
    3C-D7-DA   # SK Mtek microelectronics(shenzhen)limited
    3C-D9-2B   # Hewlett Packard
    3C-D9-CE   # Eclipse WiFi
    3C-DA-2A   # zte corporation
    3C-DD-89   # SOMO HOLDINGS & TECH. CO.,LTD.
    3C-DF-1E   # Cisco Systems, Inc
    3C-DF-A9   # ARRIS Group, Inc.
    3C-DF-BD   # HUAWEI TECHNOLOGIES CO.,LTD
    3C-E0-72   # Apple, Inc.
    3C-E5-A6   # Hangzhou H3C Technologies Co., Ltd.
    3C-E5-B4   # KIDASEN INDUSTRIA E COMERCIO DE ANTENAS LTDA
    3C-E6-24   # LG Display
    3C-EA-4F   # 2Wire Inc
    3C-EA-FB   # NSE AG
    3C-EF-8C   # ZHEJIANG DAHUA TECHNOLOGY CO.,LTD.
    3C-F3-92   # Virtualtek. Co. Ltd
    3C-F5-2C   # DSPECIALISTS GmbH
    3C-F7-2A   # Nokia Corporation
    3C-F7-48   # Shenzhen Linsn Technology Development Co.,Ltd
    3C-F8-08   # HUAWEI TECHNOLOGIES CO.,LTD
    3C-FB-96   # Emcraft Systems LLC
    3C-FD-FE   # Intel Corporate
    40-01-07   # Arista Corp
    40-01-C6   # 3COM EUROPE LTD
    40-04-0C   # A&T
    40-07-C0   # Railtec Systems GmbH
    40-0E-67   # Tremol Ltd.
    40-0E-85   # Samsung Electro Mechanics co.,LTD.
    40-11-DC   # Sonance
    40-12-E4   # Compass-EOS
    40-13-D9   # Global ES
    40-15-97   # Protect America, Inc.
    40-16-7E   # ASUSTek COMPUTER INC.
    40-16-9F   # TP-LINK TECHNOLOGIES CO.,LTD.
    40-16-FA   # EKM Metering
    40-18-B1   # Aerohive Networks Inc.
    40-18-D7   # Smartronix, Inc.
    40-1B-5F   # Weifang GoerTek Electronics Co., Ltd.
    40-1D-59   # Biometric Associates, LP
    40-22-ED   # Digital Projection Ltd
    40-25-C2   # Intel Corporate
    40-27-0B   # Mobileeco Co., Ltd
    40-28-14   # RFI Engineering
    40-2B-A1   # Sony Mobile Communications AB
    40-2C-F4   # Universal Global Scientific Industrial Co., Ltd.
    40-30-04   # Apple, Inc.
    40-30-67   # Conlog (Pty) Ltd
    40-33-1A   # Apple, Inc.
    40-33-6C   # Godrej & Boyce Mfg. co. ltd
    40-37-AD   # Macro Image Technology, Inc.
    40-3C-FC   # Apple, Inc.
    40-3D-EC   # HUMAX Co., Ltd.
    40-3F-8C   # TP-LINK TECHNOLOGIES CO.,LTD.
    40-40-22   # ZIV
    40-40-6B   # Icomera
    40-40-A7   # Sony Mobile Communications AB
    40-45-DA   # Spreadtrum Communications (Shanghai) Co., Ltd.
    40-49-0F   # Hon Hai Precision Ind. Co.,Ltd.
    40-4A-03   # ZyXEL Communications Corporation
    40-4A-18   # Addrek Smart Solutions
    40-4D-8E   # HUAWEI TECHNOLOGIES CO.,LTD
    40-4E-EB   # Higher Way Electronic Co., Ltd.
    40-50-E0   # Milton Security Group LLC
    40-51-6C   # Grandex International Corporation
    40-52-0D   # Pico Technology
    40-54-E4   # Wearsafe Labs Inc
    40-55-39   # Cisco Systems, Inc
    40-56-0C   # In Home Displays Ltd
    40-5A-9B   # ANOVO
    40-5D-82   # NETGEAR
    40-5F-BE   # RIM
    40-5F-C2   # Texas Instruments
    40-60-5A   # Hawkeye Tech Co. Ltd
    40-61-86   # MICRO-STAR INT'L CO.,LTD
    40-61-8E   # Stella-Green Co
    40-62-B6   # Tele system communication
    40-65-A3   # Sagemcom Broadband SAS
    40-66-7A   # mediola - connected living AG
    40-68-26   # Thales UK Limited
    40-6A-AB   # RIM
    40-6C-8F   # Apple, Inc.
    40-6F-2A   # BlackBerry RTS
    40-70-09   # ARRIS Group, Inc.
    40-70-4A   # Power Idea Technology Limited
    40-70-74   # Life Technology (China) Co., Ltd
    40-74-96   # aFUN TECHNOLOGY INC.
    40-78-6A   # Motorola Mobility LLC, a Lenovo Company
    40-78-75   # IMBEL - Industria de Material Belico do Brasil
    40-7A-80   # Nokia Corporation
    40-7B-1B   # Mettle Networks Inc.
    40-7F-E0   # Glory Star Technics (ShenZhen) Limited
    40-82-56   # Continental Automotive GmbH
    40-83-DE   # Zebra Technologies Inc
    40-84-93   # Clavister AB
    40-86-2E   # JDM MOBILE INTERNET SOLUTION CO., LTD.
    40-88-05   # Motorola Mobility LLC, a Lenovo Company
    40-88-E0   # Beijing Ereneben Information Technology Limited Shenzhen Branch
    40-8A-9A   # TITENG CO., Ltd.
    40-8B-07   # Actiontec Electronics, Inc
    40-8B-F6   # Shenzhen TCL New Technology Co; Ltd.
    40-8D-5C   # GIGA-BYTE TECHNOLOGY CO.,LTD.
    40-95-58   # Aisino Corporation
    40-97-D1   # BK Electronics cc
    40-98-4C   # Casacom Solutions AG
    40-98-4E   # Texas Instruments
    40-98-7B   # Aisino Corporation
    40-9B-0D   # Shenzhen Yourf Kwan Industrial Co., Ltd
    40-9F-87   # Jide Technology (Hong Kong) Limited
    40-9F-C7   # BAEKCHUN I&C Co., Ltd.
    40-A5-EF   # Shenzhen Four Seas Global Link Network Technology Co., Ltd.
    40-A6-77   # Juniper Networks
    40-A6-A4   # PassivSystems Ltd
    40-A6-D9   # Apple, Inc.
    40-A6-E8   # Cisco Systems, Inc
    40-A8-F0   # Hewlett Packard
    40-AC-8D   # Data Management, Inc.
    40-B0-FA   # LG Electronics
    40-B2-C8   # Nortel Networks
    40-B3-95   # Apple, Inc.
    40-B3-CD   # Chiyoda Electronics Co.,Ltd.
    40-B3-FC   # Logital Co. Limited
    40-B4-F0   # Juniper Networks
    40-B6-B1   # SUNGSAM CO,.Ltd
    40-B7-F3   # ARRIS Group, Inc.
    40-B8-37   # Sony Mobile Communications AB
    40-B8-9A   # Hon Hai Precision Ind. Co.,Ltd.
    40-BA-61   # ARIMA Communications Corp.
    40-BC-73   # Cronoplast  S.L.
    40-BC-8B   # itelio GmbH
    40-BD-9E   # Physio-Control, Inc
    40-BF-17   # Digistar Telecom. SA
    40-C2-45   # Shenzhen Hexicom Technology Co., Ltd.
    40-C4-D6   # ChongQing Camyu Technology Development Co.,Ltd.
    40-C6-2A   # Shanghai Jing Ren Electronic Technology Co., Ltd.
    40-C7-C9   # Naviit Inc.
    40-CB-A8   # HUAWEI TECHNOLOGIES CO.,LTD
    40-CD-3A   # Z3 Technology
    40-D2-8A   # Nintendo Co., Ltd.
    40-D3-2D   # Apple, Inc.
    40-D3-57   # Ison Technology Co., Ltd.
    40-D4-0E   # Biodata Ltd
    40-D5-59   # MICRO S.E.R.I.
    40-D8-55   # IEEE Registration Authority
    40-E2-30   # AzureWave Technology Inc.
    40-E3-D6   # Aruba Networks
    40-E7-30   # DEY Storage Systems, Inc.
    40-E7-93   # Shenzhen Siviton Technology Co.,Ltd
    40-EA-CE   # FOUNDER BROADBAND NETWORK SERVICE CO.,LTD
    40-EC-F8   # Siemens AG
    40-EF-4C   # Fihonest communication co.,Ltd
    40-F0-2F   # Liteon Technology Corporation
    40-F1-4C   # ISE Europe SPRL
    40-F2-01   # Sagemcom Broadband SAS
    40-F2-E9   # IBM
    40-F3-08   # Murata Manufacturing Co., Ltd.
    40-F4-07   # Nintendo Co., Ltd.
    40-F4-EC   # Cisco Systems, Inc
    40-F5-2E   # Leica Microsystems (Schweiz) AG
    40-FC-89   # ARRIS Group, Inc.
    44-00-10   # Apple, Inc.
    44-03-A7   # Cisco Systems, Inc
    44-0C-FD   # NetMan Co., Ltd.
    44-11-C2   # Telegartner Karl Gartner GmbH
    44-13-19   # WKK TECHNOLOGY LTD.
    44-18-4F   # Fitview
    44-19-B6   # Hangzhou Hikvision Digital Technology Co.,Ltd.
    44-1C-A8   # Hon Hai Precision Ind. Co.,Ltd.
    44-1E-91   # ARVIDA Intelligent Electronics Technology  Co.,Ltd.
    44-1E-A1   # Hewlett Packard
    44-23-AA   # Farmage Co., Ltd.
    44-25-BB   # Bamboo Entertainment Corporation
    44-29-38   # NietZsche enterprise Co.Ltd.
    44-2A-60   # Apple, Inc.
    44-2A-FF   # E3 Technology, Inc.
    44-2B-03   # Cisco Systems, Inc
    44-31-92   # Hewlett Packard
    44-32-2A   # Avaya Inc
    44-32-C8   # Technicolor USA Inc.
    44-33-4C   # Shenzhen Bilian electronic CO.,LTD
    44-34-8F   # MXT INDUSTRIAL LTDA
    44-35-6F   # Neterix
    44-37-19   # 2 Save Energy Ltd
    44-37-6F   # Young Electric Sign Co
    44-37-E6   # Hon Hai Precision Ind. Co.,Ltd.
    44-38-39   # Cumulus Networks, inc
    44-39-C4   # Universal Global Scientific Industrial Co.,Ltd
    44-3C-9C   # Pintsch Tiefenbach GmbH
    44-3D-21   # Nuvolt
    44-3E-B2   # DEOTRON Co., LTD.
    44-48-91   # HDMI Licensing, LLC
    44-4A-65   # Silverflare Ltd.
    44-4C-0C   # Apple, Inc.
    44-4C-A8   # Arista Networks
    44-4E-1A   # Samsung Electronics Co.,Ltd
    44-4F-5E   # Pan Studios Co.,Ltd.
    44-51-DB   # Raytheon BBN Technologies
    44-54-C0   # Thompson Aerospace
    44-55-B1   # HUAWEI TECHNOLOGIES CO.,LTD
    44-56-8D   # PNC Technologies  Co., Ltd.
    44-56-B7   # Spawn Labs, Inc
    44-58-29   # Cisco SPVTG
    44-59-9F   # Criticare Systems, Inc
    44-5E-CD   # Razer Inc
    44-5E-F3   # Tonalite Holding B.V.
    44-5F-7A   # Shihlin Electric & Engineering Corp.
    44-5F-8C   # Intercel Group Limited
    44-61-32   # ecobee inc
    44-61-9C   # FONsystem co. ltd.
    44-65-6A   # Mega Video Electronic(HK) Industry Co., Ltd
    44-66-6E   # IP-LINE
    44-67-55   # Orbit Irrigation
    44-68-AB   # JUIN COMPANY, LIMITED
    44-6C-24   # Reallin Electronic Co.,Ltd
    44-6D-57   # Liteon Technology Corporation
    44-6D-6C   # Samsung Electronics Co.,Ltd
    44-70-0B   # IFFU
    44-70-98   # MING HONG TECHNOLOGY (SHEN ZHEN) LIMITED
    44-73-D6   # Logitech
    44-74-6C   # Sony Mobile Communications AB
    44-7B-C4   # DualShine Technology(SZ)Co.,Ltd
    44-7C-7F   # Innolight Technology Corporation
    44-7D-A5   # VTION INFORMATION TECHNOLOGY (FUJIAN) CO.,LTD
    44-7E-76   # Trek Technology (S) Pte Ltd
    44-7E-95   # Alpha and Omega, Inc
    44-80-EB   # Motorola Mobility LLC, a Lenovo Company
    44-82-E5   # HUAWEI TECHNOLOGIES CO.,LTD
    44-83-12   # Star-Net
    44-85-00   # Intel Corporate
    44-86-C1   # Siemens Low Voltage & Products
    44-87-23   # HOYA SERVICE CORPORATION
    44-87-FC   # ELITEGROUP COMPUTER SYSTEM CO., LTD.
    44-88-CB   # Camco Technologies NV
    44-8A-5B   # Micro-Star INT'L CO., LTD.
    44-8C-52   # KTIS CO., Ltd
    44-8E-12   # DT Research, Inc.
    44-8E-81   # VIG
    44-91-DB   # Shanghai Huaqin Telecom Technology Co.,Ltd
    44-94-FC   # NETGEAR
    44-95-FA   # Qingdao Santong Digital Technology Co.Ltd
    44-96-2B   # Aidon Oy
    44-97-5A   # SHENZHEN FAST TECHNOLOGIES CO.,LTD
    44-9B-78   # The Now Factory
    44-9C-B5   # Alcomp, Inc
    44-A4-2D   # TCT Mobile Limited
    44-A6-89   # PROMAX ELECTRONICA SA
    44-A6-E5   # THINKING TECHNOLOGY CO.,LTD
    44-A7-CF   # Murata Manufacturing Co., Ltd.
    44-A8-42   # Dell Inc.
    44-A8-C2   # SEWOO TECH CO., LTD
    44-AA-27   # udworks Co., Ltd.
    44-AA-E8   # Nanotec Electronic GmbH & Co. KG
    44-AD-D9   # Cisco Systems, Inc
    44-B3-2D   # TP-LINK TECHNOLOGIES CO.,LTD.
    44-B3-82   # Kuang-chi Institute of Advanced Technology
    44-C1-5C   # Texas Instruments
    44-C2-33   # Guangzhou Comet Technology Development Co.Ltd
    44-C3-06   # SIFROM Inc.
    44-C3-9B   # OOO RUBEZH NPO
    44-C4-A9   # Opticom Communication, LLC
    44-C5-6F   # NGN Easy Satfinder (Tianjin) Electronic Co., Ltd
    44-C6-9B   # Wuhan Feng Tian Information Network CO.,LTD
    44-C9-A2   # Greenwald Industries
    44-CE-7D   # SFR
    44-D1-5E   # Shanghai Kingto Information Technology Ltd
    44-D2-44   # Seiko Epson Corporation
    44-D2-CA   # Anvia TV Oy
    44-D3-CA   # Cisco Systems, Inc
    44-D4-E0   # Sony Mobile Communications AB
    44-D6-3D   # Talari Networks
    44-D8-32   # AzureWave Technology Inc.
    44-D8-84   # Apple, Inc.
    44-D9-E7   # Ubiquiti Networks, Inc.
    44-DC-91   # PLANEX COMMUNICATIONS INC.
    44-DC-CB   # SEMINDIA SYSTEMS PVT LTD
    44-E0-8E   # Cisco SPVTG
    44-E1-37   # ARRIS Group, Inc.
    44-E4-9A   # OMNITRONICS PTY LTD
    44-E4-D9   # Cisco Systems, Inc
    44-E8-A5   # Myreka Technologies Sdn. Bhd.
    44-E9-DD   # Sagemcom Broadband SAS
    44-ED-57   # Longicorn, inc.
    44-EE-02   # MTI Ltd.
    44-EE-30   # Budelmann Elektronik GmbH
    44-F4-36   # zte corporation
    44-F4-59   # Samsung Electronics
    44-F4-77   # Juniper Networks
    44-F8-49   # Union Pacific Railroad
    44-FB-42   # Apple, Inc.
    44-FD-A3   # Everysight LTD.
    48-00-31   # HUAWEI TECHNOLOGIES CO.,LTD
    48-02-2A   # B-Link Electronic Limited
    48-03-62   # DESAY ELECTRONICS(HUIZHOU)CO.,LTD
    48-06-6A   # Tempered Networks, Inc.
    48-0C-49   # NAKAYO TELECOMMUNICATIONS,INC
    48-0F-CF   # Hewlett Packard
    48-12-49   # Luxcom Technologies Inc.
    48-13-7E   # Samsung Electronics Co.,Ltd
    48-13-F3   # BBK Electronics Corp., Ltd.
    48-17-4C   # MicroPower technologies
    48-18-42   # Shanghai Winaas Co. Equipment Co. Ltd.
    48-1A-84   # Pointer Telocation Ltd
    48-1B-D2   # Intron Scientific co., ltd.
    48-1D-70   # Cisco SPVTG
    48-26-E8   # Tek-Air Systems, Inc.
    48-28-2F   # zte corporation
    48-2C-EA   # Motorola Inc Business Light Radios
    48-33-DD   # ZENNIO AVANCE Y TECNOLOGIA, S.L.
    48-34-3D   # IEP GmbH
    48-36-5F   # Wintecronics Ltd.
    48-39-74   # Proware Technologies Co., Ltd.
    48-3D-32   # Syscor Controls &amp; Automation
    48-43-7C   # Apple, Inc.
    48-44-87   # Cisco SPVTG
    48-44-F7   # Samsung Electronics Co., LTD
    48-45-20   # Intel Corporate
    48-46-F1   # Uros Oy
    48-46-FB   # HUAWEI TECHNOLOGIES CO.,LTD
    48-50-73   # Microsoft Corporation
    48-51-B7   # Intel Corporate
    48-52-61   # SOREEL
    48-54-15   # NET RULES TECNOLOGIA EIRELI
    48-55-5F   # Fiberhome Telecommunication Tech.Co.,Ltd.
    48-57-DD   # Facebook
    48-59-29   # LG Electronics
    48-5A-3F   # WISOL
    48-5A-B6   # Hon Hai Precision Ind. Co.,Ltd.
    48-5B-39   # ASUSTek COMPUTER INC.
    48-5D-36   # Verizon
    48-5D-60   # AzureWave Technology Inc.
    48-60-BC   # Apple, Inc.
    48-61-A3   # Concern Axion JSC
    48-62-76   # HUAWEI TECHNOLOGIES CO.,LTD
    48-6B-2C   # BBK Electronics Corp., Ltd.,
    48-6B-91   # Fleetwood Group Inc.
    48-6E-73   # Pica8, Inc.
    48-6E-FB   # Davit System Technology Co., Ltd.
    48-6F-D2   # StorSimple Inc
    48-71-19   # SGB GROUP LTD.
    48-74-6E   # Apple, Inc.
    48-76-04   # Private
    48-82-44   # Life Fitness / Div. of Brunswick
    48-86-E8   # Microsoft Corporation
    48-8A-D2   # SHENZHEN MERCURY COMMUNICATION TECHNOLOGIES CO.,LTD.
    48-8E-42   # DIGALOG GmbH
    48-91-53   # Weinmann Geräte für Medizin GmbH + Co. KG
    48-91-F6   # Shenzhen Reach software technology CO.,LTD
    48-9A-42   # Technomate Ltd
    48-9B-E2   # SCI Innovations Ltd
    48-9D-18   # Flashbay Limited
    48-9D-24   # BlackBerry RTS
    48-A2-2D   # Shenzhen Huaxuchang Telecom Technology Co.,Ltd
    48-A2-B7   # Kodofon JSC
    48-A6-D2   # GJsun Optical Science and Tech Co.,Ltd.
    48-A9-D2   # Wistron Neweb Corp.
    48-AA-5D   # Store Electronic Systems
    48-AD-08   # HUAWEI TECHNOLOGIES CO.,LTD
    48-B2-53   # Marketaxess Corporation
    48-B5-A7   # Glory Horse Industries Ltd.
    48-B6-20   # ROLI Ltd.
    48-B8-DE   # HOMEWINS TECHNOLOGY CO.,LTD.
    48-B9-77   # PulseOn Oy
    48-B9-C2   # Teletics Inc.
    48-BE-2D   # Symanitron
    48-BF-74   # Baicells Technologies Co.,LTD
    48-C0-93   # Xirrus, Inc.
    48-C1-AC   # PLANTRONICS, INC.
    48-C8-62   # Simo Wireless,Inc.
    48-C8-B6   # SysTec GmbH
    48-CB-6E   # Cello Electronics (UK) Ltd
    48-D0-CF   # Universal Electronics, Inc.
    48-D1-8E   # Metis Communication Co.,Ltd
    48-D2-24   # Liteon Technology Corporation
    48-D5-4C   # Jeda Networks
    48-D7-05   # Apple, Inc.
    48-D7-FF   # BLANKOM Antennentechnik GmbH
    48-D8-55   # Telvent
    48-D8-FE   # ClarIDy Solutions, Inc.
    48-DB-50   # HUAWEI TECHNOLOGIES CO.,LTD
    48-DC-FB   # Nokia Corporation
    48-DF-1C   # Wuhan NEC Fibre Optic Communications industry Co. Ltd
    48-E1-AF   # Vity
    48-E2-44   # Hon Hai Precision Ind. Co.,Ltd.
    48-E9-F1   # Apple, Inc.
    48-EA-63   # Zhejiang Uniview Technologies Co., Ltd.
    48-EB-30   # ETERNA TECHNOLOGY, INC.
    48-ED-80   # daesung eltec
    48-EE-07   # Silver Palm Technologies LLC
    48-EE-0C   # D-Link International
    48-EE-86   # UTStarcom (China) Co.,Ltd
    48-F2-30   # Ubizcore Co.,LTD
    48-F3-17   # Private
    48-F4-7D   # TechVision Holding  Internation Limited
    48-F7-C0   # Cisco SPVTG
    48-F7-F1   # Alcatel-Lucent
    48-F8-B3   # Cisco-Linksys, LLC
    48-F8-E1   # Alcatel Lucent WT
    48-F9-25   # Maestronic
    48-FC-B8   # Woodstream Corporation
    48-FE-EA   # HOMA B.V.
    4C-00-82   # Cisco Systems, Inc
    4C-02-2E   # CMR KOREA CO., LTD
    4C-02-89   # LEX COMPUTECH CO., LTD
    4C-06-8A   # Basler Electric Company
    4C-07-C9   # COMPUTER OFFICE Co.,Ltd.
    4C-09-B4   # zte corporation
    4C-09-D4   # Arcadyan Technology Corporation
    4C-0B-3A   # TCT Mobile Limited
    4C-0B-BE   # Microsoft
    4C-0D-EE   # JABIL CIRCUIT (SHANGHAI) LTD.
    4C-0F-6E   # Hon Hai Precision Ind. Co.,Ltd.
    4C-0F-C7   # Earda Electronics Co.,Ltd
    4C-11-BF   # ZHEJIANG DAHUA TECHNOLOGY CO.,LTD.
    4C-14-80   # NOREGON SYSTEMS, INC
    4C-14-A3   # TCL Technoly Electronics (Huizhou) Co., Ltd.
    4C-16-F1   # zte corporation
    4C-17-EB   # Sagemcom Broadband SAS
    4C-1A-3A   # PRIMA Research And Production Enterprise Ltd.
    4C-1A-95   # Novakon Co., Ltd.
    4C-1F-CC   # HUAWEI TECHNOLOGIES CO.,LTD
    4C-21-D0   # Sony Mobile Communications AB
    4C-22-58   # cozybit, Inc.
    4C-25-78   # Nokia Corporation
    4C-26-E7   # Welgate Co., Ltd.
    4C-2C-80   # Beijing Skyway Technologies Co.,Ltd
    4C-2C-83   # Zhejiang KaNong Network Technology Co.,Ltd.
    4C-2F-9D   # ICM Controls
    4C-30-89   # Thales Transportation Systems GmbH
    4C-32-2D   # TELEDATA NETWORKS
    4C-32-D9   # M Rutty Holdings Pty. Ltd.
    4C-34-88   # Intel Corporate
    4C-39-09   # HPL Electric & Power Private Limited
    4C-39-10   # Newtek Electronics co., Ltd.
    4C-3B-74   # VOGTEC(H.K.) Co., Ltd
    4C-3C-16   # Samsung Electronics Co.,Ltd
    4C-48-DA   # Beijing Autelan Technology Co.,Ltd
    4C-4B-68   # Mobile Device, Inc.
    4C-4E-35   # Cisco Systems, Inc
    4C-54-27   # Linepro Sp. z o.o.
    4C-54-99   # HUAWEI TECHNOLOGIES CO.,LTD
    4C-55-85   # Hamilton Systems
    4C-55-B8   # Turkcell Teknoloji
    4C-55-CC   # Zentri Pty Ltd
    4C-5D-CD   # Oy Finnish Electric Vehicle Technologies Ltd
    4C-5E-0C   # Routerboard.com
    4C-5F-D2   # Alcatel-Lucent
    4C-60-D5   # airPointe of New Hampshire
    4C-60-DE   # NETGEAR
    4C-62-55   # SANMINA-SCI SYSTEM DE MEXICO S.A. DE C.V.
    4C-63-EB   # Application Solutions (Electronics and Vision) Ltd
    4C-64-D9   # Guangdong Leawin Group Co., Ltd
    4C-6E-6E   # Comnect Technology CO.,LTD
    4C-72-B9   # PEGATRON CORPORATION
    4C-73-67   # Genius Bytes Software Solutions GmbH
    4C-73-A5   # KOVE
    4C-74-03   # BQ
    4C-76-25   # Dell Inc.
    4C-77-4F   # Embedded Wireless Labs
    4C-78-97   # Arrowhead Alarm Products Ltd
    4C-79-BA   # Intel Corporate
    4C-7C-5F   # Apple, Inc.
    4C-7F-62   # Nokia Corporation
    4C-80-4F   # Armstrong Monitoring Corp
    4C-80-93   # Intel Corporate
    4C-82-CF   # Echostar Technologies
    4C-83-DE   # Cisco SPVTG
    4C-8B-30   # Actiontec Electronics, Inc
    4C-8B-55   # Grupo Digicon
    4C-8B-EF   # HUAWEI TECHNOLOGIES CO.,LTD
    4C-8D-79   # Apple, Inc.
    4C-8E-CC   # SILKAN SA
    4C-8F-A5   # Jastec
    4C-96-14   # Juniper Networks
    4C-98-EF   # Zeo
    4C-9E-80   # KYOKKO ELECTRIC Co., Ltd.
    4C-9E-E4   # Hanyang Navicom Co.,Ltd.
    4C-9E-FF   # ZyXEL Communications Corporation
    4C-A1-61   # Rain Bird Corporation
    4C-A5-15   # Baikal Electronics JSC
    4C-A5-6D   # Samsung Electronics Co.,Ltd
    4C-A7-4B   # Alcatel Lucent
    4C-A9-28   # Insensi
    4C-AA-16   # AzureWave Technologies (Shanghai) Inc.
    4C-AB-33   # KST technology
    4C-AC-0A   # zte corporation
    4C-AE-31   # ShengHai Electronics (Shenzhen) Ltd
    4C-B0-E8   # Beijing RongZhi xinghua technology co., LTD
    4C-B1-6C   # HUAWEI TECHNOLOGIES CO.,LTD
    4C-B1-99   # Apple, Inc.
    4C-B4-4A   # NANOWAVE Technologies Inc.
    4C-B4-EA   # HRD (S) PTE., LTD.
    4C-B7-6D   # Novi Security
    4C-B8-1C   # SAM Electronics GmbH
    4C-B8-2C   # Cambridge Mobile Telematics, Inc.
    4C-B9-C8   # CONET CO., LTD.
    4C-BA-A3   # Bison Electronics Inc.
    4C-BB-58   # Chicony Electronics Co., Ltd.
    4C-BC-42   # Shenzhen Hangsheng Electronics Co.,Ltd.
    4C-BC-A5   # Samsung Electronics Co.,Ltd
    4C-C4-52   # Shang Hai Tyd. Electon Technology Ltd.
    4C-C6-02   # Radios, Inc.
    4C-C6-81   # Shenzhen Aisat Electronic Co., Ltd.
    4C-C9-4F   # Alcatel-Lucent
    4C-CA-53   # Skyera, Inc.
    4C-CB-F5   # zte corporation
    4C-CC-34   # Motorola Solutions Inc.
    4C-CC-6A   # Micro-Star INTL CO., LTD.
    4C-D0-8A   # HUMAX Co., Ltd.
    4C-D6-37   # Qsono Electronics Co., Ltd
    4C-D7-B6   # Helmer Scientific
    4C-D9-C4   # Magneti Marelli Automotive Electronics (Guangzhou) Co. Ltd
    4C-DF-3D   # TEAM ENGINEERS ADVANCE TECHNOLOGIES INDIA PVT LTD
    4C-E1-BB   # Zhuhai HiFocus Technology Co., Ltd.
    4C-E2-F1   # sclak srl
    4C-E6-76   # BUFFALO.INC
    4C-E9-33   # RailComm, LLC
    4C-EB-42   # Intel Corporate
    4C-ED-DE   # ASKEY COMPUTER CORP
    4C-EE-B0   # SHC Netzwerktechnik GmbH
    4C-F0-2E   # Vifa Denmark A/S
    4C-F2-BF   # Cambridge Industries(Group) Co.,Ltd.
    4C-F4-5B   # Blue Clover Devices
    4C-F5-A0   # Scalable Network Technologies Inc
    4C-F7-37   # SamJi Electronics Co., Ltd
    4C-FB-45   # HUAWEI TECHNOLOGIES CO.,LTD
    4C-FF-12   # Fuze Entertainment Co., ltd
    50-00-8C   # Hong Kong Telecommunications (HKT) Limited
    50-01-BB   # Samsung Electronics
    50-05-3D   # CyWee Group Ltd
    50-06-04   # Cisco Systems, Inc
    50-06-AB   # Cisco Systems, Inc
    50-0B-32   # Foxda Technology Industrial(ShenZhen)Co.,LTD
    50-0E-6D   # TrafficCast International
    50-11-EB   # SilverNet Ltd
    50-14-B5   # Richfit Information Technology Co., Ltd
    50-17-FF   # Cisco Systems, Inc
    50-1A-A5   # GN Netcom A/S
    50-1A-C5   # Microsoft
    50-1C-BF   # Cisco Systems, Inc
    50-20-6B   # Emerson Climate Technologies Transportation Solutions
    50-22-67   # PixeLINK
    50-25-2B   # Nethra Imaging Incorporated
    50-26-90   # FUJITSU LIMITED
    50-27-C7   # TECHNART Co.,Ltd
    50-29-4D   # NANJING IOT SENSOR TECHNOLOGY CO,LTD
    50-2A-7E   # Smart electronic GmbH
    50-2A-8B   # Telekom Research and Development Sdn Bhd
    50-2D-1D   # Nokia Corporation
    50-2D-A2   # Intel Corporate
    50-2D-F4   # Phytec Messtechnik GmbH
    50-2E-5C   # HTC Corporation
    50-2E-CE   # Asahi Electronics Co.,Ltd
    50-31-AD   # ABB Global Industries and Services Private Limited
    50-32-75   # Samsung Electronics Co.,Ltd
    50-39-55   # Cisco SPVTG
    50-3C-C4   # Lenovo Mobile Communication Technology Ltd.
    50-3D-E5   # Cisco Systems, Inc
    50-3F-56   # Syncmold Enterprise Corp
    50-45-F7   # Liuhe Intelligence Technology Ltd.
    50-46-5D   # ASUSTek COMPUTER INC.
    50-48-EB   # BEIJING HAIHEJINSHENG NETWORK TECHNOLOGY CO. LTD.
    50-4A-5E   # Masimo Corporation
    50-4A-6E   # NETGEAR
    50-4F-94   # Loxone Electronics GmbH
    50-50-2A   # Egardia
    50-50-65   # TAKT Corporation
    50-55-27   # LG Electronics
    50-56-63   # Texas Instruments
    50-56-A8   # Jolla Ltd
    50-56-BF   # Samsung Electronics Co.,Ltd
    50-57-A8   # Cisco Systems, Inc
    50-58-00   # WyTec International, Inc.
    50-5A-C6   # GUANGDONG SUPER TELECOM CO.,LTD.
    50-60-28   # Xirrus Inc.
    50-61-84   # Avaya Inc
    50-61-D6   # Indu-Sol GmbH
    50-63-13   # Hon Hai Precision Ind. Co.,Ltd.
    50-64-41   # Greenlee
    50-65-F3   # Hewlett Packard
    50-67-87   # iTellus
    50-67-AE   # Cisco Systems, Inc
    50-67-F0   # ZyXEL Communications Corporation
    50-6A-03   # NETGEAR
    50-6F-9A   # Wi-Fi Alliance
    50-70-E5   # He Shan World Fair Electronics Technology Limited
    50-72-24   # Texas Instruments
    50-72-4D   # BEG Brueck Electronic GmbH
    50-76-91   # Tekpea, Inc.
    50-76-A6   # Ecil Informatica Ind. Com. Ltda
    50-79-5B   # Interexport Telecomunicaciones S.A.
    50-7A-55   # Apple, Inc.
    50-7B-9D   # LCFC(HeFei) Electronics Technology co., ltd
    50-7D-02   # BIODIT
    50-7E-5D   # Arcadyan Technology Corporation
    50-85-69   # Samsung Electronics Co.,Ltd
    50-87-89   # Cisco Systems, Inc
    50-87-B8   # Nuvyyo Inc
    50-8A-42   # Uptmate Technology Co., LTD
    50-8A-CB   # SHENZHEN MAXMADE TECHNOLOGY CO., LTD.
    50-8C-77   # DIRMEIER Schanktechnik GmbH &Co KG
    50-8D-6F   # CHAHOO Limited
    50-93-4F   # Gradual Tecnologia Ltda.
    50-97-72   # Westinghouse Digital
    50-98-71   # Inventum Technologies Private Limited
    50-9F-27   # HUAWEI TECHNOLOGIES CO.,LTD
    50-A0-54   # Actineon
    50-A0-BF   # Alba Fiber Systems Inc.
    50-A4-C8   # Samsung Electronics Co.,Ltd
    50-A6-E3   # David Clark Company
    50-A7-15   # Aboundi, Inc.
    50-A7-2B   # HUAWEI TECHNOLOGIES CO.,LTD
    50-A7-33   # Ruckus Wireless
    50-A9-DE   # Smartcom - Bulgaria AD
    50-AB-BF   # Hoseo Telecom
    50-AD-D5   # Dynalec Corporation
    50-AF-73   # Shenzhen Bitland Information Technology Co., Ltd.
    50-B6-95   # Micropoint Biotechnologies,Inc.
    50-B7-C3   # Samsung Electronics CO., LTD
    50-B8-88   # wi2be Tecnologia S/A
    50-B8-A2   # ImTech Technologies LLC,
    50-BD-5F   # TP-LINK TECHNOLOGIES CO.,LTD.
    50-C0-06   # Carmanah Signs
    50-C2-71   # SECURETECH INC
    50-C5-8D   # Juniper Networks
    50-C7-BF   # TP-LINK TECHNOLOGIES CO.,LTD.
    50-C8-E5   # Samsung Electronics Co.,Ltd
    50-C9-71   # GN Netcom A/S
    50-C9-A0   # SKIPPER Electronics AS
    50-CC-F8   # Samsung Electro Mechanics
    50-CD-22   # Avaya Inc
    50-CD-32   # NanJing Chaoran Science & Technology Co.,Ltd.
    50-CE-75   # Measy Electronics Ltd
    50-D2-74   # Steffes Corporation
    50-D5-9C   # Thai Habel Industrial Co., Ltd.
    50-D6-D7   # Takahata Precision
    50-DA-00   # Hangzhou H3C Technologies Co., Limited
    50-DF-95   # Lytx
    50-E0-C7   # TurControlSystme AG
    50-E1-4A   # Private
    50-E5-49   # GIGA-BYTE TECHNOLOGY CO.,LTD.
    50-EA-D6   # Apple, Inc.
    50-EB-1A   # Brocade Communications Systems, Inc.
    50-ED-78   # Changzhou Yongse Infotech Co.,Ltd
    50-ED-94   # EGATEL SL
    50-F0-03   # Open Stack, Inc.
    50-F0-D3   # Samsung Electronics Co.,Ltd
    50-F4-3C   # Leeo Inc
    50-F5-20   # Samsung Electronics Co.,Ltd
    50-F6-1A   # Kunshan JADE Technologies co., Ltd.
    50-FA-84   # TP-LINK TECHNOLOGIES CO.,LTD.
    50-FA-AB   # L-tek d.o.o.
    50-FC-30   # Treehouse Labs
    50-FC-9F   # Samsung Electronics Co.,Ltd
    50-FE-F2   # Sify Technologies Ltd
    54-03-F5   # EBN Technology Corp.
    54-04-96   # Gigawave LTD
    54-04-A6   # ASUSTek COMPUTER INC.
    54-05-36   # Vivago Oy
    54-05-5F   # Alcatel Lucent
    54-09-8D   # deister electronic GmbH
    54-11-2F   # Sulzer Pump Solutions Finland Oy
    54-11-5F   # Atamo Pty Ltd
    54-14-73   # Wingtech Group (HongKong）Limited
    54-14-FD   # Orbbec 3D Technology International
    54-1B-5D   # Techno-Innov
    54-1D-FB   # Freestyle Energy Ltd
    54-1E-56   # Juniper Networks
    54-1F-D5   # Advantage Electronics
    54-20-18   # Tely Labs
    54-21-60   # Resolution Products
    54-22-F8   # zte corporation
    54-26-96   # Apple, Inc.
    54-27-1E   # AzureWave Technology Inc.
    54-27-58   # Motorola (Wuhan) Mobility Technologies Communication Co., Ltd.
    54-2A-9C   # LSY Defense, LLC.
    54-2A-A2   # Alpha Networks Inc.
    54-2C-EA   # PROTECTRON
    54-2F-89   # Euclid Laboratories, Inc.
    54-31-31   # Raster Vision Ltd
    54-35-30   # Hon Hai Precision Ind. Co.,Ltd.
    54-35-DF   # Symeo GmbH
    54-36-9B   # 1Verge Internet Technology (Beijing) Co., Ltd.
    54-39-68   # Edgewater Networks Inc
    54-39-DF   # HUAWEI TECHNOLOGIES CO.,LTD
    54-3D-37   # Ruckus Wireless
    54-40-AD   # Samsung Electronics Co.,Ltd
    54-42-49   # Sony Corporation
    54-44-08   # Nokia Corporation
    54-46-6B   # Shenzhen CZTIC Electronic Technology Co., Ltd
    54-4A-00   # Cisco Systems, Inc
    54-4A-05   # wenglor sensoric gmbh
    54-4A-16   # Texas Instruments
    54-4B-8C   # Juniper Networks
    54-4E-45   # Private
    54-4E-90   # Apple, Inc.
    54-51-46   # AMG Systems Ltd.
    54-53-ED   # Sony Corporation
    54-54-14   # Digital RF Corea, Inc
    54-5E-BD   # NL Technologies
    54-5F-A9   # Teracom Limited
    54-60-09   # Google, Inc.
    54-61-72   # ZODIAC AEROSPACE SAS
    54-61-EA   # Zaplox AB
    54-64-D9   # Sagemcom Broadband SAS
    54-65-DE   # ARRIS Group, Inc.
    54-67-51   # Compal Broadband Networks, Inc.
    54-72-4F   # Apple, Inc.
    54-73-98   # Toyo Electronics Corporation
    54-74-E6   # Webtech Wireless
    54-75-D0   # Cisco Systems, Inc
    54-78-1A   # Cisco Systems, Inc
    54-79-75   # Nokia Corporation
    54-7C-69   # Cisco Systems, Inc
    54-7F-54   # INGENICO
    54-7F-A8   # TELCO systems, s.r.o.
    54-7F-EE   # Cisco Systems, Inc
    54-81-AD   # Eagle Research Corporation
    54-84-7B   # Digital Devices GmbH
    54-88-0E   # Samsung Electro Mechanics co., LTD.
    54-89-22   # Zelfy Inc
    54-89-98   # HUAWEI TECHNOLOGIES CO.,LTD
    54-92-BE   # Samsung Electronics Co.,Ltd
    54-93-59   # SHENZHEN TWOWING TECHNOLOGIES CO.,LTD.
    54-94-78   # Silvershore Technology Partners
    54-9A-11   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    54-9A-16   # Uzushio Electric Co.,Ltd.
    54-9B-12   # Samsung Electronics
    54-9D-85   # EnerAccess inc
    54-9F-13   # Apple, Inc.
    54-9F-35   # Dell Inc.
    54-A0-4F   # t-mac Technologies Ltd
    54-A0-50   # ASUSTek COMPUTER INC.
    54-A2-74   # Cisco Systems, Inc
    54-A3-1B   # Shenzhen Linkworld Technology Co,.LTD
    54-A3-FA   # BQT Solutions (Australia)Pty Ltd
    54-A5-1B   # HUAWEI TECHNOLOGIES CO.,LTD
    54-A5-4B   # NSC Communications Siberia Ltd
    54-A6-19   # Alcatel-Lucent Shanghai Bell Co., Ltd
    54-A9-D4   # Minibar Systems
    54-AB-3A   # QUANTA COMPUTER INC.
    54-AE-27   # Apple, Inc.
    54-B6-20   # SUHDOL E&C Co.Ltd.
    54-B7-53   # Hunan Fenghui Yinjia Science And Technology Co.,Ltd
    54-B8-0A   # D-Link International
    54-BE-53   # zte corporation
    54-BE-F7   # PEGATRON CORPORATION
    54-C8-0F   # TP-LINK TECHNOLOGIES CO.,LTD.
    54-CD-10   # Panasonic Mobile Communications Co.,Ltd.
    54-CD-A7   # Fujian Shenzhou Electronic Co.,Ltd
    54-CD-EE   # ShenZhen Apexis Electronic Co.,Ltd
    54-D0-ED   # AXIM Communications
    54-D1-63   # MAX-TECH,INC
    54-D1-B0   # Universal Laser Systems, Inc
    54-D4-6F   # Cisco SPVTG
    54-DF-00   # Ulterius Technologies, LLC
    54-DF-63   # Intrakey technologies GmbH
    54-E0-32   # Juniper Networks
    54-E1-40   # INGENICO
    54-E2-C8   # Dongguan Aoyuan Electronics Technology Co., Ltd
    54-E2-E0   # Pace plc
    54-E3-B0   # JVL Industri Elektronik
    54-E4-3A   # Apple, Inc.
    54-E4-BD   # FN-LINK TECHNOLOGY LIMITED
    54-E6-3F   # ShenZhen LingKeWeiEr Technology Co., Ltd.
    54-E6-FC   # TP-LINK TECHNOLOGIES CO.,LTD.
    54-EA-A8   # Apple, Inc.
    54-EE-75   # Wistron InfoComm(Kunshan)Co.,Ltd.
    54-EF-92   # Shenzhen Elink Technology Co., LTD
    54-EF-FE   # Fullpower Technologies, Inc.
    54-F5-B6   # ORIENTAL PACIFIC INTERNATIONAL LIMITED
    54-F6-66   # Berthold Technologies GmbH and Co.KG
    54-F6-C5   # FUJIAN STAR-NET COMMUNICATION CO.,LTD
    54-F8-76   # ABB AG
    54-FA-3E   # Samsung Electronics Co.,Ltd
    54-FB-58   # WISEWARE, Lda
    54-FD-BF   # Scheidt & Bachmann GmbH
    54-FF-82   # Davit Solution co.
    54-FF-CF   # Mopria Alliance
    58-04-CB   # Tianjin Huisun Technology Co.,Ltd.
    58-05-28   # LABRIS NETWORKS
    58-05-56   # Elettronica GF S.r.L.
    58-08-FA   # Fiber Optic & telecommunication INC.
    58-09-43   # Private
    58-09-E5   # Kivic Inc.
    58-0A-20   # Cisco Systems, Inc
    58-10-8C   # Intelbras
    58-12-43   # AcSiP Technology Corp.
    58-16-26   # Avaya Inc
    58-17-0C   # Sony Mobile Communications AB
    58-1C-BD   # Affinegy
    58-1D-91   # Advanced Mobile Telecom co.,ltd.
    58-1F-28   # HUAWEI TECHNOLOGIES CO.,LTD
    58-1F-67   # Open-m technology limited
    58-1F-AA   # Apple, Inc.
    58-1F-EF   # Tuttnaer LTD
    58-20-B1   # Hewlett Packard
    58-21-36   # KMB systems, s.r.o.
    58-23-8C   # Technicolor CH USA
    58-2A-F7   # HUAWEI TECHNOLOGIES CO.,LTD
    58-2B-DB   # Pax AB
    58-2E-FE   # Lighting Science Group
    58-2F-42   # Universal Electric Corporation
    58-34-3B   # Glovast Technology Ltd.
    58-35-D9   # Cisco Systems, Inc
    58-3C-C6   # Omneality Ltd.
    58-3F-54   # LG Electronics (Mobile Communications)
    58-42-E4   # Baxter International Inc
    58-44-98   # Xiaomi Communications Co Ltd
    58-46-8F   # Koncar Electronics and Informatics
    58-46-E1   # Baxter International Inc
    58-47-04   # Shenzhen Webridge Technology Co.,Ltd
    58-48-22   # Sony Mobile Communications AB
    58-48-C0   # COFLEC
    58-49-25   # E3 Enterprise
    58-49-3B   # Palo Alto Networks
    58-49-BA   # Chitai Electronic Corp.
    58-4C-19   # Chongqing Guohong Technology Development Company Limited
    58-4C-EE   # Digital One Technologies, Limited
    58-50-76   # Linear Equipamentos Eletronicos SA
    58-50-AB   # TLS Corporation
    58-50-E6   # Best Buy Corporation
    58-53-C0   # Beijing Guang Runtong Technology Development Company co.,Ltd
    58-55-CA   # Apple, Inc.
    58-56-E8   # ARRIS Group, Inc.
    58-57-0D   # Danfoss Solar Inverters
    58-63-56   # FN-LINK TECHNOLOGY LIMITED
    58-63-9A   # TPL SYSTEMES
    58-65-E6   # INFOMARK CO., LTD.
    58-66-BA   # Hangzhou H3C Technologies Co., Limited
    58-67-1A   # Barnes&Noble
    58-67-7F   # Clare Controls Inc.
    58-68-5D   # Tempo Australia Pty Ltd
    58-69-6C   # Fujian Ruijie Networks co, ltd
    58-69-F9   # Fusion Transactive Ltd.
    58-6A-B1   # Hangzhou H3C Technologies Co., Limited
    58-6D-8F   # Cisco-Linksys, LLC
    58-6E-D6   # Private
    58-70-C6   # Shanghai Xiaoyi Technology Co., Ltd.
    58-75-21   # CJSC RTSoft
    58-76-75   # Beijing ECHO Technologies Co.,Ltd
    58-76-C5   # DIGI I'S LTD
    58-7A-4D   # Stonesoft Corporation
    58-7B-E9   # AirPro Technology India Pvt. Ltd
    58-7E-61   # Hisense Electric Co., Ltd
    58-7F-57   # Apple, Inc.
    58-7F-66   # HUAWEI TECHNOLOGIES CO.,LTD
    58-7F-B7   # SONAR INDUSTRIAL CO., LTD.
    58-7F-C8   # S2M
    58-82-A8   # Microsoft
    58-84-E4   # IP500 Alliance e.V.
    58-85-6E   # QSC AG
    58-87-4C   # LITE-ON CLEAN ENERGY TECHNOLOGY CORP.
    58-87-E2   # Shenzhen Coship Electronics Co., Ltd.
    58-8B-F3   # ZyXEL Communications Corporation
    58-8D-09   # Cisco Systems, Inc
    58-91-CF   # Intel Corporate
    58-92-0D   # Kinetic Avionics Limited
    58-93-96   # Ruckus Wireless
    58-94-6B   # Intel Corporate
    58-94-CF   # Vertex Standard LMR, Inc.
    58-97-1E   # Cisco Systems, Inc
    58-97-BD   # Cisco Systems, Inc
    58-98-35   # Technicolor
    58-98-6F   # Revolution Display
    58-9B-0B   # Shineway Technologies, Inc.
    58-9C-FC   # FreeBSD Foundation
    58-A2-B5   # LG Electronics
    58-A7-6F   # iD corporation
    58-A8-39   # Intel Corporate
    58-AC-78   # Cisco Systems, Inc
    58-B0-35   # Apple, Inc.
    58-B0-D4   # ZuniData Systems Inc.
    58-B6-33   # Ruckus Wireless
    58-B9-61   # SOLEM Electronique
    58-B9-E1   # Crystalfontz America, Inc.
    58-BC-27   # Cisco Systems, Inc
    58-BD-A3   # Nintendo Co., Ltd.
    58-BD-F9   # Sigrand
    58-BF-EA   # Cisco Systems, Inc
    58-C2-32   # NEC Corporation
    58-C3-8B   # Samsung Electronics
    58-CF-4B   # Lufkin Industries
    58-D0-71   # BW Broadcast
    58-D0-8F   # IEEE 1904.1 Working Group
    58-D6-D3   # Dairy Cheq Inc
    58-DB-8D   # Fast Co., Ltd.
    58-DC-6D   # Exceptional Innovation, Inc.
    58-E0-2C   # Micro Technic A/S
    58-E3-26   # Compass Technologies Inc.
    58-E4-76   # CENTRON COMMUNICATIONS TECHNOLOGIES FUJIAN CO.,LTD
    58-E6-36   # EVRsafe Technologies
    58-E7-47   # Deltanet AG
    58-E8-08   # AUTONICS CORPORATION
    58-EB-14   # Proteus Digital Health
    58-EC-E1   # Newport Corporation
    58-EE-CE   # Icon Time Systems
    58-F1-02   # BLU Products Inc.
    58-F3-87   # HCCP
    58-F3-9C   # Cisco Systems, Inc
    58-F4-96   # Source Chain
    58-F6-7B   # Xia Men UnionCore Technology LTD.
    58-F6-BF   # Kyoto University
    58-F9-8E   # SECUDOS GmbH
    58-FC-73   # Arria Live Media, Inc.
    58-FC-DB   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    58-FD-20   # Bravida Sakerhet AB
    5C-02-6A   # Applied Vision Corporation
    5C-07-6F   # Thought Creator
    5C-0A-5B   # SAMSUNG ELECTRO-MECHANICS CO., LTD.
    5C-0C-BB   # CELIZION Inc.
    5C-0E-8B   # Zebra Technologies Inc
    5C-11-93   # Seal One AG
    5C-14-37   # Thyssenkrupp Aufzugswerke GmbH
    5C-15-15   # ADVAN
    5C-15-E1   # AIDC TECHNOLOGY (S) PTE LTD
    5C-16-C7   # Big Switch Networks
    5C-17-37   # I-View Now, LLC.
    5C-17-D3   # LGE
    5C-18-B5   # Talon Communications
    5C-20-D0   # Asoni Communication Co., Ltd.
    5C-22-C4   # DAE EUN ELETRONICS CO., LTD
    5C-24-79   # Baltech AG
    5C-25-4C   # Avire Global Pte Ltd
    5C-26-0A   # Dell Inc.
    5C-2A-EF   # Open Access Pty Ltd
    5C-2B-F5   # Vivint
    5C-2E-59   # Samsung Electronics Co.,Ltd
    5C-2E-D2   # ABC(XiSheng) Electronics Co.,Ltd
    5C-31-3E   # Texas Instruments
    5C-33-27   # Spazio Italia srl
    5C-33-5C   # Swissphone Telecom AG
    5C-33-8E   # Alpha Networks Inc.
    5C-35-3B   # Compal Broadband Networks, Inc.
    5C-35-DA   # There Corporation Oy
    5C-36-B8   # TCL King Electrical Appliances (Huizhou) Co., Ltd
    5C-38-E0   # Shanghai Super Electronics Technology Co.,LTD
    5C-3B-35   # Gehirn Inc.
    5C-3C-27   # Samsung Electronics Co.,Ltd
    5C-40-58   # Jefferson Audio Video Systems, Inc.
    5C-41-E7   # Wiatec International Ltd.
    5C-43-D2   # HAZEMEYER
    5C-45-27   # Juniper Networks
    5C-49-79   # AVM Audiovisuelles Marketing und Computersysteme GmbH
    5C-4A-26   # Enguity Technology Corp
    5C-4C-A9   # HUAWEI TECHNOLOGIES CO.,LTD
    5C-50-15   # Cisco Systems, Inc
    5C-51-4F   # Intel Corporate
    5C-51-88   # Motorola Mobility LLC, a Lenovo Company
    5C-56-ED   # 3pleplay Electronics Private Limited
    5C-57-1A   # ARRIS Group, Inc.
    5C-57-C8   # Nokia Corporation
    5C-59-48   # Apple, Inc.
    5C-5B-35   # Mist Systems, Inc.
    5C-5B-C2   # YIK Corporation
    5C-5E-AB   # Juniper Networks
    5C-63-BF   # TP-LINK TECHNOLOGIES CO.,LTD.
    5C-69-84   # NUVICO
    5C-6A-7D   # KENTKART EGE ELEKTRONIK SAN. VE TIC. LTD. STI.
    5C-6B-32   # Texas Instruments
    5C-6B-4F   # Private
    5C-6D-20   # Hon Hai Precision Ind. Co.,Ltd.
    5C-6F-4F   # S.A. SISTEL
    5C-77-57   # Haivision Network Video
    5C-7D-5E   # HUAWEI TECHNOLOGIES CO.,LTD
    5C-83-8F   # Cisco Systems, Inc
    5C-84-86   # Brightsource Industries Israel LTD
    5C-86-4A   # Secret Labs LLC
    5C-87-78   # Cybertelbridge co.,ltd
    5C-89-9A   # TP-LINK TECHNOLOGIES CO.,LTD.
    5C-89-D4   # Beijing Banner Electric Co.,Ltd
    5C-8A-38   # Hewlett Packard
    5C-8D-4E   # Apple, Inc.
    5C-8F-E0   # ARRIS Group, Inc.
    5C-93-A2   # Liteon Technology Corporation
    5C-95-AE   # Apple, Inc.
    5C-96-56   # AzureWave Technology Inc.
    5C-96-6A   # RTNET
    5C-96-9D   # Apple, Inc.
    5C-97-F3   # Apple, Inc.
    5C-9A-D8   # FUJITSU LIMITED
    5C-A1-78   # TableTop Media (dba Ziosk)
    5C-A3-9D   # SAMSUNG ELECTRO-MECHANICS CO., LTD.
    5C-A3-EB   # Lokel s.r.o.
    5C-A4-8A   # Cisco Systems, Inc
    5C-AA-FD   # Sonos, Inc.
    5C-AC-4C   # Hon Hai Precision Ind. Co.,Ltd.
    5C-AD-CF   # Apple, Inc.
    5C-B3-95   # HUAWEI TECHNOLOGIES CO.,LTD
    5C-B4-3E   # HUAWEI TECHNOLOGIES CO.,LTD
    5C-B5-24   # Sony Mobile Communications AB
    5C-B5-59   # CNEX Labs
    5C-B6-CC   # NovaComm Technologies Inc.
    5C-B8-CB   # Allis Communications
    5C-B9-01   # Hewlett Packard
    5C-BD-9E   # HONGKONG MIRACLE EAGLE TECHNOLOGY(GROUP) LIMITED
    5C-C2-13   # Fr. Sauter AG
    5C-C5-D4   # Intel Corporate
    5C-C6-D0   # Skyworth Digital Technology(Shenzhen) Co.,Ltd
    5C-C9-D3   # PALLADIUM ENERGY ELETRONICA DA AMAZONIA LTDA
    5C-CA-32   # Theben AG
    5C-CC-FF   # Techroutes Network Pvt Ltd
    5C-CE-AD   # CDYNE Corporation
    5C-CF-7F   # Espressif Inc.
    5C-D1-35   # Xtreme Power Systems
    5C-D2-E4   # Intel Corporate
    5C-D4-1B   # UCZOON Technology Co., LTD
    5C-D4-AB   # Zektor
    5C-D6-1F   # Qardio, Inc
    5C-D9-98   # D-Link Corporation
    5C-DA-D4   # Murata Manufacturing Co., Ltd.
    5C-DC-96   # Arcadyan Technology Corporation
    5C-DD-70   # Hangzhou H3C Technologies Co., Limited
    5C-E0-C5   # Intel Corporate
    5C-E0-CA   # FeiTian United (Beijing) System Technology Co., Ltd.
    5C-E0-F6   # NIC.br- Nucleo de Informacao e Coordenacao do Ponto BR
    5C-E2-23   # Delphin Technology AG
    5C-E2-86   # Nortel Networks
    5C-E2-F4   # AcSiP Technology Corp.
    5C-E3-B6   # Fiberhome Telecommunication Technologies Co.,LTD
    5C-E7-BF   # New Singularity International Technical Development Co.,Ltd
    5C-E8-EB   # Samsung Electronics
    5C-EB-4E   # R. STAHL HMI Systems GmbH
    5C-EB-68   # Cheerstar Technology Co., Ltd
    5C-EE-79   # Global Digitech Co LTD
    5C-F2-07   # Speco Technologies
    5C-F3-70   # CC&C Technologies, Inc
    5C-F3-FC   # IBM Corp
    5C-F4-AB   # ZyXEL Communications Corporation
    5C-F5-0D   # Institute of microelectronic applications
    5C-F5-DA   # Apple, Inc.
    5C-F6-DC   # Samsung Electronics Co.,Ltd
    5C-F7-C3   # SYNTECH (HK) TECHNOLOGY LIMITED
    5C-F8-21   # Texas Instruments
    5C-F8-A1   # Murata Manufacturing Co., Ltd.
    5C-F9-38   # Apple, Inc.
    5C-F9-6A   # HUAWEI TECHNOLOGIES CO.,LTD
    5C-F9-DD   # Dell Inc.
    5C-F9-F0   # Atomos Engineering P/L
    5C-FC-66   # Cisco Systems, Inc
    5C-FF-35   # Wistron Corporation
    5C-FF-FF   # Shenzhen Kezhonglong Optoelectronic Technology Co., Ltd
    60-01-94   # Espressif Inc.
    60-02-92   # PEGATRON CORPORATION
    60-02-B4   # Wistron NeWeb Corp.
    60-03-08   # Apple, Inc.
    60-03-47   # Billion Electric Co. Ltd.
    60-04-17   # POSBANK CO.,LTD
    60-0F-77   # SilverPlus, Inc
    60-11-99   # Siama Systems Inc
    60-12-83   # Soluciones Tecnologicas para la Salud y el Bienestar SA
    60-12-8B   # CANON INC.
    60-15-C7   # IdaTech
    60-18-2E   # ShenZhen Protruly Electronic Ltd co.
    60-18-88   # zte corporation
    60-19-0C   # RRAMAC
    60-19-29   # VOLTRONIC POWER TECHNOLOGY(SHENZHEN) CORP.
    60-19-70   # HUIZHOU QIAOXING ELECTRONICS TECHNOLOGY CO., LTD.
    60-19-71   # ARRIS Group, Inc.
    60-1D-0F   # Midnite Solar
    60-1E-02   # EltexAlatau
    60-21-03   # STCUBE.INC
    60-21-C0   # Murata Manufacturing Co., Ltd.
    60-24-C1   # Jiangsu Zhongxun Electronic Technology Co., Ltd
    60-2A-54   # CardioTek B.V.
    60-2A-D0   # Cisco SPVTG
    60-32-F0   # Mplus technology
    60-33-4B   # Apple, Inc.
    60-35-53   # Buwon Technology
    60-36-96   # The Sapling Company
    60-36-DD   # Intel Corporate
    60-38-0E   # ALPS ELECTRIC CO.,LTD.
    60-39-1F   # ABB Ltd
    60-3F-C5   # COX CO., LTD
    60-44-F5   # Easy Digital Ltd.
    60-45-5E   # Liptel s.r.o.
    60-45-BD   # Microsoft
    60-46-16   # XIAMEN VANN INTELLIGENT CO., LTD
    60-47-D4   # FORICS Electronic Technology Co., Ltd.
    60-48-26   # Newbridge Technologies Int. Ltd.
    60-4A-1C   # SUYIN Corporation
    60-50-C1   # Kinetek Sports
    60-51-2C   # TCT mobile limited
    60-52-D0   # FACTS Engineering
    60-54-64   # Eyedro Green Solutions Inc.
    60-57-18   # Intel Corporate
    60-5B-B4   # AzureWave Technology Inc.
    60-60-1F   # SZ DJI TECHNOLOGY CO.,LTD
    60-63-FD   # Transcend Communication Beijing Co.,Ltd.
    60-64-A1   # RADiflow Ltd.
    60-67-20   # Intel Corporate
    60-69-44   # Apple, Inc.
    60-69-9B   # isepos GmbH
    60-6B-BD   # Samsung Electronics Co., LTD
    60-6C-66   # Intel Corporate
    60-6D-C7   # Hon Hai Precision Ind. Co.,Ltd.
    60-73-5C   # Cisco Systems, Inc
    60-74-8D   # Atmaca Elektronik
    60-76-88   # Velodyne
    60-77-E2   # Samsung Electronics Co.,Ltd
    60-7E-DD   # Microsoft Mobile Oy
    60-81-2B   # Custom Control Concepts
    60-81-F9   # Helium Systems, Inc
    60-83-B2   # GkWare e.K.
    60-84-3B   # Soladigm, Inc.
    60-86-45   # Avery Weigh-Tronix, LLC
    60-89-3C   # Thermo Fisher Scientific P.O.A.
    60-89-B1   # Key Digital Systems
    60-89-B7   # KAEL MÜHENDİSLİK ELEKTRONİK TİCARET SANAYİ LİMİTED ŞİRKETİ
    60-8C-2B   # Hanson Technology
    60-8D-17   # Sentrus Government Systems Division, Inc
    60-8F-5C   # Samsung Electronics Co.,Ltd
    60-90-84   # DSSD Inc
    60-92-17   # Apple, Inc.
    60-96-20   # Private
    60-99-D1   # Vuzix / Lenovo
    60-9A-A4   # GVI SECURITY INC.
    60-9C-9F   # Brocade Communications Systems, Inc.
    60-9E-64   # Vivonic GmbH
    60-9F-9D   # CloudSwitch
    60-A1-0A   # Samsung Electronics Co.,Ltd
    60-A3-7D   # Apple, Inc.
    60-A4-4C   # ASUSTek COMPUTER INC.
    60-A8-FE   # Nokia
    60-A9-B0   # Merchandising Technologies, Inc
    60-AF-6D   # Samsung Electronics Co.,Ltd
    60-B1-85   # ATH system
    60-B3-C4   # Elber Srl
    60-B6-06   # Phorus
    60-B6-17   # Fiberhome Telecommunication Tech.Co.,Ltd.
    60-B9-33   # Deutron Electronics Corp.
    60-B9-82   # RO.VE.R. Laboratories S.p.A.
    60-BB-0C   # Beijing HuaqinWorld Technology Co,Ltd
    60-BC-4C   # EWM Hightec Welding GmbH
    60-BD-91   # Move Innovation
    60-BE-B5   # Motorola Mobility LLC, a Lenovo Company
    60-C1-CB   # Fujian Great Power PLC Equipment Co.,Ltd
    60-C3-97   # 2Wire Inc
    60-C5-47   # Apple, Inc.
    60-C5-A8   # Beijing LT Honway Technology Co.,Ltd
    60-C7-98   # Verifone, Inc.
    60-C9-80   # Trymus
    60-CB-FB   # AirScape Inc.
    60-CD-A9   # Abloomy
    60-CD-C5   # Taiwan Carol Electronics., Ltd
    60-D0-A9   # Samsung Electronics Co.,Ltd
    60-D1-AA   # Vishal Telecommunications Pvt Ltd
    60-D2-B9   # REALAND BIO CO., LTD.
    60-D3-0A   # Quatius Limited
    60-D8-19   # Hon Hai Precision Ind. Co.,Ltd.
    60-D9-A0   # Lenovo Mobile Communication Technology Ltd.
    60-D9-C7   # Apple, Inc.
    60-DA-23   # Estech Co.,Ltd
    60-DB-2A   # HNS
    60-DE-44   # HUAWEI TECHNOLOGIES CO.,LTD
    60-E0-0E   # SHINSEI ELECTRONICS CO LTD
    60-E3-27   # TP-LINK TECHNOLOGIES CO.,LTD.
    60-E6-BC   # Sino-Telecom Technology Co.,Ltd.
    60-E7-01   # HUAWEI TECHNOLOGIES CO.,LTD
    60-E9-56   # Ayla Networks, Inc
    60-EB-69   # Quanta computer Inc.
    60-F1-3D   # JABLOCOM s.r.o.
    60-F1-89   # Murata Manufacturing Co., Ltd.
    60-F2-81   # TRANWO TECHNOLOGY CO., LTD.
    60-F2-EF   # VisionVera International Co., Ltd.
    60-F3-DA   # Logic Way GmbH
    60-F4-94   # Hon Hai Precision Ind. Co.,Ltd.
    60-F5-9C   # CRU-Dataport
    60-F6-73   # TERUMO CORPORATION
    60-F8-1D   # Apple, Inc.
    60-FA-CD   # Apple, Inc.
    60-FB-42   # Apple, Inc.
    60-FD-56   # WOORISYSTEMS CO., Ltd
    60-FE-1E   # China Palms Telecom.Ltd
    60-FE-20   # 2Wire Inc
    60-FE-C5   # Apple, Inc.
    60-FE-F9   # Thomas & Betts
    60-FF-DD   # C.E. ELECTRONICS, INC
    64-00-2D   # Powerlinq Co., LTD
    64-00-6A   # Dell Inc.
    64-00-F1   # Cisco Systems, Inc
    64-05-BE   # NEW LIGHT LED
    64-09-4C   # Beijing Superbee Wireless Technology Co.,Ltd
    64-09-80   # Xiaomi Communications Co Ltd
    64-0B-4A   # Digital Telecom Technology Limited
    64-0D-E6   # Petra Systems
    64-0E-36   # TAZTAG
    64-0E-94   # Pluribus Networks, Inc.
    64-0F-28   # 2Wire Inc
    64-10-84   # HEXIUM Technical Development Co., Ltd.
    64-12-25   # Cisco Systems, Inc
    64-16-7F   # Polycom
    64-16-8D   # Cisco Systems, Inc
    64-16-F0   # HUAWEI TECHNOLOGIES CO.,LTD
    64-1A-22   # Heliospectra AB
    64-1C-67   # DIGIBRAS INDUSTRIA DO BRASILS/A
    64-1E-81   # Dowslake Microsystems
    64-20-0C   # Apple, Inc.
    64-21-84   # Nippon Denki Kagaku Co.,LTD
    64-22-16   # Shandong Taixin Electronic co.,Ltd
    64-24-00   # Xorcom Ltd.
    64-27-37   # Hon Hai Precision Ind. Co.,Ltd.
    64-2D-B7   # SEUNGIL ELECTRONICS
    64-31-50   # Hewlett Packard
    64-31-7E   # Dexin Corporation
    64-34-09   # BITwave Pte Ltd
    64-3A-B1   # SICHUAN TIANYI COMHEART TELECOMCO.,LTD
    64-3E-8C   # HUAWEI TECHNOLOGIES CO.,LTD
    64-3F-5F   # Exablaze
    64-42-14   # Swisscom Energy Solutions AG
    64-43-46   # GuangDong Quick Network Computer CO.,LTD
    64-4B-C3   # Shanghai WOASiS Telecommunications Ltd., Co.
    64-4B-F0   # CalDigit, Inc
    64-4D-70   # dSPACE GmbH
    64-4F-74   # LENUS Co., Ltd.
    64-4F-B0   # Hyunjin.com
    64-51-06   # Hewlett Packard
    64-51-7E   # LONG BEN (DONGGUAN) ELECTRONIC TECHNOLOGY CO.,LTD.
    64-52-99   # The Chamberlain Group, Inc
    64-53-5D   # Frauscher Sensortechnik
    64-54-22   # Equinox Payments
    64-55-63   # Intelight Inc.
    64-55-7F   # NSFOCUS Information Technology Co., Ltd.
    64-55-B1   # ARRIS Group, Inc.
    64-56-01   # TP-LINK TECHNOLOGIES CO.,LTD.
    64-59-F8   # Vodafone Omnitel B.V.
    64-5A-04   # Chicony Electronics Co., Ltd.
    64-5D-92   # SICHUAN TIANYI COMHEART TELECOMCO.,LTD
    64-5D-D7   # Shenzhen Lifesense Medical Electronics Co., Ltd.
    64-5E-BE   # Yahoo! JAPAN
    64-5F-FF   # Nicolet Neuro
    64-62-23   # Cellient Co., Ltd.
    64-64-9B   # Juniper Networks
    64-65-C0   # Nuvon, Inc
    64-66-B3   # TP-LINK TECHNOLOGIES CO.,LTD.
    64-67-07   # Beijing Omnific Technology, Ltd.
    64-68-0C   # Comtrend Corporation
    64-69-BC   # Hytera Communications Co .,ltd
    64-6A-52   # Avaya Inc
    64-6A-74   # AUTH-SERVERS, LLC
    64-6C-B2   # Samsung Electronics Co.,Ltd
    64-6E-6C   # Radio Datacom LLC
    64-6E-EA   # Iskratel d.o.o.
    64-70-02   # TP-LINK TECHNOLOGIES CO.,LTD.
    64-72-D8   # GooWi Technology Co.,Limited
    64-73-E2   # Arbiter Systems, Inc.
    64-76-57   # Innovative Security Designs
    64-76-BA   # Apple, Inc.
    64-77-91   # Samsung Electronics Co.,Ltd
    64-7B-D4   # Texas Instruments
    64-7C-34   # Ubee Interactive Corp.
    64-7D-81   # YOKOTA INDUSTRIAL CO,.LTD
    64-7F-DA   # TEKTELIC Communications Inc.
    64-80-8B   # VG Controls, Inc.
    64-80-99   # Intel Corporate
    64-81-25   # Alphatron Marine BV
    64-87-88   # Juniper Networks
    64-87-D7   # ADB Broadband Italia
    64-88-FF   # Sichuan Changhong Electric Ltd.
    64-89-9A   # LG Electronics
    64-8D-9E   # IVT Electronic Co.,Ltd
    64-99-5D   # LGE
    64-99-68   # Elentec
    64-99-A0   # AG Elektronik AB
    64-9A-12   # P2 Mobile Technologies Limited
    64-9A-BE   # Apple, Inc.
    64-9B-24   # V Technology Co., Ltd.
    64-9C-81   # Qualcomm iSkoot, Inc.
    64-9C-8E   # Texas Instruments
    64-9E-F3   # Cisco Systems, Inc
    64-9F-F7   # Kone OYj
    64-A0-E7   # Cisco Systems, Inc
    64-A2-32   # OOO Samlight
    64-A3-41   # Wonderlan (Beijing) Technology Co., Ltd.
    64-A3-CB   # Apple, Inc.
    64-A5-C3   # Apple, Inc.
    64-A6-51   # HUAWEI TECHNOLOGIES CO.,LTD
    64-A7-69   # HTC Corporation
    64-A7-DD   # Avaya Inc
    64-A8-37   # Juni Korea Co., Ltd
    64-AE-0C   # Cisco Systems, Inc
    64-AE-88   # Polytec GmbH
    64-B2-1D   # Chengdu Phycom Tech Co., Ltd.
    64-B3-10   # Samsung Electronics Co.,Ltd
    64-B3-70   # PowerComm Solutions LLC
    64-B4-73   # Xiaomi Communications Co Ltd
    64-B6-4A   # ViVOtech, Inc.
    64-B8-53   # Samsung Electronics Co.,Ltd
    64-B9-E8   # Apple, Inc.
    64-BA-BD   # SDJ Technologies, Inc.
    64-BC-0C   # LG Electronics
    64-BC-11   # CombiQ AB
    64-C3-54   # Avaya Inc
    64-C5-AA   # South African Broadcasting Corporation
    64-C6-67   # Barnes&Noble
    64-C6-AF   # AXERRA Networks Ltd
    64-C9-44   # LARK Technologies, Inc
    64-D0-2D   # Next Generation Integration (NGI)
    64-D1-A3   # Sitecom Europe BV
    64-D2-41   # Keith & Koep GmbH
    64-D4-BD   # ALPS ELECTRIC CO.,LTD.
    64-D4-DA   # Intel Corporate
    64-D8-14   # Cisco Systems, Inc
    64-D9-12   # Solidica, Inc.
    64-D9-54   # Taicang T&W Electronics
    64-D9-89   # Cisco Systems, Inc
    64-DB-18   # OpenPattern
    64-DB-81   # Syszone Co., Ltd.
    64-DC-01   # Static Systems Group PLC
    64-DE-1C   # Kingnetic Pte Ltd
    64-E1-61   # DEP Corp.
    64-E5-99   # EFM Networks
    64-E6-25   # Woxu Wireless Co., Ltd
    64-E6-82   # Apple, Inc.
    64-E8-4F   # Serialway Communication Technology Co. Ltd
    64-E8-92   # Morio Denki Co., Ltd.
    64-E8-E6   # global moisture management system
    64-E9-50   # Cisco Systems, Inc
    64-EA-C5   # SiboTech Automation Co., Ltd.
    64-EB-8C   # Seiko Epson Corporation
    64-ED-57   # ARRIS Group, Inc.
    64-ED-62   # WOORI SYSTEMS Co., Ltd
    64-F2-42   # Gerdes Aktiengesellschaft
    64-F5-0E   # Kinion Technology Company Limited
    64-F6-9D   # Cisco Systems, Inc
    64-F9-70   # Kenade Electronics Technology Co.,LTD.
    64-F9-87   # Avvasi Inc.
    64-FB-81   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    64-FC-8C   # Zonar Systems
    68-05-71   # Samsung Electronics Co.,Ltd
    68-05-CA   # Intel Corporate
    68-09-27   # Apple, Inc.
    68-0A-D7   # Yancheng Kecheng Optoelectronic Technology Co., Ltd
    68-12-2D   # Special Instrument Development Co., Ltd.
    68-12-95   # Lupine Lighting Systems GmbH
    68-14-01   # Hon Hai Precision Ind. Co.,Ltd.
    68-15-90   # Sagemcom Broadband SAS
    68-15-D3   # Zaklady Elektroniki i Mechaniki Precyzyjnej R&G S.A.
    68-16-05   # Systems And Electronic Development FZCO
    68-17-29   # Intel Corporate
    68-19-3F   # Digital Airways
    68-1A-B2   # zte corporation
    68-1C-A2   # Rosewill Inc.
    68-1D-64   # Sunwave Communications Co., Ltd
    68-1E-8B   # InfoSight Corporation
    68-1F-D8   # Advanced Telemetry
    68-23-4B   # Nihon Dengyo Kousaku
    68-28-BA   # Dejai
    68-28-F6   # Vubiq Networks, Inc.
    68-2D-DC   # Wuhan Changjiang Electro-Communication Equipment CO.,LTD
    68-36-B5   # DriveScale, Inc.
    68-3B-1E   # Countwise LTD
    68-3C-7D   # Magic Intelligence Technology Limited
    68-3E-34   # Meizu Technology Co., LTD
    68-3E-EC   # ERECA
    68-43-52   # Bhuu Limited
    68-48-98   # Samsung Electronics Co.,Ltd
    68-4B-88   # Galtronics Telemetry Inc.
    68-4C-A8   # Shenzhen Herotel Tech. Co., Ltd.
    68-51-B7   # PowerCloud Systems, Inc.
    68-54-ED   # Alcatel-Lucent - Nuage
    68-54-F5   # enLighted Inc
    68-58-C5   # ZF TRW Automotive
    68-59-7F   # Alcatel Lucent
    68-5B-35   # Apple, Inc.
    68-5B-36   # POWERTECH INDUSTRIAL CO., LTD.
    68-5D-43   # Intel Corporate
    68-5E-6B   # PowerRay Co., Ltd.
    68-63-59   # Advanced Digital Broadcast SA
    68-64-4B   # Apple, Inc.
    68-69-2E   # Zycoo Co.,Ltd
    68-69-F2   # ComAp s.r.o.
    68-6E-23   # Wi3 Inc.
    68-6E-48   # Prophet Electronic Technology Corp.,Ltd
    68-72-51   # Ubiquiti Networks
    68-72-DC   # CETORY.TV Company Limited
    68-76-4F   # Sony Mobile Communications AB
    68-78-48   # Westunitis Co., Ltd.
    68-78-4C   # Nortel Networks
    68-79-24   # ELS-GmbH & Co. KG
    68-79-ED   # SHARP Corporation
    68-7C-C8   # Measurement Systems S. de R.L.
    68-7C-D5   # Y Soft Corporation, a.s.
    68-7F-74   # Cisco-Linksys, LLC
    68-83-1A   # Pandora Mobility Corporation
    68-84-70   # eSSys Co.,Ltd
    68-85-40   # IGI Mobile, Inc.
    68-85-6A   # OuterLink Corporation
    68-86-A7   # Cisco Systems, Inc
    68-86-E7   # Orbotix, Inc.
    68-87-6B   # INQ Mobile Limited
    68-89-C1   # HUAWEI TECHNOLOGIES CO.,LTD
    68-8A-B5   # EDP Servicos
    68-8F-84   # HUAWEI TECHNOLOGIES CO.,LTD
    68-92-34   # Ruckus Wireless
    68-94-23   # Hon Hai Precision Ind. Co.,Ltd.
    68-96-7B   # Apple, Inc.
    68-97-4B   # Shenzhen Costar Electronics Co. Ltd.
    68-97-E8   # Society of Motion Picture &amp; Television Engineers
    68-99-CD   # Cisco Systems, Inc
    68-9A-B7   # Atelier Vision Corporation
    68-9C-5E   # AcSiP Technology Corp.
    68-9C-70   # Apple, Inc.
    68-9C-E2   # Cisco Systems, Inc
    68-9E-19   # Texas Instruments
    68-A0-F6   # HUAWEI TECHNOLOGIES CO.,LTD
    68-A1-B7   # Honghao Mingchuan Technology (Beijing) CO.,Ltd.
    68-A3-78   # FREEBOX SAS
    68-A3-C4   # Liteon Technology Corporation
    68-A4-0E   # BSH Bosch and Siemens Home Appliances GmbH
    68-A8-28   # HUAWEI TECHNOLOGIES CO.,LTD
    68-A8-6D   # Apple, Inc.
    68-AA-D2   # DATECS LTD.,
    68-AB-8A   # RF IDeas
    68-AE-20   # Apple, Inc.
    68-AF-13   # Futura Mobility
    68-B0-94   # INESA ELECTRON CO.,LTD
    68-B4-3A   # WaterFurnace International, Inc.
    68-B5-99   # Hewlett Packard
    68-B6-FC   # Hitron Technologies. Inc
    68-B8-D9   # Act KDE, Inc.
    68-B9-83   # b-plus GmbH
    68-BC-0C   # Cisco Systems, Inc
    68-BD-AB   # Cisco Systems, Inc
    68-C9-0B   # Texas Instruments
    68-CA-00   # Octopus Systems Limited
    68-CC-9C   # Mine Site Technologies
    68-CD-0F   # U Tek Company Limited
    68-CE-4E   # L-3 Communications Infrared Products
    68-D1-FD   # Shenzhen Trimax Technology Co.,Ltd
    68-D2-47   # Portalis LC
    68-D9-25   # ProSys Development Services
    68-D9-3C   # Apple, Inc.
    68-DB-67   # Nantong Coship Electronics Co., Ltd
    68-DB-96   # OPWILL Technologies CO .,LTD
    68-DB-CA   # Apple, Inc.
    68-DC-E8   # PacketStorm Communications
    68-DF-DD   # Xiaomi Communications Co Ltd
    68-E1-66   # Private
    68-E4-1F   # Unglaube Identech GmbH
    68-E8-EB   # Linktel Technologies Co.,Ltd
    68-EB-AE   # Samsung Electronics Co.,Ltd
    68-EB-C5   # Angstrem Telecom
    68-EC-62   # YODO Technology Corp. Ltd.
    68-ED-43   # BlackBerry RTS
    68-ED-A4   # Shenzhen Seavo Technology Co.,Ltd
    68-EE-96   # Cisco SPVTG
    68-EF-BD   # Cisco Systems, Inc
    68-F0-6D   # ALONG INDUSTRIAL CO., LIMITED
    68-F0-BC   # Shenzhen LiWiFi Technology Co., Ltd
    68-F1-25   # Data Controls Inc.
    68-F7-28   # LCFC(HeFei) Electronics Technology co., ltd
    68-F8-95   # Redflow Limited
    68-F9-56   # Objetivos y Servicio de Valor Añadido
    68-FB-95   # Generalplus Technology Inc.
    68-FC-B3   # Next Level Security Systems, Inc.
    6C-02-73   # Shenzhen Jin Yun Video Equipment Co., Ltd.
    6C-04-60   # RBH Access Technologies Inc.
    6C-09-D6   # Digiquest Electronics LTD
    6C-0B-84   # Universal Global Scientific Industrial Co.,Ltd.
    6C-0E-0D   # Sony Mobile Communications AB
    6C-0F-6A   # JDC Tech Co., Ltd.
    6C-14-F7   # Erhardt+Leimer GmbH
    6C-15-F9   # Nautronix Limited
    6C-18-11   # Decatur Electronics
    6C-19-8F   # D-Link International
    6C-1E-70   # Guangzhou YBDS IT Co.,Ltd
    6C-20-56   # Cisco Systems, Inc
    6C-22-AB   # Ainsworth Game Technology
    6C-23-B9   # Sony Mobile Communications AB
    6C-25-B9   # BBK Electronics Corp., Ltd.,
    6C-27-79   # Microsoft Mobile Oy
    6C-29-95   # Intel Corporate
    6C-2C-06   # OOO NPP Systemotechnika-NN
    6C-2E-33   # Accelink Technologies Co.,Ltd.
    6C-2E-72   # B&B EXPORTING LIMITED
    6C-2E-85   # Sagemcom Broadband SAS
    6C-2F-2C   # Samsung Electronics Co.,Ltd
    6C-32-DE   # Indieon Technologies Pvt. Ltd.
    6C-33-A9   # Magicjack LP
    6C-38-A1   # Ubee Interactive Corp.
    6C-39-1D   # Beijing ZhongHuaHun Network Information center
    6C-3A-84   # Shenzhen Aero-Startech. Co.Ltd
    6C-3B-E5   # Hewlett Packard
    6C-3C-53   # SoundHawk Corp
    6C-3E-6D   # Apple, Inc.
    6C-3E-9C   # KE Knestel Elektronik GmbH
    6C-40-08   # Apple, Inc.
    6C-40-C6   # Nimbus Data Systems, Inc.
    6C-41-6A   # Cisco Systems, Inc
    6C-44-18   # Zappware
    6C-45-98   # Antex Electronic Corp.
    6C-4A-39   # BITA
    6C-4B-7F   # Vossloh-Schwabe Deutschland GmbH
    6C-50-4D   # Cisco Systems, Inc
    6C-57-79   # Aclima, Inc.
    6C-59-40   # SHENZHEN MERCURY COMMUNICATION TECHNOLOGIES CO.,LTD.
    6C-5A-34   # Shenzhen Haitianxiong Electronic Co., Ltd.
    6C-5A-B5   # TCL Technoly Electronics (Huizhou) Co., Ltd.
    6C-5C-DE   # SunReports, Inc.
    6C-5D-63   # ShenZhen Rapoo Technology Co., Ltd.
    6C-5E-7A   # Ubiquitous Internet Telecom Co., Ltd
    6C-5F-1C   # Lenovo Mobile Communication Technology Ltd.
    6C-61-26   # Rinicom Holdings
    6C-62-6D   # Micro-Star INT'L CO., LTD
    6C-64-1A   # Penguin Computing
    6C-6E-FE   # Core Logic Inc.
    6C-6F-18   # Stereotaxis, Inc.
    6C-70-39   # Novar GmbH
    6C-70-9F   # Apple, Inc.
    6C-71-D9   # AzureWave Technology Inc.
    6C-72-20   # D-Link International
    6C-72-E7   # Apple, Inc.
    6C-76-60   # KYOCERA Corporation
    6C-81-FE   # Mitsuba Corporation
    6C-83-36   # Samsung Electronics Co.,Ltd
    6C-83-66   # Nanjing SAC Power Grid Automation Co., Ltd.
    6C-86-86   # Technonia
    6C-88-14   # Intel Corporate
    6C-8B-2F   # zte corporation
    6C-8C-DB   # Otus Technologies Ltd
    6C-8D-65   # Wireless Glue Networks, Inc.
    6C-8D-C1   # Apple, Inc.
    6C-90-B1   # SanLogic Inc
    6C-92-BF   # Inspur Electronic Information Industry Co.,Ltd.
    6C-93-54   # Yaojin Technology (Shenzhen) Co., LTD.
    6C-94-F8   # Apple, Inc.
    6C-98-EB   # Ocedo GmbH
    6C-99-89   # Cisco Systems, Inc
    6C-9A-C9   # Valentine Research, Inc.
    6C-9B-02   # Nokia Corporation
    6C-9C-E9   # Nimble Storage
    6C-9C-ED   # Cisco Systems, Inc
    6C-A1-00   # Intel Corporate
    6C-A6-82   # EDAM information & communications
    6C-A7-5F   # zte corporation
    6C-A7-80   # Nokia Corporation
    6C-A7-FA   # YOUNGBO ENGINEERING INC.
    6C-A8-49   # Avaya Inc
    6C-A9-06   # Telefield Ltd
    6C-A9-6F   # TransPacket AS
    6C-AA-B3   # Ruckus Wireless
    6C-AB-4D   # Digital Payment Technologies
    6C-AC-60   # Venetex Corp
    6C-AD-3F   # Hubbell Building Automation, Inc.
    6C-AD-EF   # KZ Broadband Technologies, Ltd.
    6C-AD-F8   # AzureWave Technology Inc.
    6C-AE-8B   # IBM Corporation
    6C-B0-CE   # NETGEAR
    6C-B3-11   # Shenzhen Lianrui Electronics Co.,Ltd
    6C-B3-50   # Anhui comhigher tech co.,ltd
    6C-B5-6B   # HUMAX Co., Ltd.
    6C-B7-F4   # Samsung Electronics Co.,Ltd
    6C-BE-E9   # Alcatel-Lucent-IPD
    6C-BF-B5   # Noon Technology Co., Ltd
    6C-C1-D2   # ARRIS Group, Inc.
    6C-C2-17   # Hewlett Packard
    6C-C2-6B   # Apple, Inc.
    6C-CA-08   # ARRIS Group, Inc.
    6C-D0-32   # LG Electronics
    6C-D1-46   # Smartek d.o.o.
    6C-D1-B0   # WING SING ELECTRONICS HONG KONG LIMITED
    6C-D6-8A   # LG Electronics Inc
    6C-DC-6A   # Promethean Limited
    6C-E0-1E   # Modcam AB
    6C-E0-B0   # SOUND4
    6C-E3-B6   # Nera Telecommunications Ltd.
    6C-E4-CE   # Villiger Security Solutions AG
    6C-E8-73   # TP-LINK TECHNOLOGIES CO.,LTD.
    6C-E9-07   # Nokia Corporation
    6C-E9-83   # Gastron Co., LTD.
    6C-EB-B2   # Dongguan Sen DongLv Electronics Co.,Ltd
    6C-EC-A1   # SHENZHEN CLOU ELECTRONICS CO. LTD.
    6C-EC-EB   # Texas Instruments
    6C-F0-49   # GIGA-BYTE TECHNOLOGY CO.,LTD.
    6C-F3-73   # Samsung Electronics Co.,Ltd
    6C-F3-7F   # Aruba Networks
    6C-F5-E8   # Mooredoll Inc.
    6C-F9-7C   # Nanoptix Inc.
    6C-FA-58   # Avaya Inc
    6C-FA-89   # Cisco Systems, Inc
    6C-FA-A7   # AMPAK Technology, Inc.
    6C-FD-B9   # Proware Technologies Co Ltd.
    6C-FF-BE   # MPB Communications Inc.
    70-01-36   # FATEK Automation Corporation
    70-02-58   # 01DB-METRAVIB
    70-05-14   # LG Electronics
    70-0B-C0   # Dewav Technology Company
    70-0F-C7   # SHENZHEN IKINLOOP TECHNOLOGY CO.,LTD.
    70-0F-EC   # Poindus Systems Corp.
    70-10-5C   # Cisco Systems, Inc
    70-10-6F   # Hewlett Packard Enterprise
    70-11-24   # Apple, Inc.
    70-11-AE   # Music Life LTD
    70-14-04   # Limited Liability Company
    70-14-A6   # Apple, Inc.
    70-18-8B   # Hon Hai Precision Ind. Co.,Ltd.
    70-1A-04   # Liteon Technology Corporation
    70-1A-ED   # ADVAS CO., LTD.
    70-1D-7F   # Comtech Technology Co., Ltd.
    70-23-93   # fos4X GmbH
    70-25-26   # Alcatel-Lucent
    70-25-59   # CyberTAN Technology Inc.
    70-2A-7D   # EpSpot AB
    70-2B-1D   # E-Domus International Limited
    70-2C-1F   # Wisol
    70-2D-D1   # Newings Communication CO., LTD.
    70-2F-4B   # PolyVision Inc.
    70-2F-97   # Aava Mobile Oy
    70-30-18   # Avaya Inc
    70-30-5D   # Ubiquoss Inc
    70-30-5E   # Nanjing Zhongke Menglian Information Technology Co.,LTD
    70-31-87   # ACX GmbH
    70-32-D5   # Athena Wireless Communications Inc
    70-38-11   # Invensys Rail
    70-38-B4   # Low Tech Solutions
    70-38-EE   # Avaya Inc
    70-3A-D8   # Shenzhen Afoundry Electronic Co., Ltd
    70-3C-39   # SEAWING Kft
    70-3E-AC   # Apple, Inc.
    70-41-B7   # Edwards Lifesciences LLC
    70-46-42   # CHYNG HONG ELECTRONIC CO., LTD.
    70-48-0F   # Apple, Inc.
    70-4A-AE   # Xstream Flow (Pty) Ltd
    70-4A-E4   # Rinstrum Pty Ltd
    70-4C-ED   # TMRG, Inc.
    70-4E-01   # KWANGWON TECH CO., LTD.
    70-4E-66   # SHENZHEN FAST TECHNOLOGIES CO.,LTD
    70-52-C5   # Avaya Inc
    70-53-3F   # Alfa Instrumentos Eletronicos Ltda.
    70-54-D2   # PEGATRON CORPORATION
    70-54-F5   # HUAWEI TECHNOLOGIES CO.,LTD
    70-56-81   # Apple, Inc.
    70-58-12   # Panasonic AVC Networks Company
    70-59-57   # Medallion Instrumentation Systems
    70-59-86   # OOO TTV
    70-5A-0F   # Hewlett Packard
    70-5A-B6   # COMPAL INFORMATION (KUNSHAN) CO., LTD.
    70-5B-2E   # M2Communication Inc.
    70-5C-AD   # Konami Gaming Inc
    70-5E-AA   # Action Target, Inc.
    70-60-DE   # LaVision GmbH
    70-61-73   # Calantec GmbH
    70-62-B8   # D-Link International
    70-64-17   # ORBIS TECNOLOGIA ELECTRICA S.A.
    70-65-82   # Suzhou Hanming Technologies Co., Ltd.
    70-68-79   # Saijo Denki International Co., Ltd.
    70-6F-81   # Private
    70-70-4C   # Purple Communications, Inc
    70-71-B3   # Brain Corporation
    70-71-BC   # PEGATRON CORPORATION
    70-72-0D   # Lenovo Mobile Communication Technology Ltd.
    70-72-3C   # HUAWEI TECHNOLOGIES CO.,LTD
    70-72-CF   # EdgeCore Networks
    70-73-CB   # Apple, Inc.
    70-76-30   # Pace plc
    70-76-DD   # Oxyguard International A/S
    70-76-F0   # LevelOne Communications (India) Private Limited
    70-76-FF   # KERLINK
    70-77-81   # Hon Hai Precision Ind. Co.,Ltd.
    70-79-38   # Wuxi Zhanrui Electronic Technology Co.,LTD
    70-7B-E8   # HUAWEI TECHNOLOGIES CO.,LTD
    70-7C-18   # ADATA Technology Co., Ltd
    70-7E-43   # ARRIS Group, Inc.
    70-7E-DE   # NASTEC LTD.
    70-81-05   # Cisco Systems, Inc
    70-81-EB   # Apple, Inc.
    70-82-0E   # as electronics GmbH
    70-82-8E   # OleumTech Corporation
    70-85-C6   # Pace plc
    70-88-4D   # JAPAN RADIO CO., LTD.
    70-8B-78   # citygrow technology co., ltd
    70-8D-09   # Nokia Corporation
    70-93-83   # Intelligent Optical Network High Tech CO.,LTD.
    70-93-F8   # Space Monkey, Inc.
    70-97-56   # Happyelectronics Co.,Ltd
    70-9A-0B   # Italian Institute of Technology
    70-9B-A5   # Shenzhen Y&D Electronics Co.,LTD.
    70-9B-FC   # Bryton Inc.
    70-9C-8F   # Nero AG
    70-9E-29   # Sony Computer Entertainment Inc.
    70-9E-86   # X6D Limited
    70-9F-2D   # zte corporation
    70-A1-91   # Trendsetter Medical, LLC
    70-A4-1C   # Advanced Wireless Dynamics S.L.
    70-A6-6A   # Prox Dynamics AS
    70-A8-E3   # HUAWEI TECHNOLOGIES CO.,LTD
    70-AA-B2   # BlackBerry RTS
    70-AD-54   # Malvern Instruments Ltd
    70-AF-25   # Nishiyama Industry Co.,LTD.
    70-B0-35   # Shenzhen Zowee Technology Co., Ltd
    70-B0-8C   # Shenou Communication Equipment Co.,Ltd
    70-B1-4E   # Pace plc
    70-B2-65   # Hiltron s.r.l.
    70-B3-D5   # IEEE Registration Authority
    70-B5-99   # Embedded Technologies s.r.o.
    70-B9-21   # Fiberhome Telecommunication Technologies Co.,LTD
    70-BA-EF   # Hangzhou H3C Technologies Co., Limited
    70-BF-3E   # Charles River Laboratories
    70-C6-AC   # Bosch Automotive Aftermarket
    70-C7-6F   # INNO S
    70-CA-4D   # Shenzhen lnovance Technology Co.,Ltd.
    70-CA-9B   # Cisco Systems, Inc
    70-CD-60   # Apple, Inc.
    70-D4-F2   # RIM
    70-D5-7E   # Scalar Corporation
    70-D5-E7   # Wellcore Corporation
    70-D6-B6   # Metrum Technologies
    70-D8-80   # Upos System sp. z o.o.
    70-D9-31   # Cambridge Industries(Group) Co.,Ltd.
    70-DA-9C   # TECSEN
    70-DD-A1   # Tellabs
    70-DE-E2   # Apple, Inc.
    70-E0-27   # HONGYU COMMUNICATION TECHNOLOGY LIMITED
    70-E1-39   # 3view Ltd
    70-E2-4C   # SAE IT-systems GmbH & Co. KG
    70-E2-84   # Wistron InfoComm(Zhongshan) Corporation
    70-E4-22   # Cisco Systems, Inc
    70-E7-2C   # Apple, Inc.
    70-E8-43   # Beijing C&W Optical Communication Technology Co.,Ltd.
    70-EC-E4   # Apple, Inc.
    70-EE-50   # Netatmo
    70-F1-76   # Data Modul AG
    70-F1-96   # Actiontec Electronics, Inc
    70-F1-A1   # Liteon Technology Corporation
    70-F1-E5   # Xetawave LLC
    70-F3-95   # Universal Global Scientific Industrial Co., Ltd.
    70-F9-27   # Samsung Electronics
    70-F9-6D   # Hangzhou H3C Technologies Co., Limited
    70-FC-8C   # OneAccess SA
    70-FF-5C   # Cheerzing Communication(Xiamen)Technology Co.,Ltd
    70-FF-76   # Texas Instruments
    74-03-BD   # BUFFALO.INC
    74-04-2B   # Lenovo Mobile Communication (Wuhan) Company Limited
    74-0A-BC   # JSJS Designs (Europe) Limited
    74-0E-DB   # Optowiz Co., Ltd
    74-14-89   # SRT Wireless
    74-15-E2   # Tri-Sen Systems Corporation
    74-18-65   # Shanghai DareGlobal Technologies Co.,Ltd
    74-19-F8   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    74-1B-B2   # Apple, Inc.
    74-1E-93   # Fiberhome Telecommunication Tech.Co.,Ltd.
    74-1F-4A   # Hangzhou H3C Technologies Co., Limited
    74-25-8A   # Hangzhou H3C Technologies Co., Limited
    74-26-AC   # Cisco Systems, Inc
    74-27-3C   # ChangYang Technology (Nanjing) Co., LTD
    74-27-EA   # Elitegroup Computer Systems Co., Ltd.
    74-29-AF   # Hon Hai Precision Ind. Co.,Ltd.
    74-2B-0F   # Infinidat Ltd.
    74-2B-62   # FUJITSU LIMITED
    74-2D-0A   # Norfolk Elektronik AG
    74-2E-FC   # DirectPacket Research, Inc,
    74-2F-68   # AzureWave Technology Inc.
    74-31-70   # Arcadyan Technology Corporation
    74-32-56   # NT-ware Systemprg GmbH
    74-37-2F   # Tongfang Shenzhen Cloudcomputing Technology Co.,Ltd
    74-38-89   # ANNAX Anzeigesysteme GmbH
    74-3E-2B   # Ruckus Wireless
    74-3E-CB   # Gentrice tech
    74-44-01   # NETGEAR
    74-45-8A   # Samsung Electronics Co.,Ltd
    74-46-A0   # Hewlett Packard
    74-4A-A4   # zte corporation
    74-4B-E9   # EXPLORER HYPERTECH CO.,LTD
    74-4D-79   # Arrive Systems Inc.
    74-51-BA   # Xiaomi Communications Co Ltd
    74-53-27   # COMMSEN CO., LIMITED
    74-54-7D   # Cisco SPVTG
    74-56-12   # ARRIS Group, Inc.
    74-57-98   # TRUMPF Laser GmbH + Co. KG
    74-5A-AA   # HUAWEI TECHNOLOGIES CO.,LTD
    74-5C-9F   # TCT mobile ltd.
    74-5E-1C   # PIONEER CORPORATION
    74-5F-00   # Samsung Semiconductor Inc.
    74-5F-AE   # TSL PPL
    74-63-DF   # VTS GmbH
    74-65-D1   # Atlinks
    74-66-30   # T:mi Ytti
    74-67-F7   # Zebra Technologoes
    74-6A-3A   # Aperi Corporation
    74-6A-89   # Rezolt Corporation
    74-6A-8F   # VS Vision Systems GmbH
    74-6B-82   # MOVEK
    74-6F-19   # ICARVISIONS (SHENZHEN) TECHNOLOGY CO., LTD.
    74-6F-3D   # Contec GmbH
    74-72-F2   # Chipsip Technology Co., Ltd.
    74-73-36   # MICRODIGTAL Inc
    74-75-48   # Amazon Technologies Inc.
    74-78-18   # Jurumani Solutions
    74-7B-7A   # ETH Inc.
    74-7D-B6   # Aliwei Communications, Inc
    74-7E-1A   # Red Embedded Design Limited
    74-7E-2D   # Beijing Thomson CITIC Digital Technology Co. LTD.
    74-81-14   # Apple, Inc.
    74-85-2A   # PEGATRON CORPORATION
    74-86-7A   # Dell Inc.
    74-88-2A   # HUAWEI TECHNOLOGIES CO.,LTD
    74-88-8B   # ADB Broadband Italia
    74-8E-08   # Bestek Corp.
    74-8E-F8   # Brocade Communications Systems, Inc.
    74-8F-1B   # MasterImage 3D
    74-8F-4D   # MEN Mikro Elektronik GmbH
    74-90-50   # Renesas Electronics Corporation
    74-91-1A   # Ruckus Wireless
    74-91-BD   # Four systems Co.,Ltd.
    74-93-A4   # Zebra Technologies Corp.
    74-94-3D   # AgJunction
    74-96-37   # Todaair Electronic Co., Ltd
    74-99-75   # IBM Corporation
    74-9C-52   # Huizhou Desay SV Automotive Co., Ltd.
    74-9C-E3   # Art2Wave Canada Inc.
    74-9D-DC   # 2Wire Inc
    74-A0-2F   # Cisco Systems, Inc
    74-A0-63   # HUAWEI TECHNOLOGIES CO.,LTD
    74-A2-E6   # Cisco Systems, Inc
    74-A3-4A   # ZIMI CORPORATION
    74-A4-A7   # QRS Music Technologies, Inc.
    74-A4-B5   # Powerleader Science and Technology Co. Ltd.
    74-A5-28   # HUAWEI TECHNOLOGIES CO.,LTD
    74-A7-22   # LG Electronics
    74-A7-8E   # zte corporation
    74-AC-5F   # Qiku Internet Network Scientific (Shenzhen) Co., Ltd.
    74-AD-B7   # China Mobile Group Device Co.,Ltd.
    74-AE-76   # iNovo Broadband, Inc.
    74-B0-0C   # Network Video Technologies, Inc
    74-B9-EB   # JinQianMao Technology Co.,Ltd.
    74-BA-DB   # Longconn Electornics(shenzhen)Co.,Ltd
    74-BE-08   # ATEK Products, LLC
    74-BF-A1   # HYUNTECK
    74-BF-B7   # Nusoft Corporation
    74-C2-46   # Amazon Technologies Inc.
    74-C3-30   # SHENZHEN FAST TECHNOLOGIES CO.,LTD
    74-C6-21   # Zhejiang Hite Renewable Energy Co.,LTD
    74-C6-3B   # AzureWave Technology Inc.
    74-C9-9A   # Ericsson AB
    74-CA-25   # Calxeda, Inc.
    74-CD-0C   # Smith Myers Communications Ltd.
    74-CE-56   # Packet Force Technology Limited Company
    74-D0-2B   # ASUSTek COMPUTER INC.
    74-D0-DC   # ERICSSON AB
    74-D4-35   # GIGA-BYTE TECHNOLOGY CO.,LTD.
    74-D6-75   # WYMA Tecnologia
    74-D6-EA   # Texas Instruments
    74-D7-CA   # Panasonic Corporation Automotive
    74-D8-50   # Evrisko Systems
    74-DA-38   # Edimax Technology Co. Ltd.
    74-DA-EA   # Texas Instruments
    74-DB-D1   # Ebay Inc
    74-DE-2B   # Liteon Technology Corporation
    74-E0-6E   # Ergophone GmbH
    74-E1-4A   # IEEE Registration Authority
    74-E1-B6   # Apple, Inc.
    74-E2-77   # Vizmonet Pte Ltd
    74-E2-8C   # Microsoft Corporation
    74-E2-F5   # Apple, Inc.
    74-E4-24   # APISTE CORPORATION
    74-E5-0B   # Intel Corporate
    74-E5-37   # RADSPIN
    74-E5-43   # Liteon Technology Corporation
    74-E6-E2   # Dell Inc.
    74-E7-C6   # ARRIS Group, Inc.
    74-EA-3A   # TP-LINK TECHNOLOGIES CO.,LTD.
    74-EA-E8   # ARRIS Group, Inc.
    74-EC-F1   # Acumen
    74-F0-6D   # AzureWave Technology Inc.
    74-F0-7D   # BnCOM Co.,Ltd
    74-F1-02   # Beijing HCHCOM Technology Co., Ltd
    74-F4-13   # Maxwell Forest
    74-F6-12   # ARRIS Group, Inc.
    74-F7-26   # Neuron Robotics
    74-F8-5D   # Berkeley Nucleonics Corp
    74-F8-DB   # IEEE Registration Authority
    74-FD-A0   # Compupal (Group) Corporation
    74-FE-48   # ADVANTECH CO., LTD.
    74-FF-7D   # Wren Sound Systems, LLC
    78-02-8F   # Adaptive Spectrum and Signal Alignment (ASSIA), Inc.
    78-05-41   # Queclink Wireless Solutions Co., Ltd
    78-07-38   # Z.U.K. Elzab S.A.
    78-0A-C7   # Baofeng TV Co., Ltd.
    78-0C-B8   # Intel Corporate
    78-11-85   # NBS Payment Solutions Inc.
    78-12-B8   # ORANTEK LIMITED
    78-18-81   # AzureWave Technology Inc.
    78-19-2E   # NASCENT Technology
    78-19-F7   # Juniper Networks
    78-1C-5A   # SHARP Corporation
    78-1D-BA   # HUAWEI TECHNOLOGIES CO.,LTD
    78-1D-FD   # Jabil Inc
    78-1F-DB   # Samsung Electronics Co.,Ltd
    78-22-3D   # Affirmed Networks
    78-24-AF   # ASUSTek COMPUTER INC.
    78-25-44   # Omnima Limited
    78-25-AD   # SAMSUNG ELECTRONICS CO., LTD.
    78-2B-CB   # Dell Inc.
    78-2E-EF   # Nokia Corporation
    78-30-3B   # Stephen Technologies Co.,Limited
    78-30-E1   # UltraClenz, LLC
    78-31-2B   # zte corporation
    78-31-C1   # Apple, Inc.
    78-32-4F   # Millennium Group, Inc.
    78-3A-84   # Apple, Inc.
    78-3C-E3   # Kai-EE
    78-3D-5B   # TELNET Redes Inteligentes S.A.
    78-3E-53   # BSkyB Ltd
    78-3F-15   # EasySYNC Ltd.
    78-40-E4   # Samsung Electronics Co.,Ltd
    78-44-05   # FUJITU(HONG KONG) ELECTRONIC Co.,LTD.
    78-44-76   # Zioncom technology co.,ltd
    78-45-61   # CyberTAN Technology Inc.
    78-45-C4   # Dell Inc.
    78-46-C4   # DAEHAP HYPER-TECH
    78-47-1D   # Samsung Electronics Co.,Ltd
    78-48-59   # Hewlett Packard
    78-49-1D   # The Will-Burt Company
    78-4B-08   # f.robotics acquisitions ltd
    78-4B-87   # Murata Manufacturing Co., Ltd.
    78-51-0C   # LiveU Ltd.
    78-52-1A   # Samsung Electronics Co.,Ltd
    78-52-62   # Shenzhen Hojy Software Co., Ltd.
    78-53-F2   # ROXTON Ltd.
    78-54-2E   # D-Link International
    78-55-17   # SankyuElectronics
    78-57-12   # Mobile Integration Workgroup
    78-58-F3   # Vachen Co.,Ltd
    78-59-3E   # RAFI GmbH & Co.KG
    78-59-5E   # Samsung Electronics Co.,Ltd
    78-59-68   # Hon Hai Precision Ind. Co.,Ltd.
    78-5C-72   # Hioso Technology Co., Ltd.
    78-5F-4C   # Argox Information Co., Ltd.
    78-61-7C   # MITSUMI ELECTRIC CO.,LTD
    78-64-E6   # Green Motive Technology Limited
    78-66-AE   # ZTEC Instruments, Inc.
    78-6A-89   # HUAWEI TECHNOLOGIES CO.,LTD
    78-6C-1C   # Apple, Inc.
    78-71-9C   # ARRIS Group, Inc.
    78-7E-61   # Apple, Inc.
    78-7F-62   # GiK mbH
    78-81-8F   # Server Racks Australia Pty Ltd
    78-84-3C   # Sony Corporation
    78-84-EE   # INDRA ESPACIO S.A.
    78-89-73   # CMC
    78-8B-77   # Standar Telecom
    78-8C-54   # Eltek Technologies LTD
    78-8D-F7   # Hitron Technologies. Inc
    78-8E-33   # Jiangsu SEUIC Technology Co.,Ltd
    78-92-3E   # Nokia Corporation
    78-92-9C   # Intel Corporate
    78-96-84   # ARRIS Group, Inc.
    78-98-FD   # Q9 Networks Inc.
    78-99-5C   # Nationz Technologies Inc
    78-99-66   # Musilab Electronics (DongGuan)Co.,Ltd.
    78-99-8F   # MEDILINE ITALIA SRL
    78-9C-85   # August Home, Inc.
    78-9C-E7   # Shenzhen Aikede Technology Co., Ltd
    78-9E-D0   # Samsung Electronics
    78-9F-4C   # HOERBIGER Elektronik GmbH
    78-9F-70   # Apple, Inc.
    78-9F-87   # Siemens AG I IA PP PRM
    78-A0-51   # iiNet Labs Pty Ltd
    78-A1-06   # TP-LINK TECHNOLOGIES CO.,LTD.
    78-A1-83   # Advidia
    78-A2-A0   # Nintendo Co., Ltd.
    78-A3-51   # SHENZHEN ZHIBOTONG ELECTRONICS CO.,LTD
    78-A3-E4   # Apple, Inc.
    78-A5-04   # Texas Instruments
    78-A5-DD   # Shenzhen Smarteye Digital Electronics Co., Ltd
    78-A6-83   # Precidata
    78-A6-BD   # DAEYEON Control&Instrument Co,.Ltd
    78-A7-14   # Amphenol
    78-A8-73   # Samsung Electronics Co.,Ltd
    78-AB-60   # ABB Australia
    78-AB-BB   # Samsung Electronics Co.,Ltd
    78-AC-BF   # Igneous Systems
    78-AC-C0   # Hewlett Packard
    78-AE-0C   # Far South Networks
    78-B3-B9   # ShangHai sunup lighting CO.,LTD
    78-B3-CE   # Elo touch solutions
    78-B5-D2   # Ever Treasure Industrial Limited
    78-B6-C1   # AOBO Telecom Co.,Ltd
    78-B8-1A   # INTER SALES A/S
    78-BA-D0   # Shinybow Technology Co. Ltd.
    78-BA-F9   # Cisco Systems, Inc
    78-BD-BC   # Samsung Electronics Co.,Ltd
    78-BE-B6   # Enhanced Vision
    78-BE-BD   # STULZ GmbH
    78-C2-C0   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    78-C3-E9   # Samsung Electronics Co.,Ltd
    78-C4-0E   # H&D Wireless
    78-C4-AB   # Shenzhen Runsil Technology Co.,Ltd
    78-C5-E5   # Texas Instruments
    78-C6-BB   # Innovasic, Inc.
    78-CA-04   # Nokia Corporation
    78-CA-39   # Apple, Inc.
    78-CA-5E   # ELNO
    78-CA-83   # IEEE Registration Authority
    78-CB-33   # DHC Software Co.,Ltd
    78-CB-68   # DAEHAP HYPER-TECH
    78-CD-8E   # SMC Networks Inc
    78-D0-04   # Neousys Technology Inc.
    78-D1-29   # Vicos
    78-D3-4F   # Pace-O-Matic, Inc.
    78-D3-8D   # HONGKONG YUNLINK TECHNOLOGY LIMITED
    78-D5-B5   # NAVIELEKTRO KY
    78-D6-6F   # Aristocrat Technologies Australia Pty. Ltd.
    78-D6-B2   # Toshiba
    78-D6-F0   # Samsung Electro Mechanics
    78-D7-52   # HUAWEI TECHNOLOGIES CO.,LTD
    78-D7-5F   # Apple, Inc.
    78-D9-9F   # NuCom HK Ltd.
    78-DA-6E   # Cisco Systems, Inc
    78-DA-B3   # GBO Technology
    78-DD-08   # Hon Hai Precision Ind. Co.,Ltd.
    78-DD-D6   # c-scape
    78-DE-E4   # Texas Instruments
    78-E3-B5   # Hewlett Packard
    78-E4-00   # Hon Hai Precision Ind. Co.,Ltd.
    78-E7-D1   # Hewlett Packard
    78-E8-B6   # zte corporation
    78-E9-80   # RainUs Co.,Ltd
    78-EB-14   # SHENZHEN FAST TECHNOLOGIES CO.,LTD
    78-EB-39   # Instituto Nacional de Tecnología Industrial
    78-EC-22   # Shanghai Qihui Telecom Technology Co., LTD
    78-EC-74   # Kyland-USA
    78-EF-4C   # Unetconvergence Co., Ltd.
    78-F5-57   # HUAWEI TECHNOLOGIES CO.,LTD
    78-F5-E5   # BEGA Gantenbrink-Leuchten KG
    78-F5-FD   # HUAWEI TECHNOLOGIES CO.,LTD
    78-F7-BE   # Samsung Electronics Co.,Ltd
    78-F7-D0   # Silverbrook Research
    78-F8-82   # LG Electronics (Mobile Communications)
    78-F9-44   # Private
    78-FC-14   # B Communications Pty Ltd
    78-FD-94   # Apple, Inc.
    78-FE-3D   # Juniper Networks
    78-FE-41   # Socus networks
    78-FE-E2   # Shanghai Diveo Technology Co., Ltd
    78-FF-57   # Intel Corporate
    7C-01-87   # Curtis Instruments, Inc.
    7C-01-91   # Apple, Inc.
    7C-02-BC   # Hansung Electronics Co. LTD
    7C-03-4C   # Sagemcom Broadband SAS
    7C-03-D8   # Sagemcom Broadband SAS
    7C-05-07   # PEGATRON CORPORATION
    7C-05-1E   # RAFAEL LTD.
    7C-06-23   # Ultra Electronics, CIS
    7C-08-D9   # Shanghai B-Star Technology Co
    7C-09-2B   # Bekey A/S
    7C-0A-50   # J-MEX Inc.
    7C-0B-C6   # Samsung Electronics Co.,Ltd
    7C-0E-CE   # Cisco Systems, Inc
    7C-11-BE   # Apple, Inc.
    7C-11-CD   # QianTang Technology
    7C-14-76   # Damall Technologies SAS
    7C-16-0D   # Saia-Burgess Controls AG
    7C-18-CD   # E-TRON Co.,Ltd.
    7C-1A-03   # 8Locations Co., Ltd.
    7C-1A-FC   # Dalian Co-Edifice Video Technology Co., Ltd
    7C-1C-F1   # HUAWEI TECHNOLOGIES CO.,LTD
    7C-1D-D9   # Xiaomi Communications Co Ltd
    7C-1E-52   # Microsoft
    7C-1E-B3   # 2N TELEKOMUNIKACE a.s.
    7C-20-48   # KoamTac
    7C-20-64   # Alcatel Lucent IPD
    7C-25-87   # chaowifi.com
    7C-2B-E1   # Shenzhen Ferex Electrical Co.,Ltd
    7C-2C-F3   # Secure Electrans Ltd
    7C-2E-0D   # Blackmagic Design
    7C-2F-80   # Gigaset Communications GmbH
    7C-33-6E   # MEG Electronics Inc.
    7C-38-6C   # Real Time Logic
    7C-39-20   # SSOMA SECURITY
    7C-3B-D5   # Imago Group
    7C-3C-B6   # Shenzhen Homecare Technology Co.,Ltd.
    7C-3E-9D   # PATECH
    7C-43-8F   # E-Band Communications Corp.
    7C-44-4C   # Entertainment Solutions, S.L.
    7C-49-B9   # Plexus Manufacturing Sdn Bhd
    7C-4A-82   # Portsmith LLC
    7C-4A-A8   # MindTree Wireless PVT Ltd
    7C-4B-78   # Red Sun Synthesis Pte Ltd
    7C-4C-58   # Scale Computing, Inc.
    7C-4C-A5   # BSkyB Ltd
    7C-4F-B5   # Arcadyan Technology Corporation
    7C-53-4A   # Metamako
    7C-55-E7   # YSI, Inc.
    7C-5A-67   # JNC Systems, Inc.
    7C-5C-F8   # Intel Corporate
    7C-60-97   # HUAWEI TECHNOLOGIES CO.,LTD
    7C-61-93   # HTC Corporation
    7C-66-9D   # Texas Instruments
    7C-69-F6   # Cisco Systems, Inc
    7C-6A-B3   # IBC TECHNOLOGIES INC.
    7C-6A-C3   # GatesAir, Inc
    7C-6A-DB   # SafeTone Technology Co.,Ltd
    7C-6B-33   # Tenyu Tech Co. Ltd.
    7C-6B-52   # Tigaro Wireless
    7C-6C-39   # PIXSYS SRL
    7C-6C-8F   # AMS NEVE LTD
    7C-6D-62   # Apple, Inc.
    7C-6D-F8   # Apple, Inc.
    7C-6F-06   # Caterpillar Trimble Control Technologies
    7C-6F-F8   # ShenZhen ACTO Digital Video Technology Co.,Ltd.
    7C-70-BC   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    7C-71-76   # Wuxi iData Technology Company Ltd.
    7C-72-E4   # Unikey Technologies
    7C-76-73   # ENMAS GmbH
    7C-7A-53   # Phytrex Technology Corp.
    7C-7A-91   # Intel Corporate
    7C-7B-E4   # Z'SEDAI KENKYUSHO CORPORATION
    7C-7D-3D   # HUAWEI TECHNOLOGIES CO.,LTD
    7C-7D-41   # Jinmuyu Electronics Co., Ltd.
    7C-82-2D   # Nortec
    7C-82-74   # Shenzhen Hikeen Technology CO.,LTD
    7C-83-06   # Glen Dimplex Nordic as
    7C-8D-91   # Shanghai Hongzhuo Information Technology co.,LTD
    7C-8E-E4   # Texas Instruments
    7C-91-22   # Samsung Electronics Co.,Ltd
    7C-94-B2   # Philips Healthcare PCCI
    7C-95-F3   # Cisco Systems, Inc
    7C-97-63   # Openmatics s.r.o.
    7C-9A-9B   # VSE valencia smart energy
    7C-A1-5D   # GN ReSound A/S
    7C-A2-37   # King Slide Technology CO., LTD.
    7C-A2-3E   # HUAWEI TECHNOLOGIES CO.,LTD
    7C-A2-9B   # D.SignT GmbH & Co. KG
    7C-A6-1D   # MHL, LLC
    7C-AB-25   # MESMO TECHNOLOGY INC.
    7C-AC-B2   # Bosch Software Innovations GmbH
    7C-AD-74   # Cisco Systems, Inc
    7C-B0-3E   # OSRAM GmbH
    7C-B1-5D   # HUAWEI TECHNOLOGIES CO.,LTD
    7C-B1-77   # Satelco AG
    7C-B2-1B   # Cisco SPVTG
    7C-B2-32   # Hui Zhou Gaoshengda Technology Co.,LTD
    7C-B2-5C   # Acacia Communications
    7C-B5-42   # ACES Technology
    7C-B7-33   # ASKEY COMPUTER CORP
    7C-B7-7B   # Paradigm Electronics Inc
    7C-BB-6F   # Cosco Electronics Co., Ltd.
    7C-BB-8A   # Nintendo Co., Ltd.
    7C-BD-06   # AE REFUsol
    7C-BF-88   # Mobilicom LTD
    7C-BF-B1   # ARRIS Group, Inc.
    7C-C3-A1   # Apple, Inc.
    7C-C4-EF   # Devialet
    7C-C5-37   # Apple, Inc.
    7C-C7-09   # Shenzhen RF-LINK Elec&Technology.,Ltd
    7C-C8-AB   # Acro Associates, Inc.
    7C-C8-D0   # TIANJIN YAAN TECHNOLOGY CO., LTD.
    7C-C8-D7   # Damalisk
    7C-C9-5A   # EMC
    7C-CB-0D   # Antaira Technologies, LLC
    7C-CC-B8   # Intel Corporate
    7C-CD-11   # MS-Magnet
    7C-CD-3C   # Guangzhou Juzing Technology Co., Ltd
    7C-CF-CF   # Shanghai SEARI Intelligent System Co., Ltd
    7C-D1-C3   # Apple, Inc.
    7C-D3-0A   # INVENTEC Corporation
    7C-D7-62   # Freestyle Technology Pty Ltd
    7C-D8-44   # Enmotus Inc
    7C-D9-FE   # New Cosmos Electric Co., Ltd.
    7C-DA-84   # Dongnian Networks Inc.
    7C-DD-11   # Chongqing MAS SCI&TECH.Co.,Ltd
    7C-DD-20   # IOXOS Technologies S.A.
    7C-DD-90   # Shenzhen Ogemray Technology Co., Ltd.
    7C-E0-44   # NEON Inc
    7C-E1-FF   # Computer Performance, Inc. DBA Digital Loggers, Inc.
    7C-E4-AA   # Private
    7C-E5-24   # Quirky, Inc.
    7C-E5-6B   # ESEN Optoelectronics Technology Co.,Ltd.
    7C-E9-D3   # Hon Hai Precision Ind. Co.,Ltd.
    7C-EB-EA   # ASCT
    7C-EC-79   # Texas Instruments
    7C-ED-8D   # Microsoft
    7C-EF-18   # Creative Product Design Pty. Ltd.
    7C-EF-8A   # Inhon International Ltd.
    7C-F0-5F   # Apple, Inc.
    7C-F0-98   # Bee Beans Technologies, Inc.
    7C-F0-BA   # Linkwell Telesystems Pvt Ltd
    7C-F4-29   # NUUO Inc.
    7C-F8-54   # Samsung Electronics
    7C-F9-0E   # Samsung Electronics Co.,Ltd
    7C-FA-DF   # Apple, Inc.
    7C-FE-28   # Salutron Inc.
    7C-FE-4E   # Shenzhen Safe vision Technology Co.,LTD
    7C-FE-90   # Mellanox Technologies, Inc.
    7C-FF-62   # Huizhou Super Electron Technology Co.,Ltd.
    80-00-0B   # Intel Corporate
    80-00-10   # ATT BELL LABORATORIES
    80-00-6E   # Apple, Inc.
    80-01-84   # HTC Corporation
    80-02-DF   # ORA Inc.
    80-05-DF   # Montage Technology Group Limited
    80-07-A2   # Esson Technology Inc.
    80-09-02   # Keysight Technologies, Inc.
    80-0A-06   # COMTEC co.,ltd
    80-0A-80   # IEEE Registration Authority
    80-0B-51   # Chengdu XGimi Technology Co.,Ltd
    80-0E-24   # ForgetBox
    80-14-40   # Sunlit System Technology Corp
    80-14-A8   # Guangzhou V-SOLUTION Electronic Technology Co., Ltd.
    80-16-B7   # Brunel University
    80-17-7D   # Nortel Networks
    80-18-A7   # Samsung Eletronics Co., Ltd
    80-19-34   # Intel Corporate
    80-19-67   # Shanghai Reallytek Information Technology  Co.,Ltd
    80-1D-AA   # Avaya Inc
    80-1F-02   # Edimax Technology Co. Ltd.
    80-20-AF   # Trade FIDES, a.s.
    80-22-75   # Beijing Beny Wave Technology Co Ltd
    80-29-94   # Technicolor CH USA
    80-2A-A8   # Ubiquiti Networks, Inc.
    80-2A-FA   # Germaneers GmbH
    80-2D-E1   # Solarbridge Technologies
    80-2E-14   # azeti Networks AG
    80-2F-DE   # Zurich Instruments AG
    80-30-DC   # Texas Instruments
    80-34-57   # OT Systems Limited
    80-37-73   # NETGEAR
    80-38-96   # SHARP Corporation
    80-38-BC   # HUAWEI TECHNOLOGIES CO.,LTD
    80-38-FD   # LeapFrog Enterprises, Inc.
    80-39-E5   # PATLITE CORPORATION
    80-3B-2A   # ABB Xiamen Low Voltage Equipment Co.,Ltd.
    80-3B-9A   # ghe-ces electronic ag
    80-3F-5D   # Winstars Technology Ltd
    80-3F-D6   # bytes at work AG
    80-41-4E   # BBK Electronics Corp., Ltd.,
    80-42-7C   # Adolf Tedsen GmbH & Co. KG
    80-47-31   # Packet Design, Inc.
    80-48-A5   # SICHUAN TIANYI COMHEART TELECOM CO.,LTD
    80-49-71   # Apple, Inc.
    80-4B-20   # Ventilation Control
    80-4E-81   # Samsung Electronics Co.,Ltd
    80-4F-58   # ThinkEco, Inc.
    80-50-1B   # Nokia Corporation
    80-50-67   # W & D TECHNOLOGY CORPORATION
    80-56-F2   # Hon Hai Precision Ind. Co.,Ltd.
    80-57-19   # Samsung Electronics Co.,Ltd
    80-58-C5   # NovaTec Kommunikationstechnik GmbH
    80-59-FD   # Noviga
    80-60-07   # RIM
    80-61-8F   # Shenzhen sangfei consumer communications co.,ltd
    80-64-59   # Nimbus Inc.
    80-65-6D   # Samsung Electronics Co.,Ltd
    80-65-E9   # BenQ Corporation
    80-66-29   # Prescope Technologies CO.,LTD.
    80-6A-B0   # Shenzhen TINNO Mobile Technology Corp.
    80-6C-1B   # Motorola Mobility LLC, a Lenovo Company
    80-6C-8B   # KAESER KOMPRESSOREN AG
    80-6C-BC   # NET New Electronic Technology GmbH
    80-71-1F   # Juniper Networks
    80-71-7A   # HUAWEI TECHNOLOGIES CO.,LTD
    80-73-9F   # KYOCERA Corporation
    80-74-59   # K's Co.,Ltd.
    80-76-93   # Newag SA
    80-79-AE   # ShanDong Tecsunrise  Co.,Ltd
    80-7A-7F   # ABB Genway Xiamen Electrical Equipment CO., LTD
    80-7A-BF   # HTC Corporation
    80-7B-1E   # Corsair Components
    80-7B-85   # IEEE Registration Authority
    80-7D-1B   # Neosystem Co. Ltd.
    80-7D-E3   # Chongqing Sichuan Instrument Microcircuit Co.LTD.
    80-81-A5   # TONGQING COMMUNICATION EQUIPMENT (SHENZHEN) Co.,Ltd
    80-82-87   # ATCOM Technology Co.Ltd.
    80-86-98   # Netronics Technologies Inc.
    80-86-F2   # Intel Corporate
    80-89-17   # TP-LINK TECHNOLOGIES CO.,LTD.
    80-8B-5C   # Shenzhen Runhuicheng Technology Co., Ltd
    80-91-2A   # Lih Rong electronic Enterprise Co., Ltd.
    80-91-C0   # AgileMesh, Inc.
    80-92-9F   # Apple, Inc.
    80-93-93   # Xapt GmbH
    80-94-6C   # TOKYO RADAR CORPORATION
    80-96-B1   # ARRIS Group, Inc.
    80-96-CA   # Hon Hai Precision Ind. Co.,Ltd.
    80-97-1B   # Altenergy Power System,Inc.
    80-9B-20   # Intel Corporate
    80-9F-AB   # Fiberhome Telecommunication Technologies Co.,LTD
    80-A1-AB   # Intellisis
    80-A1-D7   # Shanghai DareGlobal Technologies Co.,Ltd
    80-A5-89   # AzureWave Technology Inc.
    80-A8-5D   # Osterhout Design Group
    80-AA-A4   # USAG
    80-AC-AC   # Juniper Networks
    80-AD-67   # Kasda Networks Inc
    80-B2-19   # ELEKTRON TECHNOLOGY UK LIMITED
    80-B2-89   # Forworld Electronics Ltd.
    80-B3-2A   # Alstom Grid
    80-B6-86   # HUAWEI TECHNOLOGIES CO.,LTD
    80-B7-09   # Viptela, Inc
    80-B9-5C   # ELFTECH Co., Ltd.
    80-BA-AC   # TeleAdapt Ltd
    80-BA-E6   # Neets
    80-BB-EB   # Satmap Systems Ltd
    80-BE-05   # Apple, Inc.
    80-C1-6E   # Hewlett Packard
    80-C5-E6   # Microsoft Corporation
    80-C6-3F   # Remec Broadband Wireless , LLC
    80-C6-AB   # Technicolor USA Inc.
    80-C6-CA   # Endian s.r.l.
    80-C8-62   # Openpeak, Inc
    80-CE-B1   # Theissen Training Systems GmbH
    80-CF-41   # Lenovo Mobile Communication Technology Ltd.
    80-D0-19   # Embed, Inc
    80-D0-9B   # HUAWEI TECHNOLOGIES CO.,LTD
    80-D1-60   # Integrated Device Technology (Malaysia) Sdn. Bhd.
    80-D1-8B   # Hangzhou I'converge Technology Co.,Ltd
    80-D2-1D   # AzureWave Technology Inc.
    80-D4-33   # LzLabs GmbH
    80-D6-05   # Apple, Inc.
    80-D7-33   # QSR Automations, Inc.
    80-DB-31   # Power Quotient International Co., Ltd.
    80-E0-1D   # Cisco Systems, Inc
    80-E4-DA   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    80-E6-50   # Apple, Inc.
    80-E8-6F   # Cisco Systems, Inc
    80-EA-23   # Wistron Neweb Corp.
    80-EA-96   # Apple, Inc.
    80-EA-CA   # Dialog Semiconductor Hellas SA
    80-EB-77   # Wistron Corporation
    80-ED-2C   # Apple, Inc.
    80-EE-73   # Shuttle Inc.
    80-F2-5E   # Kyynel
    80-F5-03   # Pace plc
    80-F5-93   # IRCO Sistemas de Telecomunicación S.A.
    80-F6-2E   # Hangzhou H3C Technologies Co., Limited
    80-F8-EB   # RayTight
    80-FA-5B   # CLEVO CO.
    80-FB-06   # HUAWEI TECHNOLOGIES CO.,LTD
    80-FF-A8   # UNIDIS
    84-00-D2   # Sony Mobile Communications AB
    84-01-A7   # Greyware Automation Products, Inc
    84-0B-2D   # SAMSUNG ELECTRO-MECHANICS CO., LTD
    84-0F-45   # Shanghai GMT Digital Technologies Co., Ltd
    84-10-0D   # Motorola Mobility LLC, a Lenovo Company
    84-11-9E   # Samsung Electronics Co.,Ltd
    84-17-15   # GP Electronics (HK) Ltd.
    84-17-66   # Weifang GoerTek Electronics Co., Ltd
    84-18-26   # Osram GmbH
    84-18-3A   # Ruckus Wireless
    84-18-88   # Juniper Networks
    84-1B-38   # Shenzhen Excelsecu Data Technology Co.,Ltd
    84-1B-5E   # NETGEAR
    84-1E-26   # KERNEL-I Co.,LTD
    84-21-41   # Shenzhen Ginwave Technologies Ltd.
    84-24-8D   # Zebra Technologies Inc
    84-25-3F   # Silex Technology, Inc
    84-25-A4   # Tariox Limited
    84-25-DB   # Samsung Electronics Co.,Ltd
    84-26-15   # ADB Broadband Italia
    84-26-2B   # Alcatel-Lucent
    84-26-90   # BEIJING THOUGHT SCIENCE CO.,LTD.
    84-27-CE   # Corporation of the Presiding Bishop of The Church of Jesus Christ of Latter-day Saints
    84-28-5A   # Saffron Solutions Inc
    84-29-14   # EMPORIA TELECOM Produktions- und VertriebsgesmbH & Co KG
    84-29-99   # Apple, Inc.
    84-2B-2B   # Dell Inc.
    84-2B-50   # Huria Co.,Ltd.
    84-2B-BC   # Modelleisenbahn GmbH
    84-2E-27   # Samsung Electronics Co.,Ltd
    84-2F-75   # Innokas Group
    84-30-E5   # SkyHawke Technologies, LLC
    84-32-EA   # ANHUI WANZTEN P&T CO., LTD
    84-34-97   # Hewlett Packard
    84-36-11   # hyungseul publishing networks
    84-38-35   # Apple, Inc.
    84-38-38   # Samsung Electro Mechanics co., LTD.
    84-3A-4B   # Intel Corporate
    84-3F-4E   # Tri-Tech Manufacturing, Inc.
    84-44-64   # ServerU Inc
    84-48-23   # WOXTER TECHNOLOGY Co. Ltd
    84-49-15   # vArmour Networks, Inc.
    84-4B-B7   # Beijing Sankuai Online Technology Co.,Ltd
    84-4B-F5   # Hon Hai Precision Ind. Co.,Ltd.
    84-4F-03   # Ablelink Electronics Ltd
    84-51-81   # Samsung Electronics Co.,Ltd
    84-55-A5   # Samsung Electronics Co.,Ltd
    84-56-9C   # Coho Data, Inc.,
    84-57-87   # DVR C&C Co., Ltd.
    84-5B-12   # HUAWEI TECHNOLOGIES CO.,LTD
    84-5C-93   # Chabrier Services
    84-5D-D7   # Shenzhen Netcom Electronics Co.,Ltd
    84-61-A0   # ARRIS Group, Inc.
    84-62-23   # Shenzhen Coship Electronics Co., Ltd.
    84-62-A6   # EuroCB (Phils), Inc.
    84-63-D6   # Microsoft Corporation
    84-68-3E   # Intel Corporate
    84-6A-ED   # Wireless Tsukamoto.,co.LTD
    84-6E-B1   # Park Assist LLC
    84-72-07   # I&C Technology
    84-73-03   # Letv Mobile and Intelligent Information Technology (Beijing) Corporation Ltd.
    84-74-2A   # zte corporation
    84-76-16   # Addat s.r.o.
    84-77-78   # Cochlear Limited
    84-78-8B   # Apple, Inc.
    84-78-AC   # Cisco Systems, Inc
    84-79-73   # Shanghai Baud Data Communication Co.,Ltd.
    84-7A-88   # HTC Corporation
    84-7D-50   # Holley Metering Limited
    84-7E-40   # Texas Instruments
    84-80-2D   # Cisco Systems, Inc
    84-82-F4   # Beijing Huasun Unicreate Technology Co., Ltd
    84-83-36   # Newrun
    84-83-71   # Avaya Inc
    84-84-33   # Paradox Engineering SA
    84-85-06   # Apple, Inc.
    84-85-0A   # Hella Sonnen- und Wetterschutztechnik GmbH
    84-86-F3   # Greenvity Communications
    84-89-AD   # Apple, Inc.
    84-8D-84   # Rajant Corporation
    84-8D-C7   # Cisco SPVTG
    84-8E-0C   # Apple, Inc.
    84-8E-96   # Embertec Pty Ltd
    84-8E-DF   # Sony Mobile Communications AB
    84-8F-69   # Dell Inc.
    84-90-00   # Arnold & Richter Cine Technik
    84-93-0C   # InCoax Networks Europe AB
    84-94-8C   # Hitron Technologies. Inc
    84-96-81   # Cathay Communication Co.,Ltd
    84-96-D8   # Pace plc
    84-97-B8   # Memjet Inc.
    84-9C-A6   # Arcadyan Technology Corporation
    84-9D-C5   # Centera Photonics Inc.
    84-A4-23   # Sagemcom Broadband SAS
    84-A4-66   # Samsung Electronics Co.,Ltd
    84-A6-C8   # Intel Corporate
    84-A7-83   # Alcatel Lucent
    84-A7-88   # Perples
    84-A8-E4   # HUAWEI TECHNOLOGIES CO.,LTD
    84-A9-91   # Cyber Trans Japan Co.,Ltd.
    84-AC-A4   # Beijing Novel Super Digital TV Technology Co., Ltd
    84-AC-FB   # Crouzet Automatismes
    84-AF-1F   # Beat System Service Co,. Ltd.
    84-B1-53   # Apple, Inc.
    84-B2-61   # Cisco Systems, Inc
    84-B5-17   # Cisco Systems, Inc
    84-B5-9C   # Juniper Networks
    84-B8-02   # Cisco Systems, Inc
    84-BA-3B   # CANON INC.
    84-C2-E4   # Jiangsu Qinheng Co., Ltd.
    84-C3-E8   # Vaillant GmbH
    84-C7-27   # Gnodal Ltd
    84-C7-A9   # C3PO S.A.
    84-C8-B1   # Incognito Software Systems Inc.
    84-C9-B2   # D-Link International
    84-CF-BF   # Fairphone
    84-D3-2A   # IEEE 1905.1
    84-D4-7E   # Aruba Networks
    84-D4-C8   # Widex A/S
    84-D6-D0   # Amazon Technologies Inc.
    84-D9-C8   # Unipattern Co.,
    84-DB-2F   # Sierra Wireless Inc
    84-DB-AC   # HUAWEI TECHNOLOGIES CO.,LTD
    84-DB-FC   # Alcatel-Lucent
    84-DD-20   # Texas Instruments
    84-DD-B7   # Cilag GmbH International
    84-DE-3D   # Crystal Vision Ltd
    84-DF-0C   # NET2GRID BV
    84-DF-19   # Chuango Security Technology Corporation
    84-E0-58   # Pace plc
    84-E4-D9   # Shenzhen NEED technology Ltd.
    84-E6-29   # Bluwan SA
    84-E7-14   # Liang Herng Enterprise,Co.Ltd.
    84-EA-99   # Vieworks
    84-EB-18   # Texas Instruments
    84-ED-33   # BBMC Co.,Ltd
    84-F1-29   # Metrascale Inc.
    84-F4-93   # OMS spol. s.r.o.
    84-F6-4C   # Cross Point BV
    84-F6-FA   # Miovision Technologies Incorporated
    84-FC-FE   # Apple, Inc.
    84-FE-9E   # RTC Industries, Inc.
    88-03-55   # Arcadyan Technology Corporation
    88-07-4B   # LG Electronics (Mobile Communications)
    88-09-05   # MTMCommunications
    88-09-AF   # Masimo Corp.
    88-0F-10   # Huami Information Technology Co.,Ltd.
    88-0F-B6   # Jabil Circuits India Pvt Ltd,-EHTP unit
    88-10-36   # Panodic(ShenZhen) Electronics Limted
    88-12-4E   # Qualcomm Atheros
    88-14-2B   # Protonic Holland
    88-15-44   # Meraki, Inc.
    88-18-AE   # Tamron Co., Ltd
    88-1B-99   # SHENZHEN XIN FEI JIA ELECTRONIC CO. LTD.
    88-1D-FC   # Cisco Systems, Inc
    88-1F-A1   # Apple, Inc.
    88-20-12   # LMI Technologies
    88-21-E3   # Nebusens, S.L.
    88-23-64   # Watchnet DVR Inc
    88-23-FE   # TTTech Computertechnik AG
    88-25-2C   # Arcadyan Technology Corporation
    88-25-93   # TP-LINK TECHNOLOGIES CO.,LTD.
    88-29-50   # Dalian Netmoon Tech Develop Co.,Ltd
    88-2E-5A   # storONE
    88-30-8A   # Murata Manufacturing Co., Ltd.
    88-32-9B   # Samsung Electro Mechanics co.,LTD.
    88-33-14   # Texas Instruments
    88-33-BE   # Ivenix, Inc.
    88-35-4C   # Transics
    88-36-12   # SRC Computers, LLC
    88-3B-8B   # Cheering Connection Co. Ltd.
    88-41-57   # Shenzhen Atsmart Technology Co.,Ltd.
    88-41-C1   # ORBISAT DA AMAZONIA IND E AEROL SA
    88-41-FC   # AirTies Wireless Netowrks
    88-43-E1   # Cisco Systems, Inc
    88-44-F6   # Nokia Corporation
    88-46-2A   # Telechips Inc.
    88-4A-EA   # Texas Instruments
    88-4B-39   # Siemens AG, Healthcare Sector
    88-51-FB   # Hewlett Packard
    88-53-2E   # Intel Corporate
    88-53-95   # Apple, Inc.
    88-53-D4   # HUAWEI TECHNOLOGIES CO.,LTD
    88-57-6D   # XTA Electronics Ltd
    88-57-EE   # BUFFALO.INC
    88-5A-92   # Cisco Systems, Inc
    88-5B-DD   # Aerohive Networks Inc.
    88-5C-47   # Alcatel Lucent
    88-5D-90   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    88-61-5A   # Siano Mobile Silicon Ltd.
    88-63-DF   # Apple, Inc.
    88-68-5C   # Shenzhen ChuangDao & Perpetual Eternal Technology Co.,Ltd
    88-6B-76   # CHINA HOPEFUL GROUP HOPEFUL ELECTRIC CO.,LTD
    88-70-33   # Hangzhou Silan Microelectronic Inc
    88-70-8C   # Lenovo Mobile Communication Technology Ltd.
    88-70-EF   # SC Professional Trading Co., Ltd.
    88-73-84   # Toshiba
    88-73-98   # K2E Tekpoint
    88-75-56   # Cisco Systems, Inc
    88-78-9C   # Game Technologies SA
    88-7F-03   # Comper Technology Investment Limited
    88-86-03   # HUAWEI TECHNOLOGIES CO.,LTD
    88-86-A0   # Simton Technologies, Ltd.
    88-87-17   # CANON INC.
    88-87-DD   # DarbeeVision Inc.
    88-89-14   # All Components Incorporated
    88-89-64   # GSI Electronics Inc.
    88-8B-5D   # Storage Appliance Corporation
    88-8C-19   # Brady Corp Asia Pacific Ltd
    88-90-8D   # Cisco Systems, Inc
    88-91-66   # Viewcooper Corp.
    88-91-DD   # Racktivity
    88-94-71   # Brocade Communications Systems, Inc.
    88-94-7E   # Fiberhome Telecommunication Technologies Co.,LTD
    88-94-F9   # Gemicom Technology, Inc.
    88-95-B9   # Unified Packet Systems Crop
    88-96-76   # TTC MARCONI s.r.o.
    88-96-B6   # Global Fire Equipment S.A.
    88-96-F2   # Valeo Schalter und Sensoren GmbH
    88-97-DF   # Entrypass Corporation Sdn. Bhd.
    88-98-21   # TERAON
    88-9B-39   # Samsung Electronics Co.,Ltd
    88-9C-A6   # BTB Korea INC
    88-9F-FA   # Hon Hai Precision Ind. Co.,Ltd.
    88-A0-84   # Formation Data Systems
    88-A2-5E   # Juniper Networks
    88-A2-D7   # HUAWEI TECHNOLOGIES CO.,LTD
    88-A3-CC   # Amatis Controls
    88-A5-BD   # QPCOM INC.
    88-A7-3C   # Ragentek Technology Group
    88-AC-C1   # Generiton Co., Ltd.
    88-AE-1D   # COMPAL INFORMATION (KUNSHAN) CO., LTD.
    88-B1-68   # Delta Control GmbH
    88-B1-E1   # AirTight Networks, Inc.
    88-B6-27   # Gembird Europe BV
    88-B8-D0   # Dongguan Koppo Electronic Co.,Ltd
    88-BA-7F   # Qfiednet Co., Ltd.
    88-BF-D5   # Simple Audio Ltd
    88-C2-42   # Poynt Co.
    88-C2-55   # Texas Instruments
    88-C3-6E   # Beijing Ereneben lnformation Technology Limited
    88-C6-26   # Logitech - Ultimate Ears
    88-C6-63   # Apple, Inc.
    88-C9-D0   # LG Electronics
    88-CB-87   # Apple, Inc.
    88-CB-A5   # Suzhou Torchstar Intelligent Technology Co.,Ltd
    88-CE-FA   # HUAWEI TECHNOLOGIES CO.,LTD
    88-CF-98   # HUAWEI TECHNOLOGIES CO.,LTD
    88-D3-7B   # FirmTek, LLC
    88-D7-BC   # DEP Company
    88-D9-62   # Canopus Systems US LLC
    88-DC-96   # SENAO Networks, Inc.
    88-DD-79   # Voltaire
    88-E0-A0   # Shenzhen VisionSTOR Technologies Co., Ltd
    88-E0-F3   # Juniper Networks
    88-E1-61   # Art Beijing Science and Technology Development Co., Ltd.
    88-E3-AB   # HUAWEI TECHNOLOGIES CO.,LTD
    88-E6-03   # Avotek corporation
    88-E7-12   # Whirlpool Corporation
    88-E7-A6   # iKnowledge Integration Corp.
    88-E8-F8   # YONG TAI ELECTRONIC (DONGGUAN) LTD.
    88-E9-17   # Tamaggo
    88-ED-1C   # Cudo Communication Co., Ltd.
    88-F0-31   # Cisco Systems, Inc
    88-F0-77   # Cisco Systems, Inc
    88-F4-88   # cellon communications technology(shenzhen)Co.,Ltd.
    88-F4-90   # Jetmobile Pte Ltd
    88-F7-C7   # Technicolor USA Inc.
    88-FD-15   # LINEEYE CO., LTD
    88-FE-D6   # ShangHai WangYong Software Co., Ltd.
    8C-00-6D   # Apple, Inc.
    8C-04-FF   # Technicolor USA Inc.
    8C-05-51   # Koubachi AG
    8C-07-8C   # FLOW DATA INC
    8C-08-8B   # Remote Solution
    8C-09-F4   # ARRIS Group, Inc.
    8C-0C-90   # Ruckus Wireless
    8C-0C-A3   # Amper
    8C-0E-E3   # GUANGDONG OPPO MOBILE TELECOMMUNICATIONS CORP.,LTD
    8C-10-D4   # Sagemcom Broadband SAS
    8C-11-CB   # ABUS Security-Center GmbH & Co. KG
    8C-18-D9   # Shenzhen RF Technology Co., Ltd
    8C-1A-BF   # Samsung Electronics Co.,Ltd
    8C-1F-94   # RF Surgical System Inc.
    8C-21-0A   # TP-LINK TECHNOLOGIES CO.,LTD.
    8C-27-1D   # QuantHouse
    8C-27-8A   # Vocollect Inc
    8C-29-37   # Apple, Inc.
    8C-2D-AA   # Apple, Inc.
    8C-2F-39   # IBA Dosimetry GmbH
    8C-33-30   # EmFirst Co., Ltd.
    8C-33-57   # HiteVision Digital Media Technology Co.,Ltd.
    8C-34-FD   # HUAWEI TECHNOLOGIES CO.,LTD
    8C-3A-E3   # LG Electronics
    8C-3C-07   # Skiva Technologies, Inc.
    8C-3C-4A   # NAKAYO TELECOMMUNICATIONS,INC
    8C-41-F2   # RDA Technologies Ltd.
    8C-44-35   # Shanghai BroadMobi Communication Technology Co., Ltd.
    8C-4A-EE   # GIGA TMS INC
    8C-4B-59   # 3D Imaging & Simulations Corp
    8C-4C-DC   # PLANEX COMMUNICATIONS INC.
    8C-4D-B9   # Unmonday Ltd
    8C-4D-EA   # Cerio Corporation
    8C-51-05   # Shenzhen ireadygo Information Technology CO.,LTD.
    8C-53-F7   # A&D ENGINEERING CO., LTD.
    8C-54-1D   # LGE
    8C-56-9D   # Imaging Solutions Group
    8C-56-C5   # Nintendo Co., Ltd.
    8C-57-9B   # Wistron Neweb Corporation
    8C-57-FD   # LVX Western
    8C-58-77   # Apple, Inc.
    8C-59-8B   # C Technologies AB
    8C-5A-F0   # Exeltech Solar Products
    8C-5C-A1   # d-broad,INC
    8C-5D-60   # UCI Corporation Co.,Ltd.
    8C-5F-DF   # Beijing Railway Signal Factory
    8C-60-4F   # Cisco Systems, Inc
    8C-64-0B   # Beyond Devices d.o.o.
    8C-64-22   # Sony Mobile Communications AB
    8C-68-78   # Nortek-AS
    8C-6A-E4   # Viogem Limited
    8C-70-5A   # Intel Corporate
    8C-71-F8   # Samsung Electronics Co.,Ltd
    8C-73-6E   # FUJITSU LIMITED
    8C-76-C1   # Goden Tech Limited
    8C-77-12   # Samsung Electronics Co.,Ltd
    8C-77-16   # LONGCHEER TELECOMMUNICATION LIMITED
    8C-79-67   # zte corporation
    8C-7B-9D   # Apple, Inc.
    8C-7C-92   # Apple, Inc.
    8C-7C-B5   # Hon Hai Precision Ind. Co.,Ltd.
    8C-7C-FF   # Brocade Communications Systems, Inc.
    8C-7E-B3   # Lytro, Inc.
    8C-7F-3B   # ARRIS Group, Inc.
    8C-82-A8   # Insigma Technology Co.,Ltd
    8C-84-01   # Private
    8C-87-3B   # Leica Camera AG
    8C-89-A5   # Micro-Star INT'L CO., LTD
    8C-8A-6E   # ESTUN AUTOMATION TECHNOLOY CO., LTD
    8C-8B-83   # Texas Instruments
    8C-8E-76   # taskit GmbH
    8C-90-D3   # Alcatel Lucent
    8C-91-09   # Toyoshima Electric Technoeogy(Suzhou) Co.,Ltd.
    8C-92-36   # Aus.Linx Technology Co., Ltd.
    8C-94-CF   # Encell Technology, Inc.
    8C-99-E6   # TCT Mobile Limited
    8C-A0-48   # Beijing NeTopChip Technology Co.,LTD
    8C-A2-FD   # Starry, Inc.
    8C-A9-82   # Intel Corporate
    8C-AB-8E   # Shanghai Feixun Communication Co.,Ltd.
    8C-AE-4C   # Plugable Technologies
    8C-AE-89   # Y-cam Solutions Ltd
    8C-B0-94   # Airtech I&C Co., Ltd
    8C-B6-4F   # Cisco Systems, Inc
    8C-B7-F7   # Shenzhen UniStrong Science & Technology Co., Ltd
    8C-B8-2C   # IPitomy Communications
    8C-B8-64   # AcSiP Technology Corp.
    8C-BE-BE   # Xiaomi Communications Co Ltd
    8C-BF-9D   # Shanghai Xinyou Information Technology Ltd. Co.
    8C-BF-A6   # Samsung Electronics Co.,Ltd
    8C-C1-21   # Panasonic Corporation AVC Networks Company
    8C-C5-E1   # ShenZhen Konka Telecommunication Technology Co.,Ltd
    8C-C6-61   # Current, powered by GE
    8C-C7-AA   # Radinet Communications Inc.
    8C-C7-D0   # zhejiang ebang communication co.,ltd
    8C-C8-CD   # Samsung Electronics Co., LTD
    8C-CD-A2   # ACTP, Inc.
    8C-CD-E8   # Nintendo Co., Ltd.
    8C-CF-5C   # BEFEGA GmbH
    8C-D1-7B   # CG Mobile
    8C-D3-A2   # VisSim AS
    8C-D6-28   # Ikor Metering
    8C-DB-25   # ESG Solutions
    8C-DC-D4   # Hewlett Packard
    8C-DD-8D   # Wifly-City System Inc.
    8C-DE-52   # ISSC Technologies Corp.
    8C-DE-99   # Comlab Inc.
    8C-DF-9D   # NEC Corporation
    8C-E0-81   # zte corporation
    8C-E2-DA   # Circle Media Inc
    8C-E7-48   # Private
    8C-E7-8C   # DK Networks
    8C-E7-B3   # Sonardyne International Ltd
    8C-EE-C6   # Precepscion Pty. Ltd.
    8C-F2-28   # SHENZHEN MERCURY COMMUNICATION TECHNOLOGIES CO.,LTD.
    8C-F8-13   # ORANGE POLSKA
    8C-F9-45   # Power Automation pte Ltd
    8C-F9-C9   # MESADA Technology Co.,Ltd.
    8C-FA-BA   # Apple, Inc.
    8C-FD-F0   # QUALCOMM Incorporated
    90-00-4E   # Hon Hai Precision Ind. Co.,Ltd.
    90-00-DB   # Samsung Electronics Co.,Ltd
    90-01-3B   # Sagemcom Broadband SAS
    90-02-8A   # Shenzhen Shidean Legrand Electronic Products Co.,Ltd
    90-02-A9   # ZHEJIANG DAHUA TECHNOLOGY CO.,LTD
    90-03-B7   # PARROT
    90-09-17   # Far-sighted mobile
    90-0A-39   # Wiio, Inc.
    90-0A-3A   # PSG Plastic Service GmbH
    90-0B-C1   # Sprocomm Technologies CO.,Ltd
    90-0C-B4   # Alinket Electronic Technology Co., Ltd
    90-0D-66   # Digimore Electronics Co., Ltd
    90-0D-CB   # ARRIS Group, Inc.
    90-17-9B   # Nanomegas
    90-17-AC   # HUAWEI TECHNOLOGIES CO.,LTD
    90-18-5E   # Apex Tool Group GmbH & Co OHG
    90-18-7C   # Samsung Electro Mechanics co., LTD.
    90-18-AE   # Shanghai Meridian Technologies, Co. Ltd.
    90-19-00   # SCS SA
    90-1A-CA   # ARRIS Group, Inc.
    90-1B-0E   # Fujitsu Technology Solutions GmbH
    90-1D-27   # zte corporation
    90-1E-DD   # GREAT COMPUTER CORPORATION
    90-20-3A   # BYD Precision Manufacture Co.,Ltd
    90-20-83   # General Engine Management Systems Ltd.
    90-21-06   # BSkyB Ltd
    90-21-55   # HTC Corporation
    90-21-81   # Shanghai Huaqin Telecom Technology Co.,Ltd
    90-23-EC   # Availink, Inc.
    90-27-E4   # Apple, Inc.
    90-2B-34   # GIGA-BYTE TECHNOLOGY CO.,LTD.
    90-2C-C7   # C-MAX Asia Limited
    90-2E-1C   # Intel Corporate
    90-2E-87   # LabJack
    90-31-CD   # Onyx Healthcare Inc.
    90-34-2B   # Gatekeeper Systems, Inc.
    90-34-FC   # Hon Hai Precision Ind. Co.,Ltd.
    90-35-6E   # Vodafone Omnitel N.V.
    90-38-DF   # Changzhou Tiannengbo System Co. Ltd.
    90-3A-A0   # Alcatel-Lucent
    90-3C-92   # Apple, Inc.
    90-3C-AE   # Yunnan KSEC Digital Technology Co.,Ltd.
    90-3D-5A   # Shenzhen Wision Technology Holding Limited
    90-3D-6B   # Zicon Technology Corp.
    90-3E-AB   # ARRIS Group, Inc.
    90-45-06   # Tokyo Boeki Medisys Inc.
    90-46-B7   # Vadaro Pte Ltd
    90-47-16   # RORZE CORPORATION
    90-48-9A   # Hon Hai Precision Ind. Co.,Ltd.
    90-49-FA   # Intel Corporate
    90-4C-E5   # Hon Hai Precision Ind. Co.,Ltd.
    90-4E-2B   # HUAWEI TECHNOLOGIES CO.,LTD
    90-50-7B   # Advanced PANMOBIL Systems GmbH & Co. KG
    90-51-3F   # Elettronica Santerno SpA
    90-54-46   # TES ELECTRONIC SOLUTIONS
    90-55-AE   # Ericsson, EAB/RWI/K
    90-56-82   # Lenbrook Industries Limited
    90-56-92   # Autotalks Ltd.
    90-59-AF   # Texas Instruments
    90-5F-2E   # TCT Mobile Limited
    90-5F-8D   # modas GmbH
    90-60-F1   # Apple, Inc.
    90-61-0C   # Fida International (S) Pte Ltd
    90-67-17   # Alphion India Private Limited
    90-67-1C   # HUAWEI TECHNOLOGIES CO.,LTD
    90-67-B5   # Alcatel-Lucent
    90-67-F3   # Alcatel Lucent
    90-68-C3   # Motorola Mobility LLC, a Lenovo Company
    90-6C-AC   # Fortinet, Inc.
    90-6D-C8   # DLG Automação Industrial Ltda
    90-6E-BB   # Hon Hai Precision Ind. Co.,Ltd.
    90-6F-18   # Private
    90-6F-A9   # NANJING PUTIAN TELECOMMUNICATIONS TECHNOLOGY CO.,LTD.
    90-70-25   # Garea Microsys Co.,Ltd.
    90-72-40   # Apple, Inc.
    90-72-82   # Sagemcom Broadband SAS
    90-79-90   # Benchmark Electronics Romania SRL
    90-7A-0A   # Gebr. Bode GmbH & Co KG
    90-7A-28   # Beijing Morncloud Information And Technology Co. Ltd.
    90-7A-F1   # Wally
    90-7E-BA   # UTEK TECHNOLOGY (SHENZHEN) CO.,LTD
    90-7F-61   # Chicony Electronics Co., Ltd.
    90-82-60   # IEEE 1904.1 Working Group
    90-83-7A   # General Electric Water & Process Technologies
    90-84-0D   # Apple, Inc.
    90-88-A2   # IONICS TECHNOLOGY ME LTDA
    90-8C-09   # Total Phase
    90-8C-44   # H.K ZONGMU TECHNOLOGY CO., LTD.
    90-8C-63   # GZ Weedong Networks Technology Co. , Ltd
    90-8D-1D   # GH Technologies
    90-8D-6C   # Apple, Inc.
    90-8D-78   # D-Link International
    90-8F-CF   # UNO System Co., Ltd
    90-90-3C   # TRISON TECHNOLOGY CORPORATION
    90-90-60   # RSI VIDEO TECHNOLOGIES
    90-92-B4   # Diehl BGT Defence GmbH & Co. KG
    90-94-E4   # D-Link International
    90-97-D5   # Espressif Inc.
    90-98-64   # Impex-Sat GmbH&amp;Co KG
    90-99-16   # ELVEES NeoTek OJSC
    90-9D-E0   # Newland Design + Assoc. Inc.
    90-9F-33   # EFM Networks
    90-9F-43   # Accutron Instruments Inc.
    90-A2-10   # United Telecoms Ltd
    90-A2-DA   # GHEO SA
    90-A4-DE   # Wistron Neweb Corp.
    90-A6-2F   # NAVER
    90-A7-83   # JSW PACIFIC CORPORATION
    90-A7-C1   # Pakedge Device and Software Inc.
    90-AC-3F   # BrightSign LLC
    90-AE-1B   # TP-LINK TECHNOLOGIES CO.,LTD.
    90-B1-1C   # Dell Inc.
    90-B1-34   # ARRIS Group, Inc.
    90-B2-1F   # Apple, Inc.
    90-B6-86   # Murata Manufacturing Co., Ltd.
    90-B8-D0   # Joyent, Inc.
    90-B9-31   # Apple, Inc.
    90-B9-7D   # Johnson Outdoors Marine Electronics d/b/a Minnkota
    90-C1-15   # Sony Mobile Communications AB
    90-C3-5F   # Nanjing Jiahao Technology Co., Ltd.
    90-C6-82   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    90-C7-92   # ARRIS Group, Inc.
    90-C9-9B   # Recore Systems
    90-CC-24   # Synaptics, Inc
    90-CD-B6   # Hon Hai Precision Ind. Co.,Ltd.
    90-CF-15   # Nokia Corporation
    90-CF-6F   # Dlogixs Co Ltd
    90-CF-7D   # Qingdao Hisense Electric Co.,Ltd.
    90-D1-1B   # Palomar Medical Technologies
    90-D7-4F   # Bookeen
    90-D7-EB   # Texas Instruments
    90-D8-52   # Comtec Co., Ltd.
    90-D8-F3   # zte corporation
    90-D9-2C   # HUG-WITSCHI AG
    90-DA-4E   # AVANU
    90-DA-6A   # FOCUS H&S Co., Ltd.
    90-DB-46   # E-LEAD ELECTRONIC CO., LTD
    90-DF-B7   # s.m.s smart microwave sensors GmbH
    90-DF-FB   # HOMERIDER SYSTEMS
    90-E0-F0   # IEEE 1722a Working Group
    90-E2-BA   # Intel Corporate
    90-E6-BA   # ASUSTek COMPUTER INC.
    90-E7-C4   # HTC Corporation
    90-EA-60   # SPI Lasers Ltd
    90-EF-68   # ZyXEL Communications Corporation
    90-F1-AA   # Samsung Electronics Co.,Ltd
    90-F1-B0   # Hangzhou Anheng Info&Tech CO.,LTD
    90-F2-78   # Radius Gateway
    90-F3-B7   # Kirisun Communications Co., Ltd.
    90-F4-C1   # Rand McNally
    90-F6-52   # TP-LINK TECHNOLOGIES CO.,LTD.
    90-F7-2F   # Phillips Machine & Welding Co., Inc.
    90-FB-5B   # Avaya Inc
    90-FB-A6   # Hon Hai Precision Ind. Co.,Ltd.
    90-FD-61   # Apple, Inc.
    90-FF-79   # Metro Ethernet Forum
    94-00-70   # Nokia Corporation
    94-01-49   # AutoHotBox
    94-01-C2   # Samsung Electronics Co.,Ltd
    94-04-9C   # HUAWEI TECHNOLOGIES CO.,LTD
    94-05-B6   # Liling FullRiver Electronics & Technology Ltd
    94-09-37   # HUMAX Co., Ltd.
    94-0B-2D   # NetView Technologies(Shenzhen) Co., Ltd
    94-0B-D5   # Himax Technologies, Inc
    94-0C-6D   # TP-LINK TECHNOLOGIES CO.,LTD.
    94-10-3E   # Belkin International Inc.
    94-11-DA   # ITF Fröschl GmbH
    94-16-73   # Point Core SARL
    94-1D-1C   # TLab West Systems AB
    94-20-53   # Nokia Corporation
    94-21-97   # Stalmart Technology Limited
    94-23-6E   # Shenzhen Junlan Electronic Ltd
    94-2C-B3   # HUMAX Co., Ltd.
    94-2E-17   # Schneider Electric Canada Inc
    94-2E-63   # Finsécur
    94-31-9B   # Alphatronics BV
    94-33-DD   # Taco Inc
    94-35-0A   # Samsung Electronics Co.,Ltd
    94-36-E0   # Sichuan Bihong Broadcast &amp; Television New Technologies Co.,Ltd
    94-39-E5   # Hon Hai Precision Ind. Co.,Ltd.
    94-3A-F0   # Nokia Corporation
    94-3B-B1   # KAONMEDIA
    94-40-A2   # Anywave Communication Technologies, Inc.
    94-44-44   # LG Innotek
    94-44-52   # Belkin International Inc.
    94-46-96   # BaudTec Corporation
    94-4A-09   # BitWise Controls
    94-4A-0C   # Sercomm Corporation
    94-50-47   # Rechnerbetriebsgruppe
    94-51-03   # Samsung Electronics
    94-51-BF   # Hyundai ESG
    94-53-30   # Hon Hai Precision Ind. Co.,Ltd.
    94-54-93   # Rigado, LLC
    94-57-A5   # Hewlett Packard
    94-59-2D   # EKE Building Technology Systems Ltd
    94-5B-7E   # TRILOBIT LTDA.
    94-61-24   # Pason Systems
    94-62-69   # ARRIS Group, Inc.
    94-63-D1   # Samsung Electronics Co.,Ltd
    94-65-9C   # Intel Corporate
    94-70-D2   # WINFIRM TECHNOLOGY
    94-71-AC   # TCT mobile ltd
    94-75-6E   # QinetiQ North America
    94-76-B7   # Samsung Electronics Co.,Ltd
    94-77-2B   # HUAWEI TECHNOLOGIES CO.,LTD
    94-7C-3E   # Polewall Norge AS
    94-81-A4   # Azuray Technologies
    94-85-7A   # Evantage Industries Corp
    94-86-CD   # SEOUL ELECTRONICS&TELECOM
    94-86-D4   # Surveillance Pro Corporation
    94-87-7C   # ARRIS Group, Inc.
    94-88-15   # Infinique Worldwide Inc
    94-88-54   # Texas Instruments
    94-8B-03   # EAGET Innovation and Technology Co., Ltd.
    94-8D-50   # Beamex Oy Ab
    94-8E-89   # INDUSTRIAS UNIDAS SA DE CV
    94-8F-EE   # Hughes Telematics, Inc.
    94-92-BC   # SYNTECH(HK) TECHNOLOGY LIMITED
    94-94-26   # Apple, Inc.
    94-98-A2   # Shanghai LISTEN TECH.LTD
    94-9B-FD   # Trans New Technology, Inc.
    94-9C-55   # Alta Data Technologies
    94-9F-3E   # Sonos, Inc.
    94-9F-3F   # Optek Digital Technology company limited
    94-9F-B4   # ChengDu JiaFaAnTai Technology Co.,Ltd
    94-A1-A2   # AMPAK Technology, Inc.
    94-A7-B7   # zte corporation
    94-A7-BC   # BodyMedia, Inc.
    94-AA-B8   # Joview(Beijing) Technology Co. Ltd.
    94-AB-DE   # OMX Technology - FZE
    94-AC-CA   # trivum technologies GmbH
    94-AE-61   # Alcatel Lucent
    94-AE-E3   # Belden Hirschmann Industries (Suzhou) Ltd.
    94-B1-0A   # Samsung Electronics Co.,Ltd
    94-B2-CC   # PIONEER CORPORATION
    94-B4-0F   # Aruba Networks
    94-B8-C5   # RuggedCom Inc.
    94-B9-B4   # Aptos Technology
    94-BA-31   # Visiontec da Amazônia Ltda.
    94-BA-56   # Shenzhen Coship Electronics Co., Ltd.
    94-BB-AE   # Husqvarna AB
    94-BF-1E   # eflow Inc. / Smart Device Planning and Development Division
    94-BF-95   # Shenzhen Coship Electronics Co., Ltd
    94-C0-14   # Sorter Sp. j. Konrad Grzeszczyk MichaA, Ziomek
    94-C0-38   # Tallac Networks
    94-C1-50   # 2Wire Inc
    94-C3-E4   # SCA Schucker Gmbh & Co KG
    94-C4-E9   # PowerLayer Microsystems HongKong Limited
    94-C6-EB   # NOVA electronics, Inc.
    94-C7-AF   # Raylios Technology
    94-C9-60   # Zhongshan B&T technology.co.,ltd
    94-C9-62   # Teseq AG
    94-CA-0F   # Honeywell Analytics
    94-CC-B9   # ARRIS Group, Inc.
    94-CD-AC   # Creowave Oy
    94-CE-2C   # Sony Mobile Communications AB
    94-CE-31   # CTS Limited
    94-D0-19   # Cydle Corp.
    94-D4-17   # GPI KOREA INC.
    94-D6-0E   # shenzhen yunmao information technologies co., ltd
    94-D7-23   # Shanghai DareGlobal Technologies Co., Ltd
    94-D7-71   # Samsung Electronics Co.,Ltd
    94-D8-59   # TCT mobile ltd
    94-D9-3C   # ENELPS
    94-DB-49   # SITCORP
    94-DB-C9   # AzureWave Technology Inc.
    94-DD-3F   # A+V Link Technologies, Corp.
    94-DE-0E   # SmartOptics AS
    94-DE-80   # GIGA-BYTE TECHNOLOGY CO.,LTD.
    94-DF-4E   # Wistron InfoComm(Kunshan)Co.,Ltd.
    94-DF-58   # IJ Electron CO.,Ltd.
    94-E0-D0   # HealthStream Taiwan Inc.
    94-E2-26   # D. ORtiz Consulting, LLC
    94-E2-FD   # Boge Kompressoren OTTO Boge GmbH & Co. KG
    94-E7-11   # Xirka Dama Persada PT
    94-E8-48   # FYLDE MICRO LTD
    94-E9-6A   # Apple, Inc.
    94-E9-8C   # Alcatel-Lucent
    94-EB-2C   # Google, Inc.
    94-EB-CD   # BlackBerry RTS
    94-F1-9E   # HUIZHOU MAORONG INTELLIGENT TECHNOLOGY CO.,LTD
    94-F2-78   # Elma Electronic
    94-F6-65   # Ruckus Wireless
    94-F6-92   # Geminico co.,Ltd.
    94-F6-A3   # Apple, Inc.
    94-F7-20   # Tianjin Deviser Electronics Instrument Co., Ltd
    94-FA-E8   # Shenzhen Eycom Technology Co., Ltd
    94-FB-B2   # Shenzhen Gongjin Electronics Co.,Ltd
    94-FD-1D   # WhereWhen Corp
    94-FD-2E   # Shanghai Uniscope Technologies Co.,Ltd
    94-FE-F4   # Sagemcom Broadband SAS
    98-02-84   # Theobroma Systems GmbH
    98-02-D8   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    98-03-A0   # ABB n.v. Power Quality Products
    98-03-D8   # Apple, Inc.
    98-0C-82   # Samsung Electro Mechanics
    98-0D-2E   # HTC Corporation
    98-0E-E4   # Private
    98-10-94   # Shenzhen Vsun communication technology Co.,ltd
    98-16-EC   # IC Intracom
    98-1D-FA   # Samsung Electronics Co.,Ltd
    98-20-8E   # Definium Technologies
    98-26-2A   # Applied Research Associates, Inc
    98-29-1D   # Jaguar de Mexico, SA de CV
    98-29-3F   # Fujian Start Computer Equipment Co.,Ltd
    98-2C-BE   # 2Wire Inc
    98-2D-56   # Resolution Audio
    98-2F-3C   # Sichuan Changhong Electric Ltd.
    98-30-00   # Beijing KEMACOM Technologies Co., Ltd.
    98-30-71   # DAIKYUNG VASCOM
    98-34-9D   # Krauss Maffei Technologies GmbH
    98-35-71   # Sub10 Systems Ltd
    98-35-B8   # Assembled Products Corporation
    98-37-13   # PT.Navicom Indonesia
    98-3B-16   # AMPAK Technology, Inc.
    98-3F-9F   # China SSJ (Suzhou) Network Technology Inc.
    98-42-46   # SOL INDUSTRY PTE., LTD
    98-43-DA   # INTERTECH
    98-47-3C   # SHANGHAI SUNMON COMMUNICATION TECHNOGY CO.,LTD
    98-4A-47   # CHG Hospital Beds
    98-4B-4A   # ARRIS Group, Inc.
    98-4B-E1   # Hewlett Packard
    98-4C-04   # Zhangzhou Keneng Electrical Equipment Co Ltd
    98-4C-D3   # Mantis Deposition
    98-4E-97   # Starlight Marketing (H. K.) Ltd.
    98-4F-EE   # Intel Corporate
    98-52-B1   # Samsung Electronics
    98-57-D3   # HON HAI-CCPBG  PRECISION IND.CO.,LTD.
    98-58-8A   # SYSGRATION Ltd.
    98-59-45   # Texas Instruments
    98-5A-EB   # Apple, Inc.
    98-5C-93   # SBG Systems SAS
    98-5D-46   # PeopleNet Communication
    98-5E-1B   # ConversDigital Co., Ltd.
    98-5F-D3   # Microsoft Corporation
    98-60-22   # EMW Co., Ltd.
    98-66-EA   # Industrial Control Communications, Inc.
    98-6B-3D   # ARRIS Group, Inc.
    98-6C-F5   # zte corporation
    98-6D-C8   # TOSHIBA MITSUBISHI-ELECTRIC INDUSTRIAL SYSTEMS CORPORATION
    98-70-E8   # INNATECH SDN BHD
    98-73-C4   # Sage Electronic Engineering LLC
    98-74-3D   # Shenzhen Jun Kai Hengye Technology Co. Ltd
    98-76-B6   # Adafruit
    98-77-70   # Pep Digital Technology (Guangzhou) Co., Ltd
    98-7B-F3   # Texas Instruments
    98-7E-46   # Emizon Networks Limited
    98-82-17   # Disruptive Ltd
    98-83-89   # Samsung Electronics Co.,Ltd
    98-86-B1   # Flyaudio corporation (China)
    98-87-44   # Wuxi Hongda Science and Technology Co.,LTD
    98-89-ED   # Anadem Information Inc.
    98-8B-5D   # Sagemcom Broadband SAS
    98-8B-AD   # Corintech Ltd.
    98-8E-34   # ZHEJIANG BOXSAM ELECTRONIC CO.,LTD
    98-8E-4A   # NOXUS(BEIJING) TECHNOLOGY CO.,LTD
    98-8E-DD   # TE Connectivity Limerick
    98-90-80   # Linkpower Network System Inc Ltd.
    98-90-96   # Dell Inc.
    98-93-CC   # LG Electronics Inc.
    98-94-49   # Skyworth Wireless Technology Ltd.
    98-97-D1   # MitraStar Technology Corp.
    98-A7-B0   # MCST ZAO
    98-AA-D7   # BLUE WAVE NETWORKING CO LTD
    98-B0-39   # Alcatel-Lucent
    98-B8-E3   # Apple, Inc.
    98-BC-57   # SVA TECHNOLOGIES CO.LTD
    98-BC-99   # Edeltech Co.,Ltd.
    98-BE-94   # IBM
    98-C0-EB   # Global Regency Ltd
    98-C8-45   # PacketAccess
    98-CB-27   # Galore Networks Pvt. Ltd.
    98-CD-B4   # Virident Systems, Inc.
    98-D3-31   # Shenzhen Bolutek Technology Co.,Ltd.
    98-D6-86   # Chyi Lee industry Co., ltd.
    98-D6-BB   # Apple, Inc.
    98-D6-F7   # LG Electronics
    98-D8-8C   # Nortel Networks
    98-DA-92   # Vuzix Corporation
    98-DC-D9   # UNITEC Co., Ltd.
    98-E0-D9   # Apple, Inc.
    98-E1-65   # Accutome
    98-E7-9A   # Foxconn(NanJing) Communication Co.,Ltd.
    98-E8-48   # Axiim
    98-EC-65   # Cosesy ApS
    98-EE-CB   # Wistron InfoComm(ZhongShan)Corporation
    98-F0-AB   # Apple, Inc.
    98-F1-70   # Murata Manufacturing Co., Ltd.
    98-F4-28   # zte corporation
    98-F5-37   # zte corporation
    98-F5-A9   # OHSUNG ELECTRONICS CO.,LTD.
    98-F8-C1   # IDT Technology Limited
    98-F8-DB   # Marini Impianti Industriali s.r.l.
    98-FA-E3   # Xiaomi Communications Co Ltd
    98-FB-12   # Grand Electronics (HK) Ltd
    98-FC-11   # Cisco-Linksys, LLC
    98-FE-03   # Ericsson - North America
    98-FE-94   # Apple, Inc.
    98-FF-6A   # OTEC(Shanghai)Technology Co.,Ltd.
    98-FF-D0   # Lenovo Mobile Communication Technology Ltd.
    9C-01-11   # Shenzhen Newabel Electronic Co., Ltd.
    9C-02-98   # Samsung Electronics Co.,Ltd
    9C-03-9E   # Beijing Winchannel Software Technology Co., Ltd
    9C-04-73   # Tecmobile (International) Ltd.
    9C-04-EB   # Apple, Inc.
    9C-06-6E   # Hytera Communications Corporation Limited
    9C-0D-AC   # Tymphany HK Limited
    9C-0E-4A   # Shenzhen Vastking Electronic Co.,Ltd.
    9C-14-65   # Edata Elektronik San. ve Tic. A.Ş.
    9C-18-74   # Nokia Danmark A/S
    9C-1C-12   # Aruba Networks
    9C-1F-DD   # Accupix Inc.
    9C-20-7B   # Apple, Inc.
    9C-21-6A   # TP-LINK TECHNOLOGIES CO.,LTD.
    9C-22-0E   # TASCAN Service GmbH
    9C-28-40   # Discovery Technology,LTD..
    9C-28-BF   # Continental Automotive Czech Republic s.r.o.
    9C-28-EF   # HUAWEI TECHNOLOGIES CO.,LTD
    9C-29-3F   # Apple, Inc.
    9C-2A-70   # Hon Hai Precision Ind. Co.,Ltd.
    9C-2A-83   # Samsung Electronics Co.,Ltd
    9C-30-66   # RWE Effizienz GmbH
    9C-31-78   # Foshan Huadian Intelligent Communications Teachnologies Co.,Ltd
    9C-31-B6   # Kulite Semiconductor Products Inc
    9C-34-26   # ARRIS Group, Inc.
    9C-35-83   # Nipro Diagnostics, Inc
    9C-35-EB   # Apple, Inc.
    9C-37-F4   # HUAWEI TECHNOLOGIES CO.,LTD
    9C-3A-AF   # Samsung Electronics Co.,Ltd
    9C-3E-AA   # EnvyLogic Co.,Ltd.
    9C-41-7C   # Hame  Technology Co.,  Limited
    9C-44-3D   # CHENGDU XUGUANG TECHNOLOGY CO, LTD
    9C-44-A6   # SwiftTest, Inc.
    9C-45-63   # DIMEP Sistemas
    9C-4A-7B   # Nokia Corporation
    9C-4C-AE   # Mesa Labs
    9C-4E-20   # Cisco Systems, Inc
    9C-4E-36   # Intel Corporate
    9C-4E-8E   # ALT Systems Ltd
    9C-4E-BF   # BoxCast
    9C-4F-DA   # Apple, Inc.
    9C-53-CD   # ENGICAM s.r.l.
    9C-54-1C   # Shenzhen My-power Technology Co.,Ltd
    9C-54-CA   # Zhengzhou VCOM Science and Technology Co.,Ltd
    9C-55-B4   # I.S.E. S.r.l.
    9C-57-11   # Feitian Xunda(Beijing) Aeronautical Information Technology Co., Ltd.
    9C-57-AD   # Cisco Systems, Inc
    9C-5B-96   # NMR Corporation
    9C-5C-8D   # FIREMAX INDÚSTRIA E COMÉRCIO DE PRODUTOS ELETRÔNICOS  LTDA
    9C-5C-8E   # ASUSTek COMPUTER INC.
    9C-5C-F9   # Sony Mobile Communications AB
    9C-5D-12   # Aerohive Networks Inc.
    9C-5D-95   # VTC Electronics Corp.
    9C-5E-73   # Calibre UK LTD
    9C-61-1D   # Omni-ID USA, Inc.
    9C-64-5E   # Harman Consumer Group
    9C-65-B0   # Samsung Electronics Co.,Ltd
    9C-65-F9   # AcSiP Technology Corp.
    9C-66-50   # Glodio Technolies Co.,Ltd Tianjin Branch
    9C-68-5B   # Octonion SA
    9C-6A-BE   # QEES ApS.
    9C-6C-15   # Microsoft Corporation
    9C-75-14   # Wildix srl
    9C-77-AA   # NADASNV
    9C-79-AC   # Suntec Software(Shanghai) Co., Ltd.
    9C-7A-03   # Ciena Corporation
    9C-7B-D2   # NEOLAB Convergence
    9C-80-7D   # SYSCABLE Korea Inc.
    9C-80-DF   # Arcadyan Technology Corporation
    9C-86-DA   # Phoenix Geophysics Ltd.
    9C-88-88   # Simac Techniek NV
    9C-88-AD   # Fiberhome Telecommunication Technologies Co.,LTD
    9C-8B-F1   # The Warehouse Limited
    9C-8D-1A   # INTEG process group inc
    9C-8D-D3   # Leonton Technologies
    9C-8E-99   # Hewlett Packard
    9C-8E-DC   # Teracom Limited
    9C-93-4E   # Xerox Corporation
    9C-93-E4   # Private
    9C-95-F8   # SmartDoor Systems, LLC
    9C-97-26   # Technicolor
    9C-98-11   # Guangzhou Sunrise Electronics Development Co., Ltd
    9C-99-A0   # Xiaomi Communications Co Ltd
    9C-9C-1D   # Starkey Labs Inc.
    9C-A1-0A   # SCLE SFE
    9C-A1-34   # Nike, Inc.
    9C-A3-BA   # SAKURA Internet Inc.
    9C-A5-77   # Osorno Enterprises Inc.
    9C-A6-9D   # Whaley Technology Co.Ltd
    9C-A9-E4   # zte corporation
    9C-AD-97   # Hon Hai Precision Ind. Co.,Ltd.
    9C-AD-EF   # Obihai Technology, Inc.
    9C-AE-D3   # Seiko Epson Corporation
    9C-AF-CA   # Cisco Systems, Inc
    9C-B0-08   # Ubiquitous Computing Technology Corporation
    9C-B2-06   # PROCENTEC
    9C-B6-54   # Hewlett Packard
    9C-B6-D0   # Rivet Networks
    9C-B7-0D   # Liteon Technology Corporation
    9C-B7-93   # Creatcomm Technology Inc.
    9C-BB-98   # Shen Zhen RND Electronic Co.,LTD
    9C-BD-9D   # SkyDisk, Inc.
    9C-BE-E0   # Biosoundlab Co., Ltd.
    9C-C0-77   # PrintCounts, LLC
    9C-C0-D2   # Conductix-Wampfler GmbH
    9C-C1-72   # HUAWEI TECHNOLOGIES CO.,LTD
    9C-C7-A6   # AVM GmbH
    9C-C7-D1   # SHARP Corporation
    9C-CA-D9   # Nokia Corporation
    9C-CD-82   # CHENG UEI PRECISION INDUSTRY CO.,LTD
    9C-D2-1E   # Hon Hai Precision Ind. Co.,Ltd.
    9C-D2-4B   # zte corporation
    9C-D3-5B   # Samsung Electronics Co.,Ltd
    9C-D3-6D   # NETGEAR
    9C-D6-43   # D-Link International
    9C-D9-17   # Motorola Mobility LLC, a Lenovo Company
    9C-DF-03   # Harman/Becker Automotive Systems GmbH
    9C-DF-B1   # Shenzhen Crave Communication Co., LTD
    9C-E1-0E   # NCTech Ltd
    9C-E1-D6   # Junger Audio-Studiotechnik GmbH
    9C-E2-30   # JULONG CO,.LTD.
    9C-E6-35   # Nintendo Co., Ltd.
    9C-E6-E7   # Samsung Electronics Co.,Ltd
    9C-E7-BD   # Winduskorea co., Ltd
    9C-EB-E8   # BizLink (Kunshan) Co.,Ltd
    9C-EF-D5   # Panda Wireless, Inc.
    9C-F3-87   # Apple, Inc.
    9C-F6-1A   # UTC Fire and Security
    9C-F6-7D   # Ricardo Prague, s.r.o.
    9C-F8-DB   # shenzhen eyunmei technology co,.ltd
    9C-F9-38   # AREVA NP GmbH
    9C-FB-F1   # MESOMATIC GmbH & Co.KG
    9C-FC-01   # Apple, Inc.
    9C-FF-BE   # OTSL Inc.
    A0-02-DC   # Amazon Technologies Inc.
    A0-03-63   # Robert Bosch Healthcare GmbH
    A0-06-27   # NEXPA System
    A0-07-98   # Samsung Electronics
    A0-07-B6   # Advanced Technical Support, Inc.
    A0-0A-BF   # Wieson Technologies Co., Ltd.
    A0-0B-BA   # SAMSUNG ELECTRO-MECHANICS
    A0-0C-A1   # SKTB SKiT
    A0-12-90   # Avaya Inc
    A0-12-DB   # TABUCHI ELECTRIC CO.,LTD
    A0-13-3B   # HiTi Digital, Inc.
    A0-13-CB   # Fiberhome Telecommunication Technologies Co.,LTD
    A0-14-3D   # PARROT SA
    A0-16-5C   # Triteka LTD
    A0-18-28   # Apple, Inc.
    A0-18-59   # Shenzhen Yidashi Electronics Co Ltd
    A0-19-17   # Bertel S.p.a.
    A0-1B-29   # Sagemcom Broadband SAS
    A0-1C-05   # NIMAX TELECOM CO.,LTD.
    A0-1D-48   # Hewlett Packard
    A0-1E-0B   # MINIX Technology Limited
    A0-21-95   # Samsung Electronics Digital Imaging
    A0-21-B7   # NETGEAR
    A0-23-1B   # TeleComp R&D Corp.
    A0-2B-B8   # Hewlett Packard
    A0-2E-F3   # United Integrated Services Co., Led.
    A0-32-99   # Lenovo (Beijing) Co., Ltd.
    A0-36-9F   # Intel Corporate
    A0-36-F0   # Comprehensive Power
    A0-36-FA   # Ettus Research LLC
    A0-39-F7   # LG Electronics (Mobile Communications)
    A0-3A-75   # PSS Belgium N.V.
    A0-3B-1B   # Inspire Tech
    A0-3E-6B   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    A0-40-25   # Actioncable, Inc.
    A0-40-41   # SAMWONFA Co.,Ltd.
    A0-41-A7   # NL Ministry of Defense
    A0-42-3F   # Tyan Computer Corp
    A0-48-1C   # Hewlett Packard
    A0-4C-C1   # Helixtech Corp.
    A0-4E-04   # Nokia Corporation
    A0-4F-D4   # ADB Broadband Italia
    A0-51-C6   # Avaya Inc
    A0-55-4F   # Cisco Systems, Inc
    A0-55-DE   # Pace plc
    A0-56-B2   # Harman/Becker Automotive Systems GmbH
    A0-59-3A   # V.D.S. Video Display Systems srl
    A0-5A-A4   # Grand Products Nevada, Inc.
    A0-5B-21   # ENVINET GmbH
    A0-5D-C1   # TMCT Co., LTD.
    A0-5D-E7   # DIRECTV, Inc.
    A0-5E-6B   # MELPER Co., Ltd.
    A0-63-91   # NETGEAR
    A0-65-18   # VNPT TECHNOLOGY
    A0-67-BE   # Sicon s.r.l.
    A0-69-86   # Wellav Technologies Ltd
    A0-6A-00   # Verilink Corporation
    A0-6C-EC   # RIM
    A0-6D-09   # Intelcan Technosystems Inc.
    A0-6E-50   # Nanotek Elektronik Sistemler Ltd. Sti.
    A0-71-A9   # Nokia Corporation
    A0-73-32   # Cashmaster International Limited
    A0-73-FC   # Rancore Technologies Private Limited
    A0-75-91   # Samsung Electronics Co.,Ltd
    A0-77-71   # Vialis BV
    A0-78-BA   # Pantech Co., Ltd.
    A0-82-1F   # Samsung Electronics Co.,Ltd
    A0-82-C7   # P.T.I Co.,LTD
    A0-86-1D   # Chengdu Fuhuaxin Technology co.,Ltd
    A0-86-C6   # Xiaomi Communications Co Ltd
    A0-86-EC   # SAEHAN HITEC Co., Ltd
    A0-88-69   # Intel Corporate
    A0-88-B4   # Intel Corporate
    A0-89-E4   # Skyworth Digital Technology(Shenzhen) Co.,Ltd
    A0-8A-87   # HuiZhou KaiYue Electronic Co.,Ltd
    A0-8C-15   # Gerhard D. Wempe KG
    A0-8C-9B   # Xtreme Technologies Corp
    A0-8D-16   # HUAWEI TECHNOLOGIES CO.,LTD
    A0-90-DE   # VEEDIMS,LLC
    A0-91-69   # LG Electronics
    A0-93-47   # GUANGDONG OPPO MOBILE TELECOMMUNICATIONS CORP.,LTD
    A0-98-05   # OpenVox Communication Co Ltd
    A0-98-ED   # Shandong Intelligent Optical Communication Development Co., Ltd.
    A0-99-9B   # Apple, Inc.
    A0-9A-5A   # Time Domain
    A0-9B-BD   # Total Aviation Solutions Pty Ltd
    A0-A1-30   # DLI Taiwan Branch office
    A0-A2-3C   # GPMS
    A0-A3-E2   # Actiontec Electronics, Inc
    A0-A6-5C   # Supercomputing Systems AG
    A0-A7-63   # Polytron Vertrieb GmbH
    A0-A8-CD   # Intel Corporate
    A0-AA-FD   # EraThink Technologies Corp.
    A0-AD-A1   # JMR Electronics, Inc
    A0-B1-00   # ShenZhen Cando Electronics Co.,Ltd
    A0-B3-CC   # Hewlett Packard
    A0-B4-37   # GENERAL DYNAMICS C4 SYSEMS
    A0-B4-A5   # Samsung Electronics Co.,Ltd
    A0-B5-DA   # HongKong THTF Co., Ltd
    A0-B6-62   # Acutvista Innovation Co., Ltd.
    A0-B9-ED   # Skytap
    A0-BA-B8   # Pixon Imaging
    A0-BB-3E   # IEEE Registration Authority
    A0-BF-50   # S.C. ADD-PRODUCTION S.R.L.
    A0-BF-A5   # CORESYS
    A0-C2-DE   # Costar Video Systems
    A0-C3-DE   # Triton Electronic Systems Ltd.
    A0-C5-62   # Pace plc
    A0-C5-89   # Intel Corporate
    A0-C6-EC   # ShenZhen ANYK Technology Co.,LTD
    A0-CB-FD   # Samsung Electronics Co.,Ltd
    A0-CE-C8   # CE LINK LIMITED
    A0-CF-5B   # Cisco Systems, Inc
    A0-D1-2A   # AXPRO Technology Inc.
    A0-D3-7A   # Intel Corporate
    A0-D3-C1   # Hewlett Packard
    A0-DA-92   # Nanjing Glarun Atten Technology Co. Ltd.
    A0-DC-04   # Becker-Antriebe GmbH
    A0-DD-97   # PolarLink Technologies, Ltd
    A0-DD-E5   # SHARP Corporation
    A0-DE-05   # JSC Irbis-T
    A0-E2-01   # AVTrace Ltd.(China)
    A0-E2-5A   # Amicus SK, s.r.o.
    A0-E2-95   # DAT System Co.,Ltd
    A0-E4-53   # Sony Mobile Communications AB
    A0-E4-CB   # ZyXEL Communications Corporation
    A0-E5-34   # Stratec Biomedical AG
    A0-E5-E9   # enimai Inc
    A0-E6-F8   # Texas Instruments
    A0-E9-DB   # Ningbo FreeWings Technologies Co.,Ltd
    A0-EB-76   # AirCUVE Inc.
    A0-EC-80   # zte corporation
    A0-EC-F9   # Cisco Systems, Inc
    A0-ED-CD   # Apple, Inc.
    A0-EF-84   # Seine Image Int'l Co., Ltd
    A0-F2-17   # GE Medical System(China) Co., Ltd.
    A0-F3-C1   # TP-LINK TECHNOLOGIES CO.,LTD.
    A0-F3-E4   # Alcatel Lucent IPD
    A0-F4-19   # Nokia Corporation
    A0-F4-50   # HTC Corporation
    A0-F4-59   # FN-LINK TECHNOLOGY LIMITED
    A0-F6-FD   # Texas Instruments
    A0-F8-49   # Cisco Systems, Inc
    A0-F8-95   # Shenzhen TINNO Mobile Technology Corp.
    A0-F9-E0   # VIVATEL COMPANY LIMITED
    A0-FC-6E   # Telegrafia a.s.
    A0-FE-91   # AVAT Automation GmbH
    A4-01-30   # ABIsystems Co., LTD
    A4-02-B9   # Intel Corporate
    A4-05-9E   # STA Infinity LLP
    A4-08-EA   # Murata Manufacturing Co., Ltd.
    A4-09-CB   # Alfred Kaercher GmbH &amp; Co KG
    A4-0B-ED   # Carry Technology Co.,Ltd
    A4-0C-C3   # Cisco Systems, Inc
    A4-12-42   # NEC Platforms, Ltd.
    A4-13-4E   # Luxul
    A4-15-66   # Wei Fang Goertek Electronics Co.,Ltd
    A4-15-88   # ARRIS Group, Inc.
    A4-17-31   # Hon Hai Precision Ind. Co.,Ltd.
    A4-18-75   # Cisco Systems, Inc
    A4-1B-C0   # Fastec Imaging Corporation
    A4-1F-72   # Dell Inc.
    A4-21-8A   # Nortel Networks
    A4-23-05   # Open Networking Laboratory
    A4-24-B3   # FlatFrog Laboratories AB
    A4-24-DD   # Cambrionix Ltd
    A4-25-1B   # Avaya Inc
    A4-29-40   # Shenzhen YOUHUA Technology Co., Ltd
    A4-29-B7   # bluesky
    A4-2B-8C   # NETGEAR
    A4-2B-B0   # TP-LINK TECHNOLOGIES CO.,LTD.
    A4-2C-08   # Masterwork Automodules
    A4-31-11   # ZIV
    A4-31-35   # Apple, Inc.
    A4-33-D1   # Fibrlink Communications Co.,Ltd.
    A4-34-D9   # Intel Corporate
    A4-38-31   # RF elements s.r.o.
    A4-38-FC   # Plastic Logic
    A4-3A-69   # Vers Inc
    A4-3B-FA   # IEEE Registration Authority
    A4-3D-78   # GUANGDONG OPPO MOBILE TELECOMMUNICATIONS CORP.,LTD
    A4-44-D1   # Wingtech Group (HongKong）Limited
    A4-46-6B   # EOC Technology
    A4-46-FA   # AmTRAN Video Corporation
    A4-4A-D3   # ST Electronics(Shanghai) Co.,Ltd
    A4-4B-15   # Sun Cupid Technology (HK) LTD
    A4-4C-11   # Cisco Systems, Inc
    A4-4E-2D   # Adaptive Wireless Solutions, LLC
    A4-4E-31   # Intel Corporate
    A4-4F-29   # IEEE Registration Authority
    A4-50-55   # busware.de
    A4-51-6F   # Microsoft Mobile Oy
    A4-52-6F   # ADB Broadband Italia
    A4-56-02   # fenglian Technology Co.,Ltd.
    A4-56-1B   # MCOT Corporation
    A4-56-30   # Cisco Systems, Inc
    A4-5A-1C   # smart-electronic GmbH
    A4-5C-27   # Nintendo Co., Ltd.
    A4-5D-36   # Hewlett Packard
    A4-5D-A1   # ADB Broadband Italia
    A4-5E-60   # Apple, Inc.
    A4-60-32   # MRV Communications (Networks) LTD
    A4-67-06   # Apple, Inc.
    A4-68-BC   # Private
    A4-6C-2A   # Cisco Systems, Inc
    A4-6C-C1   # LTi REEnergy GmbH
    A4-6E-79   # DFT System Co.Ltd
    A4-70-D6   # Motorola Mobility LLC, a Lenovo Company
    A4-77-33   # Google, Inc.
    A4-77-60   # Nokia Corporation
    A4-79-E4   # KLINFO Corp
    A4-7A-A4   # ARRIS Group, Inc.
    A4-7A-CF   # VIBICOM COMMUNICATIONS INC.
    A4-7B-2C   # Alcatel-Lucent
    A4-7B-85   # ULTIMEDIA Co Ltd,
    A4-7C-14   # ChargeStorm AB
    A4-7C-1F   # Cobham plc
    A4-7E-39   # zte corporation
    A4-81-EE   # Nokia Corporation
    A4-84-31   # Samsung Electronics Co.,Ltd
    A4-85-6B   # Q Electronics Ltd
    A4-89-5B   # ARK INFOSOLUTIONS PVT LTD
    A4-8C-DB   # Lenovo
    A4-8D-3B   # Vizio, Inc
    A4-8E-0A   # DeLaval International AB
    A4-90-05   # CHINA GREATWALL COMPUTER SHENZHEN CO.,LTD
    A4-93-4C   # Cisco Systems, Inc
    A4-97-BB   # Hitachi Industrial Equipment Systems Co.,Ltd
    A4-99-47   # HUAWEI TECHNOLOGIES CO.,LTD
    A4-99-81   # FuJian Elite Power Tech CO.,LTD.
    A4-9A-58   # Samsung Electronics Co.,Ltd
    A4-9B-13   # Burroughs Payment Systems, Inc.
    A4-9D-49   # Ketra, Inc.
    A4-9E-DB   # AutoCrib, Inc.
    A4-9F-85   # Lyve Minds, Inc
    A4-9F-89   # Shanghai Rui Rui Communication Technology Co.Ltd.
    A4-A1-C2   # Ericsson AB
    A4-A1-E4   # Innotube, Inc.
    A4-A2-4A   # Cisco SPVTG
    A4-A4-D3   # Bluebank Communication Technology Co.Ltd
    A4-A6-A9   # Private
    A4-A8-0F   # Shenzhen Coship Electronics Co., Ltd.
    A4-AD-00   # Ragsdale Technology
    A4-AD-B8   # Vitec Group, Camera Dynamics Ltd
    A4-AE-9A   # Maestro Wireless Solutions ltd.
    A4-B1-21   # Arantia 2010 S.L.
    A4-B1-97   # Apple, Inc.
    A4-B1-E9   # Technicolor
    A4-B1-EE   # H. ZANDER GmbH & Co. KG
    A4-B2-A7   # Adaxys Solutions AG
    A4-B3-6A   # JSC SDO Chromatec
    A4-B8-05   # Apple, Inc.
    A4-B8-18   # PENTA Gesellschaft für elektronische Industriedatenverarbeitung mbH
    A4-B9-80   # Parking BOXX Inc.
    A4-BA-76   # HUAWEI TECHNOLOGIES CO.,LTD
    A4-BA-DB   # Dell Inc.
    A4-BB-AF   # Lime Instruments
    A4-BE-61   # EutroVision System, Inc.
    A4-C0-C7   # ShenZhen Hitom Communication Technology Co..LTD
    A4-C0-E1   # Nintendo Co., Ltd.
    A4-C1-38   # Telink Semiconductor (Taipei) Co. Ltd.
    A4-C2-AB   # Hangzhou LEAD-IT Information & Technology Co.,Ltd
    A4-C3-61   # Apple, Inc.
    A4-C4-94   # Intel Corporate
    A4-C7-DE   # Cambridge Industries(Group) Co.,Ltd.
    A4-CC-32   # Inficomm Co., Ltd
    A4-D0-94   # Erwin Peters Systemtechnik GmbH
    A4-D1-8C   # Apple, Inc.
    A4-D1-8F   # Shenzhen Skyee Optical Fiber Communication Technology Ltd.
    A4-D1-D1   # ECOtality North America
    A4-D1-D2   # Apple, Inc.
    A4-D3-B5   # GLITEL Stropkov, s.r.o.
    A4-D5-78   # Texas Instruments
    A4-D8-56   # Gimbal, Inc
    A4-DA-3F   # Bionics Corp.
    A4-DB-2E   # Kingspan Environmental Ltd
    A4-DB-30   # Liteon Technology Corporation
    A4-DC-BE   # HUAWEI TECHNOLOGIES CO.,LTD
    A4-DE-50   # Total Walther GmbH
    A4-DE-C9   # QLove Mobile Intelligence Information Technology (W.H.) Co. Ltd.
    A4-E0-E6   # FILIZOLA S.A. PESAGEM E AUTOMACAO
    A4-E3-2E   # Silicon & Software Systems Ltd.
    A4-E3-91   # DENY FONTAINE
    A4-E4-B8   # BlackBerry RTS
    A4-E7-31   # Nokia Corporation
    A4-E7-E4   # Connex GmbH
    A4-E9-91   # SISTEMAS AUDIOVISUALES ITELSIS S.L.
    A4-E9-A3   # Honest Technology Co., Ltd
    A4-EB-D3   # Samsung Electronics Co.,Ltd
    A4-ED-4E   # ARRIS Group, Inc.
    A4-EE-57   # SEIKO EPSON CORPORATION
    A4-EF-52   # Telewave Co., Ltd.
    A4-F1-E8   # Apple, Inc.
    A4-F3-C1   # Open Source Robotics Foundation, Inc.
    A4-F5-22   # CHOFU SEISAKUSHO CO.,LTD
    A4-F7-D0   # LAN Accessories Co., Ltd.
    A4-FB-8D   # Hangzhou Dunchong Technology Co.Ltd
    A4-FC-CE   # Security Expert Ltd.
    A8-01-80   # IMAGO Technologies GmbH
    A8-06-00   # Samsung Electronics Co.,Ltd
    A8-0C-0D   # Cisco Systems, Inc
    A8-11-FC   # ARRIS Group, Inc.
    A8-13-74   # Panasonic Corporation AVC Networks Company
    A8-15-4D   # TP-LINK TECHNOLOGIES CO.,LTD.
    A8-15-D6   # Shenzhen Meione Technology CO., LTD
    A8-16-B2   # LG Electronics
    A8-17-58   # Elektronik System i Umeå AB
    A8-1B-18   # XTS CORP
    A8-1B-5A   # GUANGDONG OPPO MOBILE TELECOMMUNICATIONS CORP.,LTD
    A8-1B-5D   # Foxtel Management Pty Ltd
    A8-1D-16   # AzureWave Technology Inc.
    A8-1F-AF   # KRYPTON POLSKA
    A8-20-66   # Apple, Inc.
    A8-24-EB   # ZAO NPO Introtest
    A8-26-D9   # HTC Corporation
    A8-29-4C   # Precision Optical Transceivers, Inc.
    A8-2B-D6   # Shina System Co., Ltd
    A8-30-AD   # Wei Fang Goertek Electronics Co.,Ltd
    A8-32-9A   # Digicom Futuristic Technologies Ltd.
    A8-39-44   # Actiontec Electronics, Inc
    A8-40-41   # Dragino Technology Co., Limited
    A8-44-81   # Nokia Corporation
    A8-45-CD   # Siselectron Technology LTD.
    A8-45-E9   # Firich Enterprises CO., LTD.
    A8-47-4A   # Hon Hai Precision Ind. Co.,Ltd.
    A8-49-A5   # Lisantech Co., Ltd.
    A8-54-B2   # Wistron Neweb Corp.
    A8-55-6A   # Pocketnet Technology Inc.
    A8-57-4E   # TP-LINK TECHNOLOGIES CO.,LTD.
    A8-58-40   # Cambridge Industries(Group) Co.,Ltd.
    A8-5B-78   # Apple, Inc.
    A8-5B-B0   # Shenzhen Dehoo Technology Co.,Ltd
    A8-5B-F3   # Audivo GmbH
    A8-61-AA   # Cloudview Limited
    A8-62-A2   # JIWUMEDIA CO., LTD.
    A8-63-DF   # DISPLAIRE CORPORATION
    A8-63-F2   # Texas Instruments
    A8-64-05   # nimbus 9, Inc
    A8-65-B2   # DONGGUAN YISHANG ELECTRONIC TECHNOLOGY CO., LIMITED
    A8-66-7F   # Apple, Inc.
    A8-6A-6F   # RIM
    A8-70-A5   # UniComm Inc.
    A8-72-85   # IDT, INC.
    A8-74-1D   # PHOENIX CONTACT Electronics GmbH
    A8-75-D6   # FreeTek International Co., Ltd.
    A8-75-E2   # Aventura Technologies, Inc.
    A8-77-6F   # Zonoff
    A8-7B-39   # Nokia Corporation
    A8-7C-01   # Samsung Electronics Co.,Ltd
    A8-7E-33   # Nokia Danmark A/S
    A8-80-38   # ShenZhen MovingComm Technology Co., Limited
    A8-81-F1   # BMEYE B.V.
    A8-82-7F   # CIBN Oriental Network(Beijing) CO.,Ltd
    A8-86-DD   # Apple, Inc.
    A8-87-92   # Broadband Antenna Tracking Systems
    A8-87-ED   # ARC Wireless LLC
    A8-88-08   # Apple, Inc.
    A8-8C-EE   # MicroMade Galka i Drozdz sp.j.
    A8-8D-7B   # SunDroid Global limited.
    A8-8E-24   # Apple, Inc.
    A8-90-08   # Beijing Yuecheng Technology Co. Ltd.
    A8-92-2C   # LG Electronics
    A8-93-E6   # JIANGXI JINGGANGSHAN CKING COMMUNICATION TECHNOLOGY CO.,LTD
    A8-95-B0   # Aker Subsea Ltd
    A8-96-8A   # Apple, Inc.
    A8-97-DC   # IBM
    A8-98-C6   # Shinbo Co., Ltd.
    A8-99-5C   # aizo ag
    A8-9B-10   # inMotion Ltd.
    A8-9D-21   # Cisco Systems, Inc
    A8-9D-D2   # Shanghai DareGlobal Technologies Co., Ltd
    A8-9F-BA   # Samsung Electronics Co.,Ltd
    A8-A0-89   # Tactical Communications
    A8-A6-68   # zte corporation
    A8-A7-95   # Hon Hai Precision Ind. Co.,Ltd.
    A8-AD-3D   # Alcatel-Lucent Shanghai Bell Co., Ltd
    A8-B0-AE   # LEONI
    A8-B1-D4   # Cisco Systems, Inc
    A8-B9-B3   # ESSYS
    A8-BB-CF   # Apple, Inc.
    A8-BD-1A   # Honey Bee (Hong Kong) Limited
    A8-BD-3A   # UNIONMAN TECHNOLOGY CO.,LTD
    A8-C2-22   # TM-Research Inc.
    A8-C8-7F   # Roqos, Inc.
    A8-CA-7B   # HUAWEI TECHNOLOGIES CO.,LTD
    A8-CB-95   # EAST BEST CO., LTD.
    A8-CC-C5   # Saab AB (publ)
    A8-CE-90   # CVC
    A8-D0-E3   # Systech Electronics Ltd.
    A8-D0-E5   # Juniper Networks
    A8-D2-36   # Lightware Visual Engineering
    A8-D3-C8   # Wachendorff Elektronik  GmbH & Co. KG
    A8-D3-F7   # Arcadyan Technology Corporation
    A8-D4-09   # USA 111 Inc
    A8-D8-28   # Bayer HealthCare
    A8-D8-8A   # Wyconn
    A8-E0-18   # Nokia Corporation
    A8-E3-EE   # Sony Computer Entertainment Inc.
    A8-E5-39   # Moimstone Co.,Ltd
    A8-EF-26   # Tritonwave
    A8-F0-38   # SHEN ZHEN SHI JIN HUA TAI ELECTRONICS CO.,LTD
    A8-F2-74   # Samsung Electronics
    A8-F4-70   # Fujian Newland Communication Science Technologies Co.,Ltd.
    A8-F7-E0   # PLANET Technology Corporation
    A8-F9-4B   # Eltex Enterprise Ltd.
    A8-FA-D8   # Apple, Inc.
    A8-FB-70   # WiseSec L.t.d
    A8-FC-B7   # Consolidated Resource Imaging
    AA-00-00   # DIGITAL EQUIPMENT CORPORATION
    AA-00-01   # DIGITAL EQUIPMENT CORPORATION
    AA-00-02   # DIGITAL EQUIPMENT CORPORATION
    AA-00-03   # DIGITAL EQUIPMENT CORPORATION
    AA-00-04   # DIGITAL EQUIPMENT CORPORATION
    AC-01-42   # Uriel Technologies SIA
    AC-02-CA   # HI Solutions, Inc.
    AC-02-CF   # RW Tecnologia Industria e Comercio Ltda
    AC-02-EF   # Comsis
    AC-06-13   # Senselogix Ltd
    AC-06-C7   # ServerNet S.r.l.
    AC-0A-61   # Labor S.r.L.
    AC-0D-FE   # Ekon GmbH - myGEKKO
    AC-11-D3   # Suzhou HOTEK  Video Technology Co. Ltd
    AC-14-61   # ATAW  Co., Ltd.
    AC-14-D2   # wi-daq, inc.
    AC-16-2D   # Hewlett Packard
    AC-17-02   # Fibar Group sp. z o.o.
    AC-18-26   # SEIKO EPSON CORPORATION
    AC-19-9F   # SUNGROW POWER SUPPLY CO.,LTD.
    AC-1F-D7   # Real Vision Technology Co.,Ltd.
    AC-20-AA   # DMATEK Co., Ltd.
    AC-22-0B   # ASUSTek COMPUTER INC.
    AC-29-3A   # Apple, Inc.
    AC-2A-0C   # CSR ZHUZHOU INSTITUTE CO.,LTD.
    AC-2B-6E   # Intel Corporate
    AC-2D-A3   # TXTR GmbH
    AC-2F-A8   # Humannix Co.,Ltd.
    AC-31-9D   # Shenzhen TG-NET Botone Technology Co.,Ltd.
    AC-34-CB   # Shanhai GBCOM Communication Technology Co. Ltd
    AC-36-13   # Samsung Electronics Co.,Ltd
    AC-38-70   # Lenovo Mobile Communication Technology Ltd.
    AC-3A-7A   # Roku, Inc.
    AC-3C-0B   # Apple, Inc.
    AC-3C-B4   # Nilan A/S
    AC-3D-05   # Instorescreen Aisa
    AC-3D-75   # HANGZHOU ZHIWAY TECHNOLOGIES CO.,LTD.
    AC-3F-A4   # TAIYO YUDEN CO.,LTD
    AC-40-EA   # C&T Solution Inc.
    AC-41-22   # Eclipse Electronic Systems Inc.
    AC-44-F2   # Revolabs Inc
    AC-47-23   # Genelec
    AC-4A-FE   # Hisense Broadband Multimedia Technology Co.,Ltd.
    AC-4B-C8   # Juniper Networks
    AC-4E-91   # HUAWEI TECHNOLOGIES CO.,LTD
    AC-4F-FC   # SVS-VISTEK GmbH
    AC-50-36   # Pi-Coral Inc
    AC-51-35   # MPI TECH
    AC-51-EE   # Cambridge Communication Systems Ltd
    AC-54-EC   # IEEE P1823 Standards Working Group
    AC-56-2C   # LAVA INTERNATIONAL(H.K) LIMITED
    AC-58-3B   # Human Assembler, Inc.
    AC-5A-14   # Samsung Electronics Co.,Ltd
    AC-5D-10   # Pace Americas
    AC-5E-8C   # Utillink
    AC-60-B6   # Ericsson AB
    AC-61-23   # Drivven, Inc.
    AC-61-EA   # Apple, Inc.
    AC-62-0D   # Jabil Circuit (Wuxi) Co. LTD
    AC-64-62   # zte corporation
    AC-67-06   # Ruckus Wireless
    AC-67-6F   # Electrocompaniet A.S.
    AC-6B-AC   # Jenny Science AG
    AC-6E-1A   # Shenzhen Gongjin Electronics Co.,Ltd
    AC-6F-4F   # Enspert Inc
    AC-6F-BB   # TATUNG Technology Inc.
    AC-6F-D9   # Valueplus Inc.
    AC-72-36   # Lexking Technology Co., Ltd.
    AC-72-89   # Intel Corporate
    AC-7A-42   # iConnectivity
    AC-7A-4D   # ALPS ELECTRIC CO.,LTD.
    AC-7B-A1   # Intel Corporate
    AC-7E-8A   # Cisco Systems, Inc
    AC-7F-3E   # Apple, Inc.
    AC-80-D6   # Hexatronic AB
    AC-81-12   # Gemtek Technology Co., Ltd.
    AC-81-F3   # Nokia Corporation
    AC-83-17   # Shenzhen Furtunetel Communication Co., Ltd
    AC-83-F0   # ImmediaTV Corporation
    AC-85-3D   # HUAWEI TECHNOLOGIES CO.,LTD
    AC-86-74   # Open Mesh, Inc.
    AC-86-7E   # Create New Technology (HK) Limited Company
    AC-87-A3   # Apple, Inc.
    AC-89-95   # AzureWave Technology Inc.
    AC-8A-CD   # ROGER D.Wensker, G.Wensker sp.j.
    AC-8D-14   # Smartrove Inc
    AC-93-2F   # Nokia Corporation
    AC-94-03   # Envision Peripherals Inc
    AC-9A-22   # NXP Semiconductors
    AC-9A-96   # Lantiq Deutschland GmbH
    AC-9B-0A   # Sony Computer Entertainment Inc.
    AC-9B-84   # Smak Tecnologia e Automacao
    AC-9C-E4   # Alcatel-Lucent Shanghai Bell Co., Ltd
    AC-9E-17   # ASUSTek COMPUTER INC.
    AC-A0-16   # Cisco Systems, Inc
    AC-A2-13   # Shenzhen Bilian electronic CO.,LTD
    AC-A2-2C   # Baycity Technologies Ltd
    AC-A3-1E   # Aruba Networks
    AC-A4-30   # Peerless AV
    AC-A9-19   # TrekStor GmbH
    AC-A9-A0   # Audioengine, Ltd.
    AC-AB-8D   # Lyngso Marine A/S
    AC-AB-BF   # AthenTek Inc.
    AC-B3-13   # ARRIS Group, Inc.
    AC-B5-7D   # Liteon Technology Corporation
    AC-B7-4F   # METEL s.r.o.
    AC-B8-59   # Uniband Electronic Corp,
    AC-BC-32   # Apple, Inc.
    AC-BD-0B   # IMAC CO.,LTD
    AC-BE-75   # Ufine Technologies Co.,Ltd.
    AC-BE-B6   # Visualedge Technology Co., Ltd.
    AC-C2-EC   # CLT INT'L IND. CORP.
    AC-C5-1B   # Zhuhai Pantum Electronics Co., Ltd.
    AC-C5-95   # Graphite Systems
    AC-C6-98   # Kohzu Precision Co., Ltd.
    AC-C7-3F   # VITSMO CO., LTD.
    AC-C9-35   # Ness Corporation
    AC-CA-54   # Telldus Technologies AB
    AC-CA-8E   # ODA Technologies
    AC-CA-AB   # Virtual Electric Inc
    AC-CA-BA   # Midokura Co., Ltd.
    AC-CB-09   # Hefcom Metering (Pty) Ltd
    AC-CC-8E   # Axis Communications AB
    AC-CE-8F   # HWA YAO TECHNOLOGIES CO., LTD
    AC-CF-23   # Hi-flying electronics technology Co.,Ltd
    AC-CF-5C   # Apple, Inc.
    AC-CF-85   # HUAWEI TECHNOLOGIES CO.,LTD
    AC-D0-74   # Espressif Inc.
    AC-D1-80   # Crexendo Business Solutions, Inc.
    AC-D1-B8   # Hon Hai Precision Ind. Co.,Ltd.
    AC-D3-64   # ABB SPA, ABB SACE DIV.
    AC-D6-57   # Shaanxi Guolian Digital TV Technology Co., Ltd.
    AC-D9-D6   # tci GmbH
    AC-DB-DA   # Shenzhen Geniatech Inc, Ltd
    AC-DE-48   # Private
    AC-E0-10   # Liteon Technology Corporation
    AC-E0-69   # ISAAC Instruments
    AC-E2-15   # HUAWEI TECHNOLOGIES CO.,LTD
    AC-E3-48   # MadgeTech, Inc
    AC-E4-2E   # SK hynix
    AC-E5-F0   # Doppler Labs
    AC-E6-4B   # Shenzhen Baojia Battery Technology Co., Ltd.
    AC-E8-7B   # HUAWEI TECHNOLOGIES CO.,LTD
    AC-E8-7E   # Bytemark Computer Consulting Ltd
    AC-E9-7F   # IoT Tech Limited
    AC-E9-AA   # Hay Systems Ltd
    AC-EA-6A   # GENIX INFOCOMM CO., LTD.
    AC-EC-80   # ARRIS Group, Inc.
    AC-EE-3B   # 6harmonics Inc
    AC-EE-9E   # Samsung Electronics Co.,Ltd
    AC-F0-B2   # Becker Electronics Taiwan Ltd.
    AC-F1-DF   # D-Link International
    AC-F2-C5   # Cisco Systems, Inc
    AC-F7-F3   # Xiaomi Communications Co Ltd
    AC-F9-7E   # ELESYS INC.
    AC-FD-93   # Weifang GoerTek Electronics Co., Ltd.
    AC-FD-CE   # Intel Corporate
    AC-FD-EC   # Apple, Inc.
    B0-00-B4   # Cisco Systems, Inc
    B0-05-94   # Liteon Technology Corporation
    B0-08-BF   # Vital Connect, Inc.
    B0-09-D3   # Avizia
    B0-10-41   # Hon Hai Precision Ind. Co.,Ltd.
    B0-12-03   # Dynamics Hong Kong Limited
    B0-12-66   # Futaba-Kikaku
    B0-14-08   # LIGHTSPEED INTERNATIONAL CO.
    B0-17-43   # EDISON GLOBAL CIRCUITS LLC
    B0-1B-7C   # Ontrol A.S.
    B0-1C-91   # Elim Co
    B0-1F-81   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    B0-24-F3   # Progeny Systems
    B0-25-AA   # Private
    B0-34-95   # Apple, Inc.
    B0-35-8D   # Nokia Corporation
    B0-38-29   # Siliconware Precision Industries Co., Ltd.
    B0-38-50   # Nanjing CAS-ZDC IOT SYSTEM CO.,LTD
    B0-41-1D   # ITTIM Technologies
    B0-43-5D   # NuLEDs, Inc.
    B0-45-15   # mira fitness,LLC.
    B0-45-19   # TCT mobile ltd
    B0-45-45   # YACOUB Automation GmbH
    B0-46-FC   # MitraStar Technology Corp.
    B0-47-BF   # Samsung Electronics Co.,Ltd
    B0-48-7A   # TP-LINK TECHNOLOGIES CO.,LTD.
    B0-49-5F   # OMRON HEALTHCARE Co., Ltd.
    B0-4C-05   # Fresenius Medical Care Deutschland GmbH
    B0-50-BC   # SHENZHEN BASICOM ELECTRONIC CO.,LTD.
    B0-51-8E   # Holl technology CO.Ltd.
    B0-57-06   # Vallox Oy
    B0-58-C4   # Broadcast Microwave Services, Inc
    B0-59-47   # Shenzhen Qihu Intelligent Technology Company Limited
    B0-5A-DA   # Hewlett Packard
    B0-5B-1F   # THERMO FISHER SCIENTIFIC S.P.A.
    B0-5B-67   # HUAWEI TECHNOLOGIES CO.,LTD
    B0-5C-E5   # Nokia Corporation
    B0-61-C7   # Ericsson-LG Enterprise
    B0-65-63   # Shanghai Railway Communication Factory
    B0-65-BD   # Apple, Inc.
    B0-68-B6   # Hangzhou OYE Technology Co. Ltd
    B0-69-71   # DEI Sales, Inc.
    B0-6C-BF   # 3ality Digital Systems GmbH
    B0-75-0C   # QA Cafe
    B0-75-4D   # Alcatel-Lucent
    B0-75-D5   # zte corporation
    B0-77-AC   # ARRIS Group, Inc.
    B0-78-F0   # Beijing HuaqinWorld Technology Co.,Ltd.
    B0-79-08   # Cummings Engineering
    B0-79-3C   # Revolv Inc
    B0-79-94   # Motorola Mobility LLC, a Lenovo Company
    B0-7D-47   # Cisco Systems, Inc
    B0-7D-62   # Dipl.-Ing. H. Horstmann GmbH
    B0-80-8C   # Laser Light Engines
    B0-81-D8   # I-sys Corp
    B0-83-FE   # Dell Inc.
    B0-86-9E   # Chloride S.r.L
    B0-88-07   # Strata Worldwide
    B0-89-91   # LGE
    B0-8E-1A   # URadio Systems Co., Ltd
    B0-90-74   # Fulan Electronics Limited
    B0-91-34   # Taleo
    B0-91-37   # ISis ImageStream Internet Solutions, Inc
    B0-96-6C   # Lanbowan Technology Ltd.
    B0-97-3A   # E-Fuel Corporation
    B0-98-9F   # LG CNS
    B0-99-28   # FUJITSU LIMITED
    B0-9A-E2   # STEMMER IMAGING GmbH
    B0-9B-D4   # GNH Software India Private Limited
    B0-9F-BA   # Apple, Inc.
    B0-A1-0A   # Pivotal Systems Corporation
    B0-A3-7E   # Qingdao Haier Telecom Co.，Ltd
    B0-A7-2A   # Ensemble Designs, Inc.
    B0-A7-37   # Roku, Inc.
    B0-A8-6E   # Juniper Networks
    B0-AA-36   # GUANGDONG OPPO MOBILE TELECOMMUNICATIONS CORP.,LTD
    B0-AA-77   # Cisco Systems, Inc
    B0-AC-FA   # FUJITSU LIMITED
    B0-AD-AA   # Avaya Inc
    B0-B2-DC   # ZyXEL Communications Corporation
    B0-B3-2B   # Slican Sp. z o.o.
    B0-B4-48   # Texas Instruments
    B0-B8-D5   # Nanjing Nengrui Auto Equipment CO.,Ltd
    B0-BD-6D   # Echostreams Innovative Solutions
    B0-BD-A1   # ZAKLAD ELEKTRONICZNY SIMS
    B0-BF-99   # WIZITDONGDO
    B0-C0-90   # Chicony Electronics Co., Ltd.
    B0-C2-87   # Technicolor CH USA
    B0-C4-E7   # Samsung Electronics
    B0-C5-54   # D-Link International
    B0-C5-59   # Samsung Electronics Co.,Ltd
    B0-C5-CA   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    B0-C6-9A   # Juniper Networks
    B0-C7-45   # BUFFALO.INC
    B0-C8-3F   # Jiangsu Cynray IOT Co., Ltd.
    B0-C8-AD   # People Power Company
    B0-C9-5B   # Beijing Symtech CO.,LTD
    B0-CE-18   # Zhejiang shenghui lighting co.,Ltd
    B0-CF-4D   # MI-Zone Technology Ireland
    B0-D0-9C   # Samsung Electronics Co.,Ltd
    B0-D2-F5   # Vello Systems, Inc.
    B0-D5-9D   # Shenzhen Zowee Technology Co., Ltd
    B0-D5-CC   # Texas Instruments
    B0-D7-C5   # Logipix Ltd
    B0-DA-00   # CERA ELECTRONIQUE
    B0-DF-3A   # Samsung Electronics Co.,Ltd
    B0-E0-3C   # TCT mobile ltd
    B0-E2-E5   # Fiberhome Telecommunication Tech.Co.,Ltd.
    B0-E3-9D   # CAT SYSTEM CO.,LTD.
    B0-E5-0E   # NRG SYSTEMS INC
    B0-E7-54   # 2Wire Inc
    B0-E8-92   # SEIKO EPSON CORPORATION
    B0-E9-7E   # Advanced Micro Peripherals
    B0-EC-71   # Samsung Electronics Co.,Ltd
    B0-EC-8F   # GMX SAS
    B0-EC-E1   # Private
    B0-EE-45   # AzureWave Technology Inc.
    B0-F1-A3   # Fengfan (BeiJing) Technology Co., Ltd.
    B0-F1-BC   # Dhemax Ingenieros Ltda
    B0-FA-EB   # Cisco Systems, Inc
    B0-FE-BD   # Private
    B4-00-9C   # CableWorld Ltd.
    B4-01-42   # GCI Science & Technology Co.,LTD
    B4-04-18   # Smartchip Integrated Inc.
    B4-05-66   # SP Best Corporation Co., LTD.
    B4-07-F9   # SAMSUNG ELECTRO-MECHANICS
    B4-08-32   # TC Communications
    B4-0A-C6   # DEXON Systems Ltd.
    B4-0B-44   # Smartisan Technology Co., Ltd.
    B4-0B-7A   # Brusa Elektronik AG
    B4-0C-25   # Palo Alto Networks
    B4-0E-96   # HERAN
    B4-0E-DC   # LG-Ericsson Co.,Ltd.
    B4-14-89   # Cisco Systems, Inc
    B4-15-13   # HUAWEI TECHNOLOGIES CO.,LTD
    B4-17-80   # DTI Group Ltd
    B4-18-D1   # Apple, Inc.
    B4-1D-EF   # Internet Laboratories, Inc.
    B4-21-1D   # Beijing GuangXin Technology Co., Ltd
    B4-21-8A   # Dog Hunter LLC
    B4-24-E7   # Codetek Technology Co.,Ltd
    B4-28-F1   # E-Prime Co., Ltd.
    B4-29-3D   # Shenzhen Urovo Technology Co.,Ltd.
    B4-2A-39   # ORBIT MERRET, spol. s r. o.
    B4-2C-92   # Zhejiang Weirong Electronic Co., Ltd
    B4-2C-BE   # Direct Payment Solutions Limited
    B4-30-52   # HUAWEI TECHNOLOGIES CO.,LTD
    B4-31-B8   # Aviwest
    B4-34-6C   # MATSUNICHI DIGITAL TECHNOLOGY (HONG KONG) LIMITED
    B4-35-64   # Fujian Tian Cheng Electron Science & Technical Development Co.,Ltd.
    B4-35-F7   # Zhejiang Pearmain Electronics Co.ltd.
    B4-36-A9   # Fibocom Wireless Inc.
    B4-37-41   # Consert, Inc.
    B4-37-D1   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    B4-39-34   # Pen Generations, Inc.
    B4-39-D6   # ProCurve Networking by HP
    B4-3A-28   # Samsung Electronics Co.,Ltd
    B4-3D-B2   # Degreane Horizon
    B4-3E-3B   # Viableware, Inc
    B4-41-7A   # ShenZhen Gongjin Electronics Co.,Ltd
    B4-43-0D   # Broadlink Pty Ltd
    B4-47-5E   # Avaya Inc
    B4-4B-D2   # Apple, Inc.
    B4-4C-C2   # NR ELECTRIC CO., LTD
    B4-51-F9   # NB Software
    B4-52-53   # Seagate Technology
    B4-52-7D   # Sony Mobile Communications AB
    B4-52-7E   # Sony Mobile Communications AB
    B4-55-70   # Borea
    B4-58-61   # CRemote, LLC
    B4-5C-A4   # Thing-talk Wireless Communication Technologies Corporation Limited
    B4-61-FF   # Lumigon A/S
    B4-62-38   # Exablox
    B4-62-93   # Samsung Electronics Co.,Ltd
    B4-62-AD   # Elysia Germany GmbH
    B4-66-98   # Zealabs srl
    B4-67-E9   # Qingdao GoerTek Technology Co., Ltd.
    B4-6D-35   # Dalian Seasky Automation Co;Ltd
    B4-6D-83   # Intel Corporate
    B4-73-56   # Hangzhou Treebear Networking Co., Ltd.
    B4-74-43   # Samsung Electronics Co.,Ltd
    B4-74-9F   # ASKEY COMPUTER CORP
    B4-75-0E   # Belkin International Inc.
    B4-79-A7   # Samsung Electro Mechanics co., LTD.
    B4-7C-29   # Shenzhen Guzidi Technology Co.,Ltd
    B4-7F-5E   # Foresight Manufacture (S) Pte Ltd
    B4-82-55   # Research Products Corporation
    B4-82-7B   # AKG Acoustics GmbH
    B4-82-C5   # Relay2, Inc.
    B4-82-FE   # ASKEY COMPUTER CORP
    B4-85-47   # Amptown System Company GmbH
    B4-89-10   # Coster T.E. S.P.A.
    B4-8B-19   # Apple, Inc.
    B4-94-4E   # WeTelecom Co., Ltd.
    B4-98-42   # zte corporation
    B4-99-4C   # Texas Instruments
    B4-99-BA   # Hewlett Packard
    B4-9D-0B   # BQ
    B4-9D-B4   # Axion Technologies Inc.
    B4-9E-AC   # Imagik Int'l Corp
    B4-9E-E6   # SHENZHEN TECHNOLOGY CO LTD
    B4-A4-B5   # Zen Eye Co.,Ltd
    B4-A4-E3   # Cisco Systems, Inc
    B4-A5-A9   # MODI GmbH
    B4-A8-28   # Shenzhen Concox Information Technology Co., Ltd
    B4-A8-2B   # Histar Digital Electronics Co., Ltd.
    B4-A9-5A   # Avaya Inc
    B4-A9-FE   # GHIA Technology (Shenzhen) LTD
    B4-AA-4D   # Ensequence, Inc.
    B4-AB-2C   # MtM Technology Corporation
    B4-AE-2B   # Microsoft
    B4-AE-6F   # Circle Reliance, Inc DBA Cranberry Networks
    B4-B0-17   # Avaya Inc
    B4-B2-65   # DAEHO I&T
    B4-B3-62   # zte corporation
    B4-B5-2F   # Hewlett Packard
    B4-B5-42   # Hubbell Power Systems, Inc.
    B4-B5-AF   # Minsung Electronics
    B4-B6-76   # Intel Corporate
    B4-B8-59   # Texa Spa
    B4-B8-8D   # Thuh Company
    B4-C4-4E   # VXL eTech Pvt Ltd
    B4-C7-99   # Zebra Technologies Inc
    B4-C8-10   # UMPI Elettronica
    B4-CC-E9   # PROSYST
    B4-CE-F6   # HTC Corporation
    B4-CF-DB   # Shenzhen Jiuzhou Electric Co.,LTD
    B4-D8-A9   # BetterBots
    B4-D8-DE   # iota Computing, Inc.
    B4-DD-15   # ControlThings Oy Ab
    B4-DF-3B   # Chromlech
    B4-DF-FA   # Litemax Electronics Inc.
    B4-E0-CD   # Fusion-io, Inc
    B4-E1-0F   # Dell Inc.
    B4-E1-C4   # Microsoft Mobile Oy
    B4-E1-EB   # Private
    B4-E9-B0   # Cisco Systems, Inc
    B4-ED-19   # Pie Digital, Inc.
    B4-ED-54   # Wohler Technologies
    B4-EE-B4   # ASKEY COMPUTER CORP
    B4-EE-D4   # Texas Instruments
    B4-EF-04   # DAIHAN Scientific Co., Ltd.
    B4-EF-39   # Samsung Electronics Co.,Ltd
    B4-F0-AB   # Apple, Inc.
    B4-F2-E8   # Pace plc
    B4-F3-23   # PETATEL INC.
    B4-FC-75   # SEMA Electronics(HK) CO.,LTD
    B4-FE-8C   # Centro Sicurezza Italia SpA
    B8-03-05   # Intel Corporate
    B8-04-15   # Bayan Audio
    B8-08-CF   # Intel Corporate
    B8-09-8A   # Apple, Inc.
    B8-0B-9D   # ROPEX Industrie-Elektronik GmbH
    B8-13-E9   # Trace Live Network
    B8-14-13   # Keen High Holding(HK) Ltd.
    B8-16-19   # ARRIS Group, Inc.
    B8-17-C2   # Apple, Inc.
    B8-18-6F   # ORIENTAL MOTOR CO., LTD.
    B8-19-99   # Nesys
    B8-20-E7   # Guangzhou Horizontal Information & Network Integration Co. Ltd
    B8-24-10   # Magneti Marelli Slovakia s.r.o.
    B8-24-1A   # SWEDA INFORMATICA LTDA
    B8-26-6C   # ANOV France
    B8-26-D4   # Furukawa Industrial S.A. Produtos Elétricos
    B8-27-EB   # Raspberry Pi Foundation
    B8-28-8B   # Parker Hannifin Manufacturing (UK) Ltd
    B8-29-F7   # Blaster Tech
    B8-2A-72   # Dell Inc.
    B8-2A-DC   # EFR Europäische Funk-Rundsteuerung GmbH
    B8-2C-A0   # Honeywell HomMed
    B8-30-A8   # Road-Track Telematics Development
    B8-32-41   # Wuhan Tianyu Information Industry Co., Ltd.
    B8-36-D8   # Videoswitch
    B8-38-61   # Cisco Systems, Inc
    B8-38-CA   # Kyokko Tsushin System CO.,LTD
    B8-3A-7B   # Worldplay (Canada) Inc.
    B8-3A-9D   # FIVE INTERACTIVE, LLC
    B8-3D-4E   # Shenzhen Cultraview Digital Technology Co.,Ltd Shanghai Branch
    B8-3E-59   # Roku, Inc.
    B8-41-5F   # ASP AG
    B8-43-E4   # Vlatacom
    B8-44-D9   # Apple, Inc.
    B8-47-C6   # SanJet Technology Corp.
    B8-4F-D5   # Microsoft Corporation
    B8-55-10   # Zioncom Electronics (Shenzhen) Ltd.
    B8-56-BD   # ITT LLC
    B8-57-D8   # Samsung Electronics Co.,Ltd
    B8-58-10   # NUMERA, INC.
    B8-5A-73   # Samsung Electronics Co.,Ltd
    B8-5A-F7   # Ouya, Inc
    B8-5A-FE   # Handaer Communication Technology (Beijing) Co., Ltd
    B8-5E-7B   # Samsung Electronics Co.,Ltd
    B8-60-91   # Onnet Technologies and Innovations LLC
    B8-61-6F   # Accton Technology Corp
    B8-62-1F   # Cisco Systems, Inc
    B8-63-BC   # ROBOTIS, Co, Ltd
    B8-64-91   # CK Telecom Ltd
    B8-65-3B   # Bolymin, Inc.
    B8-69-C2   # Sunitec Enterprise Co., Ltd.
    B8-6B-23   # Toshiba
    B8-6C-E8   # Samsung Electronics Co.,Ltd
    B8-70-F4   # COMPAL INFORMATION (KUNSHAN) CO., LTD.
    B8-74-24   # Viessmann Elektronik GmbH
    B8-74-47   # Convergence Technologies
    B8-75-C0   # PayPal, Inc.
    B8-76-3F   # Hon Hai Precision Ind. Co.,Ltd.
    B8-77-C3   # Decagon Devices, Inc.
    B8-78-2E   # Apple, Inc.
    B8-78-79   # Roche Diagnostics GmbH
    B8-79-7E   # Secure Meters (UK) Limited
    B8-7A-C9   # Siemens Ltd.
    B8-7C-F2   # Aerohive Networks Inc.
    B8-86-87   # Liteon Technology Corporation
    B8-87-1E   # Good Mind Industries Co., Ltd.
    B8-87-A8   # Step Ahead Innovations Inc.
    B8-88-E3   # COMPAL INFORMATION (KUNSHAN) CO., LTD.
    B8-89-81   # Chengdu InnoThings Technology Co., Ltd.
    B8-89-CA   # ILJIN ELECTRIC Co., Ltd.
    B8-8A-60   # Intel Corporate
    B8-8D-12   # Apple, Inc.
    B8-8E-3A   # Infinite Technologies JLT
    B8-8E-C6   # Stateless Networks
    B8-8F-14   # Analytica GmbH
    B8-92-1D   # BG T&A
    B8-94-D2   # Retail Innovation HTT AB
    B8-96-74   # AllDSP GmbH & Co. KG
    B8-97-5A   # BIOSTAR Microtech Int'l Corp.
    B8-98-B0   # Atlona Inc.
    B8-98-F7   # Gionee Communication Equipment Co,Ltd.ShenZhen
    B8-99-19   # 7signal Solutions, Inc
    B8-99-B0   # Cohere Technologies
    B8-9A-CD   # ELITE OPTOELECTRONIC(ASIA)CO.,LTD
    B8-9A-ED   # OceanServer Technology, Inc
    B8-9B-C9   # SMC Networks Inc
    B8-9B-E4   # ABB Power Systems Power Generation
    B8-A1-75   # Roku, Inc.
    B8-A3-86   # D-Link International
    B8-A3-E0   # BenRui Technology Co.,Ltd
    B8-A8-AF   # Logic S.p.A.
    B8-AC-6F   # Dell Inc.
    B8-AD-3E   # BLUECOM
    B8-AE-6E   # Nintendo Co., Ltd.
    B8-AE-ED   # Elitegroup Computer Systems Co., Ltd.
    B8-AF-67   # Hewlett Packard
    B8-B1-C7   # BT&COM CO.,LTD
    B8-B2-EB   # Googol Technology (HK) Limited
    B8-B3-DC   # DEREK (SHAOGUAN) LIMITED
    B8-B4-2E   # Gionee Communication Equipment Co,Ltd.ShenZhen
    B8-B7-D7   # 2GIG Technologies
    B8-B8-1E   # Intel Corporate
    B8-B9-4E   # Shenzhen iBaby Labs, Inc.
    B8-BA-68   # Xi'an Jizhong Digital Communication Co.,Ltd
    B8-BA-72   # Cynove
    B8-BB-6D   # ENERES Co.,Ltd.
    B8-BC-1B   # HUAWEI TECHNOLOGIES CO.,LTD
    B8-BD-79   # TrendPoint Systems
    B8-BE-BF   # Cisco Systems, Inc
    B8-BF-83   # Intel Corporate
    B8-C1-A2   # Dragon Path Technologies Co., Limited
    B8-C3-BF   # Henan Chengshi NetWork Technology Co.，Ltd
    B8-C4-6F   # PRIMMCON INDUSTRIES INC
    B8-C6-8E   # Samsung Electronics Co.,Ltd
    B8-C7-16   # Fiberhome Telecommunication Technologies Co.,LTD
    B8-C7-5D   # Apple, Inc.
    B8-C8-55   # Shanghai GBCOM Communication Technology Co.,Ltd.
    B8-CA-3A   # Dell Inc.
    B8-CD-93   # Penetek, Inc
    B8-CD-A7   # Maxeler Technologies Ltd.
    B8-D0-6F   # GUANGZHOU HKUST FOK YING TUNG RESEARCH INSTITUTE
    B8-D4-9D   # M Seven System Ltd.
    B8-D8-12   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    B8-D9-CE   # Samsung Electronics
    B8-DA-F1   # Strahlenschutz- Entwicklungs- und Ausruestungsgesellschaft mbH
    B8-DA-F7   # Advanced Photonics, Inc.
    B8-DC-87   # IAI Corporation
    B8-DF-6B   # SpotCam Co., Ltd.
    B8-E5-89   # Payter BV
    B8-E6-25   # 2Wire Inc
    B8-E7-79   # 9Solutions Oy
    B8-E8-56   # Apple, Inc.
    B8-E9-37   # Sonos, Inc.
    B8-EE-65   # Liteon Technology Corporation
    B8-EE-79   # YWire Technologies, Inc.
    B8-F0-80   # SPS, INC.
    B8-F3-17   # iSun Smasher Communications Private Limited
    B8-F4-D0   # Herrmann Ultraschalltechnik GmbH & Co. Kg
    B8-F5-E7   # WayTools, LLC
    B8-F6-B1   # Apple, Inc.
    B8-F7-32   # Aryaka Networks Inc
    B8-F8-28   # Changshu Gaoshida Optoelectronic Technology Co. Ltd.
    B8-F9-34   # Sony Mobile Communications AB
    B8-FC-9A   # Le Shi Zhi Xin Electronic Technology (Tianjin) Limited
    B8-FD-32   # Zhejiang ROICX Microelectronics
    B8-FF-61   # Apple, Inc.
    B8-FF-6F   # Shanghai Typrotech Technology Co.Ltd
    B8-FF-FE   # Texas Instruments
    BC-02-00   # Stewart Audio
    BC-05-43   # AVM GmbH
    BC-0D-A5   # Texas Instruments
    BC-0F-2B   # FORTUNE TECHGROUP CO.,LTD
    BC-0F-64   # Intel Corporate
    BC-12-5E   # Beijing  WisVideo  INC.
    BC-14-01   # Hitron Technologies. Inc
    BC-14-85   # Samsung Electronics Co.,Ltd
    BC-14-EF   # ITON Technology Limited
    BC-15-A6   # Taiwan Jantek Electronics,Ltd.
    BC-16-65   # Cisco Systems, Inc
    BC-16-F5   # Cisco Systems, Inc
    BC-1A-67   # YF Technology Co., Ltd
    BC-20-A4   # Samsung Electronics
    BC-20-BA   # Inspur (Shandong) Electronic Information Co., Ltd
    BC-25-E0   # HUAWEI TECHNOLOGIES CO.,LTD
    BC-25-F0   # 3D Display Technologies Co., Ltd.
    BC-26-1D   # HONG KONG TECON TECHNOLOGY
    BC-28-46   # NextBIT Computing Pvt. Ltd.
    BC-28-D6   # Rowley Associates Limited
    BC-2B-6B   # Beijing Haier IC Design Co.,Ltd
    BC-2B-D7   # Revogi Innovation Co., Ltd.
    BC-2C-55   # Bear Flag Design, Inc.
    BC-2D-98   # ThinGlobal LLC
    BC-30-5B   # Dell Inc.
    BC-30-7D   # Wistron Neweb Corp.
    BC-30-7E   # Wistron Neweb Corp
    BC-34-00   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    BC-35-E5   # Hydro Systems Company
    BC-38-D2   # Pandachip Limited
    BC-39-A6   # CSUN System Technology Co.,LTD
    BC-3A-EA   # GUANGDONG OPPO MOBILE TELECOMMUNICATIONS CORP.,LTD
    BC-3B-AF   # Apple, Inc.
    BC-3E-13   # Accordance Systems Inc.
    BC-41-00   # CODACO ELECTRONIC s.r.o.
    BC-43-77   # Hang Zhou Huite Technology Co.,ltd.
    BC-44-34   # Shenzhen TINNO Mobile Technology Corp.
    BC-44-86   # Samsung Electronics Co.,Ltd
    BC-44-B0   # Elastifile
    BC-46-99   # TP-LINK TECHNOLOGIES CO.,LTD.
    BC-47-60   # Samsung Electronics Co.,Ltd
    BC-4B-79   # SensingTek
    BC-4C-C4   # Apple, Inc.
    BC-4D-FB   # Hitron Technologies. Inc
    BC-4E-3C   # CORE STAFF CO., LTD.
    BC-4E-5D   # ZhongMiao Technology Co., Ltd.
    BC-51-FE   # Swann communications Pty Ltd
    BC-52-B4   # Alcatel-Lucent
    BC-52-B7   # Apple, Inc.
    BC-54-36   # Apple, Inc.
    BC-54-F9   # Drogoo Technology Co., Ltd.
    BC-5C-4C   # ELECOM CO.,LTD.
    BC-5F-F4   # ASRock Incorporation
    BC-5F-F6   # SHENZHEN MERCURY COMMUNICATION TECHNOLOGIES CO.,LTD.
    BC-60-10   # Qingdao Hisense Communications Co.,Ltd
    BC-62-0E   # HUAWEI TECHNOLOGIES CO.,LTD
    BC-62-9F   # Telenet Systems P. Ltd.
    BC-66-41   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    BC-67-1C   # Cisco Systems, Inc
    BC-67-78   # Apple, Inc.
    BC-67-84   # Environics Oy
    BC-6A-16   # tdvine
    BC-6A-29   # Texas Instruments
    BC-6A-2F   # Henge Docks LLC
    BC-6B-4D   # Alcatel-Lucent
    BC-6C-21   # Apple, Inc.
    BC-6E-64   # Sony Mobile Communications AB
    BC-6E-76   # Green Energy Options Ltd
    BC-71-C1   # XTrillion, Inc.
    BC-72-B1   # Samsung Electronics Co.,Ltd
    BC-74-D7   # HangZhou JuRu Technology CO.,LTD
    BC-76-4E   # Rackspace US, Inc.
    BC-76-70   # HUAWEI TECHNOLOGIES CO.,LTD
    BC-77-37   # Intel Corporate
    BC-77-9F   # SBM Co., Ltd.
    BC-79-AD   # Samsung Electronics Co.,Ltd
    BC-7D-D1   # Radio Data Comms
    BC-81-1F   # Ingate Systems
    BC-81-99   # BASIC Co.,Ltd.
    BC-83-A7   # SHENZHEN CHUANGWEI-RGB ELECTRONICS CO.,LTD
    BC-85-1F   # Samsung Electronics
    BC-85-56   # Hon Hai Precision Ind. Co.,Ltd.
    BC-88-93   # VILLBAU Ltd.
    BC-8B-55   # NPP ELIKS America Inc. DBA T&M Atlantic
    BC-8C-CD   # Samsung Electro Mechanics co.,LTD.
    BC-8D-0E   # Alcatel-Lucent
    BC-92-6B   # Apple, Inc.
    BC-96-80   # Shenzhen Gongjin Electronics Co.,Ltd
    BC-98-89   # Fiberhome Telecommunication Tech.Co.,Ltd.
    BC-99-BC   # FonSee Technology Inc.
    BC-9C-31   # HUAWEI TECHNOLOGIES CO.,LTD
    BC-9C-C5   # Beijing Huafei Technology Co., Ltd.
    BC-9D-A5   # DASCOM Europe GmbH
    BC-A4-E1   # Nabto
    BC-A9-D6   # Cyber-Rain, Inc.
    BC-AD-AB   # Avaya Inc
    BC-AE-C5   # ASUSTek COMPUTER INC.
    BC-B1-81   # SHARP CORPORATION
    BC-B1-F3   # Samsung Electronics
    BC-B3-08   # HONGKONG RAGENTEK COMMUNICATION TECHNOLOGY CO.,LIMITED
    BC-B8-52   # Cybera, Inc.
    BC-BA-E1   # AREC Inc.
    BC-BB-C9   # Kellendonk Elektronik GmbH
    BC-BC-46   # SKS Welding Systems GmbH
    BC-C1-68   # DinBox Sverige AB
    BC-C2-3A   # Thomson Video Networks
    BC-C3-42   # Panasonic System Networks Co., Ltd.
    BC-C4-93   # Cisco Systems, Inc
    BC-C6-1A   # SPECTRA EMBEDDED SYSTEMS
    BC-C6-DB   # Nokia Corporation
    BC-C8-10   # Cisco SPVTG
    BC-CA-B5   # ARRIS Group, Inc.
    BC-CD-45   # VOISMART
    BC-CF-CC   # HTC Corporation
    BC-D1-1F   # Samsung Electronics Co.,Ltd
    BC-D1-65   # Cisco SPVTG
    BC-D1-77   # TP-LINK TECHNOLOGIES CO.,LTD.
    BC-D1-D3   # Shenzhen TINNO Mobile Technology Corp.
    BC-D5-B6   # d2d technologies
    BC-D9-40   # ASR Co,.Ltd.
    BC-E0-9D   # Eoslink
    BC-E5-9F   # WATERWORLD Technology Co.,LTD
    BC-E6-3F   # Samsung Electronics Co.,Ltd
    BC-E7-67   # Quanzhou  TDX Electronics Co., Ltd
    BC-EA-2B   # CityCom GmbH
    BC-EA-FA   # Hewlett Packard
    BC-EB-5F   # Fujian Beifeng Telecom Technology Co., Ltd.
    BC-EC-23   # SHENZHEN CHUANGWEI-RGB ELECTRONICS CO.,LTD
    BC-EC-5D   # Apple, Inc.
    BC-EE-7B   # ASUSTek COMPUTER INC.
    BC-F1-F2   # Cisco Systems, Inc
    BC-F2-AF   # devolo AG
    BC-F5-AC   # LG Electronics
    BC-F6-1C   # Geomodeling Wuxi Technology Co. Ltd.
    BC-F6-85   # D-Link International
    BC-F8-11   # Xiamen DNAKE Technology Co.,Ltd
    BC-FE-8C   # Altronic, LLC
    BC-FF-AC   # TOPCON CORPORATION
    C0-05-C2   # ARRIS Group, Inc.
    C0-0D-7E   # Additech, Inc.
    C0-11-73   # Samsung Electronics Co.,Ltd
    C0-11-A6   # Fort-Telecom ltd.
    C0-12-42   # Alpha Security Products
    C0-14-3D   # Hon Hai Precision Ind. Co.,Ltd.
    C0-18-85   # Hon Hai Precision Ind. Co.,Ltd.
    C0-1A-DA   # Apple, Inc.
    C0-1E-9B   # Pixavi AS
    C0-22-50   # Private
    C0-25-06   # AVM GmbH
    C0-25-5C   # Cisco Systems, Inc
    C0-25-67   # Nexxt Solutions
    C0-25-A2   # NEC Platforms, Ltd.
    C0-27-B9   # Beijing National Railway Research & Design Institute  of Signal & Communication Co., Ltd.
    C0-29-73   # Audyssey Laboratories Inc.
    C0-29-F3   # XySystem
    C0-2B-FC   # iNES. applied informatics GmbH
    C0-2C-7A   # Shenzhen Horn Audio Co.,Ltd.
    C0-2D-EE   # Cuff
    C0-33-5E   # Microsoft
    C0-34-B4   # Gigastone Corporation
    C0-35-80   # A&R TECH
    C0-35-BD   # Velocytech Aps
    C0-35-C5   # Prosoft Systems LTD
    C0-38-96   # Hon Hai Precision Ind. Co.,Ltd.
    C0-38-F9   # Nokia Danmark A/S
    C0-3B-8F   # Minicom Digital Signage
    C0-3D-46   # Shanghai Mochui Network Technology Co., Ltd
    C0-3E-0F   # BSkyB Ltd
    C0-3F-0E   # NETGEAR
    C0-3F-2A   # Biscotti, Inc.
    C0-3F-D5   # Elitegroup Computer Systems Co., LTD
    C0-41-F6   # LG Electronics Inc
    C0-43-01   # Epec Oy
    C0-44-E3   # Shenzhen Sinkna Electronics Co., LTD
    C0-49-3D   # MAITRISE TECHNOLOGIQUE
    C0-4A-00   # TP-LINK TECHNOLOGIES CO.,LTD.
    C0-4A-09   # Zhejiang Everbright Communication Equip. Co,. Ltd
    C0-4D-F7   # SERELEC
    C0-56-27   # Belkin International Inc.
    C0-56-E3   # Hangzhou Hikvision Digital Technology Co.,Ltd.
    C0-57-BC   # Avaya Inc
    C0-58-A7   # Pico Systems Co., Ltd.
    C0-5E-6F   # V. Stonkaus firma Kodinis Raktas
    C0-5E-79   # SHENZHEN HUAXUN ARK TECHNOLOGIES CO.,LTD
    C0-61-18   # TP-LINK TECHNOLOGIES CO.,LTD.
    C0-62-6B   # Cisco Systems, Inc
    C0-63-94   # Apple, Inc.
    C0-64-C6   # Nokia Corporation
    C0-65-99   # Samsung Electronics Co.,Ltd
    C0-67-AF   # Cisco Systems, Inc
    C0-6C-0F   # Dobbs Stanford
    C0-6C-6D   # MagneMotion, Inc.
    C0-70-09   # HUAWEI TECHNOLOGIES CO.,LTD
    C0-7B-BC   # Cisco Systems, Inc
    C0-7C-D1   # PEGATRON CORPORATION
    C0-7E-40   # SHENZHEN XDK COMMUNICATION EQUIPMENT CO.,LTD
    C0-81-70   # Effigis GeoSolutions
    C0-83-0A   # 2Wire Inc
    C0-84-7A   # Apple, Inc.
    C0-84-88   # Finis Inc
    C0-88-5B   # SnD Tech Co., Ltd.
    C0-89-97   # Samsung Electronics Co.,Ltd
    C0-8A-DE   # Ruckus Wireless
    C0-8B-6F   # S I Sistemas Inteligentes Eletrônicos Ltda
    C0-8C-60   # Cisco Systems, Inc
    C0-91-32   # Patriot Memory
    C0-91-34   # ProCurve Networking by HP
    C0-98-79   # Acer Inc.
    C0-98-E5   # University of Michigan
    C0-9A-71   # XIAMEN MEITU MOBILE TECHNOLOGY CO.LTD
    C0-9C-92   # COBY
    C0-9D-26   # Topicon HK Lmd.
    C0-9F-42   # Apple, Inc.
    C0-A0-BB   # D-Link International
    C0-A0-C7   # FAIRFIELD INDUSTRIES
    C0-A0-DE   # Multi Touch Oy
    C0-A0-E2   # Eden Innovations
    C0-A2-6D   # Abbott Point of Care
    C0-A3-64   # 3D Systems Massachusetts
    C0-A3-9E   # EarthCam, Inc.
    C0-AA-68   # OSASI Technos Inc.
    C0-AC-54   # Sagemcom Broadband SAS
    C0-B3-39   # Comigo Ltd.
    C0-B3-57   # Yoshiki Electronics Industry Ltd.
    C0-B7-13   # Beijing Xiaoyuer Technology Co. Ltd.
    C0-B8-B1   # BitBox Ltd
    C0-BA-E6   # Application Solutions (Electronics and Vision) Ltd
    C0-BD-42   # ZPA Smart Energy a.s.
    C0-BD-D1   # Samsung Electro Mechanics co., LTD.
    C0-C1-C0   # Cisco-Linksys, LLC
    C0-C3-B6   # Automatic Systems
    C0-C5-20   # Ruckus Wireless
    C0-C5-22   # ARRIS Group, Inc.
    C0-C5-69   # SHANGHAI LYNUC CNC TECHNOLOGY CO.,LTD
    C0-C6-87   # Cisco SPVTG
    C0-C9-46   # MITSUYA LABORATORIES INC.
    C0-CB-38   # Hon Hai Precision Ind. Co.,Ltd.
    C0-CC-F8   # Apple, Inc.
    C0-CE-CD   # Apple, Inc.
    C0-CF-A3   # Creative Electronics & Software, Inc.
    C0-D0-44   # Sagemcom Broadband SAS
    C0-D9-62   # ASKEY COMPUTER CORP
    C0-DA-74   # Hangzhou Sunyard Technology Co., Ltd.
    C0-DC-6A   # Qingdao Eastsoft Communication Technology Co.,LTD
    C0-DF-77   # Conrad Electronic SE
    C0-E4-22   # Texas Instruments
    C0-E5-4E   # DENX Computer Systems GmbH
    C0-EA-E4   # Sonicwall
    C0-EE-40   # Laird Technologies
    C0-EE-FB   # OnePlus Tech (Shenzhen) Ltd
    C0-F1-C4   # Pacidal Corporation Ltd.
    C0-F2-FB   # Apple, Inc.
    C0-F7-9D   # Powercode
    C0-F8-DA   # Hon Hai Precision Ind. Co.,Ltd.
    C0-F9-91   # GME Standard Communications P/L
    C0-FF-D4   # NETGEAR
    C4-00-06   # Lipi Data Systems Ltd.
    C4-00-49   # Kamama
    C4-01-42   # MaxMedia Technology Limited
    C4-01-7C   # Ruckus Wireless
    C4-01-B1   # SeekTech INC
    C4-01-CE   # PRESITION (2000) CO., LTD.
    C4-04-15   # NETGEAR
    C4-04-7B   # Shenzhen YOUHUA Technology Co., Ltd
    C4-05-28   # HUAWEI TECHNOLOGIES CO.,LTD
    C4-07-2F   # HUAWEI TECHNOLOGIES CO.,LTD
    C4-08-4A   # Alcatel-Lucent
    C4-08-80   # Shenzhen UTEPO Tech Co., Ltd.
    C4-09-38   # FUJIAN STAR-NET COMMUNICATION CO.,LTD
    C4-0A-CB   # Cisco Systems, Inc
    C4-0E-45   # ACK Networks,Inc.
    C4-0F-09   # Hermes electronic GmbH
    C4-10-8A   # Ruckus Wireless
    C4-12-F5   # D-Link International
    C4-13-E2   # Aerohive Networks Inc.
    C4-14-3C   # Cisco Systems, Inc
    C4-16-FA   # Prysm Inc
    C4-17-FE   # Hon Hai Precision Ind. Co.,Ltd.
    C4-19-8B   # Dominion Voting Systems Corporation
    C4-19-EC   # Qualisys AB
    C4-1E-CE   # HMI Sources Ltd.
    C4-21-C8   # KYOCERA Corporation
    C4-23-7A   # WhizNets Inc.
    C4-24-2E   # Galvanic Applied Sciences Inc
    C4-26-28   # Airo Wireless
    C4-27-95   # Technicolor USA Inc.
    C4-28-2D   # Embedded Intellect Pty Ltd
    C4-29-1D   # KLEMSAN ELEKTRIK ELEKTRONIK SAN.VE TIC.AS.
    C4-2C-03   # Apple, Inc.
    C4-2F-90   # Hangzhou Hikvision Digital Technology Co.,Ltd.
    C4-34-6B   # Hewlett Packard
    C4-36-55   # Shenzhen Fenglian Technology Co., Ltd.
    C4-36-6C   # LG Innotek
    C4-36-DA   # Rusteletech Ltd.
    C4-38-D3   # TAGATEC CO.,LTD
    C4-39-3A   # SMC Networks Inc
    C4-3A-9F   # Siconix Inc.
    C4-3A-BE   # Sony Mobile Communications AB
    C4-3C-3C   # CYBELEC SA
    C4-3D-C7   # NETGEAR
    C4-40-44   # RackTop Systems Inc.
    C4-42-02   # Samsung Electronics Co.,Ltd
    C4-43-8F   # LG Electronics
    C4-45-67   # SAMBON PRECISON and ELECTRONICS
    C4-45-EC   # Shanghai Yali Electron Co.,LTD
    C4-46-19   # Hon Hai Precision Ind. Co.,Ltd.
    C4-47-3F   # HUAWEI TECHNOLOGIES CO.,LTD
    C4-48-38   # Satcom Direct, Inc.
    C4-4A-D0   # FIREFLIES SYSTEMS
    C4-4B-44   # Omniprint Inc.
    C4-4B-D1   # Wallys Communications  Teachnologies Co.,Ltd.
    C4-4E-1F   # BlueN
    C4-4E-AC   # Shenzhen Shiningworth Technology Co., Ltd.
    C4-50-06   # Samsung Electronics Co.,Ltd
    C4-54-44   # QUANTA COMPUTER INC.
    C4-55-A6   # Cadac Holdings Ltd
    C4-55-C2   # Bach-Simpson
    C4-56-00   # Galleon Embedded Computing
    C4-56-FE   # Lava International Ltd.
    C4-57-6E   # Samsung Electronics Co.,Ltd
    C4-58-C2   # Shenzhen TATFOOK Technology Co., Ltd.
    C4-59-76   # Fugoo Coorporation
    C4-5D-D8   # HDMI Forum
    C4-60-44   # Everex Electronics Limited
    C4-62-6B   # ZPT Vigantice
    C4-62-EA   # Samsung Electronics Co.,Ltd
    C4-63-54   # U-Raku, Inc.
    C4-64-13   # Cisco Systems, Inc
    C4-66-99   # vivo Mobile Communication Co., Ltd.
    C4-67-B5   # Libratone A/S
    C4-69-3E   # Turbulence Design Inc.
    C4-6A-B7   # Xiaomi Communications Co Ltd
    C4-6B-B4   # myIDkey
    C4-6D-F1   # DataGravity
    C4-6E-1F   # TP-LINK TECHNOLOGIES CO.,LTD.
    C4-71-30   # Fon Technology S.L.
    C4-71-FE   # Cisco Systems, Inc
    C4-72-95   # Cisco Systems, Inc
    C4-73-1E   # Samsung Eletronics Co., Ltd
    C4-77-AB   # Beijing ASU Tech Co.,Ltd
    C4-7B-2F   # Beijing JoinHope Image Technology Ltd.
    C4-7B-A3   # NAVIS Inc.
    C4-7D-46   # FUJITSU LIMITED
    C4-7D-4F   # Cisco Systems, Inc
    C4-7D-CC   # Zebra Technologies Inc
    C4-7D-FE   # A.N. Solutions GmbH
    C4-7F-51   # Inventek Systems
    C4-82-3F   # Fujian Newland Auto-ID Tech. Co,.Ltd.
    C4-82-4E   # Changzhou Uchip Electronics Co., LTD.
    C4-85-08   # Intel Corporate
    C4-88-E5   # Samsung Electronics Co.,Ltd
    C4-8E-8F   # Hon Hai Precision Ind. Co.,Ltd.
    C4-91-3A   # Shenzhen Sanland Electronic Co., ltd.
    C4-92-4C   # KEISOKUKI CENTER CO.,LTD.
    C4-93-00   # 8Devices
    C4-93-13   # 100fio networks technology llc
    C4-93-80   # Speedytel technology
    C4-95-A2   # SHENZHEN WEIJIU INDUSTRY AND TRADE DEVELOPMENT CO., LTD
    C4-98-05   # Minieum Networks, Inc
    C4-9A-02   # LG Electronics (Mobile Communicaitons)
    C4-9E-41   # G24 Power Limited
    C4-9F-F3   # Mciao Technologies, Inc.
    C4-A8-1D   # D-Link International
    C4-AA-A1   # SUMMIT DEVELOPMENT, spol.s r.o.
    C4-AD-21   # MEDIAEDGE Corporation
    C4-AD-F1   # GOPEACE Inc.
    C4-B5-12   # General Electric Digital Energy
    C4-BA-99   # I+ME Actia Informatik und Mikro-Elektronik GmbH
    C4-BA-A3   # Beijing Winicssec Technologies Co., Ltd.
    C4-BB-EA   # Pakedge Device and Software Inc
    C4-BD-6A   # SKF GmbH
    C4-BE-84   # Texas Instruments
    C4-C0-AE   # MIDORI ELECTRONIC CO., LTD.
    C4-C1-9F   # National Oilwell Varco Instrumentation, Monitoring, and Optimization (NOV IMO)
    C4-C7-55   # Beijing HuaqinWorld Technology Co.,Ltd
    C4-C9-19   # Energy Imports Ltd
    C4-C9-EC   # Gugaoo   HK Limited
    C4-CA-D9   # Hangzhou H3C Technologies Co., Limited
    C4-CD-45   # Beijing Boomsense Technology CO.,LTD.
    C4-D4-89   # JiangSu Joyque Information Industry Co.,Ltd
    C4-D6-55   # Tercel technology co.,ltd
    C4-D9-87   # Intel Corporate
    C4-DA-26   # NOBLEX SA
    C4-DA-7D   # Ivium Technologies B.V.
    C4-E0-32   # IEEE 1904.1 Working Group
    C4-E1-7C   # U2S co.
    C4-E5-10   # Mechatro, Inc.
    C4-E7-BE   # SCSpro Co.,Ltd
    C4-E9-2F   # AB Sciex
    C4-E9-84   # TP-LINK TECHNOLOGIES CO.,LTD.
    C4-EA-1D   # Technicolor
    C4-EB-E3   # RRCN SAS
    C4-ED-BA   # Texas Instruments
    C4-EE-AE   # VSS Monitoring
    C4-EE-F5   # Oclaro, Inc.
    C4-EF-70   # Home Skinovations
    C4-F4-64   # Spica international
    C4-F5-7C   # Brocade Communications Systems, Inc.
    C4-FC-E4   # DishTV NZ Ltd
    C8-00-84   # Cisco Systems, Inc
    C8-02-10   # LG Innotek
    C8-02-58   # ITW GSE ApS
    C8-02-A6   # Beijing Newmine Technology
    C8-07-18   # TDSi
    C8-08-E9   # LG Electronics
    C8-0A-A9   # Quanta Computer Inc.
    C8-0E-14   # AVM Audiovisuelles Marketing und Computersysteme GmbH
    C8-0E-77   # Le Shi Zhi Xin Electronic Technology (Tianjin) Limited
    C8-0E-95   # OmniLync Inc.
    C8-10-73   # CENTURY OPTICOMM CO.,LTD
    C8-14-79   # Samsung Electronics Co.,Ltd
    C8-16-BD   # HISENSE ELECTRIC CO.,LTD.
    C8-19-F7   # Samsung Electronics Co.,Ltd
    C8-1A-FE   # DLOGIC GmbH
    C8-1B-6B   # Innova Security
    C8-1E-8E   # ADV Security (S) Pte Ltd
    C8-1E-E7   # Apple, Inc.
    C8-1F-66   # Dell Inc.
    C8-20-8E   # Storagedata
    C8-29-2A   # Barun Electronics
    C8-2A-14   # Apple, Inc.
    C8-2E-94   # Halfa Enterprise Co., Ltd.
    C8-31-68   # eZEX corporation
    C8-32-32   # Hunting Innova
    C8-33-4B   # Apple, Inc.
    C8-34-8E   # Intel Corporate
    C8-35-B8   # Ericsson, EAB/RWI/K
    C8-3A-35   # Tenda Technology Co., Ltd.
    C8-3B-45   # JRI-Maxant
    C8-3D-97   # Nokia Corporation
    C8-3D-FC   # PIONEER CORPORATION
    C8-3E-99   # Texas Instruments
    C8-3E-A7   # KUNBUS GmbH
    C8-3F-B4   # ARRIS Group, Inc.
    C8-45-29   # IMK Networks Co.,Ltd
    C8-45-44   # Shanghai Enlogic Electric Technology Co., Ltd.
    C8-45-8F   # Wyler AG
    C8-47-8C   # Beken Corporation
    C8-48-F5   # MEDISON Xray Co., Ltd
    C8-4C-75   # Cisco Systems, Inc
    C8-51-95   # HUAWEI TECHNOLOGIES CO.,LTD
    C8-56-45   # Intermas France
    C8-56-63   # Sunflex Europe GmbH
    C8-60-00   # ASUSTek COMPUTER INC.
    C8-64-C7   # zte corporation
    C8-66-5D   # Aerohive Networks Inc.
    C8-67-5E   # Aerohive Networks Inc.
    C8-69-CD   # Apple, Inc.
    C8-6C-1E   # Display Systems Ltd
    C8-6C-87   # ZyXEL Communications Corporation
    C8-6C-B6   # Optcom Co., Ltd.
    C8-6F-1D   # Apple, Inc.
    C8-72-48   # Aplicom Oy
    C8-7B-5B   # zte corporation
    C8-7C-BC   # Valink Co., Ltd.
    C8-7D-77   # Shenzhen Kingtech Communication Equipment Co.,Ltd
    C8-7E-75   # Samsung Electronics Co.,Ltd
    C8-84-39   # Sunrise Technologies
    C8-84-47   # Beautiful Enterprise Co., Ltd
    C8-85-50   # Apple, Inc.
    C8-87-22   # Lumenpulse
    C8-87-3B   # Net Optics
    C8-8A-83   # Dongguan HuaHong Electronics Co.,Ltd
    C8-8B-47   # Nolangroup S.P.A con Socio Unico
    C8-8E-D1   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    C8-90-3E   # Pakton Technologies
    C8-91-F9   # Sagemcom Broadband SAS
    C8-93-46   # MXCHIP Company Limited
    C8-93-83   # Embedded Automation, Inc.
    C8-94-D2   # Jiangsu Datang  Electronic Products Co., Ltd
    C8-97-9F   # Nokia Corporation
    C8-9C-1D   # Cisco Systems, Inc
    C8-9C-DC   # ELITEGROUP COMPUTER SYSTEM CO., LTD.
    C8-9F-1D   # SHENZHEN COMMUNICATION TECHNOLOGIES CO.,LTD
    C8-9F-42   # VDII Innovation AB
    C8-A0-30   # Texas Instruments
    C8-A1-B6   # Shenzhen Longway Technologies Co., Ltd
    C8-A1-BA   # Neul Ltd
    C8-A2-CE   # Oasis Media Systems LLC
    C8-A6-20   # Nebula, Inc
    C8-A7-0A   # Verizon Business
    C8-A7-29   # SYStronics Co., Ltd.
    C8-A8-23   # Samsung Electronics Co.,Ltd
    C8-A9-FC   # Goyoo Networks Inc.
    C8-AA-21   # ARRIS Group, Inc.
    C8-AA-CC   # Private
    C8-AE-9C   # Shanghai TYD Elecronic Technology Co. Ltd
    C8-AF-40   # marco Systemanalyse und Entwicklung GmbH
    C8-B3-73   # Cisco-Linksys, LLC
    C8-B5-B7   # Apple, Inc.
    C8-BA-94   # Samsung Electro Mechanics co., LTD.
    C8-BB-D3   # Embrane
    C8-BC-C8   # Apple, Inc.
    C8-BE-19   # D-Link International
    C8-C1-26   # ZPM Industria e Comercio Ltda
    C8-C1-3C   # RuggedTek Hangzhou Co., Ltd
    C8-C2-C6   # Shanghai Airm2m Communication Technology Co., Ltd
    C8-C5-0E   # Shenzhen Primestone Network Technologies.Co., Ltd.
    C8-C7-91   # Zero1.tv GmbH
    C8-CB-B8   # Hewlett Packard
    C8-CD-72   # Sagemcom Broadband SAS
    C8-D0-19   # Shanghai Tigercel Communication Technology Co.,Ltd
    C8-D1-0B   # Nokia Corporation
    C8-D1-5E   # HUAWEI TECHNOLOGIES CO.,LTD
    C8-D1-D1   # AGAiT Technology Corporation
    C8-D2-C1   # Jetlun (Shenzhen) Corporation
    C8-D3-A3   # D-Link International
    C8-D4-29   # Muehlbauer AG
    C8-D5-90   # FLIGHT DATA SYSTEMS
    C8-D5-FE   # Shenzhen Zowee Technology Co., Ltd
    C8-D7-19   # Cisco-Linksys, LLC
    C8-D7-79   # Qingdao Haier Telecom Co.，Ltd
    C8-DD-C9   # Lenovo Mobile Communication Technology Ltd.
    C8-DE-51   # Integra Networks, Inc.
    C8-DF-7C   # Nokia Corporation
    C8-E0-EB   # Apple, Inc.
    C8-E1-30   # Milkyway Group Ltd
    C8-E1-A7   # Vertu Corporation Limited
    C8-E4-2F   # Technical Research Design and Development
    C8-E7-D8   # SHENZHEN MERCURY COMMUNICATION TECHNOLOGIES CO.,LTD.
    C8-EE-08   # TANGTOP TECHNOLOGY CO.,LTD
    C8-EE-75   # Pishion International Co. Ltd
    C8-EE-A6   # Shenzhen SHX Technology Co., Ltd
    C8-EF-2E   # Beijing Gefei Tech. Co., Ltd
    C8-F2-30   # GUANGDONG OPPO MOBILE TELECOMMUNICATIONS CORP.,LTD
    C8-F3-6B   # Yamato Scale Co.,Ltd.
    C8-F3-86   # Shenzhen Xiaoniao Technology Co.,Ltd
    C8-F4-06   # Avaya Inc
    C8-F6-50   # Apple, Inc.
    C8-F6-8D   # S.E.TECHNOLOGIES LIMITED
    C8-F7-04   # Building Block Video
    C8-F7-33   # Intel Corporate
    C8-F9-81   # Seneca s.r.l.
    C8-F9-C8   # NewSharp Technology(SuZhou)Co,Ltd
    C8-F9-F9   # Cisco Systems, Inc
    C8-FB-26   # Cisco SPVTG
    C8-FE-30   # Bejing DAYO Mobile Communication Technology Ltd.
    C8-FF-28   # Liteon Technology Corporation
    C8-FF-77   # Dyson Limited
    CC-00-80   # BETTINI SRL
    CC-03-FA   # Technicolor CH USA
    CC-04-7C   # G-WAY Microwave
    CC-04-B4   # Select Comfort
    CC-05-1B   # Samsung Electronics Co.,Ltd
    CC-07-AB   # Samsung Electronics Co.,Ltd
    CC-07-E4   # Lenovo Mobile Communication Technology Ltd.
    CC-08-E0   # Apple, Inc.
    CC-09-C8   # IMAQLIQ LTD
    CC-0C-DA   # Miljovakt AS
    CC-0D-EC   # Cisco SPVTG
    CC-10-A3   # Beijing Nan Bao Technology Co., Ltd.
    CC-14-A6   # Yichun MyEnergy Domain, Inc
    CC-18-7B   # Manzanita Systems, Inc.
    CC-19-A8   # PT Inovação e Sistemas SA
    CC-1A-FA   # zte corporation
    CC-1B-E0   # IEEE Registration Authority
    CC-1E-FF   # Metrological Group BV
    CC-1F-C4   # InVue
    CC-20-E8   # Apple, Inc.
    CC-22-18   # InnoDigital Co., Ltd.
    CC-25-EF   # Apple, Inc.
    CC-26-2D   # Verifi, LLC
    CC-29-F5   # Apple, Inc.
    CC-2A-80   # Micro-Biz intelligence solutions Co.,Ltd
    CC-2D-8C   # LG Electronics Inc
    CC-30-80   # VAIO Corporation
    CC-33-BB   # Sagemcom Broadband SAS
    CC-34-29   # TP-LINK TECHNOLOGIES CO.,LTD.
    CC-34-D7   # GEWISS S.P.A.
    CC-35-40   # Technicolor USA Inc.
    CC-37-AB   # Edgecore Networks Corportation
    CC-39-8C   # Shiningtek
    CC-3A-61   # SAMSUNG ELECTRO MECHANICS CO., LTD.
    CC-3B-3E   # Lester Electrical
    CC-3C-3F   # SA.S.S. Datentechnik AG
    CC-3D-82   # Intel Corporate
    CC-3E-5F   # Hewlett Packard
    CC-3F-1D   # Intesis Software SL
    CC-43-E3   # Trump s.a.
    CC-44-63   # Apple, Inc.
    CC-46-D6   # Cisco Systems, Inc
    CC-47-03   # Intercon Systems Co., Ltd.
    CC-4A-E1   # fourtec -Fourier Technologies
    CC-4B-FB   # Hellberg Safety AB
    CC-4E-24   # Brocade Communications Systems, Inc.
    CC-4E-EC   # HUMAX Co., Ltd.
    CC-50-1C   # KVH Industries, Inc.
    CC-50-76   # Ocom Communications, Inc.
    CC-52-AF   # Universal Global Scientific Industrial Co., Ltd.
    CC-53-B5   # HUAWEI TECHNOLOGIES CO.,LTD
    CC-54-59   # OnTime Networks AS
    CC-55-AD   # RIM
    CC-59-3E   # TOUMAZ LTD
    CC-5C-75   # Weightech Com. Imp. Exp. Equip. Pesagem Ltda
    CC-5D-4E   # ZyXEL Communications Corporation
    CC-5D-57   # Information  System Research Institute,Inc.
    CC-5F-BF   # Topwise 3G Communication Co., Ltd.
    CC-60-BB   # Empower RF Systems
    CC-65-AD   # ARRIS Group, Inc.
    CC-69-B0   # Global Traffic Technologies, LLC
    CC-6B-98   # Minetec Wireless Technologies
    CC-6B-F1   # Sound Masking Inc.
    CC-6D-A0   # Roku, Inc.
    CC-6D-EF   # TJK Tietolaite Oy
    CC-72-0F   # Viscount Systems Inc.
    CC-74-98   # Filmetrics Inc.
    CC-76-69   # SEETECH
    CC-78-5F   # Apple, Inc.
    CC-78-AB   # Texas Instruments
    CC-79-4A   # BLU Products Inc.
    CC-79-CF   # Shenzhen RF-LINK Elec&Technology Co.Ltd
    CC-7A-30   # CMAX Wireless Co., Ltd.
    CC-7B-35   # zte corporation
    CC-7D-37   # ARRIS Group, Inc.
    CC-7E-E7   # Panasonic AVC Networks Company
    CC-85-6C   # SHENZHEN MDK DIGITAL TECHNOLOGY CO.,LTD
    CC-89-FD   # Nokia Corporation
    CC-8C-E3   # Texas Instruments
    CC-90-93   # Hansong Tehnologies
    CC-91-2B   # TE Connectivity Touch Solutions
    CC-94-4A   # Pfeiffer Vacuum GmbH
    CC-95-D7   # Vizio, Inc
    CC-96-35   # LVS Co.,Ltd.
    CC-96-A0   # HUAWEI TECHNOLOGIES CO.,LTD
    CC-9E-00   # Nintendo Co., Ltd.
    CC-9F-35   # Transbit Sp. z o.o.
    CC-A0-E5   # DZG Metering GmbH
    CC-A2-23   # HUAWEI TECHNOLOGIES CO.,LTD
    CC-A3-74   # Guangdong Guanglian Electronic Technology Co.Ltd
    CC-A4-62   # ARRIS Group, Inc.
    CC-A4-AF   # Shenzhen Sowell Technology Co., LTD
    CC-A6-14   # AIFA TECHNOLOGY CORP.
    CC-AF-78   # Hon Hai Precision Ind. Co.,Ltd.
    CC-B2-55   # D-Link International
    CC-B3-F8   # FUJITSU ISOTEC LIMITED
    CC-B5-5A   # Fraunhofer ITWM
    CC-B6-91   # NECMagnusCommunications
    CC-B8-88   # AnB Securite s.a.
    CC-B8-F1   # EAGLE KINGDOM TECHNOLOGIES LIMITED
    CC-BD-35   # Steinel GmbH
    CC-BD-D3   # Ultimaker B.V.
    CC-BE-71   # OptiLogix BV
    CC-C1-04   # Applied Technical Systems
    CC-C3-EA   # Motorola Mobility LLC, a Lenovo Company
    CC-C5-0A   # SHENZHEN DAJIAHAO TECHNOLOGY CO.,LTD
    CC-C6-2B   # Tri-Systems Corporation
    CC-C7-60   # Apple, Inc.
    CC-C8-D7   # CIAS Elettronica srl
    CC-CC-4E   # Sun Fountainhead USA. Corp
    CC-CC-81   # HUAWEI TECHNOLOGIES CO.,LTD
    CC-CD-64   # SM-Electronic GmbH
    CC-CE-40   # Janteq Corp
    CC-D2-9B   # Shenzhen Bopengfa Elec&Technology CO.,Ltd
    CC-D5-39   # Cisco Systems, Inc
    CC-D8-11   # Aiconn Technology Corporation
    CC-D8-C1   # Cisco Systems, Inc
    CC-D9-E9   # SCR Engineers Ltd.
    CC-E0-C3   # Mangstor, Inc.
    CC-E1-7F   # Juniper Networks
    CC-E1-D5   # BUFFALO.INC
    CC-E7-98   # My Social Stuff
    CC-E7-DF   # American Magnetics, Inc.
    CC-E8-AC   # SOYEA Technology Co.,Ltd.
    CC-EA-1C   # DCONWORKS  Co., Ltd
    CC-EE-D9   # VAHLE DETO GmbH
    CC-EF-48   # Cisco Systems, Inc
    CC-F3-A5   # Chi Mei Communication Systems, Inc
    CC-F4-07   # EUKREA ELECTROMATIQUE SARL
    CC-F5-38   # 3isysnetworks
    CC-F6-7A   # Ayecka Communication Systems LTD
    CC-F8-41   # Lumewave
    CC-F8-F0   # Xi'an HISU Multimedia Technology Co.,Ltd.
    CC-F9-54   # Avaya Inc
    CC-F9-E8   # Samsung Electronics Co.,Ltd
    CC-FA-00   # LG Electronics
    CC-FB-65   # Nintendo Co., Ltd.
    CC-FC-6D   # RIZ TRANSMITTERS
    CC-FC-B1   # Wireless Technology, Inc.
    CC-FE-3C   # Samsung Electronics
    D0-03-4B   # Apple, Inc.
    D0-04-92   # Fiberhome Telecommunication Technologies Co.,LTD
    D0-07-90   # Texas Instruments
    D0-0A-AB   # Yokogawa Digital Computer Corporation
    D0-0E-A4   # Porsche Cars North America
    D0-0E-D9   # Taicang T&W Electronics
    D0-0F-6D   # T&W Electronics Company
    D0-12-42   # BIOS Corporation
    D0-13-1E   # Sunrex Technology Corp
    D0-15-4A   # zte corporation
    D0-17-6A   # Samsung Electronics Co.,Ltd
    D0-1A-A7   # UniPrint
    D0-1C-BB   # Beijing Ctimes Digital Technology Co., Ltd.
    D0-22-12   # IEEE Registration Authority
    D0-22-BE   # Samsung Electro Mechanics co.,LTD.
    D0-23-DB   # Apple, Inc.
    D0-25-16   # SHENZHEN MERCURY COMMUNICATION TECHNOLOGIES CO.,LTD.
    D0-25-44   # Samsung Electro Mechanics co., LTD.
    D0-25-98   # Apple, Inc.
    D0-27-88   # Hon Hai Precision Ind. Co.,Ltd.
    D0-2C-45   # littleBits Electronics, Inc.
    D0-2D-B3   # HUAWEI TECHNOLOGIES CO.,LTD
    D0-31-10   # Ingenic Semiconductor Co.,Ltd
    D0-33-11   # Apple, Inc.
    D0-37-42   # Yulong Computer Telecommunication Scientific(shenzhen)Co.,Lt
    D0-37-61   # Texas Instruments
    D0-39-72   # Texas Instruments
    D0-39-B3   # ARRIS Group, Inc.
    D0-3E-5C   # HUAWEI TECHNOLOGIES CO.,LTD
    D0-43-1E   # Dell Inc.
    D0-46-DC   # Southwest Research Institute
    D0-48-F3   # DATTUS Inc
    D0-4C-C1   # SINTRONES Technology Corp.
    D0-4D-2C   # Roku, Inc.
    D0-4F-7E   # Apple, Inc.
    D0-50-99   # ASRock Incorporation
    D0-51-62   # Sony Mobile Communications AB
    D0-52-A8   # Physical Graph Corporation
    D0-53-49   # Liteon Technology Corporation
    D0-54-2D   # Cambridge Industries(Group) Co.,Ltd.
    D0-57-4C   # Cisco Systems, Inc
    D0-57-85   # Pantech Co., Ltd.
    D0-57-A1   # Werma Signaltechnik GmbH & Co. KG
    D0-58-75   # Active Control Technology Inc.
    D0-59-C3   # CeraMicro Technology Corporation
    D0-59-E4   # Samsung Electronics Co.,Ltd
    D0-5A-0F   # I-BT DIGITAL CO.,LTD
    D0-5A-F1   # Shenzhen Pulier Tech CO.,Ltd
    D0-5B-A8   # zte corporation
    D0-5C-7A   # Sartura d.o.o.
    D0-5F-B8   # Texas Instruments
    D0-5F-CE   # Hitachi Data Systems
    D0-62-A0   # China Essence Technology (Zhumadian) Co., Ltd.
    D0-63-4D   # Meiko Maschinenbau GmbH &amp; Co. KG
    D0-63-B4   # SolidRun Ltd.
    D0-66-7B   # Samsung Electronics Co., LTD
    D0-67-E5   # Dell Inc.
    D0-69-9E   # LUMINEX Lighting Control Equipment
    D0-69-D0   # Verto Medical Solutions, LLC
    D0-6A-1F   # BSE CO.,LTD.
    D0-6F-4A   # TOPWELL INTERNATIONAL HOLDINGS LIMITED
    D0-72-DC   # Cisco Systems, Inc
    D0-73-7F   # Mini-Circuits
    D0-73-8E   # DONG OH PRECISION CO., LTD.
    D0-73-D5   # LIFI LABS MANAGEMENT PTY LTD
    D0-75-BE   # Reno A&E
    D0-76-50   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    D0-7A-B5   # HUAWEI TECHNOLOGIES CO.,LTD
    D0-7C-2D   # Leie IOT technology Co., Ltd
    D0-7D-E5   # Forward Pay Systems, Inc.
    D0-7E-28   # Hewlett Packard
    D0-7E-35   # Intel Corporate
    D0-83-D4   # XTel ApS
    D0-84-B0   # Sagemcom Broadband SAS
    D0-87-E2   # Samsung Electronics Co.,Ltd
    D0-89-99   # APCON, Inc.
    D0-8A-55   # Skullcandy
    D0-8B-7E   # Passif Semiconductor
    D0-8C-B5   # Texas Instruments
    D0-8C-FF   # UPWIS AB
    D0-92-9E   # Microsoft Corporation
    D0-93-80   # Ducere Technologies Pvt. Ltd.
    D0-93-F8   # Stonestreet One LLC
    D0-95-C7   # Pantech Co., Ltd.
    D0-99-D5   # Alcatel-Lucent
    D0-9B-05   # Emtronix
    D0-9C-30   # Foster Electric Company, Limited
    D0-9D-0A   # LINKCOM
    D0-9D-AB   # TCT mobile ltd
    D0-A0-D6   # Chengdu TD Tech Ltd.
    D0-A3-11   # Neuberger Gebäudeautomation GmbH
    D0-A5-A6   # Cisco Systems, Inc
    D0-A6-37   # Apple, Inc.
    D0-AE-EC   # Alpha Networks Inc.
    D0-AF-B6   # Linktop Technology Co., LTD
    D0-B3-3F   # Shenzhen TINNO Mobile Technology Corp.
    D0-B4-98   # Robert Bosch LLC Automotive Electronics
    D0-B5-23   # Bestcare Cloucal Corp.
    D0-B5-3D   # SEPRO ROBOTIQUE
    D0-B5-C2   # Texas Instruments
    D0-BA-E4   # Shanghai MXCHIP Information Technology Co., Ltd.
    D0-BB-80   # SHL Telemedicine International Ltd.
    D0-BD-01   # DS International
    D0-BE-2C   # CNSLink Co., Ltd.
    D0-BF-9C   # Hewlett Packard
    D0-C0-BF   # Actions Microelectronics Co., Ltd
    D0-C1-93   # SKYBELL, INC
    D0-C1-B1   # Samsung Electronics Co.,Ltd
    D0-C2-82   # Cisco Systems, Inc
    D0-C4-2F   # Tamagawa Seiki Co.,Ltd.
    D0-C7-89   # Cisco Systems, Inc
    D0-C7-C0   # TP-LINK TECHNOLOGIES CO.,LTD.
    D0-CD-E1   # Scientech Electronics
    D0-CF-5E   # Energy Micro AS
    D0-D0-4B   # HUAWEI TECHNOLOGIES CO.,LTD
    D0-D0-FD   # Cisco Systems, Inc
    D0-D2-12   # K2NET Co.,Ltd.
    D0-D2-86   # Beckman Coulter K.K.
    D0-D3-FC   # Mios, Ltd.
    D0-D4-12   # ADB Broadband Italia
    D0-D4-71   # MVTECH co., Ltd
    D0-D6-CC   # Wintop
    D0-DB-32   # Nokia Corporation
    D0-DF-9A   # Liteon Technology Corporation
    D0-DF-B2   # Genie Networks Limited
    D0-DF-C7   # Samsung Electronics Co.,Ltd
    D0-E1-40   # Apple, Inc.
    D0-E3-47   # Yoga
    D0-E4-0B   # Wearable Inc.
    D0-E4-4A   # Murata Manufacturing Co., Ltd.
    D0-E5-4D   # Pace plc
    D0-E7-82   # AzureWave Technology Inc.
    D0-EB-03   # Zhehua technology limited
    D0-EB-9E   # Seowoo Inc.
    D0-F0-DB   # Ericsson
    D0-F2-7F   # SteadyServ Technoligies, LLC
    D0-F7-3B   # Helmut Mauell GmbH
    D0-FA-1D   # Qihoo  360  Technology Co.,Ltd
    D0-FF-50   # Texas Instruments
    D4-00-0D   # Phoenix Broadband Technologies, LLC.
    D4-00-57   # MC Technologies GmbH
    D4-01-29   # Broadcom
    D4-01-6D   # TP-LINK TECHNOLOGIES CO.,LTD.
    D4-02-4A   # Delphian Systems LLC
    D4-04-CD   # ARRIS Group, Inc.
    D4-05-98   # ARRIS Group, Inc.
    D4-0A-A9   # ARRIS Group, Inc.
    D4-0B-1A   # HTC Corporation
    D4-0B-B9   # Solid Semecs bv.
    D4-0F-B2   # Applied Micro Electronics AME bv
    D4-10-90   # iNFORM Systems AG
    D4-10-CF   # Huanshun Network Science and Technology Co., Ltd.
    D4-11-D6   # ShotSpotter, Inc.
    D4-12-96   # Anobit Technologies Ltd.
    D4-12-BB   # Quadrant Components Inc. Ltd
    D4-13-6F   # Asia Pacific Brands
    D4-1C-1C   # RCF S.P.A.
    D4-1E-35   # TOHO Electronics INC.
    D4-1F-0C   # JAI Oy
    D4-20-6D   # HTC Corporation
    D4-21-22   # Sercomm Corporation
    D4-22-3F   # Lenovo Mobile Communication Technology Ltd.
    D4-22-4E   # Alcatel Lucent
    D4-27-51   # Infopia Co., Ltd
    D4-28-B2   # ioBridge, Inc.
    D4-29-EA   # Zimory GmbH
    D4-2C-0F   # Pace plc
    D4-2C-3D   # Sky Light Digital Limited
    D4-2F-23   # Akenori PTE Ltd
    D4-31-9D   # Sinwatec
    D4-32-66   # Fike Corporation
    D4-37-D7   # zte corporation
    D4-3A-65   # IGRS Engineering Lab Ltd.
    D4-3A-E9   # DONGGUAN ipt INDUSTRIAL CO., LTD
    D4-3D-67   # Carma Industries Inc.
    D4-3D-7E   # Micro-Star Int'l Co, Ltd
    D4-40-F0   # HUAWEI TECHNOLOGIES CO.,LTD
    D4-43-A8   # Changzhou Haojie Electric Co., Ltd.
    D4-45-E8   # Jiangxi Hongpai Technology Co., Ltd.
    D4-4B-5E   # TAIYO YUDEN CO., LTD.
    D4-4C-24   # Vuppalamritha Magnetic Components LTD
    D4-4C-9C   # Shenzhen YOOBAO Technology Co.Ltd
    D4-4C-A7   # Informtekhnika & Communication, LLC
    D4-4F-80   # Kemper Digital GmbH
    D4-50-7A   # CEIVA Logic, Inc
    D4-52-2A   # TangoWiFi.com
    D4-52-51   # IBT Ingenieurbureau Broennimann Thun
    D4-52-97   # nSTREAMS Technologies, Inc.
    D4-53-AF   # VIGO System S.A.
    D4-55-56   # Fiber Mountain Inc.
    D4-5A-B2   # Galleon Systems
    D4-5C-70   # Wi-Fi Alliance
    D4-5D-42   # Nokia Corporation
    D4-61-32   # Pro Concept Manufacturer Co.,Ltd.
    D4-64-F7   # CHENGDU USEE DIGITAL TECHNOLOGY CO., LTD
    D4-66-A8   # Riedo Networks GmbH
    D4-67-61   # SAHAB TECHNOLOGY
    D4-67-E7   # Fiberhome Telecommunication Tech.Co.,Ltd.
    D4-68-4D   # Ruckus Wireless
    D4-68-67   # Neoventus Design Group
    D4-68-BA   # Shenzhen Sundray Technologies Company Limited
    D4-6A-91   # Snap AV
    D4-6A-A8   # HUAWEI TECHNOLOGIES CO.,LTD
    D4-6C-BF   # Goodrich ISR
    D4-6C-DA   # CSM GmbH
    D4-6D-50   # Cisco Systems, Inc
    D4-6E-5C   # HUAWEI TECHNOLOGIES CO.,LTD
    D4-6F-42   # WAXESS USA Inc
    D4-72-08   # Bragi GmbH
    D4-76-EA   # zte corporation
    D4-78-56   # Avaya Inc
    D4-79-C3   # Cameronet GmbH & Co. KG
    D4-7B-35   # NEO Monitors AS
    D4-7B-75   # HARTING Electronics GmbH
    D4-7B-B0   # ASKEY COMPUTER CORP
    D4-81-CA   # iDevices, LLC
    D4-82-3E   # Argosy Technologies, Ltd.
    D4-83-04   # SHENZHEN FAST TECHNOLOGIES CO.,LTD
    D4-85-64   # Hewlett Packard
    D4-87-D8   # Samsung Electronics
    D4-88-90   # Samsung Electronics Co.,Ltd
    D4-8C-B5   # Cisco Systems, Inc
    D4-8D-D9   # Meld Technology, Inc
    D4-8F-33   # Microsoft Corporation
    D4-8F-AA   # Sogecam Industrial, S.A.
    D4-91-AF   # Electroacustica General Iberica, S.A.
    D4-93-98   # Nokia Corporation
    D4-93-A0   # Fidelix Oy
    D4-94-5A   # COSMO CO., LTD
    D4-94-A1   # Texas Instruments
    D4-94-E8   # HUAWEI TECHNOLOGIES CO.,LTD
    D4-95-24   # Clover Network, Inc.
    D4-96-DF   # SUNGJIN C&T CO.,LTD
    D4-97-0B   # Xiaomi Communications Co Ltd
    D4-9A-20   # Apple, Inc.
    D4-9C-28   # JayBird LLC
    D4-9C-8E   # University of FUKUI
    D4-9E-6D   # Wuhan Zhongyuan Huadian Science & Technology Co.,
    D4-A0-2A   # Cisco Systems, Inc
    D4-A4-25   # SMAX Technology Co., Ltd.
    D4-A4-99   # InView Technology Corporation
    D4-A9-28   # GreenWave Reality Inc
    D4-AA-FF   # MICRO WORLD
    D4-AC-4E   # BODi rS, LLC
    D4-AD-2D   # Fiberhome Telecommunication Tech.Co.,Ltd.
    D4-AE-52   # Dell Inc.
    D4-B1-10   # HUAWEI TECHNOLOGIES CO.,LTD
    D4-B4-3E   # Messcomp Datentechnik GmbH
    D4-B8-FF   # Home Control Singapore Pte Ltd
    D4-BE-D9   # Dell Inc.
    D4-BF-2D   # SE Controls Asia Pacific Ltd
    D4-BF-7F   # UPVEL
    D4-C1-FC   # Nokia Corporation
    D4-C7-66   # Acentic GmbH
    D4-C9-B2   # Quanergy Systems Inc
    D4-C9-EF   # Hewlett Packard
    D4-CA-6D   # Routerboard.com
    D4-CA-6E   # u-blox AG
    D4-CB-AF   # Nokia Corporation
    D4-CE-B8   # Enatel LTD
    D4-CF-F9   # Shenzhen Sen5 Technology Co., Ltd.
    D4-D1-84   # ADB Broadband Italia
    D4-D2-49   # Power Ethernet
    D4-D5-0D   # Southwest Microwave, Inc
    D4-D7-48   # Cisco Systems, Inc
    D4-D7-A9   # Shanghai Kaixiang Info Tech LTD
    D4-D8-98   # Korea CNO Tech Co., Ltd
    D4-D9-19   # GoPro
    D4-DF-57   # Alpinion Medical Systems
    D4-E0-8E   # ValueHD Corporation
    D4-E3-2C   # S. Siedle & Sohne
    D4-E3-3F   # Alcatel-Lucent
    D4-E8-B2   # Samsung Electronics
    D4-EA-0E   # Avaya Inc
    D4-EC-0C   # Harley-Davidson Motor Company
    D4-EC-86   # LinkedHope Intelligent Technologies Co., Ltd
    D4-EE-07   # HIWIFI Co., Ltd.
    D4-F0-27   # Navetas Energy Management
    D4-F0-B4   # Napco Security Technologies
    D4-F1-43   # IPROAD.,Inc
    D4-F4-6F   # Apple, Inc.
    D4-F4-BE   # Palo Alto Networks
    D4-F5-13   # Texas Instruments
    D4-F6-3F   # IEA S.R.L.
    D4-F9-A1   # HUAWEI TECHNOLOGIES CO.,LTD
    D8-00-4D   # Apple, Inc.
    D8-05-2E   # Skyviia Corporation
    D8-06-D1   # Honeywell Fire System (Shanghai) Co,. Ltd.
    D8-08-F5   # Arcadia Networks Co. Ltd.
    D8-09-C3   # Cercacor Labs
    D8-0C-CF   # C.G.V. S.A.S.
    D8-0D-E3   # FXI TECHNOLOGIES AS
    D8-15-0D   # TP-LINK TECHNOLOGIES CO.,LTD.
    D8-16-0A   # Nippon Electro-Sensory Devices
    D8-18-2B   # Conti Temic Microelectronic GmbH
    D8-19-CE   # Telesquare
    D8-1B-FE   # TWINLINX CORPORATION
    D8-1C-14   # Compacta International, Ltd.
    D8-1D-72   # Apple, Inc.
    D8-1E-DE   # B&W Group Ltd
    D8-1F-CC   # Brocade Communications Systems, Inc.
    D8-24-BD   # Cisco Systems, Inc
    D8-25-22   # Pace plc
    D8-26-B9   # Guangdong Coagent Electronics S &T Co., Ltd.
    D8-27-0C   # MaxTronic International Co., Ltd.
    D8-28-C9   # General Electric Consumer and Industrial
    D8-29-16   # Ascent Communication Technology
    D8-29-86   # Best Wish Technology LTD
    D8-2A-15   # Leitner SpA
    D8-2A-7E   # Nokia Corporation
    D8-2D-9B   # Shenzhen G.Credit Communication Technology Co., Ltd
    D8-2D-E1   # Tricascade Inc.
    D8-30-62   # Apple, Inc.
    D8-31-CF   # Samsung Electronics Co.,Ltd
    D8-33-7F   # Office FA.com Co.,Ltd.
    D8-37-BE   # Shanghai Gongjing Telecom Technology Co,LTD
    D8-3C-69   # Shenzhen TINNO Mobile Technology Corp.
    D8-42-AC   # Shanghai Feixun Communication Co.,Ltd.
    D8-46-06   # Silicon Valley Global Marketing
    D8-47-10   # Sichuan Changhong Electric Ltd.
    D8-48-EE   # Hangzhou Xueji Technology Co., Ltd.
    D8-49-0B   # HUAWEI TECHNOLOGIES CO.,LTD
    D8-49-2F   # CANON INC.
    D8-4A-87   # OI ELECTRIC CO.,LTD
    D8-4B-2A   # Cognitas Technologies, Inc.
    D8-50-E6   # ASUSTek COMPUTER INC.
    D8-54-3A   # Texas Instruments
    D8-54-A2   # Aerohive Networks Inc.
    D8-55-A3   # zte corporation
    D8-57-EF   # Samsung Electronics
    D8-58-D7   # CZ.NIC, z.s.p.o.
    D8-5D-4C   # TP-LINK TECHNOLOGIES CO.,LTD.
    D8-5D-84   # CAx soft GmbH
    D8-5D-E2   # Hon Hai Precision Ind. Co.,Ltd.
    D8-5D-EF   # Busch-Jaeger Elektro GmbH
    D8-5D-FB   # Private
    D8-60-B0   # bioMérieux Italia S.p.A.
    D8-61-94   # Objetivos y Sevicios de Valor Añadido
    D8-62-DB   # Eno Inc.
    D8-65-95   # Toy's Myth Inc.
    D8-66-C6   # Shenzhen Daystar Technology Co.,ltd
    D8-66-EE   # BOXIN COMMUNICATION CO.,LTD.
    D8-67-D9   # Cisco Systems, Inc
    D8-69-60   # Steinsvik
    D8-6B-F7   # Nintendo Co., Ltd.
    D8-6C-02   # Huaqin Telecom Technology Co.,Ltd
    D8-6C-E9   # Sagemcom Broadband SAS
    D8-71-57   # Lenovo Mobile Communication Technology Ltd.
    D8-74-95   # zte corporation
    D8-75-33   # Nokia Corporation
    D8-76-0A   # Escort, Inc.
    D8-78-E5   # KUHN SA
    D8-79-88   # Hon Hai Precision Ind. Co.,Ltd.
    D8-7C-DD   # SANIX INCORPORATED
    D8-7E-B1   # x.o.ware, inc.
    D8-80-39   # Microchip Technology Inc.
    D8-81-CE   # AHN INC.
    D8-84-66   # Extreme Networks
    D8-87-D5   # Leadcore Technology CO.,LTD
    D8-88-CE   # RF Technology Pty Ltd
    D8-8A-3B   # UNIT-EM
    D8-8B-4C   # KingTing Tech.
    D8-8D-5C   # Elentec
    D8-90-E8   # Samsung Electronics Co.,Ltd
    D8-93-41   # General Electric Global Research
    D8-95-2F   # Texas Instruments
    D8-96-85   # GoPro
    D8-96-95   # Apple, Inc.
    D8-96-E0   # Alibaba Cloud Computing Ltd.
    D8-97-3B   # Artesyn Embedded Technologies
    D8-97-60   # C2 Development, Inc.
    D8-97-7C   # Grey Innovation
    D8-97-BA   # PEGATRON CORPORATION
    D8-9A-34   # Beijing SHENQI Technology Co., Ltd.
    D8-9D-67   # Hewlett Packard
    D8-9D-B9   # eMegatech International Corp.
    D8-9E-3F   # Apple, Inc.
    D8-A2-5E   # Apple, Inc.
    D8-AD-DD   # Sonavation, Inc.
    D8-AE-90   # Itibia Technologies
    D8-AF-3B   # Hangzhou Bigbright Integrated communications system Co.,Ltd
    D8-AF-F1   # Panasonic Appliances Company
    D8-B0-2E   # Guangzhou Zonerich Business Machine Co., Ltd
    D8-B0-4C   # Jinan USR IOT Technology Co., Ltd.
    D8-B1-2A   # Panasonic Mobile Communications Co., Ltd.
    D8-B1-90   # Cisco Systems, Inc
    D8-B3-77   # HTC Corporation
    D8-B6-B7   # Comtrend Corporation
    D8-B6-C1   # NetworkAccountant, Inc.
    D8-B6-D6   # Blu Tether Limited
    D8-B8-F6   # Nantworks
    D8-B9-0E   # Triple Domain Vision Co.,Ltd.
    D8-BB-2C   # Apple, Inc.
    D8-BF-4C   # Victory Concept Electronics Limited
    D8-C0-68   # Netgenetech.co.,ltd.
    D8-C3-FB   # DETRACOM
    D8-C4-E9   # Samsung Electronics Co.,Ltd
    D8-C6-91   # Hichan Technology Corp.
    D8-C7-C8   # Aruba Networks
    D8-C9-9D   # EA DISPLAY LIMITED
    D8-CB-8A   # Micro-Star INTL CO., LTD.
    D8-CF-9C   # Apple, Inc.
    D8-D1-CB   # Apple, Inc.
    D8-D2-7C   # JEMA ENERGY, SA
    D8-D3-85   # Hewlett Packard
    D8-D4-3C   # Sony Computer Entertainment Inc.
    D8-D5-B9   # Rainforest Automation, Inc.
    D8-D6-7E   # GSK CNC EQUIPMENT CO.,LTD
    D8-DA-52   # APATOR S.A.
    D8-DC-E9   # Kunshan Erlab ductless filtration system Co.,Ltd
    D8-DD-5F   # BALMUDA Inc.
    D8-DD-FD   # Texas Instruments
    D8-DE-CE   # ISUNG CO.,LTD
    D8-DF-0D   # beroNet GmbH
    D8-E3-AE   # CIRTEC MEDICAL SYSTEMS
    D8-E5-6D   # TCT Mobile Limited
    D8-E7-2B   # NetScout Systems, Inc.
    D8-E7-43   # Wush, Inc
    D8-E9-52   # KEOPSYS
    D8-EB-97   # TRENDnet, Inc.
    D8-EE-78   # Moog Protokraft
    D8-EF-CD   # Nokia
    D8-F0-F2   # Zeebo Inc
    D8-F7-10   # Libre Wireless Technologies Inc.
    D8-FB-11   # AXACORE
    D8-FB-5E   # ASKEY COMPUTER CORP
    D8-FC-38   # Giantec Semiconductor Inc
    D8-FC-93   # Intel Corporate
    D8-FE-8F   # IDFone Co., Ltd.
    D8-FE-E3   # D-Link International
    DC-00-77   # TP-LINK TECHNOLOGIES CO.,LTD.
    DC-02-65   # Meditech Kft
    DC-02-8E   # zte corporation
    DC-05-2F   # National Products Inc.
    DC-05-75   # SIEMENS ENERGY AUTOMATION
    DC-05-ED   # Nabtesco  Corporation
    DC-07-C1   # HangZhou QiYang Technology Co.,Ltd.
    DC-09-14   # Talk-A-Phone Co.
    DC-0B-1A   # ADB Broadband Italia
    DC-0E-A1   # COMPAL INFORMATION (KUNSHAN) CO., LTD.
    DC-15-DB   # Ge Ruili Intelligent Technology ( Beijing ) Co., Ltd.
    DC-16-A2   # Medtronic Diabetes
    DC-17-5A   # Hitachi High-Technologies Corporation
    DC-17-92   # Captivate Network
    DC-1D-9F   # U & B tech
    DC-1D-D4   # Microstep-MIS spol. s r.o.
    DC-1E-A3   # Accensus LLC
    DC-20-08   # ASD Electronics Ltd
    DC-2A-14   # Shanghai Longjing Technology Co.
    DC-2B-2A   # Apple, Inc.
    DC-2B-61   # Apple, Inc.
    DC-2B-66   # InfoBLOCK S.A. de C.V.
    DC-2B-CA   # Zera GmbH
    DC-2C-26   # Iton Technology Limited
    DC-2E-6A   # HCT. Co., Ltd.
    DC-2F-03   # Step forward Group Co., Ltd.
    DC-30-9C   # Heyrex Limited
    DC-33-0D   # Qingdao Haier Telecom Co.，Ltd
    DC-33-50   # TechSAT GmbH
    DC-37-14   # Apple, Inc.
    DC-37-D2   # Hunan HKT Electronic Technology Co., Ltd
    DC-38-E1   # Juniper Networks
    DC-39-79   # Skyport Systems
    DC-3A-5E   # Roku, Inc.
    DC-3C-2E   # Manufacturing System Insights, Inc.
    DC-3C-84   # Ticom Geomatics, Inc.
    DC-3C-F6   # Atomic Rules LLC
    DC-3E-51   # Solberg & Andersen AS
    DC-3E-F8   # Nokia Corporation
    DC-41-5F   # Apple, Inc.
    DC-44-27   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    DC-44-6D   # Allwinner Technology Co., Ltd
    DC-45-17   # ARRIS Group, Inc.
    DC-49-C9   # CASCO SIGNAL LTD
    DC-4A-3E   # Hewlett Packard
    DC-4E-DE   # SHINYEI TECHNOLOGY CO., LTD.
    DC-53-60   # Intel Corporate
    DC-53-7C   # Compal Broadband Networks, Inc.
    DC-56-E6   # Shenzhen Bococom Technology Co.,LTD
    DC-57-26   # Power-One
    DC-5E-36   # Paterson Technology
    DC-60-A1   # Teledyne DALSA Professional Imaging
    DC-64-7C   # C.R.S. iiMotion GmbH
    DC-64-B8   # Shenzhen JingHanDa Electronics Co.Ltd
    DC-66-3A   # Apacer Technology Inc.
    DC-6D-CD   # GUANGDONG OPPO MOBILE TELECOMMUNICATIONS CORP.,LTD
    DC-6F-00   # Livescribe, Inc.
    DC-6F-08   # Bay Storage Technology
    DC-70-14   # Private
    DC-71-44   # Samsung Electro Mechanics
    DC-7B-94   # Cisco Systems, Inc
    DC-7F-A4   # 2Wire Inc
    DC-82-5B   # JANUS, spol. s r.o.
    DC-82-F6   # iPort
    DC-85-DE   # AzureWave Technology Inc.
    DC-86-D8   # Apple, Inc.
    DC-9A-8E   # Nanjing Cocomm electronics co., LTD
    DC-9B-1E   # Intercom, Inc.
    DC-9B-9C   # Apple, Inc.
    DC-9C-52   # Sapphire Technology Limited.
    DC-9F-A4   # Nokia Corporation
    DC-9F-DB   # Ubiquiti Networks, Inc.
    DC-A3-AC   # RBcloudtech
    DC-A5-F4   # Cisco Systems, Inc
    DC-A6-BD   # Beijing Lanbo Technology Co., Ltd.
    DC-A7-D9   # Compressor Controls Corp
    DC-A8-CF   # New Spin Golf, LLC.
    DC-A9-71   # Intel Corporate
    DC-A9-89   # MACANDC
    DC-AD-9E   # GreenPriz
    DC-AE-04   # CELOXICA Ltd
    DC-B0-58   # Bürkert Werke GmbH
    DC-B3-B4   # Honeywell Environmental & Combustion Controls (Tianjin) Co., Ltd.
    DC-B4-C4   # Microsoft XCG
    DC-BF-90   # HUIZHOU QIAOXING TELECOMMUNICATION INDUSTRY CO.,LTD.
    DC-C0-DB   # Shenzhen Kaiboer Technology Co., Ltd.
    DC-C0-EB   # ASSA ABLOY CÔTE PICARDE
    DC-C1-01   # SOLiD Technologies, Inc.
    DC-C4-22   # Systembase Limited
    DC-C6-22   # BUHEUNG SYSTEM
    DC-C7-93   # Nokia Corporation
    DC-CB-A8   # Explora Technologies Inc
    DC-CE-41   # FE GLOBAL HONG KONG LIMITED
    DC-CE-BC   # Shenzhen JSR Technology Co.,Ltd.
    DC-CE-C1   # Cisco Systems, Inc
    DC-CF-94   # Beijing Rongcheng Hutong Technology Co., Ltd.
    DC-D0-F7   # Bentek Systems Ltd.
    DC-D2-FC   # HUAWEI TECHNOLOGIES CO.,LTD
    DC-D3-21   # HUMAX Co., Ltd.
    DC-D5-2A   # Sunny Heart Limited
    DC-D8-7C   # Beijing Jingdong Century Trading Co., LTD.
    DC-D8-7F   # Shenzhen JoinCyber Telecom Equipment Ltd
    DC-DA-4F   # GETCK TECHNOLOGY,  INC
    DC-DB-70   # Tonfunk Systementwicklung und Service GmbH
    DC-DC-07   # TRP Systems BV
    DC-DE-CA   # Akyllor
    DC-E0-26   # Patrol Tag, Inc
    DC-E1-AD   # Shenzhen Wintop Photoelectric Technology Co., Ltd
    DC-E2-AC   # Lumens Digital Optics Inc.
    DC-E5-78   # Experimental Factory of Scientific Engineering and Special Design Department
    DC-E7-1C   # AUG Elektronik GmbH
    DC-EB-94   # Cisco Systems, Inc
    DC-EC-06   # Heimi Network Technology Co., Ltd.
    DC-EF-09   # NETGEAR
    DC-F0-5D   # Letta Teknoloji
    DC-F1-10   # Nokia Corporation
    DC-F7-55   # SITRONIK
    DC-F8-58   # Lorent Networks, Inc.
    DC-FA-D5   # STRONG Ges.m.b.H.
    DC-FB-02   # BUFFALO.INC
    DC-FE-07   # PEGATRON CORPORATION
    E0-03-70   # ShenZhen Continental Wireless Technology Co., Ltd.
    E0-05-C5   # TP-LINK TECHNOLOGIES CO.,LTD.
    E0-06-E6   # Hon Hai Precision Ind. Co.,Ltd.
    E0-0B-28   # Inovonics
    E0-0C-7F   # Nintendo Co., Ltd.
    E0-0D-B9   # Private
    E0-10-7F   # Ruckus Wireless
    E0-14-3E   # Modoosis Inc.
    E0-18-77   # FUJITSU LIMITED
    E0-19-1D   # HUAWEI TECHNOLOGIES CO.,LTD
    E0-1A-EA   # Allied Telesis, Inc.
    E0-1C-41   # Aerohive Networks Inc.
    E0-1C-EE   # Bravo Tech, Inc.
    E0-1D-38   # Beijing HuaqinWorld Technology Co.,Ltd
    E0-1D-3B   # Cambridge Industries(Group) Co.,Ltd.
    E0-1E-07   # Anite Telecoms  US. Inc
    E0-1F-0A   # Xslent Energy Technologies. LLC
    E0-24-7F   # HUAWEI TECHNOLOGIES CO.,LTD
    E0-25-38   # Titan Pet Products
    E0-26-30   # Intrigue Technologies, Inc.
    E0-26-36   # Nortel Networks
    E0-27-1A   # TTC Next-generation Home Network System WG
    E0-28-61   # HUAWEI TECHNOLOGIES CO.,LTD
    E0-2A-82   # Universal Global Scientific Industrial Co., Ltd.
    E0-2C-B2   # Lenovo Mobile Communication (Wuhan) Company Limited
    E0-2F-6D   # Cisco Systems, Inc
    E0-30-05   # Alcatel-Lucent Shanghai Bell Co., Ltd
    E0-31-9E   # Valve Corporation
    E0-31-D0   # SZ Telstar CO., LTD
    E0-34-E4   # Feit Electric Company, Inc.
    E0-35-60   # Challenger Supply Holdings, LLC
    E0-36-76   # HUAWEI TECHNOLOGIES CO.,LTD
    E0-36-E3   # Stage One International Co., Ltd.
    E0-39-D7   # Plexxi, Inc.
    E0-3C-5B   # SHENZHEN JIAXINJIE ELECTRON CO.,LTD
    E0-3E-44   # Broadcom
    E0-3E-4A   # Cavanagh Group International
    E0-3E-7D   # data-complex GmbH
    E0-3F-49   # ASUSTek COMPUTER INC.
    E0-41-36   # MitraStar Technology Corp.
    E0-43-DB   # Shenzhen ViewAt Technology Co.,Ltd.
    E0-46-9A   # NETGEAR
    E0-4B-45   # Hi-P Electronics Pte Ltd
    E0-4F-BD   # SICHUAN TIANYI COMHEART TELECOMCO.,LTD
    E0-55-3D   # Cisco Meraki
    E0-55-97   # Emergent Vision Technologies Inc.
    E0-56-F4   # AxesNetwork Solutions inc.
    E0-58-9E   # Laerdal Medical
    E0-5B-70   # Innovid, Co., Ltd.
    E0-5D-A6   # Detlef Fink Elektronik & Softwareentwicklung
    E0-5F-B9   # Cisco Systems, Inc
    E0-60-66   # Sercomm Corporation
    E0-61-B2   # HANGZHOU ZENOINTEL TECHNOLOGY CO., LTD
    E0-62-90   # Jinan Jovision Science & Technology Co., Ltd.
    E0-63-E5   # Sony Mobile Communications AB
    E0-64-BB   # DigiView S.r.l.
    E0-66-78   # Apple, Inc.
    E0-67-B3   # C-Data Technology Co., Ltd
    E0-69-95   # PEGATRON CORPORATION
    E0-75-0A   # ALPS ELECTRIC CO.,LTD.
    E0-75-7D   # Motorola Mobility LLC, a Lenovo Company
    E0-76-D0   # AMPAK Technology, Inc.
    E0-7C-62   # Whistle Labs, Inc.
    E0-7F-53   # TECHBOARD SRL
    E0-7F-88   # EVIDENCE Network SIA
    E0-81-77   # GreenBytes, Inc.
    E0-87-B1   # Nata-Info Ltd.
    E0-88-5D   # Technicolor CH USA
    E0-89-9D   # Cisco Systems, Inc
    E0-8A-7E   # Exponent
    E0-8E-3C   # Aztech Electronics Pte Ltd
    E0-8F-EC   # REPOTEC CO., LTD.
    E0-91-53   # XAVi Technologies Corp.
    E0-91-F5   # NETGEAR
    E0-94-67   # Intel Corporate
    E0-95-79   # ORTHOsoft inc, d/b/a Zimmer CAS
    E0-97-96   # HUAWEI TECHNOLOGIES CO.,LTD
    E0-97-F2   # Atomax Inc.
    E0-98-61   # Motorola Mobility LLC, a Lenovo Company
    E0-99-71   # Samsung Electronics Co.,Ltd
    E0-9D-31   # Intel Corporate
    E0-9D-B8   # PLANEX COMMUNICATIONS INC.
    E0-A1-98   # NOJA Power Switchgear Pty Ltd
    E0-A1-D7   # SFR
    E0-A3-0F   # Pevco
    E0-A6-70   # Nokia Corporation
    E0-AA-B0   # GENERAL VISION ELECTRONICS CO. LTD.
    E0-AB-FE   # Orb Networks, Inc.
    E0-AC-CB   # Apple, Inc.
    E0-AC-F1   # Cisco Systems, Inc
    E0-AE-5E   # ALPS ELECTRIC CO.,LTD.
    E0-AE-B2   # Bender GmbH &amp; Co.KG
    E0-AE-ED   # LOENK
    E0-AF-4B   # Pluribus Networks, Inc.
    E0-B2-F1   # FN-LINK TECHNOLOGY LIMITED
    E0-B5-2D   # Apple, Inc.
    E0-B7-0A   # ARRIS Group, Inc.
    E0-B7-B1   # Pace plc
    E0-B9-A5   # AzureWave Technology Inc.
    E0-B9-BA   # Apple, Inc.
    E0-B9-E5   # Technicolor
    E0-BC-43   # C2 Microsystems, Inc.
    E0-C2-86   # Aisai Communication Technology Co., Ltd.
    E0-C2-B7   # Masimo Corporation
    E0-C3-F3   # zte corporation
    E0-C6-B3   # MilDef AB
    E0-C7-67   # Apple, Inc.
    E0-C7-9D   # Texas Instruments
    E0-C8-6A   # SHENZHEN TW-SCIE Co., Ltd
    E0-C9-22   # Jireh Energy Tech., Ltd.
    E0-C9-7A   # Apple, Inc.
    E0-CA-4D   # Shenzhen Unistar Communication Co.,LTD
    E0-CA-94   # ASKEY COMPUTER CORP
    E0-CB-1D   # Private
    E0-CB-4E   # ASUSTek COMPUTER INC.
    E0-CB-EE   # Samsung Electronics Co.,Ltd
    E0-CE-C3   # ASKEY COMPUTER CORP
    E0-CF-2D   # Gemintek Corporation
    E0-D1-0A   # Katoudenkikougyousyo co ltd
    E0-D1-73   # Cisco Systems, Inc
    E0-D1-E6   # Aliph dba Jawbone
    E0-D3-1A   # EQUES Technology Co., Limited
    E0-D7-BA   # Texas Instruments
    E0-D9-A2   # Hippih aps
    E0-DA-DC   # JVC KENWOOD Corporation
    E0-DB-10   # Samsung Electronics Co.,Ltd
    E0-DB-55   # Dell Inc.
    E0-DB-88   # Open Standard Digital-IF Interface for SATCOM Systems
    E0-DC-A0   # Siemens Electrical Apparatus Ltd., Suzhou Chengdu Branch
    E0-E5-CF   # Texas Instruments
    E0-E6-31   # SNB TECHNOLOGIES LIMITED
    E0-E7-51   # Nintendo Co., Ltd.
    E0-E8-E8   # Olive Telecommunication Pvt. Ltd
    E0-ED-1A   # vastriver Technology Co., Ltd
    E0-ED-C7   # Shenzhen Friendcom Technology Development Co., Ltd
    E0-EE-1B   # Panasonic Automotive Systems Company of America
    E0-EF-25   # Lintes Technology Co., Ltd.
    E0-F2-11   # Digitalwatt
    E0-F3-79   # Vaddio
    E0-F5-C6   # Apple, Inc.
    E0-F5-CA   # CHENG UEI PRECISION INDUSTRY CO.,LTD.
    E0-F8-47   # Apple, Inc.
    E0-F9-BE   # Cloudena Corp.
    E0-FA-EC   # Platan sp. z o.o. sp. k.
    E0-FF-F7   # Softiron Inc.
    E4-04-39   # TomTom Software Ltd
    E4-11-5B   # Hewlett Packard
    E4-12-18   # ShenZhen Rapoo Technology Co., Ltd.
    E4-12-1D   # Samsung Electronics Co.,Ltd
    E4-12-89   # topsystem Systemhaus GmbH
    E4-1A-2C   # ZPE Systems, Inc.
    E4-1C-4B   # V2 TECHNOLOGY, INC.
    E4-1D-2D   # Mellanox Technologies, Inc.
    E4-1F-13   # IBM Corp
    E4-22-A5   # PLANTRONICS, INC.
    E4-23-54   # SHENZHEN FUZHI SOFTWARE TECHNOLOGY CO.,LTD
    E4-25-E7   # Apple, Inc.
    E4-25-E9   # Color-Chip
    E4-27-71   # Smartlabs
    E4-2A-D3   # Magneti Marelli S.p.A. Powertrain
    E4-2C-56   # Lilee Systems, Ltd.
    E4-2D-02   # TCT Mobile Limited
    E4-2F-26   # Fiberhome Telecommunication Tech.Co.,Ltd.
    E4-2F-F6   # Unicore communication Inc.
    E4-32-CB   # Samsung Electronics Co.,Ltd
    E4-35-93   # Hangzhou GoTo technology Co.Ltd
    E4-35-C8   # HUAWEI TECHNOLOGIES CO.,LTD
    E4-35-FB   # Sabre Technology (Hull) Ltd
    E4-37-D7   # HENRI DEPAEPE S.A.S.
    E4-38-F2   # Advantage Controls
    E4-3F-A2   # Wuxi DSP Technologies Inc.
    E4-40-E2   # Samsung Electronics Co.,Ltd
    E4-41-E6   # Ottec Technology GmbH
    E4-46-BD   # C&C TECHNIC TAIWAN CO., LTD.
    E4-48-C7   # Cisco SPVTG
    E4-4C-6C   # Shenzhen Guo Wei Electronic Co,. Ltd.
    E4-4E-18   # Gardasoft VisionLimited
    E4-4F-29   # MA Lighting Technology GmbH
    E4-4F-5F   # EDS Elektronik Destek San.Tic.Ltd.Sti
    E4-55-EA   # Dedicated Computing
    E4-56-14   # Suttle Apparatus
    E4-57-A8   # Stuart Manufacturing, Inc.
    E4-58-B8   # Samsung Electronics Co.,Ltd
    E4-58-E7   # Samsung Electronics Co.,Ltd
    E4-5A-A2   # vivo Mobile Communication Co., Ltd.
    E4-5D-52   # Avaya Inc
    E4-5D-75   # Samsung Electronics Co.,Ltd
    E4-64-49   # ARRIS Group, Inc.
    E4-67-BA   # Danish Interpretation Systems A/S
    E4-68-A3   # HUAWEI TECHNOLOGIES CO.,LTD
    E4-69-5A   # Dictum Health, Inc.
    E4-6C-21   # messMa GmbH
    E4-6F-13   # D-Link International
    E4-71-85   # Securifi Ltd
    E4-75-1E   # Getinge Sterilization AB
    E4-77-23   # zte corporation
    E4-77-6B   # AARTESYS AG
    E4-77-D4   # Minrray Industry Co.,Ltd
    E4-7C-F9   # Samsung Electronics Co., LTD
    E4-7D-5A   # Beijing Hanbang Technology Corp.
    E4-7F-B2   # FUJITSU LIMITED
    E4-81-84   # Alcatel-Lucent
    E4-81-B3   # Shenzhen ACT Industrial Co.,Ltd.
    E4-83-99   # ARRIS Group, Inc.
    E4-85-01   # Geberit International AG
    E4-8A-D5   # RF WINDOW CO., LTD.
    E4-8B-7F   # Apple, Inc.
    E4-8C-0F   # Discovery Insure
    E4-8D-8C   # Routerboard.com
    E4-90-69   # Rockwell Automation
    E4-90-7E   # Motorola Mobility LLC, a Lenovo Company
    E4-92-E7   # Gridlink Tech. Co.,Ltd.
    E4-92-FB   # Samsung Electronics Co.,Ltd
    E4-95-6E   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    E4-96-AE   # ALTOGRAPHICS Inc.
    E4-97-F0   # Shanghai VLC Technologies Ltd. Co.
    E4-98-D1   # Microsoft Mobile Oy
    E4-98-D6   # Apple, Inc.
    E4-9A-79   # Apple, Inc.
    E4-A3-2F   # Shanghai Artimen Technology Co., Ltd.
    E4-A3-87   # Control Solutions LLC
    E4-A5-EF   # TRON LINK ELECTRONICS CO., LTD.
    E4-A7-FD   # Cellco Partnership
    E4-AA-5D   # Cisco Systems, Inc
    E4-AB-46   # UAB Selteka
    E4-AD-7D   # SCL Elements
    E4-AF-A1   # HES-SO
    E4-B0-21   # Samsung Electronics Co.,Ltd
    E4-BA-D9   # 360 Fly Inc.
    E4-C1-46   # Objetivos y Servicios de Valor A
    E4-C2-D1   # HUAWEI TECHNOLOGIES CO.,LTD
    E4-C6-2B   # Airware
    E4-C6-3D   # Apple, Inc.
    E4-C6-E6   # Mophie, LLC
    E4-C7-22   # Cisco Systems, Inc
    E4-C8-06   # Ceiec Electric Technology Inc.
    E4-CE-02   # WyreStorm Technologies Ltd
    E4-CE-70   # Health & Life co., Ltd.
    E4-CE-8F   # Apple, Inc.
    E4-D3-32   # TP-LINK TECHNOLOGIES CO.,LTD.
    E4-D3-F1   # Cisco Systems, Inc
    E4-D5-3D   # Hon Hai Precision Ind. Co.,Ltd.
    E4-D7-1D   # Oraya Therapeutics
    E4-DD-79   # En-Vision America, Inc.
    E4-E0-C5   # Samsung Electronics Co., LTD
    E4-E4-09   # LEIFHEIT AG
    E4-EC-10   # Nokia Corporation
    E4-EE-FD   # MR&D Manufacturing
    E4-F3-65   # Time-O-Matic, Inc.
    E4-F3-E3   # Shanghai iComhome Co.,Ltd.
    E4-F4-C6   # NETGEAR
    E4-F7-A1   # Datafox GmbH
    E4-F8-9C   # Intel Corporate
    E4-F8-EF   # Samsung Electronics Co.,Ltd
    E4-F9-39   # Minxon Hotel Technology INC.
    E4-FA-1D   # PAD Peripheral Advanced Design Inc.
    E4-FA-FD   # Intel Corporate
    E4-FE-D9   # EDMI Europe Ltd
    E4-FF-DD   # ELECTRON INDIA
    E8-03-9A   # Samsung Electronics CO., LTD
    E8-04-0B   # Apple, Inc.
    E8-04-10   # Private
    E8-04-62   # Cisco Systems, Inc
    E8-04-F3   # Throughtek Co., Ltd.
    E8-05-6D   # Nortel Networks
    E8-06-88   # Apple, Inc.
    E8-07-34   # Champion Optical Network Engineering, LLC
    E8-07-BF   # SHENZHEN BOOMTECH INDUSTRY CO.,LTD
    E8-08-8B   # HUAWEI TECHNOLOGIES CO.,LTD
    E8-0B-13   # Akib Systems Taiwan, INC
    E8-0C-38   # DAEYOUNG INFORMATION SYSTEM CO., LTD
    E8-0C-75   # Syncbak, Inc.
    E8-10-2E   # Really Simple Software, Inc
    E8-11-32   # Samsung Electronics CO., LTD
    E8-13-24   # GuangZhou Bonsoninfo System CO.,LTD
    E8-13-63   # Comstock RD, Inc.
    E8-15-0E   # Nokia Corporation
    E8-16-2B   # IDEO Security Co., Ltd.
    E8-17-FC   # NIFTY Corporation
    E8-18-63   # IEEE REGISTRATION AUTHORITY  - Please see MAM public listing for more information.
    E8-28-77   # TMY Co., Ltd.
    E8-28-D5   # Cots Technology
    E8-2A-EA   # Intel Corporate
    E8-2E-24   # Out of the Fog Research LLC
    E8-33-81   # ARRIS Group, Inc.
    E8-34-3E   # Beijing Infosec Technologies Co., LTD.
    E8-37-7A   # ZyXEL Communications Corporation
    E8-39-35   # Hewlett Packard
    E8-39-DF   # ASKEY COMPUTER CORP
    E8-3A-12   # Samsung Electronics Co.,Ltd
    E8-3A-97   # OCZ Technology Group
    E8-3E-B6   # RIM
    E8-3E-FB   # GEODESIC LTD.
    E8-3E-FC   # ARRIS Group, Inc.
    E8-40-40   # Cisco Systems, Inc
    E8-40-F2   # PEGATRON CORPORATION
    E8-43-B6   # QNAP Systems, Inc.
    E8-44-7E   # Bitdefender SRL
    E8-48-1F   # Advanced Automotive Antennas
    E8-4D-D0   # HUAWEI TECHNOLOGIES CO.,LTD
    E8-4E-06   # EDUP INTERNATIONAL (HK) CO., LTD
    E8-4E-84   # Samsung Electronics Co.,Ltd
    E8-4E-CE   # Nintendo Co., Ltd.
    E8-50-8B   # Samsung Electro Mechanics co., LTD.
    E8-51-6E   # TSMART Inc.
    E8-51-9D   # Yeonhab Precision Co.,LTD
    E8-54-84   # NEO Information Systems Co., Ltd.
    E8-55-B4   # SAI Technology Inc.
    E8-56-D6   # NCTech Ltd
    E8-5A-A7   # LLC Emzior
    E8-5B-5B   # LG ELECTRONICS INC
    E8-5B-F0   # Imaging Diagnostics
    E8-5D-6B   # Luminate Wireless
    E8-5E-53   # Infratec Datentechnik GmbH
    E8-61-1F   # Dawning Information Industry Co.,Ltd
    E8-61-7E   # Liteon Technology Corporation
    E8-61-83   # Black Diamond Advanced Technology, LLC
    E8-61-BE   # Melec Inc.
    E8-65-49   # Cisco Systems, Inc
    E8-66-C4   # Datawise Systems
    E8-6C-DA   # Supercomputers and Neurocomputers Research Center
    E8-6D-52   # ARRIS Group, Inc.
    E8-6D-54   # Digit Mobile Inc
    E8-6D-6E   # voestalpine SIGNALING Fareham Ltd.
    E8-71-8D   # Elsys Equipamentos Eletronicos Ltda
    E8-74-E6   # ADB Broadband Italia
    E8-75-7F   # FIRS Technologies(Shenzhen) Co., Ltd
    E8-78-A1   # BEOVIEW INTERCOM DOO
    E8-7A-F3   # S5 Tech S.r.l.
    E8-80-2E   # Apple, Inc.
    E8-80-D8   # GNTEK Electronics Co.,Ltd.
    E8-87-A3   # Loxley Public Company Limited
    E8-89-2C   # ARRIS Group, Inc.
    E8-8D-28   # Apple, Inc.
    E8-8D-F5   # ZNYX Networks, Inc.
    E8-8E-60   # NSD Corporation
    E8-91-20   # Motorola Mobility LLC, a Lenovo Company
    E8-92-18   # Arcontia International AB
    E8-92-A4   # LG Electronics
    E8-94-4C   # Cogent Healthcare Systems Ltd
    E8-94-F6   # TP-LINK TECHNOLOGIES CO.,LTD.
    E8-96-06   # testo Instruments (Shenzhen) Co., Ltd.
    E8-99-5A   # PiiGAB, Processinformation i Goteborg AB
    E8-99-C4   # HTC Corporation
    E8-9A-8F   # Quanta Computer Inc.
    E8-9A-FF   # Fujian Landi Commercial Equipment Co.,Ltd
    E8-9D-87   # Toshiba
    E8-A3-64   # Signal Path International / Peachtree Audio
    E8-A4-C1   # Deep Sea Electronics PLC
    E8-AB-FA   # Shenzhen Reecam Tech.Ltd.
    E8-B1-FC   # Intel Corporate
    E8-B2-AC   # Apple, Inc.
    E8-B4-AE   # Shenzhen C&D Electronics Co.,Ltd
    E8-B4-C8   # Samsung Electronics Co.,Ltd
    E8-B7-48   # Cisco Systems, Inc
    E8-BA-70   # Cisco Systems, Inc
    E8-BB-3D   # Sino Prime-Tech Limited
    E8-BB-A8   # GUANGDONG OPPO MOBILE TELECOMMUNICATIONS CORP.,LTD
    E8-BD-D1   # HUAWEI TECHNOLOGIES CO.,LTD
    E8-BE-81   # Sagemcom Broadband SAS
    E8-C2-29   # H-Displays (MSC) Bhd
    E8-C3-20   # Austco Communication Systems Pty Ltd
    E8-C7-4F   # Liteon Technology Corporation
    E8-CB-A1   # Nokia Corporation
    E8-CC-18   # D-Link International
    E8-CC-32   # Micronet  LTD
    E8-CD-2D   # HUAWEI TECHNOLOGIES CO.,LTD
    E8-CE-06   # SkyHawke Technologies, LLC.
    E8-D0-FA   # MKS Instruments Deutschland GmbH
    E8-D4-83   # ULTIMATE Europe Transportation Equipment GmbH
    E8-D4-E0   # Beijing BenyWave Technology Co., Ltd.
    E8-DA-96   # Zhuhai Tianrui Electrical Power Tech. Co., Ltd.
    E8-DA-AA   # VideoHome Technology Corp.
    E8-DE-27   # TP-LINK TECHNOLOGIES CO.,LTD.
    E8-DE-D6   # Intrising Networks, Inc.
    E8-DF-F2   # PRF Co., Ltd.
    E8-E0-8F   # GRAVOTECH MARKING SAS
    E8-E0-B7   # Toshiba
    E8-E1-E2   # Energotest
    E8-E5-D6   # Samsung Electronics Co.,Ltd
    E8-E7-32   # Alcatel-Lucent
    E8-E7-70   # Warp9 Tech Design, Inc.
    E8-E7-76   # Shenzhen Kootion Technology Co., Ltd
    E8-E8-75   # iS5 Communications Inc.
    E8-EA-6A   # StarTech.com
    E8-EA-DA   # Denkovi Assembly Electroncs LTD
    E8-ED-05   # ARRIS Group, Inc.
    E8-ED-F3   # Cisco Systems, Inc
    E8-EF-89   # OPMEX Tech.
    E8-F1-B0   # Sagemcom Broadband SAS
    E8-F2-26   # MILLSON CUSTOM SOLUTIONS INC.
    E8-F2-E2   # LG Innotek
    E8-F2-E3   # Starcor Beijing Co.,Limited
    E8-F7-24   # Hewlett Packard Enterprise
    E8-F9-28   # RFTECH SRL
    E8-FC-60   # ELCOM Innovations Private Limited
    E8-FC-AF   # NETGEAR
    EC-01-33   # TRINUS SYSTEMS INC.
    EC-08-6B   # TP-LINK TECHNOLOGIES CO.,LTD.
    EC-0E-C4   # Hon Hai Precision Ind. Co.,Ltd.
    EC-0E-D6   # ITECH INSTRUMENTS SAS
    EC-11-20   # FloDesign Wind Turbine Corporation
    EC-11-27   # Texas Instruments
    EC-13-B2   # Netonix
    EC-14-F6   # BioControl AS
    EC-17-2F   # TP-LINK TECHNOLOGIES CO.,LTD.
    EC-17-66   # Research Centre Module
    EC-1A-59   # Belkin International Inc.
    EC-1D-7F   # zte corporation
    EC-1F-72   # Samsung Electro Mechanics co., LTD.
    EC-21-9F   # VidaBox LLC
    EC-21-E5   # Toshiba
    EC-22-57   # JiangSu NanJing University Electronic Information Technology Co.,Ltd
    EC-22-80   # D-Link International
    EC-23-3D   # HUAWEI TECHNOLOGIES CO.,LTD
    EC-23-68   # IntelliVoice Co.,Ltd.
    EC-24-B8   # Texas Instruments
    EC-26-CA   # TP-LINK TECHNOLOGIES CO.,LTD.
    EC-2A-F0   # Ypsomed AG
    EC-2C-49   # University of Tokyo
    EC-2E-4E   # HITACHI-LG DATA STORAGE INC
    EC-30-91   # Cisco Systems, Inc
    EC-35-86   # Apple, Inc.
    EC-38-8F   # HUAWEI TECHNOLOGIES CO.,LTD
    EC-3B-F0   # NovelSat
    EC-3C-5A   # SHEN ZHEN HENG SHENG HUI DIGITAL TECHNOLOGY CO.,LTD
    EC-3C-88   # MCNEX Co.,Ltd.
    EC-3E-09   # PERFORMANCE DESIGNED PRODUCTS, LLC
    EC-3E-F7   # Juniper Networks
    EC-3F-05   # Institute 706, The Second Academy China Aerospace Science & Industry Corp
    EC-42-F0   # ADL Embedded Solutions, Inc.
    EC-43-E6   # AWCER Ltd.
    EC-43-F6   # ZyXEL Communications Corporation
    EC-44-76   # Cisco Systems, Inc
    EC-46-44   # TTK SAS
    EC-46-70   # Meinberg Funkuhren GmbH & Co. KG
    EC-47-3C   # Redwire, LLC
    EC-49-93   # Qihan Technology Co., Ltd
    EC-4C-4D   # ZAO NPK RoTeK
    EC-4D-47   # HUAWEI TECHNOLOGIES CO.,LTD
    EC-4F-82   # Calix Inc.
    EC-52-DC   # WORLD MEDIA AND TECHNOLOGY Corp.
    EC-54-2E   # Shanghai XiMei Electronic Technology Co. Ltd
    EC-55-F9   # Hon Hai Precision Ind. Co.,Ltd.
    EC-59-E7   # Microsoft Corporation
    EC-5A-86   # Yulong Computer Telecommunication Scientific (Shenzhen) Co.,Ltd
    EC-5C-69   # MITSUBISHI HEAVY INDUSTRIES MECHATRONICS SYSTEMS,LTD.
    EC-5F-23   # Qinghai Kimascend Electronics Technology Co. Ltd.
    EC-60-E0   # AVI-ON LABS
    EC-62-64   # Global411 Internet Services, LLC
    EC-63-E5   # ePBoard Design LLC
    EC-64-E7   # MOCACARE Corporation
    EC-66-D1   # B&W Group LTD
    EC-6C-9F   # Chengdu Volans Technology CO.,LTD
    EC-71-DB   # Shenzhen Baichuan Digital Technology Co., Ltd.
    EC-74-BA   # Hirschmann Automation and Control GmbH
    EC-7C-74   # Justone Technologies Co., Ltd.
    EC-7D-9D   # MEI
    EC-80-09   # NovaSparks
    EC-83-6C   # RM Tech Co., Ltd.
    EC-85-2F   # Apple, Inc.
    EC-88-8F   # TP-LINK TECHNOLOGIES CO.,LTD.
    EC-88-92   # Motorola Mobility LLC, a Lenovo Company
    EC-89-F5   # Lenovo Mobile Communication Technology Ltd.
    EC-8A-4C   # zte corporation
    EC-8E-AD   # DLX
    EC-92-33   # Eddyfi NDT Inc
    EC-93-27   # MEMMERT GmbH + Co. KG
    EC-96-81   # 2276427 Ontario Inc
    EC-98-6C   # Lufft Mess- und Regeltechnik GmbH
    EC-98-C1   # Beijing Risbo Network Technology Co.,Ltd
    EC-9A-74   # Hewlett Packard
    EC-9B-5B   # Nokia Corporation
    EC-9B-F3   # Samsung Electro Mechanics co., LTD.
    EC-9E-CD   # Artesyn Embedded Technologies
    EC-A2-9B   # Kemppi Oy
    EC-A8-6B   # ELITEGROUP COMPUTER SYSTEMS CO., LTD.
    EC-A9-FA   # GUANGDONG GENIUS TECHNOLOGY CO.,LTD.
    EC-B1-06   # Acuro Networks, Inc
    EC-B1-D7   # Hewlett Packard
    EC-B5-41   # SHINANO E and E Co.Ltd.
    EC-B8-70   # Beijing Heweinet Technology Co.,Ltd.
    EC-B9-07   # CloudGenix Inc
    EC-BA-FE   # GIROPTIC
    EC-BB-AE   # Digivoice Tecnologia em Eletronica Ltda
    EC-BD-09   # FUSION Electronics Ltd
    EC-BD-1D   # Cisco Systems, Inc
    EC-C3-8A   # Accuenergy (CANADA) Inc
    EC-C8-82   # Cisco Systems, Inc
    EC-CB-30   # HUAWEI TECHNOLOGIES CO.,LTD
    EC-CD-6D   # Allied Telesis, Inc.
    EC-D0-0E   # MiraeRecognition Co., Ltd.
    EC-D0-40   # GEA Farm Technologies GmbH
    EC-D1-9A   # Zhuhai Liming Industries Co., Ltd
    EC-D9-25   # RAMI
    EC-D9-50   # IRT SA
    EC-D9-D1   # Shenzhen TG-NET Botone Technology Co.,Ltd.
    EC-DE-3D   # Lamprey Networks, Inc.
    EC-DF-3A   # vivo Mobile Communication Co., Ltd.
    EC-E0-9B   # Samsung electronics CO., LTD
    EC-E1-A9   # Cisco Systems, Inc
    EC-E2-FD   # SKG Electric Group(Thailand) Co., Ltd.
    EC-E5-12   # tado GmbH
    EC-E5-55   # Hirschmann Automation
    EC-E7-44   # Omntec mfg. inc
    EC-E9-0B   # SISTEMA SOLUCOES ELETRONICAS LTDA - EASYTECH
    EC-E9-15   # STI Ltd
    EC-E9-F8   # Guang Zhou TRI-SUN Electronics Technology  Co., Ltd
    EC-EA-03   # DARFON LIGHTING CORP
    EC-EE-D8   # ZTLX Network Technology Co.,Ltd
    EC-F0-0E   # AboCom
    EC-F2-36   # NEOMONTANA ELECTRONICS
    EC-F3-5B   # Nokia Corporation
    EC-F4-BB   # Dell Inc.
    EC-F7-2B   # HD DIGITAL TECH CO., LTD.
    EC-FA-AA   # The IMS Company
    EC-FC-55   # A. Eberle GmbH & Co. KG
    EC-FE-7E   # BlueRadios, Inc.
    F0-00-7F   # Janz - Contadores de Energia, SA
    F0-02-2B   # Chrontel
    F0-02-48   # SmarteBuilding
    F0-07-86   # Shandong Bittel Electronics Co., Ltd
    F0-08-F1   # Samsung Electronics Co.,Ltd
    F0-0D-5C   # JinQianMao  Technology Co.,Ltd.
    F0-13-C3   # SHENZHEN FENDA TECHNOLOGY CO., LTD
    F0-15-A0   # KyungDong One Co., Ltd.
    F0-18-2B   # LG Chem
    F0-1B-6C   # vivo Mobile Communication Co., Ltd.
    F0-1C-13   # LG Electronics
    F0-1C-2D   # Juniper Networks
    F0-1E-34   # ORICO Technologies Co., Ltd
    F0-1F-AF   # Dell Inc.
    F0-21-9D   # Cal-Comp Electronics & Communications Company Ltd.
    F0-22-4E   # Esan electronic co.
    F0-23-29   # SHOWA DENKI CO.,LTD.
    F0-24-05   # OPUS High Technology Corporation
    F0-24-08   # Talaris (Sweden) AB
    F0-24-75   # Apple, Inc.
    F0-25-72   # Cisco Systems, Inc
    F0-25-B7   # Samsung Electro Mechanics co., LTD.
    F0-26-24   # WAFA TECHNOLOGIES CO., LTD.
    F0-26-4C   # Dr. Sigrist AG
    F0-27-2D   # Amazon Technologies Inc.
    F0-27-65   # Murata Manufacturing Co., Ltd.
    F0-29-29   # Cisco Systems, Inc
    F0-2A-23   # Creative Next Design
    F0-2A-61   # Waldo Networks, Inc.
    F0-2F-D8   # Bi2-Vision
    F0-32-1A   # Mita-Teknik A/S
    F0-34-04   # TCT mobile ltd
    F0-37-A1   # Huike Electronics (SHENZHEN) CO., LTD.
    F0-3A-4B   # Bloombase, Inc.
    F0-3A-55   # Omega Elektronik AS
    F0-3D-29   # Actility
    F0-3F-F8   # R L Drake
    F0-43-35   # DVN(Shanghai)Ltd.
    F0-4A-2B   # PYRAMID Computer GmbH
    F0-4B-6A   # Scientific Production Association Siberian Arsenal, Ltd.
    F0-4B-F2   # JTECH Communications, Inc.
    F0-4D-A2   # Dell Inc.
    F0-4F-7C   # Private
    F0-58-49   # CareView Communications
    F0-5A-09   # Samsung Electronics Co.,Ltd
    F0-5B-7B   # Samsung Electronics Co.,Ltd
    F0-5C-19   # Aruba Networks
    F0-5D-89   # Dycon Limited
    F0-5D-C8   # Duracell Powermat
    F0-5F-5A   # Getriebebau NORD GmbH and Co. KG
    F0-61-30   # Advantage Pharmacy Services, LLC
    F0-62-0D   # Shenzhen Egreat Tech Corp.,Ltd
    F0-62-81   # ProCurve Networking by HP
    F0-65-DD   # Primax Electronics Ltd.
    F0-68-53   # Integrated Corporation
    F0-6B-CA   # Samsung Electronics Co.,Ltd
    F0-72-8C   # Samsung Electronics Co.,Ltd
    F0-73-AE   # PEAK-System Technik
    F0-76-1C   # COMPAL INFORMATION (KUNSHAN) CO., LTD.
    F0-77-65   # Sourcefire, Inc
    F0-77-D0   # Xcellen
    F0-78-16   # Cisco Systems, Inc
    F0-79-59   # ASUSTek COMPUTER INC.
    F0-7B-CB   # Hon Hai Precision Ind. Co.,Ltd.
    F0-7D-68   # D-Link Corporation
    F0-7F-06   # Cisco Systems, Inc
    F0-7F-0C   # Leopold Kostal GmbH &Co. KG
    F0-81-AF   # IRZ AUTOMATION TECHNOLOGIES LTD
    F0-82-61   # Sagemcom Broadband SAS
    F0-84-2F   # ADB Broadband Italia
    F0-84-C9   # zte corporation
    F0-8A-28   # JIANGSU HENGSION ELECTRONIC S and T CO.,LTD
    F0-8B-FE   # COSTEL.,CO.LTD
    F0-8C-FB   # Fiberhome Telecommunication Tech.Co.,Ltd.
    F0-8E-DB   # VeloCloud Networks
    F0-92-1C   # Hewlett Packard
    F0-93-3A   # NxtConect
    F0-93-C5   # Garland Technology
    F0-99-BF   # Apple, Inc.
    F0-9A-51   # Shanghai Viroyal Electronic Technology Company Limited
    F0-9C-BB   # RaonThink Inc.
    F0-9C-E9   # Aerohive Networks Inc.
    F0-9E-63   # Cisco Systems, Inc
    F0-9F-C2   # Ubiquiti Networks, Inc.
    F0-A2-25   # Private
    F0-A7-64   # GST Co., Ltd.
    F0-AB-54   # MITSUMI ELECTRIC CO.,LTD.
    F0-AC-A4   # HBC-radiomatic
    F0-AD-4E   # Globalscale Technologies, Inc.
    F0-AE-51   # Xi3 Corp
    F0-B0-52   # Ruckus Wireless
    F0-B0-E7   # Apple, Inc.
    F0-B2-E5   # Cisco Systems, Inc
    F0-B4-29   # Xiaomi Communications Co Ltd
    F0-B4-79   # Apple, Inc.
    F0-B6-EB   # Poslab Technology Co., Ltd.
    F0-BC-C8   # MaxID (Pty) Ltd
    F0-BD-F1   # Sipod Inc.
    F0-BF-97   # Sony Corporation
    F0-C1-F1   # Apple, Inc.
    F0-C2-4C   # Zhejiang FeiYue Digital Technology Co., Ltd
    F0-C2-7C   # Mianyang Netop Telecom Equipment Co.,Ltd.
    F0-C8-8C   # LeddarTech Inc.
    F0-CB-A1   # Apple, Inc.
    F0-D1-4F   # LINEAR LLC
    F0-D1-A9   # Apple, Inc.
    F0-D3-A7   # CobaltRay Co., Ltd
    F0-D3-E7   # Sensometrix SA
    F0-D6-57   # ECHOSENS
    F0-D7-67   # Axema Passagekontroll AB
    F0-DA-7C   # RLH INDUSTRIES,INC.
    F0-DB-30   # Yottabyte
    F0-DB-E2   # Apple, Inc.
    F0-DB-F8   # Apple, Inc.
    F0-DC-E2   # Apple, Inc.
    F0-DE-71   # Shanghai EDO Technologies Co.,Ltd.
    F0-DE-B9   # ShangHai Y&Y Electronics Co., Ltd
    F0-DE-F1   # Wistron InfoComm (Kunshan)Co
    F0-E5-C3   # Drägerwerk AG & Co. KG aA
    F0-E7-7E   # Samsung Electronics Co.,Ltd
    F0-EB-D0   # Shanghai Feixun Communication Co.,Ltd.
    F0-EC-39   # Essec
    F0-ED-1E   # Bilkon Bilgisayar Kontrollu Cih. Im.Ltd.
    F0-EE-BB   # VIPAR GmbH
    F0-F0-02   # Hon Hai Precision Ind. Co.,Ltd.
    F0-F2-49   # Hitron Technologies. Inc
    F0-F2-60   # Mobitec AB
    F0-F3-36   # TP-LINK TECHNOLOGIES CO.,LTD.
    F0-F5-AE   # Adaptrum Inc.
    F0-F6-1C   # Apple, Inc.
    F0-F6-44   # Whitesky Science & Technology Co.,Ltd.
    F0-F6-69   # Motion Analysis Corporation
    F0-F7-55   # Cisco Systems, Inc
    F0-F7-B3   # Phorm
    F0-F8-42   # KEEBOX, Inc.
    F0-F9-F7   # IES GmbH & Co. KG
    F0-FD-A0   # Acurix Networks LP
    F0-FE-6B   # Shanghai High-Flying Electronics Technology Co., Ltd
    F4-03-04   # Google, Inc.
    F4-03-21   # BeNeXt B.V.
    F4-03-2F   # Reduxio Systems
    F4-04-4C   # ValenceTech Limited
    F4-06-69   # Intel Corporate
    F4-06-8D   # devolo AG
    F4-06-A5   # Hangzhou Bianfeng Networking Technology Co., Ltd.
    F4-09-D8   # Samsung Electro Mechanics co., LTD.
    F4-0B-93   # BlackBerry RTS
    F4-0E-11   # IEEE Registration Authority
    F4-0E-22   # Samsung Electronics Co.,Ltd
    F4-0F-1B   # Cisco Systems, Inc
    F4-0F-9B   # WAVELINK
    F4-15-35   # SPON Communication Technology Co.,Ltd
    F4-15-63   # F5 Networks, Inc.
    F4-15-FD   # Shanghai Pateo Electronic Equipment Manufacturing Co., Ltd.
    F4-1B-A1   # Apple, Inc.
    F4-1E-26   # Simon-Kaloi Engineering
    F4-1F-0B   # YAMABISHI Corporation
    F4-1F-C2   # Cisco Systems, Inc
    F4-20-12   # Cuciniale GmbH
    F4-28-33   # MMPC Inc.
    F4-28-53   # Zioncom Electronics (Shenzhen) Ltd.
    F4-28-96   # SPECTO PAINEIS ELETRONICOS LTDA
    F4-29-81   # vivo Mobile Communication Co., Ltd.
    F4-2C-56   # SENOR TECH CO LTD
    F4-31-C3   # Apple, Inc.
    F4-36-E1   # Abilis Systems SARL
    F4-37-B7   # Apple, Inc.
    F4-38-14   # Shanghai Howell Electronic Co.,Ltd
    F4-3D-80   # FAG Industrial Services GmbH
    F4-3E-61   # Shenzhen Gongjin Electronics Co., Ltd
    F4-3E-9D   # Benu Networks, Inc.
    F4-42-27   # S & S Research Inc.
    F4-42-8F   # Samsung Electronics Co.,Ltd
    F4-44-50   # BND Co., Ltd.
    F4-45-ED   # Portable Innovation Technology Ltd.
    F4-47-13   # Leading Public Performance Co., Ltd.
    F4-47-2A   # Nanjing Rousing Sci. and Tech. Industrial Co., Ltd
    F4-48-48   # Amscreen Group Ltd
    F4-4B-2A   # Cisco SPVTG
    F4-4D-17   # GOLDCARD HIGH-TECH CO.,LTD.
    F4-4D-30   # Elitegroup Computer Systems Co.,Ltd.
    F4-4E-05   # Cisco Systems, Inc
    F4-4E-FD   # Actions Semiconductor Co.,Ltd.(Cayman Islands)
    F4-50-EB   # Telechips Inc
    F4-52-14   # Mellanox Technologies, Inc.
    F4-54-33   # Rockwell Automation
    F4-55-95   # HENGBAO Corporation LTD.
    F4-55-9C   # HUAWEI TECHNOLOGIES CO.,LTD
    F4-55-E0   # Niceway CNC Technology Co.,Ltd.Hunan Province
    F4-57-3E   # Fiberhome Telecommunication Technologies Co.,LTD
    F4-58-42   # Boxx TV Ltd
    F4-5C-89   # Apple, Inc.
    F4-5F-69   # Matsufu Electronics distribution Company
    F4-5F-D4   # Cisco SPVTG
    F4-5F-F7   # DQ Technology Inc.
    F4-60-0D   # Panoptic Technology, Inc
    F4-63-49   # Diffon Corporation
    F4-64-5D   # Toshiba
    F4-67-2D   # ShenZhen Topstar Technology Company
    F4-6A-92   # SHENZHEN FAST TECHNOLOGIES CO.,LTD
    F4-6A-BC   # Adonit Corp. Ltd.
    F4-6D-04   # ASUSTek COMPUTER INC.
    F4-6D-E2   # zte corporation
    F4-73-CA   # Conversion Sound Inc.
    F4-76-26   # Viltechmeda UAB
    F4-7A-4E   # Woojeon&Handan
    F4-7A-CC   # SolidFire, Inc.
    F4-7B-5E   # Samsung Eletronics Co., Ltd
    F4-7F-35   # Cisco Systems, Inc
    F4-81-39   # CANON INC.
    F4-83-CD   # TP-LINK TECHNOLOGIES CO.,LTD.
    F4-87-71   # Infoblox
    F4-8B-32   # Xiaomi Communications Co Ltd
    F4-8E-09   # Nokia Corporation
    F4-8E-38   # Dell Inc.
    F4-8E-92   # HUAWEI TECHNOLOGIES CO.,LTD
    F4-90-CA   # Tensorcom
    F4-90-EA   # Deciso B.V.
    F4-94-61   # NexGen Storage
    F4-94-66   # CountMax,  ltd
    F4-99-AC   # WEBER Schraubautomaten GmbH
    F4-9F-54   # Samsung Electronics
    F4-9F-F3   # HUAWEI TECHNOLOGIES CO.,LTD
    F4-A2-94   # EAGLE WORLD DEVELOPMENT CO., LIMITED
    F4-A5-2A   # Hawa Technologies Inc
    F4-AC-C1   # Cisco Systems, Inc
    F4-B1-64   # Lightning Telecommunications Technology Co. Ltd
    F4-B3-81   # WindowMaster A/S
    F4-B5-2F   # Juniper Networks
    F4-B5-49   # Yeastar Technology Co., Ltd.
    F4-B6-E5   # TerraSem Co.,Ltd
    F4-B7-2A   # TIME INTERCONNECT LTD
    F4-B7-E2   # Hon Hai Precision Ind. Co.,Ltd.
    F4-B8-5E   # Texas Instruments
    F4-B8-A7   # zte corporation
    F4-BD-7C   # Chengdu jinshi communication Co., LTD
    F4-C4-47   # Coagent International Enterprise Limited
    F4-C6-13   # Alcatel-Lucent Shanghai Bell Co., Ltd
    F4-C6-D7   # blackned GmbH
    F4-C7-14   # HUAWEI TECHNOLOGIES CO.,LTD
    F4-C7-95   # WEY Elektronik AG
    F4-CA-24   # FreeBit Co., Ltd.
    F4-CA-E5   # FREEBOX SAS
    F4-CD-90   # Vispiron Rotec GmbH
    F4-CE-46   # Hewlett Packard
    F4-CF-E2   # Cisco Systems, Inc
    F4-D0-32   # Yunnan Ideal Information&Technology.,Ltd
    F4-D2-61   # SEMOCON Co., Ltd
    F4-D9-FB   # Samsung Electronics CO., LTD
    F4-DC-4D   # Beijing CCD Digital Technology Co., Ltd
    F4-DC-DA   # Zhuhai Jiahe Communication Technology Co., limited
    F4-DC-F9   # HUAWEI TECHNOLOGIES CO.,LTD
    F4-DD-9E   # GoPro
    F4-E1-42   # Delta Elektronika BV
    F4-E3-FB   # HUAWEI TECHNOLOGIES CO.,LTD
    F4-E6-D7   # Solar Power Technologies, Inc.
    F4-E9-26   # Tianjin Zanpu Technology Inc.
    F4-E9-D4   # QLogic Corporation
    F4-EA-67   # Cisco Systems, Inc
    F4-EB-38   # Sagemcom Broadband SAS
    F4-EC-38   # TP-LINK TECHNOLOGIES CO.,LTD.
    F4-ED-5F   # SHENZHEN KTC TECHNOLOGY GROUP
    F4-EE-14   # SHENZHEN MERCURY COMMUNICATION TECHNOLOGIES CO.,LTD.
    F4-F1-5A   # Apple, Inc.
    F4-F1-E1   # Motorola Mobility LLC, a Lenovo Company
    F4-F2-6D   # TP-LINK TECHNOLOGIES CO.,LTD.
    F4-F5-A5   # Nokia Corporation
    F4-F5-D8   # Google, Inc.
    F4-F5-E8   # Google, Inc.
    F4-F6-46   # Dediprog Technology Co. Ltd.
    F4-F9-51   # Apple, Inc.
    F4-FC-32   # Texas Instruments
    F4-FD-2B   # ZOYI Company
    F8-01-13   # HUAWEI TECHNOLOGIES CO.,LTD
    F8-02-78   # IEEE Registration Authority
    F8-03-32   # Khomp
    F8-04-2E   # Samsung Electro Mechanics co., LTD.
    F8-05-1C   # DRS Imaging and Targeting Solutions
    F8-0B-BE   # ARRIS Group, Inc.
    F8-0B-D0   # Datang Telecom communication terminal (Tianjin) Co., Ltd.
    F8-0C-F3   # LG Electronics
    F8-0D-43   # Hon Hai Precision Ind. Co.,Ltd.
    F8-0D-60   # CANON INC.
    F8-0D-EA   # ZyCast Technology Inc.
    F8-0F-41   # Wistron InfoComm(ZhongShan) Corporation
    F8-0F-84   # Natural Security SAS
    F8-10-37   # Atopia Systems, LP
    F8-15-47   # Avaya Inc
    F8-16-54   # Intel Corporate
    F8-18-97   # 2Wire Inc
    F8-1A-67   # TP-LINK TECHNOLOGIES CO.,LTD.
    F8-1C-E5   # Telefonbau Behnke GmbH
    F8-1D-93   # Longdhua(Beijing) Controls Technology Co.,Ltd
    F8-1E-DF   # Apple, Inc.
    F8-22-85   # Cypress Technology CO., LTD.
    F8-24-41   # Yeelink
    F8-27-93   # Apple, Inc.
    F8-2B-C8   # Jiangsu Switter Co., Ltd
    F8-2C-18   # 2Wire Inc
    F8-2E-DB   # RTW GmbH & Co. KG
    F8-2F-5B   # eGauge Systems LLC
    F8-2F-A8   # Hon Hai Precision Ind. Co.,Ltd.
    F8-30-94   # Alcatel-Lucent Telecom Limited
    F8-31-3E   # endeavour GmbH
    F8-32-E4   # ASUSTek COMPUTER INC.
    F8-33-76   # Good Mind Innovation Co., Ltd.
    F8-35-53   # Magenta Research Ltd.
    F8-35-DD   # Gemtek Technology Co., Ltd.
    F8-3D-4E   # Softlink Automation System Co., Ltd
    F8-3D-FF   # HUAWEI TECHNOLOGIES CO.,LTD
    F8-42-FB   # Yasuda Joho Co.,ltd.
    F8-45-AD   # Konka Group Co., Ltd.
    F8-46-2D   # SYNTEC Incorporation
    F8-47-2D   # X2gen Digital Corp. Ltd
    F8-48-97   # Hitachi, Ltd.
    F8-4A-73   # EUMTECH CO., LTD
    F8-4A-7F   # Innometriks Inc
    F8-4A-BF   # HUAWEI TECHNOLOGIES CO.,LTD
    F8-4F-57   # Cisco Systems, Inc
    F8-50-63   # Verathon
    F8-51-6D   # Denwa Technology Corp.
    F8-52-DF   # VNL Europe AB
    F8-54-AF   # ECI Telecom Ltd.
    F8-57-2E   # Core Brands, LLC
    F8-5B-9C   # SB SYSTEMS Co.,Ltd
    F8-5B-C9   # M-Cube Spa
    F8-5C-45   # IC Nexus Co. Ltd.
    F8-5F-2A   # Nokia Corporation
    F8-62-AA   # xn systems
    F8-66-01   # Suzhou Chi-tek information technology Co., Ltd
    F8-66-D1   # Hon Hai Precision Ind. Co.,Ltd.
    F8-66-F2   # Cisco Systems, Inc
    F8-69-71   # Seibu Electric Co.,
    F8-6E-CF   # Arcx Inc
    F8-71-FE   # The Goldman Sachs Group, Inc.
    F8-72-EA   # Cisco Systems, Inc
    F8-73-94   # NETGEAR
    F8-73-A2   # Avaya Inc
    F8-76-9B   # Neopis Co., Ltd.
    F8-7A-EF   # Rosonix Technology, Inc.
    F8-7B-62   # FASTWEL INTERNATIONAL CO., LTD. Taiwan Branch
    F8-7B-7A   # ARRIS Group, Inc.
    F8-7B-8C   # Amped Wireless
    F8-80-96   # Elsys Equipamentos Eletrônicos Ltda
    F8-81-1A   # OVERKIZ
    F8-84-79   # Yaojin Technology(Shenzhen)Co.,Ltd
    F8-84-F2   # Samsung Electronics Co.,Ltd
    F8-8C-1C   # KAISHUN ELECTRONIC TECHNOLOGY CO., LTD. BEIJING
    F8-8D-EF   # Tenebraex
    F8-8E-85   # Comtrend Corporation
    F8-8F-CA   # Google, Inc.
    F8-91-2A   # GLP German Light Products GmbH
    F8-93-F3   # VOLANS
    F8-95-50   # Proton Products Chengdu Ltd
    F8-95-C7   # LG Electronics (Mobile Communications)
    F8-97-CF   # DAESHIN-INFORMATION TECHNOLOGY CO., LTD.
    F8-98-B9   # HUAWEI TECHNOLOGIES CO.,LTD
    F8-99-55   # Fortress Technology Inc
    F8-9D-0D   # Control Technology Inc.
    F8-9F-B8   # YAZAKI Energy System Corporation
    F8-A0-3D   # Dinstar Technologies Co., Ltd.
    F8-A2-B4   # RHEWA-WAAGENFABRIK August Freudewald GmbH &amp;Co. KG
    F8-A4-5F   # Xiaomi Communications Co Ltd
    F8-A9-63   # COMPAL INFORMATION (KUNSHAN) CO., LTD.
    F8-A9-D0   # LG Electronics
    F8-A9-DE   # PUISSANCE PLUS
    F8-AA-8A   # Axview Technology (Shenzhen) Co.,Ltd
    F8-AC-6D   # Deltenna Ltd
    F8-B1-56   # Dell Inc.
    F8-B2-F3   # GUANGZHOU BOSMA TECHNOLOGY CO.,LTD
    F8-B5-99   # Guangzhou CHNAVS Digital Technology Co.,Ltd
    F8-BC-12   # Dell Inc.
    F8-BC-41   # Rosslare Enterprises Limited
    F8-BF-09   # HUAWEI TECHNOLOGIES CO.,LTD
    F8-C0-01   # Juniper Networks
    F8-C0-91   # Highgates Technology
    F8-C2-88   # Cisco Systems, Inc
    F8-C3-72   # TSUZUKI DENKI
    F8-C3-97   # NZXT Corp. Ltd.
    F8-C6-78   # Carefusion
    F8-C9-6C   # Fiberhome Telecommunication Tech.Co.,Ltd.
    F8-CA-B8   # Dell Inc.
    F8-CF-C5   # Motorola Mobility LLC, a Lenovo Company
    F8-D0-AC   # Sony Computer Entertainment Inc.
    F8-D0-BD   # Samsung Electronics Co.,Ltd
    F8-D1-11   # TP-LINK TECHNOLOGIES CO.,LTD.
    F8-D3-A9   # AXAN Networks
    F8-D4-62   # Pumatronix Equipamentos Eletronicos Ltda.
    F8-D7-56   # Simm Tronic Limited
    F8-D7-BF   # REV Ritter GmbH
    F8-DA-DF   # EcoTech, Inc.
    F8-DA-E2   # Beta LaserMike
    F8-DA-F4   # Taishan Online Technology Co., Ltd.
    F8-DB-4C   # PNY Technologies, INC.
    F8-DB-7F   # HTC Corporation
    F8-DB-88   # Dell Inc.
    F8-DC-7A   # Variscite LTD
    F8-DF-A8   # zte corporation
    F8-E0-79   # Motorola Mobility LLC, a Lenovo Company
    F8-E4-FB   # Actiontec Electronics, Inc
    F8-E7-1E   # Ruckus Wireless
    F8-E7-B5   # µTech Tecnologia LTDA
    F8-E8-11   # HUAWEI TECHNOLOGIES CO.,LTD
    F8-E9-03   # D-Link International
    F8-E9-68   # Egker Kft.
    F8-EA-0A   # Dipl.-Math. Michael Rauch
    F8-ED-A5   # ARRIS Group, Inc.
    F8-F0-05   # Newport Media Inc.
    F8-F0-14   # RackWare Inc.
    F8-F0-82   # Orion Networks International, Inc
    F8-F1-B6   # Motorola Mobility LLC, a Lenovo Company
    F8-F2-5A   # G-Lab GmbH
    F8-F4-64   # Rawe Electonic GmbH
    F8-F7-D3   # International Communications Corporation
    F8-F7-FF   # SYN-TECH SYSTEMS INC
    F8-FB-2F   # Santur Corporation
    F8-FE-5C   # Reciprocal Labs Corp
    F8-FE-A8   # Technico Japan Corporation
    F8-FF-5F   # Shenzhen Communication Technology Co.,Ltd
    FC-00-12   # Toshiba Samsung Storage Technolgoy Korea Corporation
    FC-01-9E   # VIEVU
    FC-01-CD   # FUNDACION TEKNIKER
    FC-06-47   # Cortland Research, LLC
    FC-07-A0   # LRE Medical GmbH
    FC-08-77   # Prentke Romich Company
    FC-09-D8   # ACTEON Group
    FC-09-F6   # GUANGDONG TONZE ELECTRIC CO.,LTD
    FC-0A-81   # Zebra Technologies Inc
    FC-0F-E6   # Sony Computer Entertainment Inc.
    FC-10-BD   # Control Sistematizado S.A.
    FC-11-86   # Logic3 plc
    FC-13-49   # Global Apps Corp.
    FC-15-B4   # Hewlett Packard
    FC-16-07   # Taian Technology(Wuxi) Co.,Ltd.
    FC-17-94   # InterCreative Co., Ltd
    FC-19-10   # Samsung Electronics Co.,Ltd
    FC-19-D0   # Cloud Vision Networks Technology Co.,Ltd.
    FC-1B-FF   # V-ZUG AG
    FC-1D-59   # I Smart Cities HK Ltd
    FC-1D-84   # Autobase
    FC-1E-16   # IPEVO corp
    FC-1F-19   # SAMSUNG ELECTRO-MECHANICS CO., LTD.
    FC-1F-C0   # EURECAM
    FC-22-9C   # Han Kyung I Net Co.,Ltd.
    FC-23-25   # EosTek (Shenzhen) Co., Ltd.
    FC-25-3F   # Apple, Inc.
    FC-27-A2   # TRANS ELECTRIC CO., LTD.
    FC-2A-54   # Connected Data, Inc.
    FC-2E-2D   # Lorom Industrial Co.LTD.
    FC-2F-40   # Calxeda, Inc.
    FC-2F-EF   # UTT Technologies Co., Ltd.
    FC-32-88   # CELOT Wireless Co., Ltd
    FC-33-5F   # Polyera
    FC-35-98   # Favite Inc.
    FC-35-E6   # Visteon corp
    FC-3D-93   # LONGCHEER TELECOMMUNICATION LIMITED
    FC-3F-AB   # Henan Lanxin Technology Co., Ltd
    FC-3F-DB   # Hewlett Packard
    FC-44-63   # Universal Audio, Inc
    FC-44-99   # Swarco LEA d.o.o.
    FC-45-5F   # JIANGXI SHANSHUI OPTOELECTRONIC TECHNOLOGY CO.,LTD
    FC-45-96   # COMPAL INFORMATION (KUNSHAN) CO., LTD.
    FC-48-EF   # HUAWEI TECHNOLOGIES CO.,LTD
    FC-4A-E9   # Castlenet Technology Inc.
    FC-4B-1C   # INTERSENSOR S.R.L.
    FC-4B-BC   # Sunplus Technology Co., Ltd.
    FC-4D-D4   # Universal Global Scientific Industrial Co., Ltd.
    FC-50-90   # SIMEX Sp. z o.o.
    FC-52-8D   # Technicolor CH USA
    FC-52-CE   # Control iD
    FC-58-FA   # Shen Zhen Shi Xin Zhong Xin Technology Co.,Ltd.
    FC-5B-24   # Weibel Scientific A/S
    FC-5B-26   # MikroBits
    FC-5B-39   # Cisco Systems, Inc
    FC-60-18   # Zhejiang Kangtai Electric Co., Ltd.
    FC-61-98   # NEC Personal Products, Ltd
    FC-62-6E   # Beijing MDC Telecom
    FC-62-B9   # ALPS ELECTRIC CO.,LTD.
    FC-64-BA   # Xiaomi Communications Co Ltd
    FC-68-3E   # Directed Perception, Inc
    FC-6C-31   # LXinstruments GmbH
    FC-6D-C0   # BME CORPORATION
    FC-6F-B7   # Pace plc
    FC-75-16   # D-Link International
    FC-75-E6   # Handreamnet
    FC-79-0B   # Hitachi High Technologies America, Inc.
    FC-7C-E7   # FCI USA LLC
    FC-83-29   # Trei technics
    FC-83-99   # Avaya Inc
    FC-8B-97   # Shenzhen Gongjin Electronics Co.,Ltd
    FC-8E-7E   # Pace plc
    FC-8F-90   # Samsung Electronics Co.,Ltd
    FC-8F-C4   # Intelligent Technology Inc.
    FC-92-3B   # Nokia Corporation
    FC-94-6C   # UBIVELOX
    FC-94-E3   # Technicolor USA Inc.
    FC-99-47   # Cisco Systems, Inc
    FC-9A-FA   # Motus Global Inc.
    FC-9F-AE   # Fidus Systems Inc
    FC-9F-E1   # CONWIN.Tech. Ltd
    FC-A1-3E   # Samsung Electronics
    FC-A2-2A   # PT. Callysta Multi Engineering
    FC-A3-86   # SHENZHEN CHUANGWEI-RGB ELECTRONICS CO.,LTD
    FC-A8-41   # Avaya Inc
    FC-A9-B0   # MIARTECH (SHANGHAI),INC.
    FC-AA-14   # GIGA-BYTE TECHNOLOGY CO.,LTD.
    FC-AD-0F   # QTS NETWORKS
    FC-AF-6A   # Qulsar Inc
    FC-AF-AC   # Socionext Inc.
    FC-B0-C4   # Shanghai DareGlobal Technologies Co., Ltd
    FC-B4-E6   # ASKEY COMPUTER CORP
    FC-B6-98   # Cambridge Industries(Group) Co.,Ltd.
    FC-BB-A1   # Shenzhen Minicreate Technology Co.,Ltd
    FC-C2-33   # Private
    FC-C2-3D   # Atmel Corporation
    FC-C2-DE   # Murata Manufacturing Co., Ltd.
    FC-C7-34   # Samsung Electronics Co.,Ltd
    FC-C8-97   # zte corporation
    FC-CC-E4   # Ascon Ltd.
    FC-CF-43   # HUIZHOU CITY HUIYANG DISTRICT MEISIQI INDUSTRY DEVELOPMENT CO,.LTD
    FC-CF-62   # IBM Corp
    FC-D4-F2   # The Coca Cola Company
    FC-D4-F6   # Messana Air.Ray Conditioning s.r.l.
    FC-D5-D9   # Shenzhen SDMC Technology Co., Ltd.
    FC-D6-BD   # Robert Bosch GmbH
    FC-D7-33   # TP-LINK TECHNOLOGIES CO.,LTD.
    FC-D8-17   # Beijing Hesun Technologies Co.Ltd.
    FC-DB-96   # ENERVALLEY CO., LTD
    FC-DB-B3   # Murata Manufacturing Co., Ltd.
    FC-DC-4A   # G-Wearables Corp.
    FC-DD-55   # Shenzhen WeWins wireless Co.,Ltd
    FC-E1-86   # A3M Co., LTD
    FC-E1-92   # Sichuan Jinwangtong Electronic Science&Technology Co,.Ltd
    FC-E1-D9   # Stable Imaging Solutions LLC
    FC-E1-FB   # Array Networks
    FC-E2-3F   # CLAY PAKY SPA
    FC-E3-3C   # HUAWEI TECHNOLOGIES CO.,LTD
    FC-E5-57   # Nokia Corporation
    FC-E8-92   # Hangzhou Lancable Technology Co.,Ltd
    FC-E9-98   # Apple, Inc.
    FC-ED-B9   # Arrayent
    FC-F1-36   # Samsung Electronics Co.,Ltd
    FC-F1-52   # Sony Computer Entertainment Inc.
    FC-F1-CD   # OPTEX-FA CO.,LTD.
    FC-F5-28   # ZyXEL Communications Corporation
    FC-F6-47   # Fiberhome Telecommunication Tech.Co.,Ltd.
    FC-F8-AE   # Intel Corporate
    FC-F8-B7   # TRONTEQ Electronic
    FC-FA-F7   # Shanghai Baud Data Communication Co.,Ltd.
    FC-FB-FB   # Cisco Systems, Inc
    FC-FC-48   # Apple, Inc.
    FC-FE-77   # Hitachi Reftechno, Inc.
    FC-FE-C2   # Invensys Controls UK Limited
    FC-FF-AA   # IEEE Registration Authority
)
#RANGE=11
idx=$RANDOM
let "idx %= ${#OUI_ARRAY[@]}"
OUI=${OUI_ARRAY[$idx]}
OUI=$(echo "$OUI" | sed 's/-/:/g')
echo "Nbr OUI = ${#OUI_ARRAY[@]}"
echo "idx = $idx"
echo "OUI = $OUI"

# generate a new NIC specific identifier
NIC=$(date | md5sum | sed 's/../&:/g' | cut -b 9-17)
newMAC="$OUI$NIC"
echo "new MAC: $newMAC"

# assign the new MAC to the interface
echo "Do you wish to assign $newMAC to ${interfaces[$itf_num]}?"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
              sudo service network-manager stop
              sleep 1
              sudo ifconfig ${interfaces[$itf_num]} down;
              sleep 1 # allow interface to go down
              sudo ifconfig ${interfaces[$itf_num]} hw ether $newMAC;
              sleep 1 # allow time to assign MAC to interface
              sudo ifconfig ${interfaces[$itf_num]} up;
              sleep 1
              sudo service network-manager start
              # display the new MAC
              ifconfig ${interfaces[$itf_num]} | grep HWaddr;
              break;;
        No ) exit;;
    esac
done

exit 0
