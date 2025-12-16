// Chuck Benz, Hollis, NH   Copyright (c)2002
//
// As informações e descrição contidas aqui são propriedade de Chuck Benz.
//
// A permissão é concedida para qualquer reutilização destas informações
// e descrição, desde que este aviso de direitos autorais seja preservado.
// Modificações podem ser feitas desde que este aviso seja preservado.
//
// 11-OUT-2002: atualizado com mensagens mais claras e verificação de decodeout

`timescale 1ns / 1ns

module test_8b10b ;
   // Memória para armazenar os vetores de teste (268 linhas)
   reg [29:0]	code8b10b [0:267] ;
   reg [8:0] 	testin;   // Entrada de teste para o Encoder (8 bits dados + 1 bit K)
   reg 		dispin;   // Entrada de disparidade inicial para o Encoder
   reg [10:0] 	i;        // Índice do loop
   wire [9:0] 	testout;  // Saída codificada do Encoder (10 bits)
   wire 	dispout, decodedisp, decodeerr, disperr ;
   wire [8:0] 	decodeout; // Saída decodificada do Decoder (deve ser igual a testin)
   
   // Formato do arquivo de dados (8b10b_a.mem): 30 colunas.
   // Coluna 1 do arquivo vira bit [29], coluna 30 vira bit [0].
   // Bit [29]: Indicação de K (Controle)
   // Bits [28:21]: Byte de dados (D ou K), m e n de Dm.n
   // Bits [20:11]: Símbolo 10b esperado se a disparidade inicial for negativa (0)
   // Bits [10:1]: Símbolo 10b esperado se a disparidade inicial for positiva (1)
   // Bit [0]: É 1 se o símbolo resulta em inversão de disparidade, 0 se for balanceado.

   wire [29:0] 	code = code8b10b[i] ;
   
   // Extrai o símbolo esperado de 10 bits para disparidade inicial negativa (bits 20 a 11 do arquivo)
   wire [9:0] 	expect_0_disp = {code[11], code[12], code[13], code[14], code[15],
				 code[16], code[17], code[18], code[19], code[20]} ;
				 
   // Extrai o símbolo esperado de 10 bits para disparidade inicial positiva (bits 10 a 1 do arquivo)
   wire [9:0] 	expect_1_disp = {code[1], code[2], code[3], code[4], code[5],
				 code[6], code[7], code[8], code[9], code[10]} ;

   reg [1023:0] legal ;  // Mapa de bits para marcar cada símbolo 10b legal usado
   reg [2047:0] okdisp ; // Mapa para marcar combinações válidas de símbolo e disparidade inicial
   reg [8:0] 	mapcode [1023:0] ; // Mapeamento reverso para conferência
   reg [10:0] 	codedisp0, codedisp1 ;
   reg [9:0] 	decodein ; // Entrada para o Decoder
   reg 		decdispin ; // Disparidade de entrada para o Decoder
   integer 	errors ;

   // Instanciação do Encoder (DUT - Device Under Test)
   encode DUTE (testin, dispin, testout, dispout) ;
   // Instanciação do Decoder (DUT)
   decode DUTD (decodein, decdispin, decodeout, decodedisp, decodeerr, disperr) ;

   // Sempre que 'code' mudar (novo i), atualiza testin com os dados do arquivo
   always @ (code) testin = code[29:21] ;
   
   initial begin 
      errors = 0 ;
      // Carrega o arquivo de vetores de teste
      // Certifique-se que o arquivo "8b10b_a.mem" está no mesmo diretório
      $readmemb ("8b10b_a.mem", code8b10b) ;
      //$vcdpluson ; // Comando específico para ferramentas VCS, comentado
      $dumpvars (0); // Dump de variáveis para waveform padrão
      
      $display ("\n\nPrimeiro, teste tentando todos os 268 simbolos (256 Dx.y e 12 Kx.y)") ;
      $display ("entradas validas, com ambas disparidades iniciais + e -.");
      $display ("Verificamos se a saida do encoder e a disparidade final estao corretas.");
      $display ("Tambem verificamos se o decoder recupera o valor original corretamente.");
      
      for (i = 0 ; i < 268 ; i = i + 1) begin
	 // Caso 1: Teste com Disparidade Inicial NEGATIVA (0)
	 dispin = 0 ;
	 #1 // Avança tempo
	   decodein = testout ; // Conecta saída do encoder na entrada do decoder
	 decdispin = dispin ;   // Passa a mesma disparidade
	 #1
//	   $display ("%b %b %b %b *%b*", dispin, testin, testout, {dispout, DUTD.disp6a, DUTD.disp6a2, DUTD.disp6a0, DUTD.disp6a2}, decodeout,, decodedisp,, DUTD.k28,, DUTD.disp6b) ;
	 
	 // Verificações
	 if (testout != expect_0_disp) 
	   $display ("codigo ruim 0 (disp neg) %b %b %b %b %b", dispin, testin,  dispout, testout, expect_0_disp) ;
	 if (dispout != (dispin ^ code[0]))
	   $display ("disparidade ruim 0 %b %b %b %b %b", dispin, testin, dispout, testout, (dispin ^ code[0])) ;
	 if (0 != (9'b1_1111_1111 & (testin ^ decodeout))) // Verifica se dado decodificado é igual ao original
	   $display ("difere em abcdefghk decode, %b %b %b %b %b", dispin, testin,  dispout, testout, decodeout) ;
	 if (decodedisp != dispout)
	   $display ("difere na disp out do decoder, %b %b %b %b %b", dispin, testin,  dispout, testout, decodeout) ;
	 if (decodeerr) $display ("erro de decode acionado indevidamente, %b %b %b %b %b", dispin, testin,  dispout, testout, decodeout) ;
	 
	 // Contagem de errros
	 if ((testout != expect_0_disp) | decodeerr |
	     (dispout != (dispin ^ code[0])) | (decodedisp != dispout))
	   errors = errors + 1 ;

	 // Caso 2: Teste com Disparidade Inicial POSITIVA (1)
	 dispin = 1 ;
	 #1
	 decodein = testout ;
	 decdispin = dispin ;
	 #1
//	   $display ("%b %b %b %b *%b*", dispin, testin, testout, {dispout, DUTD.disp6a, DUTD.disp6a2, DUTD.disp6a0, DUTD.disp6a2, DUTD.fghjp31, DUTD.feqg, DUTD.heqj, DUTD.fghj22, DUTD.fi, DUTD.gi, DUTD.hi, DUTD.ji, DUTD.dispout}, decodeout,, decodedisp,, DUTD.k28,, DUTD.disp6b) ;
	 if (testout != expect_1_disp) 
	   $display ("codigo ruim 1 (disp pos) %b %b %b %b %b", dispin, testin, dispout, testout, expect_1_disp) ;
	 if (dispout != (dispin ^ code[0]))
	   $display ("disparidade ruim 1 %b %b %b %b %b", dispin, testin,  dispout, testout, (dispin ^ code[0])) ;
	 if (0 != (9'b1_1111_1111 & (testin ^ decodeout)))
	   $display ("difere em abcdefghk decode, %b %b %b %b %b", dispin, testin,  dispout, testout, decodeout) ;
	 if (decodedisp != dispout)
	   $display ("difere na disp out do decoder, %b %b %b %b %b", dispin, testin,  dispout, testout, decodeout) ;
	 if (decodeerr) $display ("erro de decode acionado indevidamente, %b %b %b %b %b", dispin, testin,  dispout, testout, decodeout) ;
	 
	 if ((testout != expect_1_disp) | decodeerr |
	     (dispout != (dispin ^ code[0])) | (decodedisp != dispout))
	   errors = errors + 1 ;
      end
      $display ("%d erros nesse teste.\n", errors) ;

      // Agora, tendo verificado todos os códigos legais, vamos rodar alguns códigos ILEGAIS
      // no decodificador... como determinar códigos ilegais? Existem 1024 casos de 10 bits.
      // Vamos marcar os que são válidos.
      
      legal = 0 ;
      okdisp = 0 ;
      for (i = 0 ; i < 268 ; i = i + 1) begin
	 #1
//	   $display ("i=%d: %b %b %d %d %x %x", i, expect_0_disp, expect_1_disp, expect_0_disp, expect_1_disp, expect_0_disp, expect_1_disp) ;
	 legal[expect_0_disp] = 1 ; // Marca código 10b como legal
	 legal[expect_1_disp] = 1 ;
	 codedisp0 = expect_0_disp ;
	 codedisp1 = {1'b1, expect_1_disp} ;
	 okdisp[codedisp0] = 1 ; // Marca combinação (disp + código) como válida
	 okdisp[codedisp1] = 1 ;
	 mapcode[expect_0_disp] = code[29:21] ; // Salva qual era o dado original
	 mapcode[expect_1_disp] = code[29:21] ;
      end

      $display ("Agora vamos testar TODAS as combinacoes (legais e ilegais) no decoder.");
      $display ("checando todos as entradas possiveis de decode") ;
      
      for (i = 0 ; i < 1024 ; i = i + 1) begin
	 decodein = i ;
	 decdispin = 0 ;
	 codedisp1 = 1024 | i ;
	 #1
	 // Verifica se:
	 // 1. Código é ilegal E decoder NÃO reportou erro
	 // 2. Código é legal MAS saída difere do mapa
	 // 3. Código é legal MAS erro de disparidade reportado está incorreto
	 if (((legal[i] == 0) & (decodeerr != 1)) |
	     (legal[i] & (mapcode[i] != decodeout)) |
	     (legal[i] & (disperr != !okdisp[i])))
	   $display ("10b:%b start disp:%b 8b:%b end disp:%b codevio:%b dispvio:%b known code:%b used disp:", 
		     decodein, decdispin, decodeout, decodedisp, decodeerr, disperr, legal[i], okdisp[i]) ;
		     
	 if ((legal[i] == 0) & (decodeerr != 1)) $display ("ERR: code err devia ser 1 (codigo ilegal nao detectado)") ;
	 if (legal[i] & (mapcode[i] != decodeout)) $display ("ERR: saida decode incorreta") ;
	 if (legal[i] & (disperr != 1) & !okdisp[i]) $display ("ERR: disp err devia ser acionado") ;
	 else if (legal[i] & (disperr != 0) & okdisp[i])
	   $display ("ERR: disp err NAO devia ser acionado") ;

	 if (((legal[i] == 0) & (decodeerr != 1)) |
	     (legal[i] & !disperr & !okdisp[i]) |
	     (legal[i] & (mapcode[i] != decodeout)) |
	     (legal[i] & disperr & okdisp[i]))
	   errors = errors + 1 ;

	 decdispin = 1 ; // Repete teste com dispin = 1
	 #1
	 if (((legal[i] == 0) & (decodeerr != 1)) |
	     (legal[i] & (mapcode[i] != decodeout)) |
	     (legal[i] & (disperr != !okdisp[i|1024])))
	   $display ("10b:%b start disp:%b 8b:%b end disp:%b codevio:%b dispvio:%b known code:%b used disp:", 
		     decodein, decdispin, decodeout, decodedisp, decodeerr, disperr, legal[i], okdisp[i|1024]) ;
	 if ((legal[i] == 0) & (decodeerr != 1)) $display ("ERR: code err devia ser 1") ;
	 if (legal[i] & (mapcode[i] != decodeout)) $display ("ERR: saida decode incorreta") ;
	 if (legal[i] & (disperr != 1) & !okdisp[i|1024]) $display ("ERR: disp err devia ser acionado") ;
	 else if (legal[i] & (disperr != 0) & okdisp[i|1024])
	   $display ("ERR: disp err NAO devia ser acionado") ;
	 if (((legal[i] == 0) & (decodeerr != 1)) |
	     (legal[i] & !disperr & !okdisp[i|1024]) |
	     (legal[i] & (mapcode[i] != decodeout)) |
	     (legal[i] & disperr & okdisp[i|1024]))
	   errors = errors + 1 ;
      end // for (i = 0 ; i < 1024 ; i = i + 1)

      $display ("\nTeste do decoder concluido.\n") ;
      $display ("Total de erros: %d", errors);
      if (errors == 0) $display ("Parabens! Nenhum erro encontrado.\n");
      $finish ;
   end // initial begin
   
endmodule