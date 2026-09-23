
contador_registros(0).
contador_propostas(0).

!start.

+!start
    <- .print("Eu sou o initiator.");
       .print("Aguardando registro dos participants.").
       
@receber_registro[atomic]
+registrar(Agente)[source(Sender)]
    : contador_registros(N) & total_participants(Total)
    <- +participant(Agente);
       NovoN = N + 1;
       -contador_registros(N);
       +contador_registros(NovoN);
       .print("Participant registrado: ", Agente );
       .print("Participants registrados: ", NovoN, " de ", Total  );
       !verificar_registros(NovoN,Total).

+!verificar_registros(Quantidade, Total)
    : Quantidade < Total
    <- true.

+!verificar_registros(Quantidade, Total)
    : Quantidade == Total
    <- .print("Todos os participants foram registrados.");
       !enviar_cfp(transporte).

+!enviar_cfp(Servico)
    <- .findall(P, participant(P), Participants);
       .print("Participants encontrados: ", Participants);
       !enviar_para_lista(Participants, Servico).


+!enviar_para_lista([], Servico)
    <- .print("CFPs enviados para todos os participants.").


+!enviar_para_lista([P|Resto], Servico)
    <- .print("Enviando CFP para ", P);
       .send(P, tell,cfp(Servico));
       !enviar_para_lista(Resto,Servico).


// ======================================================
// RECEBIMENTO DAS PROPOSTAS
// ======================================================

@receber_proposta[atomic]
+proposta(Servico, Preco)[source(Sender)]
    : contador_propostas(N)
    <- .print("Recebi proposta de ",Sender," para ", Servico, " no valor de ", Preco );

       // Guarda a proposta
       +proposta_recebida(Sender, Servico, Preco);

       // Incrementa o contador
       NovoN = N + 1;
       -contador_propostas(N);
       +contador_propostas(NovoN);
       .print("Proposta numero ", NovoN, " recebida.");

       !verificar_total(Servico, NovoN).

+!verificar_total(Servico, Quantidade)
    <- .findall(P, participant(P), Participants);
       .length(Participants,TotalParticipants);
       !verificar_se_completo(Servico, Quantidade, TotalParticipants ).


+!verificar_se_completo( Servico, Recebidas, Esperadas)
    : Recebidas < Esperadas
    <- .print("Propostas recebidas: ", Recebidas," de ", Esperadas ).

+!verificar_se_completo(Servico, Recebidas,  Esperadas)
    : Recebidas == Esperadas
    <- .print("Propostas recebidas: ", Recebidas, " de ", Esperadas);
       .print("Todas as propostas para ", Servico, " foram recebidas." );
       !selecionar_melhor(Servico).


+!selecionar_melhor(Servico)
    <- .findall([Preco,Agente], proposta_recebida(Agente, Servico, Preco), Propostas);
       .print("Propostas para selecao: ",Propostas);
       .sort(Propostas, Ordenadas);
       .print("Propostas ordenadas: ",Ordenadas);
       !processar_melhor(Servico, Ordenadas ).


// ======================================================
// PRIMEIRO ELEMENTO = MENOR PRECO
// ======================================================

+!processar_melhor(Servico, [[Preco,Vencedor]|Restantes])
    <- .print("Melhor proposta encontrada.");
       .print("Vencedor = ", Vencedor);
       .print("Preco = ", Preco);
       .send(Vencedor, tell, accept(Servico));
       !rejeitar_propostas(Servico, Restantes).


+!rejeitar_propostas(Servico, [])
    <- .print("Todas as demais propostas foram rejeitadas.").


+!rejeitar_propostas(Servico, [[Preco,Agente]|Restantes])
    <- .print("Rejeitando proposta de ", Agente," no valor de ", Preco);
       .send(Agente, tell, reject(Servico));
       !rejeitar_propostas(Servico, Restantes).


+concluido(Servico)[source(Sender)]
    <- .print("O agente ",Sender, " concluiu o servico ",  Servico);
       .print("CNP finalizado com sucesso.").