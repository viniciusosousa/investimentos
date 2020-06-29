
delimiter #
create or replace procedure financas.atualiza_dados()
begin
    declare i int default 2;

    CREATE TEMPORARY TABLE financas.tmp_id_carteira as
    SELECT ID, ID_TIPO_APLICACAO, COD_PAPEL
    FROM financas.tb_aplicacoes
    ORDER BY ID_TIPO_APLICACAO, COD_PAPEL, DATA_OPERACAO, ID_TIPO_OPERACAO;


    ALTER TABLE financas.tmp_id_carteira
    MODIFY id int(11),
    ADD COLUMN id_index int auto_increment primary key first,
    ADD COLUMN indice int after id_index;

    CREATE TEMPORARY TABLE financas.tmp_primeiro_id as
    SELECT ID_TIPO_APLICACAO, COD_PAPEL, MIN(id_index) pri_id_index
    from financas.tmp_id_carteira
    group by id_tipo_aplicacao, cod_papel;

    UPDATE financas.tmp_id_carteira, financas.tmp_primeiro_id
    SET tmp_id_carteira.indice = tmp_id_carteira.id_index - tmp_primeiro_id.pri_id_index + 1
    WHERE tmp_id_carteira.cod_papel = tmp_primeiro_id.cod_papel
    and tmp_id_carteira.id_tipo_aplicacao = tmp_primeiro_id.id_tipo_aplicacao;

    update financas.tb_aplicacoes, financas.tmp_id_carteira
    set tb_aplicacoes.indice = tmp_id_carteira.indice
    where tb_aplicacoes.id = tmp_id_carteira.id;

    update financas.tb_aplicacoes
    set
    vl_medio =0,
    qtd_total=0,
    vl_total=0,
    vl_medio_ant=0,
    qtd_total_ant=0,
    vl_total_ant=0,
    resultado=0;

	select @max_indice := max(indice) from financas.tb_aplicacoes;

    update financas.tb_aplicacoes
    set vl_medio = valor_unitario,
        qtd_total = qtd,
        vl_total = qtd * valor_unitario
    where indice = 1;

    while i <= @max_indice do
    update financas.tb_aplicacoes atual, financas.tb_aplicacoes ant
    set atual.vl_medio = case atual.id_tipo_operacao
                        when 2 then ant.vl_medio
                        when 1 then (ant.vl_total+(atual.qtd*atual.valor_unitario))/(atual.qtd+ant.qtd_total)
                        end,
    atual.vl_total = case atual.id_tipo_operacao
                        when 2 then ant.vl_total - (atual.qtd*ant.vl_medio)
                        when 1 then ant.vl_total + (atual.qtd*atual.valor_unitario)
                        end,
    atual.qtd_total = case atual.id_tipo_operacao
                        when 2 then ant.qtd_total - atual.qtd
                        when 1 then ant.qtd_total + atual.qtd
                        end,
    atual.resultado = case atual.id_tipo_operacao
                        when 1 then 0
                        when 2 then (atual.qtd*atual.valor_unitario)-(atual.qtd*ant.vl_medio)
                        end,
    atual.vl_medio_ant = ant.vl_medio,
    atual.qtd_total_ant = ant.qtd_total,
    atual.vl_total_ant = ant.vl_total
    where atual.cod_papel = ant.cod_papel
    and atual.id_tipo_aplicacao = ant.id_tipo_aplicacao
    and atual.indice = i
    and ant.indice = i - 1;

	set i = i +1;
    end while;

end #
delimiter ;

call financas.atualiza_dados();