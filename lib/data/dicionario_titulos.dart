// lib/data/titulos_data.dart
import 'package:flutter/material.dart';
import 'package:vita_appprojetos/modelos/modelo_titulos.dart';

// Definição das cores das raridades dos títulos
const Color comum = Color.fromRGBO(255, 255, 255, 0.702);
const Color incomum = Colors.green;
const Color raro = Colors.blue;
const Color epico = Colors.purple;
const Color lendario = Colors.orange;
const Color misterioso = Color.fromARGB(255, 218, 32, 32);

// Lista centralizada com todos os seus títulos estruturados por IDs
const List<TituloModelo> listaDeTitulosDoApp = [
  
  // comuns

  TituloModelo(
    id: 't_novato',
    nome: 'Novato',
    descricao: 'Título default, concedido ao ingressar no Vita.',
    corRaridade: comum,
  ),
  TituloModelo(
    id: 't_novato_determinado',
    nome: 'Novato Determinado',
    descricao: 'Atingir a conquista “Primeira Vitória”.',
    corRaridade: comum,
  ),
  TituloModelo(
    id: 't_escrivao',
    nome: 'Escrivão',
    descricao: 'Atingir a conquista “Anotação de Campo”.',
    corRaridade: comum,
  ),
  TituloModelo(
    id: 't_vigia_moedas',
    nome: 'Vigia das Moedas',
    descricao: 'Atingir as conquistas “Pilar de Finanças” e “Registro de Ouro”.',
    corRaridade: comum,
  ),
  TituloModelo(
    id: 't_andarilho',
    nome: 'Andarilho',
    descricao: 'Atingir o nível 5.',
    corRaridade: comum,
  ),

  // incomuns

  TituloModelo(
    id: 't_guerreiro_foco',
    nome: 'Guerreiro do Foco',
    descricao: 'Atingir a conquista “Ritmo Semanal”.',
    corRaridade: incomum,
  ),
  TituloModelo(
    id: 't_sabio_resistente',
    nome: 'Sábio Resistente',
    descricao: 'Atingir as conquistas “Sede de Conhecimento” e “Elixir da Vida”.',
    corRaridade: incomum,
  ),
  TituloModelo(
    id: 't_guardiao_memorias',
    nome: 'Guardião das Memórias',
    descricao: 'Atingir a conquista “Mosaico de Ideias”.',
    corRaridade: incomum,
  ),
  TituloModelo(
    id: 't_guardiao_moedas',
    nome: 'Guardião das Moedas',
    descricao: 'Atingir a conquista “Disciplina Financeira”.',
    corRaridade: incomum,
  ),
  TituloModelo(
    id: 't_veterano_batalhas',
    nome: 'Veterano de Batalhas',
    descricao: 'Atingir o nível 15.',
    corRaridade: incomum,
  ),

  // raros

  TituloModelo(
    id: 't_invulneravel',
    nome: 'Invulnerável',
    descricao: 'Atingir as conquistas “Armadura de Ouro” e “Vigor Pleno”.',
    corRaridade: raro,
  ),
  TituloModelo(
    id: 't_mestre_tesouro',
    nome: 'Mestre do Tesouro',
    descricao: 'Atingir as conquistas “Superávit” e “Muralha financeira”.',
    corRaridade: raro,
  ),
  TituloModelo(
    id: 't_sentinela_tempo',
    nome: 'Sentinela do Tempo',
    descricao: 'Atingir a conquista “Sequência de Guerreiro”.',
    corRaridade: raro,
  ),
  TituloModelo(
    id: 't_guardiao_experiente',
    nome: 'Guardião Experiente',
    descricao: 'Atingir o nível 30.',
    corRaridade: raro,
  ),

  // epicos

  TituloModelo(
    id: 't_imaculado',
    nome: 'Imaculado',
    descricao: 'Atingir as conquistas “Fortaleza Pessoal” e “Jornada da Perfeição”.',
    corRaridade: epico,
  ),
  TituloModelo(
    id: 't_governador_destino',
    nome: 'Governador do Destino',
    descricao: 'Atingir as conquistas “Caminho Estruturado” e “Mapa Completo”',
    corRaridade: epico,
  ),
  TituloModelo(
    id: 't_magnata',
    nome: 'Magnata',
    descricao: 'Atingir a conquista “Sonho Realizado”.',
    corRaridade: epico,
  ),
  TituloModelo(
    id: 't_campeao_implacavel',
    nome: 'Campeão Implacável',
    descricao: 'Atingir o nível 50.',
    corRaridade: epico,
  ),

  // lendarios

  TituloModelo(
    id: 't_espartano',
    nome: 'Espartano',
    descricao: 'Atingir a conquista “Eternidade Vita”.',
    corRaridade: lendario,
  ),
  TituloModelo(
    id: 't_demiurgo',
    nome: 'Demiurgo',
    descricao: 'Atingir as conquistas “Plano de Uma Era” e “Atlas Universal”.',
    corRaridade: lendario,
  ),
  TituloModelo(
    id: 't_midas',
    nome: 'Midas',
    descricao: 'Atingir as conquistas “Cofre de ferro” e “Atlas Universal”.',
    corRaridade: lendario,
  ),
  TituloModelo(
    id: 't_imortalizado',
    nome: 'O Imortalizado',
    descricao: 'Atingir o nível 75.',
    corRaridade: lendario,
  ),

  // ocultos
  
  TituloModelo(
    id: 't_mestre_centavo',
    nome: 'Mestre do Centavo',
    descricao: 'Atinge ao registrar um gasto de exatamente R\$0,01',
    corRaridade: misterioso,
  ),
  TituloModelo(
    id: 't_alma_gemea',
    nome: 'Alma Gêmea',
    descricao: 'Atinge ao manter HP e Stamina com valores idênticos durante 4 semanas consecutivas',
    corRaridade: misterioso,
  ),
  TituloModelo(
    id: 't_minimalista_absoluto',
    nome: 'Minimalista absoluto',
    descricao: 'Atinge ao ter 0 metas ativas, 0 notas, 0 gastos, mas entrar no app por 7 dias seguidos.',
    corRaridade: misterioso,
  ),
  TituloModelo(
    id: 't_sobrevivente_caos',
    nome: 'Sobrevivente do Caos',
    descricao: 'Atinge ao manter o HP exatamente em 5% durante 4 semanas consecutivas, sem alterar o valor do HP.',
    corRaridade: misterioso,
  ),
  TituloModelo(
    id: 't_immortalis_vita',
    nome: 'Immortalis Vita',
    descricao: 'Alcançar o nível 100',
    corRaridade: misterioso,
  ),
];