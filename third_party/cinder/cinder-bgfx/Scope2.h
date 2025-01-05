//
//  Scope2.h
//  ArtHUD
//
//  Created by clint hidinger on 12/26/19.
//  Copyright © 2019 me. All rights reserved.
//

#pragma once

#include "CommandBuffer.h"


namespace cinder { namespace mtl {

class ScopedCommandBuffer : public CommandBuffer
   {
   public:
       ScopedCommandBuffer( bool waitUntilCompleted = false,
                            const std::string & bufferName = "Scoped Command Buffer" );
       ~ScopedCommandBuffer();
       
       void addCompletionHandler( std::function< void( void * mtlCommandBuffer) > handler ){
           mCompletionHandler = handler;
       }
       
       ScopedComputeEncoder scopedComputeEncoder( const std::string & bufferName = "Scoped Compute Encoder" );
       ScopedBlitEncoder scopedBlitEncoder( const std::string & bufferName = "Scoped Blit Encoder" );
       ScopedRenderEncoder scopedRenderEncoder( RenderPassDescriptorRef & descriptor,
                                                mtl::TextureBufferRef & drawableTexture,
                                                const std::string & bufferName = "Scoped Render Encoder" );
       ScopedRenderEncoder scopedRenderEncoder( RenderPassDescriptorRef & descriptorWithDrawableAttachments,
                                                const std::string & bufferName = "Scoped Render Encoder" );

   private:
       bool mWaitUntilCompleted;
       std::function< void( void * mtlCommandBuffer) > mCompletionHandler;
   };
}}
