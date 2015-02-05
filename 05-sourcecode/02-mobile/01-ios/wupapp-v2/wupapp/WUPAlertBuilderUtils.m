//
//  WUPAlertBuilderUtils.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/1/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPAlertBuilderUtils.h"

@implementation WUPAlertBuilderUtils

+(UIAlertView*) buildAlertForMissingInformation:(NSString*) fieldName
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alerta"
                                                    message:[NSString stringWithFormat:@"O campo %@ é obrigatório.",fieldName]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    return alert;
}

+(UIAlertView*) buildAlertForAddressNotFound
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Endereço não encontrado"
                                                    message:@"Tente especificar o endereço um pouco mais."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    return alert;
}

+(UIAlertView*) buildAlertForAddressNotFoundOnGooglePlacesAPI
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Endereço não encontrado"
                                                    message:@"Não foi possível encontrar um endereço para este termo. Tente outro termo."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    return alert;
}

+(UIAlertView*) buildAlertForLocationNotFoundAirplaneMode
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Localização não encontrada"
                                                    message:@"Por favor verifique sua conexão ou certifique-se que seu celular não está no modo avião"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    return alert;
}

+(UIAlertView*) buildAlertForLocationNotFoundUserDenied
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Localização não encontrada"
                                                    message:@"O serviço de localização precisa estar ativado para o correto funcionamento deste aplicativo. Permita esta opção em General > Privacy"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    return alert;
}

+(UIAlertView*) buildAlertForLocationNotFoundUnknownError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Localização não encontrada"
                                                    message:@"Não foi possível obter sua localização. Por favor tente novamente mais tarde."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    return alert;
}

+(UIAlertView*) buildAlertForMissingInformation
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erro"
                                                    message:@"Todos os campos devem ser preenchidos para prosseguir"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    return alert;
}

@end
