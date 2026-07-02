import 'package:flutter/material.dart';
import 'package:vita_appprojetos/modelos/modelo_conquista.dart';

const Color comum = Color.fromRGBO(255, 255, 255, 0.702);
const Color incomum = Colors.green;
const Color raro = Colors.blue;
const Color epico = Colors.purple;
const Color lendario = Colors.orange;

// uma unica lista com todas as conquistas separadas especificando o ID de cada uma p poder linkar no firebase
const List<ConquistaModelo> listaDeConquistasDoApp = [

  // comuns

  ConquistaModelo(
    id: 'primeira_vitoria',
    nome: 'Primeira Vitória',
    descricao: 'Conclua uma meta qualquer de curto ou longo prazo.',
    corRaridade: comum,
  ),
  ConquistaModelo(
    id: 'anotacao_campo',
    nome: 'Anotação de Campo',
    descricao: 'Crie sua primeira nota detalhada',
    corRaridade: comum,
  ),
  ConquistaModelo(
    id: 'registro_ouro',
    nome: 'Registro de Ouro.',
    descricao: 'Registre um gasto ou receita pela primeira vez.',
    corRaridade: comum,
  ),
  ConquistaModelo(
    id: 'pilar_financas',
    nome: 'Pilar das Finanças.',
    descricao: 'Configure o limite mensal de gastos pela primeira vez.',
    corRaridade: comum,
  ),
  ConquistaModelo(
    id: 'identidade_forjada',
    nome: 'Identidade Forjada.',
    descricao: 'Personalize seu título de perfil pela primeira vez.',
    corRaridade: comum,
  ),
  ConquistaModelo(
    id: 'mente_agil',
    nome: 'Mente Ágil.',
    descricao: 'Conclua uma meta de curto prazo em menos de 24 horas após criá-la.',
    corRaridade: comum,
  ),

  // incomuns

  ConquistaModelo(
    id: 'ritmo_semanal',
    nome: 'Ritmo Semanal',
    descricao: 'Alcance uma sequência diária de 7 dias.',
    corRaridade: incomum,
  ),
  ConquistaModelo(
    id: 'serie_triunfos',
    nome: 'Série de Triunfos',
    descricao: 'Conclua 5 metas de curto prazo no total.',
    corRaridade: incomum,
  ),
  ConquistaModelo(
    id: 'disciplina_financeira',
    nome: 'Disciplina Financeira.',
    descricao: 'Registre gastos por 7 dias consecutivos.',
    corRaridade: incomum,
  ),
  ConquistaModelo(
    id: 'sede_conhecimento',
    nome: 'Sede de Conhecimento.',
    descricao: 'Conclua 3 metas da categoria “Estudo” em uma única semana.',
    corRaridade: incomum,
  ),
  ConquistaModelo(
    id: 'elixir_vida',
    nome: 'Elixir da Vida.',
    descricao: 'Conclua 3 metas da categoria “Saúde” em uma única semana.',
    corRaridade: incomum,
  ),
  ConquistaModelo(
    id: 'mosaico_ideias',
    nome: 'Mosaico de Ideias.',
    descricao: 'Tenha 2 notas de cada categoria ativas ao mesmo tempo.',
    corRaridade: incomum,
  ),

  // raras

  ConquistaModelo(
    id: 'sequencia_guerreiro',
    nome: 'Sequência de Guerreiro',
    descricao: 'Alcance uma sequência diária de 30 dias.',
    corRaridade: raro,
  ),
  ConquistaModelo(
    id: 'zenite_vital',
    nome: 'Zênite Vital',
    descricao: 'Responda o quiz semanal com felicidade máxima durante 4 semanas consecutivas.',
    corRaridade: raro,
  ),
  ConquistaModelo(
    id: 'vigor_pleno',
    nome: 'Vigor Pleno.',
    descricao: 'Mantenha a Stamina cheia durante 4 semanas.',
    corRaridade: raro,
  ),
  ConquistaModelo(
    id: 'armadura_ouro',
    nome: 'Armadura de Ouro.',
    descricao: 'Mantenha o HP cheio durante 4 semanas.',
    corRaridade: raro,
  ),
  ConquistaModelo(
    id: 'superavit',
    nome: 'Superávit.',
    descricao: 'Termine o mês com o saldo disponível maior que a despesa mensal.',
    corRaridade: raro,
  ),
  ConquistaModelo(
    id: 'muralha_financeira',
    nome: 'Muralha financeira.',
    descricao: 'Passe uma semana inteira sem registrar nenhum “gasto extra”.',
    corRaridade: raro,
  ),

  // epicas
  
  ConquistaModelo(
    id: 'caminho_estruturado',
    nome: 'Caminho Estruturado',
    descricao: 'Conclua 6 metas a longo prazo no total.',
    corRaridade: epico,
  ),
  ConquistaModelo(
    id: 'mente_cristal',
    nome: 'Mente de Cristal',
    descricao: 'Responda o quiz semanal por 12 semanas consecutivos (3 meses).',
    corRaridade: epico,
  ),
  ConquistaModelo(
    id: 'fortaleza_pessoal',
    nome: 'Fortaleza Pessoal.',
    descricao: 'Mantenha HP e Stamina, ao mesmo tempo, acima de 80 durante 12 semanas consecutivas .',
    corRaridade: epico,
  ),
  ConquistaModelo(
    id: 'jornada_perfeicao',
    nome: 'Jornada da Perfeição.',
    descricao: 'Complete uma meta a longo prazo sem perder nenhum ponto de HP durante o período.',
    corRaridade: epico,
  ),
  ConquistaModelo(
    id: 'sonho_realizado',
    nome: 'Sonho Realizado.',
    descricao: 'Complete uma meta da categoria “financeira” de valor maior ou igual a 5 vezes a sua receita mensal.',
    corRaridade: epico,
  ),
  ConquistaModelo(
    id: 'mapa_completo',
    nome: 'Mapa Completo.',
    descricao: 'Conclua pelo menos 3 metas quaisquer (curto ou longo prazo) de cada categoria .',
    corRaridade: epico,
  ),

  // lendarias
  
  ConquistaModelo(
    id: 'plano_uma_era',
    nome: 'Plano de Uma Era',
    descricao: 'Conclua 12 metas a longo prazo no total.',
    corRaridade: lendario,
  ),
  ConquistaModelo(
    id: 'eternidade_vita',
    nome: 'Eternidade Vita',
    descricao: 'Mantenha uma sequência de 100 dias ativos.',
    corRaridade: lendario,
  ),
  ConquistaModelo(
    id: 'cofre_ferro',
    nome: 'Cofre de ferro.',
    descricao: 'Termine 6 meses consecutivos sem ultrapassar o limite mensal de gastos.',
    corRaridade: lendario,
  ),
  ConquistaModelo(
    id: 'imperio_pessoal',
    nome: 'Império Pessoal.',
    descricao: 'Termine 12 meses consecutivos com saldo positivo (saldo disponível > despesa mensal).',
    corRaridade: lendario,
  ),
  ConquistaModelo(
    id: 'atlas_universal',
    nome: 'Atlas Universal.',
    descricao: 'Conclua pelo menos 3 metas a longo prazo de cada categoria.',
    corRaridade: lendario,
  ),
  ConquistaModelo(
    id: 'ciclo_perfeito',
    nome: 'Ciclo Perfeito.',
    descricao: 'Responda o quiz semanal durante 52 semanas consecutivas (1 ano).',
    corRaridade: lendario,
  ),
];