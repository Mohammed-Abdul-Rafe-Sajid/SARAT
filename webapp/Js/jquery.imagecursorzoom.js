/**
 * jquery.imageCursorZoom
 * jQuery Plugin
 *
 * @author bitofsky@neowiz.com
 * @since 2015.09.10
 * @see https://github.com/bitofsky/jquery.imagecursorzoom
 * @license MIT
 * @version 1.0
 */

"use strict";

(function( window ){

  var $ = window.jQuery;
  var define = window.define;

  $.imageCursorZoom = imageCursorZoom;

  $.fn.imageCursorZoom = function( option ){
    return this.on('click.imageCursorZoom', function(){
      imageCursorZoom(this, option);
    });
  };

  /**
   * @param {ImgElement} elm
   * @param {Object} option
   */
  function imageCursorZoom( elm, option ){

    var clientWidth  = elm.clientWidth,
        clientHeight = elm.clientHeight;

    var opt = $.extend(true, {
          parent: 'BODY',
          src: function(){
            return this.src;
          },
          onerror: function(src){
            window.open(src);
          },
          ondestroy: null
          //transition: 'transform 0.05s ease-out'
        }, option),
        src = typeof opt.src == 'function' ? opt.src.call(elm) : opt.src,
        $parent = $( typeof opt.parent == 'function' ? opt.parent.call(elm) : opt.parent ),
        $wrapper = $('<div/>'),
        $clone = $('<img/>').on('load', imageLoaded).on('error', imageFailed).attr('src', src).css({visibility: 'hidden', width : 'auto', height : 'auto', transition : opt.transition}),
        parentWidth = 0,
        parentHeight = 0,
        isBody = $parent[0] === $('BODY')[0],
        scrollTop = isBody ? Math.max($('BODY').scrollTop(), $(window).scrollTop()) : $parent.scrollTop(),
        scrollLeft = isBody ? Math.max($('BODY').scrollLeft(), $(window).scrollLeft()) : $parent.scrollLeft(),
        overflowX = $parent[0].style.overflowX,
        overflowY = $parent[0].style.overflowY,
        position = $parent[0].style.position;

    try{ // IE Exception
      (isBody ? $(window) : $parent).on('resize', onResize).trigger('resize');
    }catch(e){
      opt.onerror( src );
      return;
    }

    if( !isBody )
      $parent.css('position', 'relative');

    $parent.css({
      'overflow-x': 'hidden',
      'overflow-y': 'hidden'
    });

    $wrapper
      .on('mousemove.imageCursorZoom', function( event ){
        moveImage(event.pageX, event.pageY);
      })
      .on('click.imageCursorZoom', destroy)
      .css({
        overflow: 'hidden',
        position : 'absolute',
        left : scrollLeft,
        top : scrollTop,
        background : 'white',
        width : '100%',
        height : '100%',
        'z-index' : 9999
      })
      .append( $clone )
      .appendTo( $parent );

    function imageFailed(){
      moveImage(0, 0);
      $clone.attr('src', elm.src);
      created();
    }

    function imageLoaded(){
      clientWidth = this.clientWidth || $clone.width();
      clientHeight = this.clientHeight || $clone.height();
      created();
    }

    function created(){

      moveImage(0, 0);
      $clone.css({visibility:'visible'});

      if( typeof opt.oncreate === 'function' ){
        opt.oncreate.call(elm, $clone, $wrapper);
      }

    }

    /**
     * Tracking mouse pointer
     * @param {Number} mouseX
     * @param {Number} mouseY
     */
    function moveImage( mouseX, mouseY ){

      var posX = getPx(mouseX, scrollLeft, parentWidth, clientWidth),
          posY = getPx(mouseY, scrollTop, parentHeight, clientHeight);

      $clone.css('transform', 'translate(' + posX + 'px, ' + posY + 'px)');

    }

    /**
     * Cacl px
     * @param {type} pos
     * @param {type} scroll
     * @param {type} pSize
     * @param {type} cSize
     * @returns px
     */
    function getPx( pos, scroll, pSize, cSize ){

      var x, ratio, px;

      x = pos - scroll,
      ratio = (x / pSize) > 1 ? 1 : (x / pSize),
      ratio = ratio > 1 ? 1 : ratio;
      px = (pSize - cSize) * ratio,
      px = cSize < pSize ? ((pSize - cSize) / 2) : px;
      px = cSize > pSize && px > 0 ? 0 : px;

      return px;


    }

    /**
     * Get window width / height
     * @param {Event} event
     */
    function onResize( event ){

      parentWidth = +$(this).width();
      parentHeight = +$(this).height();

    }

    /**
     * Destroy all elements
     */
    function destroy(){
      $clone.remove();
      $wrapper.remove();
      $parent[0].style.overflowX = overflowX;
      $parent[0].style.overflowY = overflowY;
      $parent[0].style.position = position;
      if( typeof opt.ondestroy === 'function' ){
        opt.ondestroy.call(elm);
      }
    }

  }

  /**
   * AMD(Asynchronous Module Definition)
   */
  if( define && define.amd )
    define('imageCursorZoom', [], function(){ return imageCursorZoom; });

})(typeof global !== "undefined" ? global : this);
