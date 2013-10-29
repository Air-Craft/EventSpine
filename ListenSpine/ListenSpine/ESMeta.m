//
//  ESMeta.m
//  ListenSpine
//
//  Created by Hari Karam Singh on 29/10/2013.
//  Copyright (c) 2013 Club 15CC. All rights reserved.
//

#import "ESMeta.h"


void __ES_OVERLOADABLE __es_var_arg(va_list *argList, signed char *var) { *var = (signed char)va_arg(*argList, long); }
void __ES_OVERLOADABLE __es_var_arg(va_list *argList, unsigned char *var) { *var = (unsigned char)va_arg(*argList, long); }
void __ES_OVERLOADABLE __es_var_arg(va_list *argList, signed short *var) { *var = (signed short)va_arg(*argList, long); }
void __ES_OVERLOADABLE __es_var_arg(va_list *argList, unsigned short *var) { *var = (unsigned short)va_arg(*argList, long); }
void __ES_OVERLOADABLE __es_var_arg(va_list *argList, signed int *var) { *var = (signed int)va_arg(*argList, signed long); }
void __ES_OVERLOADABLE __es_var_arg(va_list *argList, unsigned int *var) { *var = (unsigned int)va_arg(*argList, unsigned long); }
void __ES_OVERLOADABLE __es_var_arg(va_list *argList, signed long *var) { *var = va_arg(*argList, signed long); }
void __ES_OVERLOADABLE __es_var_arg(va_list *argList, unsigned long *var) { *var = va_arg(*argList, unsigned long); }
void __ES_OVERLOADABLE __es_var_arg(va_list *argList, signed long long *var) { *var = va_arg(*argList, signed long long); }
void __ES_OVERLOADABLE __es_var_arg(va_list *argList, unsigned long long *var) { *var = va_arg(*argList, unsigned long long); }

void __ES_OVERLOADABLE __es_var_arg(va_list *argList, float *var) { *var = (float)va_arg(*argList, double); }
void __ES_OVERLOADABLE __es_var_arg(va_list *argList, double *var) { *var = va_arg(*argList, double); }

void __ES_OVERLOADABLE __es_var_arg(va_list *argList, id *var) {
    *var = va_arg(*argList, id);
}

