

class tarifa definition.

    public section.

    methods set_tar_cor importing tarifa.
                        exporting total.
                        exceptions no_aplica.

    class-methods set_tar_base importing tarifa.

    private section

    data: tar_corp type wertv8.

    class-data tar_base type wertv8.

endclass.

class tarifa implementation.

    method set_tar_cor.
    
    tar_corp = tarifa.

    if sy-datum+4 (2) eq 4.
        total = (tar_base +tar_corp)* 0,8
    else
    total = tar_base + tar_corp.
     raise no_aplica.
    endif.

    endmethod.



    method set_tar_base.

    tar_base = tarifa.

    endmethod.


start-of-selection.

    data(gr_tarifa) = new tarifa( ).
    data: gr_tarifa type ref to tarifa, "se hace referencia a la clase.
          gv_total type wertv8.

*llamada a metodo estatico
    call method tarifa => set_tar_base 
        exporting 
            tarifa ='10.20'.


            tarifa=> set_tar_base( exporting tarifa = '10.20'). " se puede o no poner la llamada de exporting si es un solo parametro.

*llamada a metodo de instancia.

    create object gr_tarifa.

    call method gr_tarifa -> set_tar_cor.
        exporting
            tarifa = '20.40'
        importing
            total = gv_total
        exceptions
            no_aplica = 1
            others    = 2

         if sy-subrc <> 0
            message 'No se aplica la tarifa especial' type 'I'
         endif.

    gr_tarifa -> set_tar_cor ( exporting            = '20.40'
                               importing            = gv_total
                               exceptions no_aplica = 1
                               others               = 2).
         if sy-subrc <> 0
            message 'No se aplica la tarifa especial' type 'I'
         endif.

         write 'el total de la tarifa aplicada es ' gv_total.


***************************************************************************************************************************
*************************************************************************************************************************
***************************************************************************************************************************


*******************************************METODOS FUNCIONALES**************************

class Verificar definition.

    public section.
        methods sociedad importing i_sociedad type bukrs
                        returning value (existe) type abap_bool.


endclass.

class Verificar implementation.

    method sociedad.
        data: lv_soc type bukrs.

        select single bukrs from t001
            into lv_soc
            where bukrs eq i_sociedad.

        if sy-subrc eq 0.
            existe = abap_true.
        endif

    endmethod.

endclass.

start-of-selection.

    data: gr_verificar type ref to Verificar.
          gr_existe    type abap_bool.

    create object gr_verificar.

    call method gr_verificar->sociedad
     exporting
         i_sociedad = '1000'            " DEL PARAMETRO IMPORTING DEL METODO VERIFICAR
     receiving
         existe = gv_existe.             "del PARAMETRO RETURNING DEL METODO


******************************************************************************************************
**************************************METOOD DETRUCTOR***********************************************
******************************************************************************************************
**** el metodo destructor debe ser llamada mediante funciones en lenguaje "C"****

class destruc definition

    public section.      "se debe colocar el metodo constructor SIEMPRE en el la seccion publica

    methods destructor. " ese es el nombre que DEBE llevar el metodo.

    private section.
    data pointer type %_c_pointer
endclass.

class destruc implementation.

    method destructor.

        system-call c-destructor 'fxkmswrt_CDdestr_destroy' using %_c_pointer. " solo admite este tipo de llamadas 'system-call c-destructor' y esta escrito en C
    
    endmethod.

endclass.


************************************************************************************************************
**********************************************************************************************************
************************************************************************************************************


class cl_html definition.
    public section.

    types: begin of types_extension,
                addres type string,
                block type string,
                center type string,
                div  type string,
            end of types_extension.


    data home_index type types_extension.

  methods establecer_home_index  importing iv_home_index type types_extension.

endclass.

class cl_html implementation.
   
    method establecer_home_index.
        home_index = iv_home_index.
    endmethod.

endclass

start-of-selection.

*    types: begin of G_types_extension,
*                addres type string,
*                block type string,
*               center type string,
*                div  type string,
*            end of G_types_extension.

    data: gr_html type ref to cl_html,
          "gs_html  type G_types_extension.
          gs_html type=>types_extension.     "otra forma de hacerlo accediendo a los atributos de la clase.

   gs_html-addres = 'http:logalisap.com'
   gs_html-block = 'cursos'
   gs_html-center = 'elementos'
   gs_html-div = 'objetos'.

   create object gr_html.

   gr_html-> establecer_home_index (iv_home_index = gs_html).

   write: / gr_html->home_index-addres,
          / gr_html->home_index-block,
          / gr_html->home_index-center,
          / gr_html->home_index-div.


******************************************************************************************************************
******************************************CONSTANTES EN ABAP OO***************************************************
******************************************************************************************************************

class cl_foto definition.
    public section.
        CONSTANTS png type char3 value 'PNG'.
        CONSTANTS jpg type char3 value 'JPG'.
        CONSTANTS bmp type char3 value 'BMP'.

endclass


start-of-selection.

data gv_formato_foto type char3.

gv_formato_foto = cl_foto=>BMP.

write : gv_formato_foto
        cl_foto=>jpg.



***********************************************************************************************************************
**********************************************************************************************************************
***********************************************************************************************************************

